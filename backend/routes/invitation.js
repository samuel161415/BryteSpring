const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const invitationController = require('../controllers/invitationController');

// Create invitation (admin or superadmin)
router.post('/', auth.requireAuth, invitationController.createInvitation);

// Get invitation by token (public for registration flow)
router.get('/:token', invitationController.getInvitationByToken);

// Get invitation by id (protected)
router.get('/id/:id', auth.requireAuth, invitationController.getInvitationById);

// Update invitation (only inviter)
router.put('/:id', auth.requireAuth, invitationController.updateInvitation);

// Delete invitation (only inviter)
router.delete('/:id', auth.requireAuth, invitationController.deleteInvitation);

module.exports = router;
