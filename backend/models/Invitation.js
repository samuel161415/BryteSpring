const mongoose = require('mongoose');

const invitationSchema = new mongoose.Schema({
  verse_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Verse',
    required: true,
    index: true
  },
  email: {
    type: String,
    required: true,
    lowercase: true,
    trim: true,
    index: true
  },
  role_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Role',
    required: true,
    index: true
  },
  token: {
    type: String,
    required: true,
    unique: true,
    index: true
  },
  invited_by: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true
  },
  is_accepted: {
    type: Boolean,
    default: false,
    index: true
  },
  created_at: {
    type: Date,
    default: Date.now
  },
  expires_at: {
    type: Date,
    required: true
  },
  accepted_at: {
    type: Date,
    default: null
  },
  first_name: {
    type: String,
    trim: true,
    default: ''
  },
  last_name: {
    type: String,
    trim: true,
    default: ''
  },
  position: {
    type: String,
    trim: true,
    default: ''
  }
});

// Prevent duplicate active invitations to the same email for the same verse
invitationSchema.index({ verse_id: 1, email: 1, is_accepted: 1 });

module.exports = mongoose.model('Invitation', invitationSchema);
