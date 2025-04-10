const express = require('express');
const router = express.Router();
const Item = require('../models/item');

router.get('/:code', async (req, res) => {
  const item = await Item.findOne({ barcode: req.params.code });
  if (item) {
    res.json({ name: item.name, price: item.price });
  } else {
    res.status(404).json({ message: 'Item not found' });
  }
});

module.exports = router;