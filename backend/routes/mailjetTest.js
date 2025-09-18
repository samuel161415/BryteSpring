const express = require('express');
const router = express.Router();
const mailjetTestController = require('../controllers/mailjetTestController');

// Test configuration
router.get('/config', mailjetTestController.testConfiguration);

// Get account info
router.get('/account', mailjetTestController.getAccountInfo);

// Send basic test email
router.post('/send-test', mailjetTestController.sendTestEmailController);

// Send test invitation email
router.post('/send-invitation', mailjetTestController.sendTestInvitation);

module.exports = router;
