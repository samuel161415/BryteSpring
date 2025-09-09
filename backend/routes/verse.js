const express = require('express');
const router = express.Router();
const verseController = require('../controllers/verseController');
const validation = require('../middleware/validation');
const auth = require('../middleware/auth');

// Superadmin routes
router.post('/create-initial', 
  auth.requireAuth, 
  validation.validateVerseCreation, 
  verseController.createInitialVerse
);

router.get('/list', 
  auth.requireAuth, 
  verseController.listVerses
);

// Admin routes
router.post('/complete-setup', 
  auth.requireAuth, 
  validation.validateVerseSetup, 
  verseController.completeVerseSetup
);

// General routes
router.get('/:id', 
  auth.requireAuth, 
  verseController.getVerse
);

router.put('/:id', 
  auth.requireAuth, 
  validation.validateVerseSetup, 
  verseController.updateVerse
);

router.delete('/:id', 
  auth.requireAuth, 
  verseController.deleteVerse
);

module.exports = router;