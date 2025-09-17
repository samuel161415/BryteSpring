const express = require('express');
const router = express.Router();
const uploadController = require('../controllers/uploadController');
const auth = require('../middleware/auth');

// Upload single file
router.post('/single', 
  auth.requireAuth,
  uploadController.uploadMiddleware.single('file'),
  uploadController.uploadSingle
);

// Upload multiple files
router.post('/multiple', 
  auth.requireAuth,
  uploadController.uploadMiddleware.array('files', 10), // Max 10 files
  uploadController.uploadMultiple
);

// Delete file
router.delete('/delete', 
  auth.requireAuth,
  uploadController.deleteFile
);

// List files
router.get('/list', 
  auth.requireAuth,
  uploadController.listFiles
);

module.exports = router;
