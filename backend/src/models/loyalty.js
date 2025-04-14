const mongoose = require('mongoose');

const loyaltyTransactionSchema = new mongoose.Schema({
  type: { type: String, enum: ['earned', 'redeemed'], required: true },
  points: { type: Number, required: true },
  date: { type: Date, default: Date.now },
  transactionRef: { type: String },
});

const loyaltySchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  balance: { type: Number, default: 0 },
  history: [loyaltyTransactionSchema],
  updatedAt: { type: Date, default: Date.now },
});

module.exports = mongoose.model('Loyalty', loyaltySchema);