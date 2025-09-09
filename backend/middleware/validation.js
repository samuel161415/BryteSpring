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