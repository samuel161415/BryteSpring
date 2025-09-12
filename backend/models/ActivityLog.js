const mongoose = require("mongoose");

const activityLogSchema = new mongoose.Schema(
  {
    verse_id: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Verse",
      required: true,
      index: true,
    },
    user_id: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
      index: true,
    },
    action: {
      type: String,
      required: true,
      enum: [
        "login",
        "logout",
        "invite",
        "create",
        "update",
        "delete",
        "setup_complete",
        "role_assigned",
        "role_removed",
      ],
      trim: true,
    },
    resource_type: {
      type: String,
      required: true,
      enum: [
        "user",
        "asset",
        "channel",
        "verse",
        "invitation",
        "role",
        "user_role",
        "folder",
      ],
      trim: true,
    },
    resource_id: {
      type: mongoose.Schema.Types.ObjectId,
      required: true,
      index: true,
    },
    timestamp: {
      type: Date,
      default: Date.now,
      index: true,
    },
    details: {
      type: Map,
      of: mongoose.Schema.Types.Mixed,
      default: {},
    },
    ip_address: {
      type: String,
      default: null,
    },
    user_agent: {
      type: String,
      default: null,
    },
    severity: {
      type: String,
      enum: ["low", "medium", "high", "critical"],
      default: "low",
    },
  },
  {
    timestamps: { createdAt: "timestamp", updatedAt: "updated_at" },
  }
);

// Compound indexes for efficient queries
activityLogSchema.index({ verse_id: 1, timestamp: -1 });
activityLogSchema.index({ user_id: 1, timestamp: -1 });
activityLogSchema.index({ action: 1, timestamp: -1 });
activityLogSchema.index({ resource_type: 1, resource_id: 1 });

module.exports = mongoose.model("ActivityLog", activityLogSchema);
