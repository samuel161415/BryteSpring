# Verse Branding/White Labeling API

## Overview
The Verse Branding API allows Administrators to update the visual branding and white labeling settings for their verse. This includes logo, primary color, and color name customization.

## Endpoint
```
PUT /verse/:verse_id/branding
```

## Authentication
Requires Bearer token with Administrator role for the specified verse:
```
Authorization: Bearer <jwt_token>
```

---

## Request

### URL Parameters
- `verse_id` (string, required): The ID of the verse to update branding for

### Request Body
```json
{
  "branding": {
    "logo_url": "https://example.com/logo.png",
    "primary_color": "#3B82F6",
    "color_name": "Primary Blue"
  }
}
```

### Branding Fields
| Field | Type | Required | Description | Default |
|-------|------|----------|-------------|---------|
| `logo_url` | string | No | URL to the verse's logo image | `null` |
| `primary_color` | string | No | Primary color in hex format (e.g., #3B82F6) | `#3B82F6` |
| `color_name` | string | No | Human-readable name for the color | `Primary Blue` |

### Partial Updates
You can update any combination of branding fields. Fields not provided will retain their current values.

---

## Response

### Success Response (200 OK)
```json
{
  "message": "Verse branding updated successfully",
  "verse": {
    "_id": "68c3e2d6f58c817ebed1ca74",
    "name": "BRYTE VERSE",
    "branding": {
      "logo_url": "https://example.com/logo.png",
      "primary_color": "#3B82F6",
      "color_name": "Primary Blue"
    }
  }
}
```

### Error Responses

#### 400 Bad Request - Validation Error
```json
{
  "errors": [
    {
      "msg": "Invalid input",
      "param": "branding.primary_color",
      "location": "body"
    }
  ]
}
```

#### 403 Forbidden - Access Denied
```json
{
  "message": "You do not have access to this verse"
}
```

```json
{
  "message": "Only Administrators can update verse branding"
}
```

#### 404 Not Found
```json
{
  "message": "Verse not found"
}
```

#### 500 Server Error
```json
{
  "message": "Server error updating verse branding",
  "error": "Error details"
}
```

---

## Usage Examples

### Update Logo Only
```bash
curl -X PUT http://localhost:3000/verse/68c3e2d6f58c817ebed1ca74/branding \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "branding": {
      "logo_url": "https://example.com/new-logo.png"
    }
  }'
```

### Update Primary Color
```bash
curl -X PUT http://localhost:3000/verse/68c3e2d6f58c817ebed1ca74/branding \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "branding": {
      "primary_color": "#10B981",
      "color_name": "Emerald Green"
    }
  }'
```

### Complete Branding Update
```bash
curl -X PUT http://localhost:3000/verse/68c3e2d6f58c817ebed1ca74/branding \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "branding": {
      "logo_url": "https://example.com/company-logo.png",
      "primary_color": "#8B5CF6",
      "color_name": "Purple"
    }
  }'
```

### Reset to Default Branding
```bash
curl -X PUT http://localhost:3000/verse/68c3e2d6f58c817ebed1ca74/branding \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "branding": {
      "logo_url": null,
      "primary_color": "#3B82F6",
      "color_name": "Primary Blue"
    }
  }'
```

---

## Frontend Integration

### React Example
```javascript
const updateVerseBranding = async (verseId, brandingData) => {
  try {
    const response = await fetch(`/verse/${verseId}/branding`, {
      method: 'PUT',
      headers: {
        'Authorization': `Bearer ${localStorage.getItem('token')}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ branding: brandingData })
    });
    
    if (!response.ok) {
      throw new Error('Failed to update branding');
    }
    
    const result = await response.json();
    return result.verse.branding;
  } catch (error) {
    console.error('Error updating branding:', error);
    throw error;
  }
};

// Usage
updateVerseBranding('68c3e2d6f58c817ebed1ca74', {
  logo_url: 'https://example.com/logo.png',
  primary_color: '#3B82F6',
  color_name: 'Primary Blue'
});
```

### Vue.js Example
```javascript
// In your Vue component
async updateBranding() {
  try {
    const response = await this.$http.put(`/verse/${this.verseId}/branding`, {
      branding: {
        logo_url: this.brandingForm.logo_url,
        primary_color: this.brandingForm.primary_color,
        color_name: this.brandingForm.color_name
      }
    });
    
    this.verse.branding = response.data.verse.branding;
    this.$toast.success('Branding updated successfully');
  } catch (error) {
    this.$toast.error('Failed to update branding');
  }
}
```

---

## Database Schema

### Verse Branding Schema
```javascript
{
  branding: {
    logo_url: String,        // URL to logo image
    primary_color: String,   // Hex color code (e.g., #3B82F6)
    color_name: String       // Human-readable color name
  }
}
```

### Activity Log Entry
When branding is updated, an activity log entry is created:
```javascript
{
  verse_id: ObjectId,
  user_id: ObjectId,
  action: 'update',
  resource_type: 'verse_branding',
  resource_id: ObjectId,
  timestamp: Date,
  details: {
    verse_name: String,
    updated_fields: {
      logo_url: { old: String, new: String },
      primary_color: { old: String, new: String },
      color_name: { old: String, new: String }
    }
  }
}
```

---

## Authorization

### Required Permissions
- **User Role**: Administrator
- **Verse Access**: Must be an active member of the verse
- **Authentication**: Valid JWT token required

### Authorization Flow
1. **Token Validation**: Verify JWT token
2. **Verse Access**: Check if user has access to the verse
3. **Role Check**: Verify user has Administrator role
4. **Update**: Allow branding update if all checks pass

---

## Validation

### Color Validation
- Primary color should be a valid hex color code (e.g., #3B82F6)
- Color name should be a descriptive string

### URL Validation
- Logo URL should be a valid URL format
- Can be null to remove logo

### Error Handling
- Invalid color codes return 400 Bad Request
- Missing authorization returns 403 Forbidden
- Non-existent verse returns 404 Not Found

---

## Best Practices

### Logo Guidelines
- Use high-resolution images (minimum 200x200px)
- Support common formats (PNG, JPG, SVG)
- Optimize file size for web delivery
- Use HTTPS URLs for security

### Color Guidelines
- Use accessible color combinations
- Test color contrast for readability
- Provide meaningful color names
- Consider dark/light theme compatibility

### Security
- Validate all input data
- Sanitize URLs to prevent XSS
- Log all branding changes for audit
- Restrict access to Administrators only

This API provides a clean, secure way to manage verse branding and white labeling functionality.
