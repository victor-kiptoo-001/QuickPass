const mongoose = require('mongoose');

const inventorySchema = new mongoose.Schema({
  barcode: { type: String, required: true, unique: true },
  name: { type: String, required: true },
  price: { type: Number, required: true },
  stock: { type: Number, default: 0 },
  discount: { type: Number, min: 0, max: 1 }, // Percentage (e.g., 0.1 for 10%)
  imageUrl: { type: String },
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now },
});

module.exports = mongoose.model('Inventory', inventorySchema);