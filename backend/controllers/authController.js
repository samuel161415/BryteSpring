const jwt = require("jsonwebtoken");
const User = require("../models/User");
const Invitation = require("../models/Invitation");
const UserRole = require("../models/UserRole");
const UserInvitation = require("../models/UserInvitation");
const Verse = require("../models/Verse");
const ActivityLog = require("../models/ActivityLog");

// Generate JWT
const generateToken = (id) => {
  return jwt.sign({ id }, process.env.JWT_SECRET, { expiresIn: "7d" });
};

//   Register new user

const registerUser = async (req, res) => {
  const {
    email,
    password,
    avatar_url,
    invitation_token
  } = req.body;

  try {
    // Check if user already exists
    const userExists = await User.findOne({ email });
    if (userExists)
      return res.status(400).json({ message: "User already exists" });

    let first_name = '';
    let last_name = '';
    let position = '';
    let verse_id = null;
    let role_id = null;
    let is_verse_setup = false;
    let invitation = null;

    // If invitation token provided, get user details from invitation
    if (invitation_token) {
      invitation = await Invitation.findOne({ token: invitation_token });
      if (!invitation) {
        return res.status(400).json({ message: "Invalid invitation token" });
      }
      if (invitation.is_accepted) {
        return res.status(400).json({ message: "Invitation already accepted" });
      }
      if (invitation.expires_at && invitation.expires_at < new Date()) {
        return res.status(400).json({ message: "Invitation expired" });
      }

      // Get user details from invitation
      first_name = invitation.first_name || '';
      last_name = invitation.last_name || '';
      position = invitation.position || '';
      verse_id = invitation.verse_id;
      role_id = invitation.role_id;

      // Check if this is a verse setup invitation (verse not yet complete)
      const verse = await Verse.findById(verse_id);
      if (verse && !verse.is_setup_complete) {
        is_verse_setup = true;
      }
    }

    // Create new user
    const user = new User({
      email,
      first_name,
      last_name,
      position,
      avatar_url,
      joined_verse: []
    });

    // Hash password
    await user.setPassword(password);
    await user.save();

    // Handle invitation scenarios
    if (invitation_token && invitation) {
      // Create UserInvitation junction record for future login reference
      try {
        await UserInvitation.create({
          user_id: user._id,
          invitation_id: invitation._id
        });
      } catch (e) {
        console.error('Error creating UserInvitation:', e);
        // Continue even if junction creation fails
      }

      // Mark invitation as accepted for both scenarios
      // UserRole and joined_verse will be handled later:
      // - For incomplete verses: in completeVerseSetup
      // - For complete verses: in joinVerse endpoint
      invitation.is_accepted = true;
      invitation.accepted_at = new Date();
      await invitation.save();

      // Log the activity
      const activityLog = new ActivityLog({
        verse_id: invitation.verse_id,
        user_id: user._id,
        action: 'create',
        resource_type: 'user',
        resource_id: user._id,
        timestamp: new Date(),
        details: {
          action: is_verse_setup ? 'admin_registered_pending_setup' : 'user_registered_pending_verse_join',
          invitation_token: invitation_token,
          verse_setup_complete: !is_verse_setup,
          requires_action: true
        }
      });
      await activityLog.save();
    }

    // Return response with JWT
    res.status(201).json({
      _id: user._id,
      email: user.email,
      first_name: user.first_name,
      last_name: user.last_name,
      position: user.position,
      avatar_url: user.avatar_url,
      joined_verse: user.joined_verse,
      token: generateToken(user._id)
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};


//   Login user
const loginUser = async (req, res) => {
  const { email, password } = req.body;
  try {
    const user = await User.findOne({ email });
    if (user && (await user.matchPassword(password))) {
      
      // Get pending invitations for this user (if any)
      // This includes invitations that are accepted but user hasn't joined the verse yet
      const pendingInvitations = await Invitation.find({
        email: user.email,
        is_accepted: true
      })
      .sort({ created_at: -1 });


      // Filter for verses that user hasn't joined yet
      const filteredPendingInvitations = pendingInvitations.filter(invitation => {
        if (!invitation.verse_id) return false;
        return !user.joined_verse.some(verseId => 
          verseId.toString() === invitation.verse_id._id.toString()
        );
      });

      // Build response with pending invitations
      const response = {
        _id: user._id,
        first_name: user.first_name,
        last_name: user.last_name,
        position: user.position,
        email: user.email,
        avatar_url: user.avatar_url,
        joined_verse: user.joined_verse,
        token: generateToken(user._id),
        pending_invitations: []
      };

      // Add pending invitations if any
      if (filteredPendingInvitations.length > 0) {
        response.pending_invitations = filteredPendingInvitations;
      }

      res.json(response);
    } else {
      res.status(401).json({ message: "Invalid email or password" });
    }
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

//   Logout user
const logoutUser = (req, res) => {
  res.clearCookie("token"); // if using cookies
  res.json({ message: "Logged out successfully" });
};

//   Get user profile
const getUserProfile = async (req, res) => {
  res.json(req.user);
};

//   Get user by email
const getUserByEmail = async (req, res) => {
  try {
    const { email } = req.params;
    
    const user = await User.findOne({ email }).select('-password_hash');
    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    res.json({
      _id: user._id,
      email: user.email,
      first_name: user.first_name,
      last_name: user.last_name,
      position: user.position,
      avatar_url: user.avatar_url,
      joined_verse: user.joined_verse,
      is_active: user.is_active,
      created_at: user.created_at
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

//   Update user profile

// sanitize helper
const sanitize = (user) => {
  const obj = user.toObject();
  delete obj.password_hash;
  return obj;
};

//   Update user profile
const updateUserProfile = async (req, res) => {
  const ALLOWED = ["email", "first_name", "last_name", "avatar_url", "verse_ids", "position"];

  const user = await User.findById(req.user._id);
  if (!user) return res.status(404).json({ message: "User not found" });

  // generic merge for allowed keys
  ALLOWED.forEach((k) => {
    if (req.body[k] !== undefined) user[k] = req.body[k];
  });

  // handle password separately
  if (req.body.password) {
    await user.setPassword(req.body.password);
  }

  await user.save();
  return res.json({ message: "Profile updated", data: sanitize(user) });
};

// PUT /api/users/:id  (admin)
const adminUpdateUser = async (req, res) => {
  const user = await User.findById(req.params.id);
  if (!user) return res.status(404).json({ message: "User not found" });

  // Block only hard-forbidden fields; allow the rest (admin can change is_active, email, verse_ids, etc.)
  const updates = { ...req.body };
  delete updates._id;
  delete updates.password_hash; // use `password` instead so we can hash

  Object.assign(user, updates);

  if (req.body.password) {
    await user.setPassword(req.body.password);
  }

  await user.save();
  return res.json({ message: "User updated", data: sanitize(user) });
};

//   Get all users (Admin)
const getUsers = async (req, res) => {
  const users = await User.find().select("-password");
  res.json(users);
};

//   Delete user (Admin)
const deleteUser = async (req, res) => {
  const user = await User.findById(req.params.id);
  if (user) {
    await user.deleteOne();
    res.json({ message: "User deleted" });
  } else {
    res.status(404).json({ message: "User not found" });
  }
};
const forgotPassword = async (req, res) => {
  const { email } = req.body;
  const user = await User.findOne({ email });

  if (!user) return res.status(404).json({ message: "User not found" });

  const resetToken = user.getResetPasswordToken();
  await user.save({ validateBeforeSave: false });

  const resetUrl = `${req.protocol}://${req.get("host")}/api/users/reset-password/${resetToken}`;

  const message = `
    You requested a password reset.\n\n
    Please make a PUT request to: \n\n
    ${resetUrl}
  `;

  try {
    // await sendEmail({
    //   to: user.email,
    //   subject: "Password Reset Request",
    //   text: message,
    // });

    res.json({ message: "Email sent" });
  } catch (err) {
    user.resetPasswordToken = undefined;
    user.resetPasswordExpire = undefined;
    await user.save({ validateBeforeSave: false });

    res.status(500).json({ message: "Email could not be sent" });
  }
};
module.exports = {
  registerUser,
  loginUser,
  logoutUser,
  getUserProfile,
  getUserByEmail,
  updateUserProfile,
  getUsers,
  deleteUser,
  forgotPassword,
  adminUpdateUser
};
