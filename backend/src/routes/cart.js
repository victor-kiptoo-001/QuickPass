const express = require('express');
const router = express.Router();
const cartController = require('../controllers/cart_controller');
const authMiddleware = require('../middleware/auth');
const { validate, cartItemSchema } = require('../middleware/validate');

router.get('/', authMiddleware, cartController.getCart);
router.post('/add', authMiddleware, validate(Joi.array().items(cartItemSchema)), cartController.addItem);
router.post('/update', authMiddleware, validate(Joi.array().items(cartItemSchema)), cartController.updateCart);

module.exports = router;