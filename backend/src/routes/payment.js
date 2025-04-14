const express = require('express');
const router = express.Router();
const paymentController = require('../controllers/payment_controller');
const authMiddleware = require('../middleware/auth');
const { validate, paymentSchema } = require('../middleware/validate');

router.post('/mpesa', authMiddleware, validate(paymentSchema), paymentController.initiateMpesa);
router.get('/status/:paymentId', authMiddleware, paymentController.getStatus);

module.exports = router;