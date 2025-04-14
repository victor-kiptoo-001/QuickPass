const { v4: uuidv4 } = require('uuid');
const Qr = require('../models/qr');

class QrService {
  async generateQrCode(paymentId) {
    const token = uuidv4();
    const expiresAt = new Date(Date.now() + 10 * 60 * 1000); // 10 minutes
    const receiptUrl = `https://your-domain.com/receipts/${paymentId}.pdf`; // Placeholder

    const qr = new Qr({
      paymentId,
      token,
      expiresAt,
      receiptUrl,
    });

    await qr.save();
    return qr;
  }

  async validateQrCode(token) {
    const qr = await Qr.findOne({ token });
    if (!qr || qr.isUsed || new Date() > qr.expiresAt) {
      return false;
    }
    qr.isUsed = true;
    await qr.save();
    return true;
  }
}

module.exports = new QrService();