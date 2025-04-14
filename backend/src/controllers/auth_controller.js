const User = require('../models/user');
const jwt = require('jsonwebtoken');
const { env } = require('../config/environment');
const { v4: uuidv4 } = require('uuid');

// Mock OTP service (replace with real SMS provider like Twilio)
const sendOtp = async (phone) => {
  const otp = Math.floor(100000 + Math.random() * 900000).toString();
  console.log(`OTP for ${phone}: ${otp}`); // Log for demo
  return otp;
};

const requestOtp = async (req, res) => {
  try {
    const { phone } = req.body;
    const otp = await sendOtp(phone);

    // In production, store OTP securely (e.g., Redis) with expiration
    res.status(200).json({ message: 'OTP sent' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to send OTP' });
  }
};

const verifyOtp = async (req, res) => {
  try {
    const { phone, otp, deviceId } = req.body;

    // Mock OTP verification (replace with real check)
    if (otp !== '123456') {
      // Use hardcoded OTP for demo
      return res.status(400).json({ error: 'Invalid OTP' });
    }

    let user = await User.findOne({ phone });
    if (!user) {
      user = new User({ phone, deviceId });
    } else if (user.deviceId && user.deviceId !== deviceId) {
      return res.status(403).json({ error: 'Device already registered' });
    }

    user.deviceId = deviceId;
    user.lastLogin = new Date();
    const token = jwt.sign({ userId: user._id }, env.JWT_SECRET, { expiresIn: '7d' });
    user.token = token;
    await user.save();

    res.status(200).json({
      id: user._id,
      phone: user.phone,
      deviceId: user.deviceId,
      token,
      lastLogin: user.lastLogin,
      isActive: user.isActive,
    });
  } catch (error) {
    res.status(500).json({ error: 'OTP verification failed' });
  }
};

const logout = async (req, res) => {
  try {
    const user = await User.findById(req.user._id);
    if (user) {
      user.token = null;
      await user.save();
    }
    res.status(200).json({ message: 'Logged out successfully' });
  } catch (error) {
    res.status(500).json({ error: 'Logout failed' });
  }
};

module.exports = { requestOtp, verifyOtp, logout };