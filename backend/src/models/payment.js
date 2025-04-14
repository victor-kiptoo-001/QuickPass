const mongoose = require('mongoose');

const paymentSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  cartItems: [
    {
      id: { type: String, required: true },
      name: { type: String, required: true },
      price: { type: Number, required: true },
      quantity: { type: Number, default: 1 },
      discount: { type: Number },
    },
  ],
  totalAmount: { type: Number, required: true },
  method: { type: String, enum: ['mpesa', 'card', 'loyalty'], required: true },
  status: { type: String, enum: ['pending', 'completed', 'failed'], default: 'pending' },
  createdAt: { type: Date, default: Date.now },
  transactionRef: { type: String },
  loyaltyPointsUsed: { type: Number },
});

module.exports = mongoose.model('Payment', paymentSchema);