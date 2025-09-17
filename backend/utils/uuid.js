// UUID utility module - compatible with both CommonJS and ES modules
// Works in Vercel serverless environment

let uuidv4;

// Try to load UUID module dynamically
const loadUuid = async () => {
  try {
    // Try ES module import first (for newer versions)
    const { v4 } = await import('uuid');
    return v4;
  } catch (error) {
    try {
      // Fallback to CommonJS require
      const uuid = require('uuid');
      return uuid.v4 || uuid;
    } catch (requireError) {
      // Final fallback to crypto.randomUUID()
      const crypto = require('crypto');
      return () => crypto.randomUUID();
    }
  }
};

// Initialize UUID function
const initUuid = async () => {
  if (!uuidv4) {
    uuidv4 = await loadUuid();
  }
  return uuidv4;
};

// Synchronous wrapper that uses crypto.randomUUID() as fallback
const generateUuid = () => {
  try {
    // Try to use the loaded UUID function
    if (uuidv4) {
      return uuidv4();
    }
    
    // Fallback to crypto.randomUUID() which is available in Node.js 14.17.0+
    const crypto = require('crypto');
    return crypto.randomUUID();
  } catch (error) {
    // Ultimate fallback - generate a simple UUID-like string
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
      const r = Math.random() * 16 | 0;
      const v = c === 'x' ? r : (r & 0x3 | 0x8);
      return v.toString(16);
    });
  }
};

// Initialize on module load
initUuid().catch(() => {
  // Silent fail - will use fallback methods
});

module.exports = {
  v4: generateUuid,
  generateUuid
};