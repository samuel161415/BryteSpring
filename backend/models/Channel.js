const mongoose = require('mongoose');

const channelSchema = new mongoose.Schema({
  verse_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Verse',
    required: true,
    index: true
  },
  name: {
    type: String,
    required: true,
    trim: true,
    maxlength: 100
  },
  type: {
    type: String,
    required: true,
    enum: ['channel', 'category', 'voice', 'text'],
    default: 'channel'
  },
  description: {
    type: String,
    trim: true,
    maxlength: 500
  },
  parent_channel_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Channel',
    default: null
  },
  path: {
    type: String,
    trim: true,
    maxlength: 200
  },
  settings: {
    type: mongoose.Schema.Types.Mixed,
    default: {}
  },
  permissions: {
    type: mongoose.Schema.Types.Mixed,
    default: {}
  },
  created_by: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  }
}, {
  timestamps: { createdAt: 'created_at', updatedAt: 'updated_at' }
});

// Indexes for better query performance
channelSchema.index({ verse_id: 1, name: 1 });
channelSchema.index({ verse_id: 1, type: 1 });
channelSchema.index({ parent_channel_id: 1 });
channelSchema.index({ created_by: 1 });

module.exports = mongoose.model('Channel', channelSchema);
