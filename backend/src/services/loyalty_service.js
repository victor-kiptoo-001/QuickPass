const Loyalty = require('../models/loyalty');
const { v4: uuidv4 } = require('uuid');

class LoyaltyService {
  async getLoyaltyData(userId) {
    let loyalty = await Loyalty.findOne({ userId });
    if (!loyalty) {
      loyalty = new Loyalty({ userId });
      await loyalty.save();
    }
    return loyalty;
  }

  async addPoints(userId, points, transactionRef) {
    const loyalty = await this.getLoyaltyData(userId);
    loyalty.balance += points;
    loyalty.history.push({
      id: uuidv4(),
      type: 'earned',
      points,
      transactionRef,
    });
    loyalty.updatedAt = new Date();
    await loyalty.save();
    return loyalty;
  }

  async redeemPoints(userId, points, paymentId) {
    const loyalty = await this.getLoyaltyData(userId);
    if (loyalty.balance < points) {
      throw new Error('Insufficient points');
    }
    loyalty.balance -= points;
    loyalty.history.push({
      id: uuidv4(),
      type: 'redeemed',
      points,
      transactionRef: paymentId,
    });
    loyalty.updatedAt = new Date();
    await loyalty.save();
    return loyalty;
  }
}

module.exports = new LoyaltyService();