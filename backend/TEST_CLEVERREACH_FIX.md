# CleverReach Fix Testing Guide

## Problem Identified
Based on your debug results:
- ✅ `/groups.json` works (200) - Your group ID: 575474
- ✅ `/mailings.json` works (200) - Can create mailings
- ❌ `/send.json` fails (404) - This endpoint doesn't exist

## Solution Implemented
I've updated the CleverReach service to use the **correct approach**:
1. Create a mailing using `/mailings.json` (which works)
2. Send the mailing using `/mailings.json/{id}/send`

## Testing Steps

### Step 1: Test the Updated Debug Endpoint
```bash
curl -X GET http://localhost:3000/test/cleverreach-debug
```

**Expected Result:**
```json
{
  "message": "CleverReach API debug results",
  "token": "eyJ0eXAiOi...",
  "endpoints": {
    "/groups.json": {
      "status": 200,
      "success": true
    },
    "/mailings.json": {
      "status": 200,
      "success": true
    },
    "mailing_creation_test": {
      "status": 201,
      "success": true
    }
  }
}
```

### Step 2: Test Send Invitation (Should Work Now)
```bash
curl -X POST http://localhost:3000/test/send-invitation \
  -H "Content-Type: application/json" \
  -d '{
    "email": "your-email@example.com",
    "verseName": "Test Company",
    "roleName": "Expert"
  }'
```

**Expected Result:**
```json
{
  "message": "Test invitation sent successfully",
  "mailingId": 123456
}
```

## What Changed

### Before (Broken)
```javascript
// This was trying to use /send.json which doesn't exist
const sendResponse = await axios.post(`${CLEVERREACH_BASE_URL}/send.json`, {...});
```

### After (Fixed)
```javascript
// Step 1: Create mailing (this works)
const mailingResponse = await axios.post(`${CLEVERREACH_BASE_URL}/mailings.json`, {
  name: `Invitation: ${verseName}`,
  subject: subject,
  html_body: htmlContent,
  from_email: fromEmail,
  from_name: FROM_NAME,
  group_id: parseInt(groupId)
});

// Step 2: Send the mailing (this should work)
const sendResponse = await axios.post(`${CLEVERREACH_BASE_URL}/mailings.json/${mailingId}/send`, {
  group_id: parseInt(groupId),
  recipients: [to.toLowerCase()]
});
```

## Fallback Strategy
If the mailing approach fails, there's an alternative approach that creates a mailing with immediate send settings.

## Next Steps
1. **Test the debug endpoint** to confirm mailing creation works
2. **Test send invitation** - it should work now
3. **Check your email** for the test invitation
4. **Test real invitation flow** using your actual invitation endpoints

## If It Still Fails
If you still get errors, the debug endpoint will now show you exactly what's failing in the mailing creation process, making it easier to identify the specific issue.

## Environment Variables
Make sure these are set correctly:
```bash
CLEVERREACH_CLIENT_ID=fJJZuUT29g
CLEVERREACH_CLIENT_SECRET=akjRdeKHfCzJyh0TeUq8CTs4R3WXRpAO
EMAIL_FROM=noreply@yourdomain.com
FROM_NAME=BRYTE VERSE
```
