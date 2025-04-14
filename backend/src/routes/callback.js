const express = require('express');
const router = express.Router();
const callbackController = require('../controllers/callback_controller');

router.post('/mpesa', callbackController.handleMpesaCallback);

module.exports = router;