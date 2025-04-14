const express = require('express');
const router = express.Router();
const qrController = require('../controllers/qr_controller');
const authMiddleware = require('../middleware/auth');

router.get('/generate/:paymentId', authMiddleware, qrController.generateQr);
router.post('/validate', qrController.validateQr);

module.exports = router;