const mongoose = require("mongoose");
const bcrypt = require("bcryptjs");
const crypto = require("crypto");

const userSchema = new mongoose.Schema({
  email: { type: String, required: true, unique: true, lowercase: true },
  password_hash: { type: String, required: true },
  first_name: String,
  last_name: String,
  avatar_url: String,
  position: String,
  is_superadmin: { type: Boolean, default: false },
  is_active: { type: Boolean, default: true },
  joined_verse: [{ type: mongoose.Schema.Types.ObjectId, ref: "Verse" }],
  last_login: Date,
}, { timestamps: { createdAt: "created_at", updatedAt: "updated_at" } });

// helper methods
userSchema.methods.setPassword = async function (plain) {
  this.password_hash = await bcrypt.hash(plain, 10);
};
userSchema.methods.matchPassword = function (entered) {
  return bcrypt.compare(entered, this.password_hash);
};

// Generate & hash reset token
userSchema.methods.getResetPasswordToken = function () {
  const resetToken = crypto.randomBytes(20).toString("hex");

  this.resetPasswordToken = crypto
    .createHash("sha256")
    .update(resetToken)
    .digest("hex");

  this.resetPasswordExpire = Date.now() + 10 * 60 * 1000; // 10 minutes

  return resetToken;
};
module.exports = mongoose.model("User", userSchema);
