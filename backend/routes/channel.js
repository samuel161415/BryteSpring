const express = require('express');
const router = express.Router();
const channelController = require('../controllers/channelController');
const validation = require('../middleware/validation');
const auth = require('../middleware/auth');

// Debug endpoint to test role population
router.get('/debug/:verse_id', 
  auth.requireAuth,
  channelController.debugUserRole
);

// Create a new channel or folder
router.post('/create', 
  auth.requireAuth,
  validation.validateFolderCreation,
  channelController.createChannel
);

// Get channel/folder contents (children and assets)
router.get('/:channel_id/contents',
  auth.requireAuth,
  channelController.getChannelContents
);

// Get hierarchical structure of all channels/folders for a verse
router.get('/verse/:verse_id/structure',
  auth.requireAuth,
  channelController.getVerseChannelStructure
);

// Update folder/channel
router.put('/:id',
  auth.requireAuth,
  validation.validateChannelUpdate,
  channelController.updateChannel
);

// Delete folder/channel (soft delete)
router.delete('/:id',
  auth.requireAuth,
  channelController.deleteChannel
);

module.exports = router;
