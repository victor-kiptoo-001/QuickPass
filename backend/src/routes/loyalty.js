const express = require('express');
const router = express.Router();
const loyaltyController = require('../controllers/loyalty_controller');
const authMiddleware = require('../middleware/auth');
const { validate, redeemPointsSchema } = require('../middleware/validate');

router.get('/:userId', authMiddleware, loyaltyController.getLoyalty);
router.post('/redeem', authMiddleware, validate(redeemPointsSchema), loyaltyController.redeemPoints);
router.post('/add', authMiddleware, loyaltyController.addPoints);

module.exports = router;