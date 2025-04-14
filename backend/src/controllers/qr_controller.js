const qrService = require('../services/qr_service');
const Payment = require('../models/payment');

const generateQr = async (req, res) => {
  try {
    const { paymentId } = req.params;
    const payment = await Payment.findById(paymentId);
    if (!payment || payment.userId.toString() !== req.user._id.toString()) {
      return res.status(404).json({ error: 'Payment not found' });
    }
    if (payment.status !== 'completed') {
      return res.status(400).json({ error: 'Payment not completed' });
    }

    const qr = await qrService.generateQrCode(paymentId);
    res.status(200).json(qr);
  } catch (error) {
    res.status(500).json({ error: 'Failed to generate QR code' });
  }
};

const validateQr = async (req, res) => {
  try {
    const { token } = req.body;
    const isValid = await qrService.validateQrCode(token);
    res.status(200).json({ isValid });
  } catch (error) {
    res.status(500).json({ error: 'Failed to validate QR code' });
  }
};

module.exports = { generateQr, validateQr };