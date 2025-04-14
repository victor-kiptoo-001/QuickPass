const loyaltyService = require('../services/loyalty_service');

const getLoyalty = async (req, res) => {
  try {
    const { userId } = req.params;
    if (userId !== req.user._id.toString()) {
      return res.status(403).json({ error: 'Unauthorized access' });
    }
    const loyalty = await loyaltyService.getLoyaltyData(userId);
    res.status(200).json(loyalty);
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch loyalty data' });
  }
};

const redeemPoints = async (req, res) => {
  try {
    const { userId, points, paymentId } = req.body;
    if (userId !== req.user._id.toString()) {
      return res.status(403).json({ error: 'Unauthorized access' });
    }
    const loyalty = await loyaltyService.redeemPoints({ userId, points, paymentId });
    res.status(200).json(loyalty);
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};

const addPoints = async (req, res) => {
  try {
    const { userId, points, transactionRef } = req.body;
    if (userId !== req.user._id.toString()) {
      return res.status(403).json({ error: 'Unauthorized access' });
    }
    const loyalty = await loyaltyService.addPoints({ userId, points, transactionRef });
    res.status(200).json(loyalty);
  } catch (error) {
    res.status(500).json({ error: 'Failed to add points' });
  }
};

module.exports = { getLoyalty, redeemPoints, addPoints };