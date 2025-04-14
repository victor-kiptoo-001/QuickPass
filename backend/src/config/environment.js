require('dotenv').config();

const env = {
  NODE_ENV: process.env.NODE_ENV || 'development',
  PORT: process.env.PORT || 3000,
  MONGO_URI: process.env.MONGO_URI || 'mongodb://localhost:27017/quickpass',
  Mpesa_CONSUMER_KEY: process.env.Mpesa_CONSUMER_KEY || 'your_consumer_key',
  Mpesa_CONSUMER_SECRET: process.env.Mpesa_CONSUMER_SECRET || 'your_consumer_secret',
  Mpesa_SHORTCODE: process.env.Mpesa_SHORTCODE || 'your_shortcode',
  Mpesa_PASSKEY: process.env.Mpesa_PASSKEY || 'your_passkey',
  JWT_SECRET: process.env.JWT_SECRET || 'your_jwt_secret',
};

module.exports = { env };