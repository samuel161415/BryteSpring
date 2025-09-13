# Vercel Deployment Fix Guide

## Issues Fixed

### 1. ✅ UUID Import Error
**Problem**: `Error [ERR_REQUIRE_ESM]: require() of ES Module /var/task/backend/node_modules/uuid/dist-node/index.js not supported`

**Solution**: Implemented fallback UUID generation:
```javascript
// Try uuid/v4 first, fallback to crypto if it fails
let uuidv4;
try {
  uuidv4 = require('uuid/v4');
} catch (error) {
  const crypto = require('crypto');
  uuidv4 = () => crypto.randomUUID();
}
```

### 2. ✅ Mongoose Duplicate Index Warning
**Problem**: `Duplicate schema index on {"subdomain":1} found`

**Solution**: Removed duplicate index creation in Verse model:
```javascript
// Before: Had both unique: true and explicit index
subdomain: { unique: true, ... }
verseSchema.index({ subdomain: 1 }); // Duplicate!

// After: Only unique: true creates the index
subdomain: { unique: true, ... }
// verseSchema.index({ subdomain: 1 }); // Removed
```

## Files Modified

1. **`controllers/verseController.js`** - Fixed UUID import
2. **`controllers/invitationController.js`** - Fixed UUID import  
3. **`models/Verse.js`** - Removed duplicate index
4. **`vercel.json`** - Added Vercel configuration
5. **`utils/uuid.js`** - Created fallback UUID utility

## Vercel Configuration

Created `vercel.json` for proper deployment:
```json
{
  "version": 2,
  "builds": [
    {
      "src": "index.js",
      "use": "@vercel/node"
    }
  ],
  "routes": [
    {
      "src": "/(.*)",
      "dest": "/index.js"
    }
  ],
  "env": {
    "NODE_ENV": "production"
  }
}
```

## Environment Variables Required

Make sure these are set in your Vercel project:

```bash
MONGODB_URI=mongodb+srv://sam:vIDOYAfvSh51CEXu@cluster0.m0bug.mongodb.net/BryteSpring?retryWrites=true&w=majority
JWT_SECRET=your_jwt_secret_key_here
CLEVERREACH_CLIENT_ID=fJJZuUT29g
CLEVERREACH_CLIENT_SECRET=akjRdeKHfCzJyh0TeUq8CTs4R3WXRpAO
EMAIL_FROM=samuelnegalign19@gmail.com
FROM_NAME=BRYTE VERSE
INVITE_BASE_URL=https://your-vercel-domain.vercel.app
```

## Deployment Steps

1. **Commit all changes**:
   ```bash
   git add .
   git commit -m "fix: resolve Vercel deployment issues - UUID import and Mongoose index"
   git push origin main
   ```

2. **Redeploy on Vercel**:
   - Go to your Vercel dashboard
   - Click "Redeploy" on your latest deployment
   - Or push to your connected GitHub branch

3. **Verify deployment**:
   - Check Vercel logs for successful startup
   - Test endpoints to ensure they work

## Expected Results

After deployment, you should see:
- ✅ No UUID import errors
- ✅ No Mongoose duplicate index warnings
- ✅ Server starts successfully
- ✅ All endpoints work correctly

## Fallback Solutions

If issues persist:

1. **Use crypto-only UUID**:
   ```javascript
   const crypto = require('crypto');
   const uuidv4 = () => crypto.randomUUID();
   ```

2. **Downgrade uuid package**:
   ```bash
   npm install uuid@8.3.2
   ```

3. **Use CommonJS uuid**:
   ```bash
   npm install uuid@8.3.2
   ```

The deployment should now work successfully! 🎯
