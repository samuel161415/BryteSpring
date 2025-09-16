const { body } = require('express-validator');

exports.validateVerseCreation = [
  body('name')
    .trim()
    .isLength({ min: 1, max: 100 })
    .withMessage('Verse name must be between 1-100 characters'),
  body('admin_email')
    .isEmail()
    .normalizeEmail()
    .withMessage('Valid admin email is required')
];

exports.validateVerseSetup = [
  body('verse_id')
    .isMongoId()
    .withMessage('Valid verse ID is required'),
  body('name')
    .optional()
    .trim()
    .isLength({ min: 1, max: 100 })
    .withMessage('Verse name must be between 1-100 characters'),
  body('subdomain')
    .optional()
    .matches(/^[a-z0-9-]+$/)
    .withMessage('Subdomain can only contain lowercase letters, numbers, and hyphens')
    .isLength({ min: 3, max: 50 })
    .withMessage('Subdomain must be between 3-50 characters'),
  body('organization_name')
    .optional()
    .trim()
    .isLength({ max: 200 })
    .withMessage('Organization name must be less than 200 characters'),
  body('branding.primary_color')
    .optional()
    .matches(/^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$/)
    .withMessage('Primary color must be a valid hex color'),
  body('branding.color_name')
    .optional()
    .trim()
    .isLength({ max: 50 })
    .withMessage('Color name must be less than 50 characters')
];

exports.validateFolderCreation = [
  body('verse_id')
    .isMongoId()
    .withMessage('Valid verse ID is required'),
  body('name')
    .trim()
    .isLength({ min: 1, max: 100 })
    .withMessage('Channel/Folder name must be between 1-100 characters')
    .matches(/^[a-zA-Z0-9\s\-_\.]+$/)
    .withMessage('Channel/Folder name can only contain letters, numbers, spaces, hyphens, underscores, and dots'),
  body('parent_channel_id')
    .optional()
    .isMongoId()
    .withMessage('Parent channel ID must be a valid MongoDB ObjectId'),
  body('type')
    .optional()
    .isIn(['channel', 'folder'])
    .withMessage('Type must be either "channel" or "folder"'),
  body('asset_types')
    .optional()
    .isArray()
    .withMessage('Asset types must be an array'),
  body('asset_types.*')
    .optional()
    .isIn(['image', 'video', 'document', 'audio', 'text', 'data'])
    .withMessage('Invalid asset type. Allowed types: image, video, document, audio, text, data'),
  body('is_public')
    .optional()
    .isBoolean()
    .withMessage('Visibility must be a boolean value'),
  body('description')
    .optional()
    .trim()
    .isLength({ max: 500 })
    .withMessage('Description must be less than 500 characters')
];

exports.validateChannelUpdate = [
  body('name')
    .optional()
    .trim()
    .isLength({ min: 1, max: 100 })
    .withMessage('Channel name must be between 1-100 characters')
    .matches(/^[a-zA-Z0-9\s\-_\.]+$/)
    .withMessage('Channel name can only contain letters, numbers, spaces, hyphens, underscores, and dots'),
  body('asset_types')
    .optional()
    .isArray()
    .withMessage('Asset types must be an array'),
  body('asset_types.*')
    .optional()
    .isIn(['image', 'video', 'document', 'audio', 'text', 'data'])
    .withMessage('Invalid asset type. Allowed types: image, video, document, audio, text, data'),
  body('visibility.is_public')
    .optional()
    .isBoolean()
    .withMessage('Visibility must be a boolean value'),
  body('description')
    .optional()
    .trim()
    .isLength({ max: 500 })
    .withMessage('Description must be less than 500 characters'),
  body('folder_settings.allow_subfolders')
    .optional()
    .isBoolean()
    .withMessage('Allow subfolders setting must be a boolean value'),
  body('folder_settings.max_depth')
    .optional()
    .isInt({ min: 1, max: 10 })
    .withMessage('Max depth must be between 1 and 10')
];

exports.validateRoleCreation = [
  body('verse_id')
    .isMongoId()
    .withMessage('Valid verse ID is required'),
  body('name')
    .trim()
    .isLength({ min: 1, max: 50 })
    .withMessage('Role name must be between 1-50 characters')
    .isIn(['Administrator', 'Editor', 'Expert'])
    .withMessage('Role name must be one of: Administrator, Editor, Expert'),
  body('description')
    .optional()
    .trim()
    .isLength({ max: 500 })
    .withMessage('Description must be less than 500 characters'),
  body('permissions')
    .optional()
    .isObject()
    .withMessage('Permissions must be an object'),
  body('is_system_role')
    .optional()
    .isBoolean()
    .withMessage('System role flag must be a boolean value')
];

exports.validateRoleUpdate = [
  body('name')
    .optional()
    .trim()
    .isLength({ min: 1, max: 50 })
    .withMessage('Role name must be between 1-50 characters')
    .isIn(['Administrator', 'Editor', 'Expert'])
    .withMessage('Role name must be one of: Administrator, Editor, Expert'),
  body('description')
    .optional()
    .trim()
    .isLength({ max: 500 })
    .withMessage('Description must be less than 500 characters'),
  body('permissions')
    .optional()
    .isObject()
    .withMessage('Permissions must be an object'),
  body('is_system_role')
    .optional()
    .isBoolean()
    .withMessage('System role flag must be a boolean value')
];