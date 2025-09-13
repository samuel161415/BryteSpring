# Join Verse API Testing Guide

## Overview
This guide covers the new join verse functionality that supports two different user flows:

1. **Verse Setup Flow**: Admin completing verse creation (immediate join)
2. **Existing Verse Join Flow**: User joining an already completed verse (requires explicit join)

## API Endpoints

### 1. Register User (Updated)
**POST** `http://localhost:3000/register`

#### Two Scenarios:

##### Scenario A: Verse Setup (Admin completing verse creation)
```json
{
  "email": "admin@company.com",
  "password": "password123",
  "invitation_token": "INVITATION_TOKEN_FOR_SETUP"
}
```

**Response (201)**:
```json
{
  "_id": "USER_ID",
  "email": "admin@company.com",
  "first_name": "John",
  "last_name": "Doe",
  "joined_verse": ["VERSE_ID"],
  "token": "JWT_TOKEN",
  "pending_verse_join": null
}
```

##### Scenario B: Existing Verse Join (User joining completed verse)
```json
{
  "email": "user@company.com", 
  "password": "password123",
  "invitation_token": "INVITATION_TOKEN_FOR_EXISTING_VERSE"
}
```

**Response (201)**:
```json
{
  "_id": "USER_ID",
  "email": "user@company.com",
  "first_name": "Jane",
  "last_name": "Smith",
  "joined_verse": [],
  "token": "JWT_TOKEN",
  "pending_verse_join": "VERSE_ID"
}
```

### 2. Join Existing Verse
**POST** `http://localhost:3000/verse/:verse_id/join`

**Headers:**
```
Authorization: Bearer JWT_TOKEN
```

**Response (200)**:
```json
{
  "message": "Successfully joined verse",
  "verse": {
    "_id": "VERSE_ID",
    "name": "Company Verse",
    "subdomain": "company",
    "organization_name": "Company Inc"
  },
  "role": {
    "_id": "ROLE_ID",
    "name": "Expert",
    "description": "Can upload and manage assets",
    "permissions": {
      "manage_assets": true,
      "manage_channels": false
    }
  },
  "user": {
    "_id": "USER_ID",
    "email": "user@company.com",
    "first_name": "Jane",
    "last_name": "Smith",
    "joined_verse": ["VERSE_ID"]
  }
}
```

### 3. Get User by Email
**GET** `http://localhost:3000/user/email/:email`

**Headers:**
```
Authorization: Bearer JWT_TOKEN
```

**Response (200)**:
```json
{
  "_id": "USER_ID",
  "email": "user@company.com",
  "first_name": "Jane",
  "last_name": "Smith",
  "avatar_url": null,
  "joined_verse": ["VERSE_ID"],
  "is_active": true,
  "created_at": "2023-07-20T10:30:00.000Z"
}
```

## Complete User Flow Testing

### Flow 1: Admin Completing Verse Setup

1. **Superadmin creates initial verse**:
   ```bash
   curl -X POST http://localhost:3000/verse/create-initial \
     -H "Authorization: Bearer SUPERADMIN_TOKEN" \
     -H "Content-Type: application/json" \
     -d '{
       "name": "Company Verse",
       "admin_email": "admin@company.com",
       "first_name": "John",
       "last_name": "Doe",
       "position": "CEO"
     }'
   ```

2. **Admin registers with invitation token** (immediately joins):
   ```bash
   curl -X POST http://localhost:3000/register \
     -H "Content-Type: application/json" \
     -d '{
       "email": "admin@company.com",
       "password": "password123",
       "invitation_token": "INVITATION_TOKEN"
     }'
   ```

3. **Admin completes verse setup**:
   ```bash
   curl -X POST http://localhost:3000/verse/complete-setup \
     -H "Authorization: Bearer ADMIN_TOKEN" \
     -H "Content-Type: application/json" \
     -d '{
       "verse_id": "VERSE_ID",
       "subdomain": "company",
       "organization_name": "Company Inc",
       "branding": {
         "primary_color": "#3B82F6",
         "color_name": "Blue"
       }
     }'
   ```

