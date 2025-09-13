const crypto = require('crypto');

// Generate UUID v4 using Node.js crypto module (fallback for deployment)
function generateUUID() {
  return crypto.randomUUID();
}

module.exports = {
  v4: generateUUID
};
