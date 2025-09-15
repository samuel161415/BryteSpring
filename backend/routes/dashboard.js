const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const dashboardController = require('../controllers/dashboardController');

// Get dashboard data for a specific verse
// GET /api/dashboard/:verse_id
router.get('/:verse_id', auth.requireAuth, dashboardController.getDashboard);

// Get dashboard notifications for a specific verse
// GET /api/dashboard/:verse_id/notifications
router.get('/:verse_id/notifications', auth.requireAuth, dashboardController.getDashboardNotifications);

module.exports = router;