### Flow 2: User Joining Existing Verse

1. **Admin creates invitation for existing verse**:
   ```bash
   curl -X POST http://localhost:3000/invitation/create \
     -H "Authorization: Bearer ADMIN_TOKEN" \
     -H "Content-Type: application/json" \
     -d '{
       "verse_id": "VERSE_ID",
       "email": "user@company.com",
       "role_id": "ROLE_ID",
       "first_name": "Jane",
       "last_name": "Smith",
       "position": "Marketing Manager"
     }'
   ```

2. **User registers with invitation token** (pending join):
   ```bash
   curl -X POST http://localhost:3000/register \
     -H "Content-Type: application/json" \
     -d '{
       "email": "user@company.com",
       "password": "password123",
       "invitation_token": "INVITATION_TOKEN"
     }'
   ```

3. **User explicitly joins verse** (after role understanding):
   ```bash
   curl -X POST http://localhost:3000/verse/VERSE_ID/join \
     -H "Authorization: Bearer USER_TOKEN" \
     -H "Content-Type: application/json"
   ```

## Frontend Integration

### Registration Response Handling

```javascript
// After successful registration
const response = await registerUser(userData);

if (response.pending_verse_join) {
  // Show role understanding screen
  // User must click "Rolle verstanden & loslegen" 
  // Then call joinVerse API
  showRoleUnderstandingScreen(response.pending_verse_join);
} else {
  // User immediately joined (verse setup scenario)
  // Redirect to verse completion or dashboard
  redirectToVerseSetup();
}
```

### Join Verse Flow

```javascript
// When user clicks "Rolle verstanden & loslegen"
const joinVerse = async (verseId) => {
  try {
    const response = await fetch(`/verse/${verseId}/join`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      }
    });
    
    if (response.ok) {
      // Show "Du bist jetzt startklar!" screen
      showReadyScreen(response.data);
    }
  } catch (error) {
    console.error('Failed to join verse:', error);
  }
};
```

## Error Handling

### Common Error Responses

#### User Already Joined (400)
```json
{
  "message": "User has already joined this verse"
}
```

#### No Valid Invitation (403)
```json
{
  "message": "No valid invitation found for this verse"
}
```

#### Verse Not Set Up (400)
```json
{
  "message": "Cannot join verse that is not yet set up"
}
```

#### Invalid Invitation Token (400)
```json
{
  "message": "Invalid invitation token"
}
```

#### Invitation Expired (400)
```json
{
  "message": "Invitation expired"
}
```

## Database Changes

### User Collection
- `joined_verse`: Array of verse IDs the user belongs to
- Updated during registration (verse setup) or joinVerse call

### UserRole Collection
- Created during registration (verse setup) or joinVerse call
- Links user to verse with specific role

### Invitation Collection
- `is_accepted`: Set to true during registration
- `accepted_at`: Timestamp when invitation was accepted

### ActivityLog Collection
- Logs all join activities for audit trail
- Different actions for setup vs join scenarios

## Testing Checklist

- [ ] Admin can register and immediately join verse during setup
- [ ] User can register with invitation but not join until explicit action
- [ ] Join verse API works for users with valid invitations
- [ ] Join verse API fails for users without valid invitations
- [ ] Join verse API fails if user already joined
- [ ] Join verse API fails for incomplete verses
- [ ] User details are retrieved from invitation during registration
- [ ] Activity logs are created for all scenarios
- [ ] getUserByEmail endpoint works correctly
- [ ] Error handling works for all edge cases

## Security Notes

- All endpoints require authentication
- Join verse requires valid invitation that was accepted
- Users can only join verses they have invitations for
- Activity logging tracks all join activities
- Role permissions are enforced after joining
