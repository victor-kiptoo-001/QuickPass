const Payment = require('../models/payment');
const mpesaService = require('../services/mpesa_service');
const loyaltyService = require('../services/loyalty_service');

const initiateMpesa = async (req, res) => {
  try {
    const { phone, amount, cartItems, paymentId } = req.body;

    const payment = new Payment({
      userId: req.user._id,
      cartItems,
      totalAmount: amount,
      method: 'mpesa',
      status: 'pending',
    });

    const transactionRef = await mpesaService.initiateStkPush(phone, amount, paymentId);
    payment.transactionRef = transactionRef;
    await payment.save();

    res.status(200).json({
      transactionRef,
      paymentId,
    });
  } catch (error) {
    res.status(500).json({ error: 'Failed to initiate M-PESA payment' });
  }
};

const getStatus = async (req, res) => {
  try {
    const { paymentId } = req.params;
    const payment = await Payment.findById(paymentId);
    if (!payment || payment.userId.toString() !== req.user._id.toString()) {
      return res.status(404).json({ error: 'Payment not found' });
    }
    res.status(200).json({ status: payment.status });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch payment status' });
  }
};

module.exports = { initiateMpesa, getStatus };