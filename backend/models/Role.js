const mongoose = require('mongoose');

const roleSchema = new mongoose.Schema({
  verse_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Verse',
    required: true,
    index: true
  },
  name: {
    type: String,
    required: true,
    enum: ['Administrator', 'Editor', 'Expert'],
    trim: true
  },
  permissions: {
    type: Map,
    of: Boolean,
    default: {}
  },
  description: {
    type: String,
    default: '',
    maxlength: 500
  },
  is_system_role: {
    type: Boolean,
    default: false
  },
  created_at: {
    type: Date,
    default: Date.now
  },
  updated_at: {
    type: Date,
    default: Date.now
  }
}, {
  timestamps: { createdAt: 'created_at', updatedAt: 'updated_at' }
});

// Compound unique index to prevent duplicate role names per verse
roleSchema.index({ verse_id: 1, name: 1 }, { unique: true });

module.exports = mongoose.model('Role', roleSchema);
