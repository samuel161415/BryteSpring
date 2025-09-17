// UUID utility module - ES module compatible for Vercel
// Uses only Node.js built-in crypto module to avoid ES module conflicts

const crypto = require('crypto');

// Generate UUID v4 using Node.js built-in crypto.randomUUID()
// This is available in Node.js 14.17.0+ and works perfectly in Vercel
const generateUuid = () => {
  try {
    // Use Node.js built-in crypto.randomUUID() - this is the most reliable method
    return crypto.randomUUID();
  } catch (error) {
    // Fallback UUID generator if crypto.randomUUID() is not available
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
      const r = Math.random() * 16 | 0;
      const v = c === 'x' ? r : (r & 0x3 | 0x8);
      return v.toString(16);
    });
  }
};

// Export the function as v4 to match uuid package API
module.exports = {
  v4: generateUuid,
  generateUuid
};