const mongoose = require('mongoose');

const userInvitationSchema = new mongoose.Schema({
  user_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true
  },
  invitation_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Invitation',
    required: true,
    index: true
  },
  created_at: {
    type: Date,
    default: Date.now
  }
}, {
  timestamps: { createdAt: 'created_at', updatedAt: false }
});

// Compound indexes for efficient queries
userInvitationSchema.index({ user_id: 1, invitation_id: 1 }, { unique: true });

// Prevent duplicate user-invitation relationships
userInvitationSchema.index({ user_id: 1, invitation_id: 1 }, { unique: true });

module.exports = mongoose.model('UserInvitation', userInvitationSchema);
