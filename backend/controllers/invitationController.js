const { v4: uuidv4 } = require('uuid');
const Invitation = require('../models/Invitation');
const Role = require('../models/Role');

// Create invitation (admin or superadmin)
exports.createInvitation = async (req, res) => {
  try {
    const {
      verse_id,
      email,
      role_id,
      first_name,
      last_name,
      position,
      expires_in_days = 7
    } = req.body;

    // Basic auth check: require authenticated user
    const inviter = req.user;
    if (!inviter) {
      return res.status(401).json({ message: 'Unauthorized' });
    }

    // Optional: ensure inviter has permission (superadmin or manage_verse)
    // This can be expanded later using UserRole and Role permissions if needed.

    // Validate role exists and belongs to the same verse
    const role = await Role.findOne({ _id: role_id, verse_id });
    if (!role) {
      return res.status(400).json({ message: 'Invalid role for the specified verse' });
    }

    const token = uuidv4();
    const now = new Date();
    const expires_at = new Date(now.getTime() + expires_in_days * 24 * 60 * 60 * 1000);

    const invitation = new Invitation({
      verse_id,
      email: email.toLowerCase(),
      role_id,
      token,
      invited_by: inviter._id,
      is_accepted: false,
      created_at: now,
      expires_at,
      first_name,
      last_name,
      position
    });

    await invitation.save();

    // TODO: send email with token

    return res.status(200).json({
      message: 'Invitation created',
      invitation: {
        _id: invitation._id,
        verse_id: invitation.verse_id,
        email: invitation.email,
        role_id: invitation.role_id,
        token: invitation.token,
        invited_by: invitation.invited_by,
        is_accepted: invitation.is_accepted,
        created_at: invitation.created_at,
        expires_at: invitation.expires_at,
        first_name: invitation.first_name,
        last_name: invitation.last_name,
        position: invitation.position
      }
    });
  } catch (error) {
    console.error('Error creating invitation:', error);
    return res.status(500).json({ message: 'Server error creating invitation', error: error.message });
  }
};

// Get invitation by token
exports.getInvitationByToken = async (req, res) => {
  try {
    const { token } = req.params;
    const invitation = await Invitation.findOne({ token });
    if (!invitation) {
      return res.status(404).json({ message: 'Invitation not found' });
    }
    return res.status(200).json({ invitation });
  } catch (error) {
    console.error('Error fetching invitation:', error);
    return res.status(500).json({ message: 'Server error fetching invitation', error: error.message });
  }
};

// Get invitation by id (inviter or superadmin could be enforced later if needed)
exports.getInvitationById = async (req, res) => {
  try {
    const { id } = req.params;
    const invitation = await Invitation.findById(id);
    if (!invitation) {
      return res.status(404).json({ message: 'Invitation not found' });
    }
    return res.status(200).json({ invitation });
  } catch (error) {
    console.error('Error fetching invitation by id:', error);
    return res.status(500).json({ message: 'Server error fetching invitation', error: error.message });
  }
};

// Update invitation (only inviter can update)
exports.updateInvitation = async (req, res) => {
  try {
    const { id } = req.params;
    const updater = req.user;
    if (!updater) {
      return res.status(401).json({ message: 'Unauthorized' });
    }

    const invitation = await Invitation.findById(id);
    if (!invitation) {
      return res.status(404).json({ message: 'Invitation not found' });
    }

    if (invitation.invited_by.toString() !== updater._id.toString()) {
      return res.status(403).json({ message: 'Only the inviter can update this invitation' });
    }

    if (invitation.is_accepted) {
      return res.status(400).json({ message: 'Cannot update an already accepted invitation' });
    }

    const ALLOWED = ['email', 'first_name', 'last_name', 'position', 'expires_at', 'role_id'];

    // If role_id is being changed, ensure it belongs to the same verse
    if (req.body.role_id && req.body.role_id.toString() !== invitation.role_id.toString()) {
      const role = await Role.findOne({ _id: req.body.role_id, verse_id: invitation.verse_id });
      if (!role) {
        return res.status(400).json({ message: 'Invalid role for the specified verse' });
      }
    }

    ALLOWED.forEach((k) => {
      if (req.body[k] !== undefined) {
        if (k === 'email') {
          invitation[k] = String(req.body[k]).toLowerCase();
        } else {
          invitation[k] = req.body[k];
        }
      }
    });

    await invitation.save();
    return res.status(200).json({ message: 'Invitation updated', invitation });
  } catch (error) {
    console.error('Error updating invitation:', error);
    return res.status(500).json({ message: 'Server error updating invitation', error: error.message });
  }
};

// Delete invitation (only inviter can delete)
exports.deleteInvitation = async (req, res) => {
  try {
    const { id } = req.params;
    const requester = req.user;
    if (!requester) {
      return res.status(401).json({ message: 'Unauthorized' });
    }

    const invitation = await Invitation.findById(id);
    if (!invitation) {
      return res.status(404).json({ message: 'Invitation not found' });
    }

    if (invitation.invited_by.toString() !== requester._id.toString()) {
      return res.status(403).json({ message: 'Only the inviter can delete this invitation' });
    }

    if (invitation.is_accepted) {
      return res.status(400).json({ message: 'Cannot delete an already accepted invitation' });
    }

    await invitation.deleteOne();
    return res.status(200).json({ message: 'Invitation deleted' });
  } catch (error) {
    console.error('Error deleting invitation:', error);
    return res.status(500).json({ message: 'Server error deleting invitation', error: error.message });
  }
};
