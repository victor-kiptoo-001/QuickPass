const express = require('express');
const router = express.Router();
const authController = require('../controllers/auth_controller');
const { validate, authSchema, verifyOtpSchema } = require('../middleware/validate');

router.post('/request-otp', validate(authSchema), authController.requestOtp);
router.post('/verify-otp', validate(verifyOtpSchema), authController.verifyOtp);
router.post('/logout', authController.logout);

module.exports = router;