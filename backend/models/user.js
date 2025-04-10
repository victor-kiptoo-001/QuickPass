const mongoose = require('mongoose');
const bcrypt = require('bcrypt');

const userSchema = new mongoose.Schema({
  phone: { type: String, required: true, unique: true },
  deviceId: { type: String, required: true },
  loyaltyPoints: { type: Number, default: 0 },
  failedAttempts: { type: Number, default: 0 },
  lockedUntil: { type: Date }
});

userSchema.pre('save', async function(next) {
  if (this.isModified('phone')) {
    this.phone = await bcrypt.hash(this.phone, 10);
  }
  next();
});

module.exports = mongoose.model('User', userSchema);