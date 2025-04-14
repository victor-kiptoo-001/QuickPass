const mongoose = require('mongoose');

const qrSchema = new mongoose.Schema({
  paymentId: { type: mongoose.Schema.Types.ObjectId, ref: 'Payment', required: true },
  token: { type: String, required: true, unique: true },
  createdAt: { type: Date, default: Date.now },
  expiresAt: { type: Date, required: true },
  receiptUrl: { type: String, required: true },
  isUsed: { type: Boolean, default: false },
});

module.exports = mongoose.model('Qr', qrSchema);