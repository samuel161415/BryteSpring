// backend/middleware/auth.js
const jwt = require('jsonwebtoken');
const User = require('../models/User');

exports.requireAuth = async (req, res, next) => {
  try {
    const header = req.headers.authorization || '';
    const [scheme, token] = header.split(' ');
    if (scheme !== 'Bearer' || !token) {
      return res.status(401).json({ message: 'Unauthorized' });
    }

    const payload = jwt.verify(token, process.env.JWT_SECRET);
   
    const user = await User.findById(payload.id || payload.userId);
    if (!user || user.is_active === false) {
      return res.status(401).json({ message: 'Unauthorized' });
    }

    req.user = user;
    next();
  } catch (err) {
    return res.status(401).json({ message: 'Unauthorized' });
  }
};

// Admin middleware - checks if user has admin role
exports.admin = (req, res, next) => {
  if (req.user && req.user.is_superadmin === true) {
    next();
  } else {
    res.status(403).json({ message: 'Admin access required' });
  }
};

// Alias for requireAuth to maintain compatibility with existing code
exports.protect = exports.requireAuth;