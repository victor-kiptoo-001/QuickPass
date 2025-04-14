const Payment = require('../models/payment');
const loyaltyService = require('../services/loyalty_service');
const { POINTS_PER_KSH } = require('../config/app_config');

const handleMpesaCallback = async (req, res) => {
  try {
    const { ResultCode, CheckoutRequestID, Amount } = req.body.Body.stkCallback;
    const payment = await Payment.findOne({ transactionRef: CheckoutRequestID });
    if (!payment) {
      return res.status(404).json({ error: 'Payment not found' });
    }

    if (ResultCode === 0) {
      payment.status = 'completed';
      // Award loyalty points based on amount
      const points = Math.floor(Amount * POINTS_PER_KSH);
      if (points > 0) {
        await loyaltyService.addPoints({
          userId: payment.userId.toString(),
          points,
          transactionRef: payment._id.toString(),
        });
      }
    } else {
      payment.status = 'failed';
    }

    await payment.save();
    res.status(200).json({ message: 'Callback processed' });
  } catch (error) {
    console.error('M-PESA callback error:', error);
    res.status(500).json({ error: 'Failed to process callback' });
  }
};

module.exports = { handleMpesaCallback };