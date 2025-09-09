const mongoose = require('mongoose');

const brandingSchema = new mongoose.Schema({
  logo_url: { type: String, default: null },
  primary_color: { type: String, default: '#3B82F6' },
  color_name: { type: String, default: 'Primary Blue' }
});

const settingsSchema = new mongoose.Schema({
  is_public: { type: Boolean, default: false },
  allow_invites: { type: Boolean, default: true },
  max_users: { type: Number, default: 50 },
  storage_limit: { type: Number, default: 10737418240 } // 10GB in bytes
});

const verseSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    trim: true,
    maxlength: 100
  },
  admin_email: {
    type: String,
    required: true,
    lowercase: true,
    trim: true
  },
  subdomain: {
    type: String,
    unique: true,
    sparse: true, // Allows null for incomplete setup
    lowercase: true,
    match: [/^[a-z0-9-]+$/, 'Subdomain can only contain lowercase letters, numbers, and hyphens']
  },
  organization_name: {
    type: String,
    trim: true,
    maxlength: 200
  },
  branding: {
    type: brandingSchema,
    default: () => ({})
  },
  settings: {
    type: settingsSchema,
    default: () => ({})
  },
  is_setup_complete: {
    type: Boolean,
    default: false
  },
  setup_completed_at: {
    type: Date,
    default: null
  },
  setup_completed_by: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    default: null
  },
  is_active: {
    type: Boolean,
    default: true,
    index: true
  },
  created_by: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
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

// Index for better query performance
verseSchema.index({ subdomain: 1 });
verseSchema.index({ created_by: 1 });
verseSchema.index({ is_setup_complete: 1 });

module.exports = mongoose.model('Verse', verseSchema);