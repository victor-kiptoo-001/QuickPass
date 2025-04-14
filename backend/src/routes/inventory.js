const express = require('express');
const router = express.Router();
const inventoryController = require('../controllers/inventory_controller');
const authMiddleware = require('../middleware/auth');

router.get('/item/:barcode', authMiddleware, inventoryController.getItem);

module.exports = router;