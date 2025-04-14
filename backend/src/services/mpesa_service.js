const axios = require('axios');
const { env } = require('../config/environment');

class MpesaService {
  async getAccessToken() {
    const auth = Buffer.from(`${env.Mpesa_CONSUMER_KEY}:${env.Mpesa_CONSUMER_SECRET}`).toString('base64');
    const response = await axios.get('https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials', {
      headers: { Authorization: `Basic ${auth}` },
    });
    return response.data.access_token;
  }

  async initiateStkPush(phone, amount, paymentId) {
    const token = await this.getAccessToken();
    const timestamp = new Date().toISOString().replace(/[^0-9]/g, '').slice(0, 14);
    const password = Buffer.from(`${env.Mpesa_SHORTCODE}${env.Mpesa_PASSKEY}${timestamp}`).toString('base64');

    const response = await axios.post(
      'https://sandbox.safaricom.co.ke/mpesa/stkpush/v1/processrequest',
      {
        BusinessShortCode: env.Mpesa_SHORTCODE,
        Password: password,
        Timestamp: timestamp,
        TransactionType: 'CustomerPayBillOnline',
        Amount: amount,
        PartyA: phone,
        PartyB: env.Mpesa_SHORTCODE,
        PhoneNumber: phone,
        CallBackURL: 'https://your-domain.com/callback', // Replace with real callback
        AccountReference: paymentId,
        TransactionDesc: 'QuickPass Payment',
      },
      {
        headers: { Authorization: `Bearer ${token}` },
      }
    );

    return response.data.CheckoutRequestID;
  }
}

module.exports = new MpesaService();