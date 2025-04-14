const Inventory = require('../models/inventory');

const getItem = async (req, res) => {
  try {
    const { barcode } = req.params;
    const item = await Inventory.findOne({ barcode });
    if (!item) {
      return res.status(404).json({ error: 'Item not found' });
    }
    if (item.stock <= 0) {
      return res.status(400).json({ error: 'Item out of stock' });
    }
    res.status(200).json({
      id: item.barcode,
      name: item.name,
      price: item.price,
      discount: item.discount,
      imageUrl: item.imageUrl,
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch item' });
  }
};

module.exports = { getItem };