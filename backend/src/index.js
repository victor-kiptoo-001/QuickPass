const express = require('express');
const connectDB = require('./config/database');
const { env } = require('./config/environment');
const authRoutes = require('./routes/auth');
const cartRoutes = require('./routes/cart');
const paymentRoutes = require('./routes/payment');
const qrRoutes = require('./routes/qr');
const loyaltyRoutes = require('./routes/loyalty');
const inventoryRoutes = require('./routes/inventory');
const callbackRoutes = require('./routes/callback');
const rateLimiter = require('./middleware/rate_limit');

const app = express();

// Middleware
app.use(express.json());
app.use(rateLimiter);

// Routes
app.use('/auth', authRoutes);
app.use('/cart', cartRoutes);
app.use('/payment', paymentRoutes);
app.use('/qr', qrRoutes);
app.use('/loyalty', loyaltyRoutes);
app.use('/inventory', inventoryRoutes);
app.use('/callback', callbackRoutes);

// Error handling
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Something went wrong!' });
});

// Start server
const startServer = async () => {
  await connectDB();
  app.listen(env.PORT, () => {
    console.log(`Server running on port ${env.PORT}`);
  });
};

startServer();