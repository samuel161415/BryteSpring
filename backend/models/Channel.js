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
    enum: ['channel', 'folder', 'category', 'voice', 'text'],
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
    maxlength: 500
  },
  // Asset types allowed in this folder/channel
  asset_types: {
    type: [String],
    default: [],
    validate: {
      validator: function(types) {
        const allowedTypes = ['image', 'video', 'document', 'audio', 'text', 'data'];
        return types.every(type => allowedTypes.includes(type.toLowerCase()));
      },
      message: 'Invalid asset type. Allowed types: image, video, document, audio, text, data'
    }
  },
  // Visibility settings
  visibility: {
    is_public: {
      type: Boolean,
      default: true
    },
    inherited_from_parent: {
      type: Boolean,
      default: false
    }
  },
  settings: {
    type: mongoose.Schema.Types.Mixed,
    default: {}
  },
  permissions: {
    type: mongoose.Schema.Types.Mixed,
    default: {}
  },
  // Additional folder-specific settings
  folder_settings: {
    allow_subfolders: {
      type: Boolean,
      default: true
    },
    max_depth: {
      type: Number,
      default: 5
    }
  },
  created_by: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  }
}, {
  timestamps: { createdAt: 'created_at', updatedAt: 'updated_at' }
});

// Virtual for getting full path
channelSchema.virtual('full_path').get(function() {
  return this.path || this.name;
});

// Indexes for better query performance
channelSchema.index({ verse_id: 1, name: 1 });
channelSchema.index({ verse_id: 1, type: 1 });
channelSchema.index({ parent_channel_id: 1 });
channelSchema.index({ created_by: 1 });
channelSchema.index({ verse_id: 1, parent_channel_id: 1 });
channelSchema.index({ 'visibility.is_public': 1 });

// Method to build path recursively
channelSchema.methods.buildPath = async function() {
  if (!this.parent_channel_id) {
    return this.name;
  }
  
  const parent = await this.constructor.findById(this.parent_channel_id);
  if (!parent) {
    return this.name;
  }
  
  const parentPath = await parent.buildPath();
  return `${parentPath}/${this.name}`;
};

// Method to get children count
channelSchema.methods.getChildrenCount = async function() {
  return await this.constructor.countDocuments({ parent_channel_id: this._id });
};

module.exports = mongoose.model('Channel', channelSchema);
