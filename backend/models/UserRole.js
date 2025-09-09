const mongoose = require('mongoose');

const userRoleSchema = new mongoose.Schema({
  user_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    index: true
  },
  verse_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Verse',
    required: true,
    index: true
  },
  role_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Role',
    required: true,
    index: true
  },
  assigned_at: {
    type: Date,
    default: Date.now
  },
  assigned_by: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    default: null
  },
  is_active: {
    type: Boolean,
    default: true
  },
  expires_at: {
    type: Date,
    default: null
  }
}, {
  timestamps: { createdAt: 'assigned_at', updatedAt: 'updated_at' }
});

// Compound indexes for efficient queries
userRoleSchema.index({ user_id: 1, verse_id: 1 });
userRoleSchema.index({ verse_id: 1, role_id: 1 });
userRoleSchema.index({ user_id: 1, is_active: 1 });

// Prevent duplicate role assignments per user per verse
userRoleSchema.index({ user_id: 1, verse_id: 1, role_id: 1 }, { unique: true });

module.exports = mongoose.model('UserRole', userRoleSchema);
