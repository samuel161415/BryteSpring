const express = require('express');
const router = express.Router();
const roleController = require('../controllers/roleController');
const validation = require('../middleware/validation');
const auth = require('../middleware/auth');

// Get role by ID
router.get('/:id', 
  auth.requireAuth, 
  roleController.getRole
);

// List roles by verse_id
router.get('/verse/:verse_id', 
  auth.requireAuth, 
  roleController.listRolesByVerse
);

// Get user's assigned role for a verse (for join process)
router.get('/user/:verse_id/assigned', 
  auth.requireAuth, 
  roleController.getUserAssignedRole
);

// Create new role
router.post('/', 
  auth.requireAuth, 
  validation.validateRoleCreation, 
  roleController.createRole
);

// Update role
router.put('/:id', 
  auth.requireAuth, 
  validation.validateRoleUpdate, 
  roleController.updateRole
);

// Delete role
router.delete('/:id', 
  auth.requireAuth, 
  roleController.deleteRole
);

// Get available permissions (helper endpoint)
router.get('/permissions/available', 
  auth.requireAuth, 
  roleController.getAvailablePermissions
);

module.exports = router;
