const jwt = require("jsonwebtoken");
const User = require("../models/User");

// Generate JWT
const generateToken = (id) => {
  return jwt.sign({ id }, process.env.JWT_SECRET, { expiresIn: "7d" });
};

//   Register new user

const registerUser = async (req, res) => {
  const {
    email,
    password,
    first_name,
    last_name,
    avatar_url,
    joined_verse = []
  } = req.body;

  try {
    // Check if user already exists
    const userExists = await User.findOne({ email });
    if (userExists)
      return res.status(400).json({ message: "User already exists" });

    // Create new user
    const user = new User({
      email,
      first_name,
      last_name,
      avatar_url,
      joined_verse
    });

    // Hash password
    await user.setPassword(password);

    await user.save();

    // Return response with JWT
    res.status(201).json({
      _id: user._id,
      email: user.email,
      first_name: user.first_name,
      last_name: user.last_name,
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
      res.json({
        _id: user._id,
        name: user.name,
        email: user.email,
        token: generateToken(user._id),
      });
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

//   Update user profile

// sanitize helper
const sanitize = (user) => {
  const obj = user.toObject();
  delete obj.password_hash;
  return obj;
};

//   Update user profile
const updateUserProfile = async (req, res) => {
  const ALLOWED = ["email", "first_name", "last_name", "avatar_url", "verse_ids"];

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
  updateUserProfile,
  getUsers,
  deleteUser,
  forgotPassword,
  adminUpdateUser
};
