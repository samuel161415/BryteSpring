# Channel/Folder API Testing Guide

## Setup
1. Make sure your server is running on `http://localhost:3000`
2. You'll need a valid JWT token from login
3. You'll need a valid `verse_id` from your existing verse

## Test Scenarios

### 1. Create Root-Level Channel
**POST** `http://localhost:3000/channel/create`

```json
{
  "verse_id": "YOUR_VERSE_ID_HERE",
  "name": "Marketing",
  "type": "channel",
  "description": "Marketing materials and campaigns",
  "asset_types": ["image", "video", "document"],
  "is_public": true
}
```

**Headers:**
```
Authorization: Bearer YOUR_JWT_TOKEN_HERE
Content-Type: application/json
```

### 2. Create Subfolder in Existing Channel
**POST** `http://localhost:3000/channel/create`

```json
{
  "verse_id": "YOUR_VERSE_ID_HERE",
  "name": "Social Media Assets",
  "type": "folder",
  "parent_channel_id": "MARKETING_CHANNEL_ID_FROM_STEP_1",
  "description": "Social media specific assets",
  "asset_types": ["image", "video"],
  "is_public": true
}
```

### 3. Create Another Root Channel
**POST** `http://localhost:3000/channel/create`

```json
{
  "verse_id": "YOUR_VERSE_ID_HERE",
  "name": "Corporate Design",
  "type": "channel",
  "description": "Corporate branding and design assets",
  "asset_types": ["image", "document"],
  "is_public": true
}
```

### 4. Create Nested Folders
**POST** `http://localhost:3000/channel/create`

```json
{
  "verse_id": "YOUR_VERSE_ID_HERE",
  "name": "Logos",
  "type": "folder",
  "parent_channel_id": "CORPORATE_DESIGN_CHANNEL_ID_FROM_STEP_3",
  "description": "Company logos and variations",
  "asset_types": ["image"],
  "is_public": true
}
```

**POST** `http://localhost:3000/channel/create`

```json
{
  "verse_id": "YOUR_VERSE_ID_HERE",
  "name": "Color Palettes",
  "type": "folder",
  "parent_channel_id": "CORPORATE_DESIGN_CHANNEL_ID_FROM_STEP_3",
  "description": "Brand color schemes",
  "asset_types": ["image", "document"],
  "is_public": true
}
```

### 5. Get Channel Contents
**GET** `http://localhost:3000/channel/CORPORATE_DESIGN_CHANNEL_ID/contents`

**Headers:**
```
Authorization: Bearer YOUR_JWT_TOKEN_HERE
```

### 6. Get Complete Verse Structure
**GET** `http://localhost:3000/channel/verse/YOUR_VERSE_ID_HERE/structure`

**Headers:**
```
Authorization: Bearer YOUR_JWT_TOKEN_HERE
```

### 7. Update Channel/Folder
**PUT** `http://localhost:3000/channel/CHANNEL_ID_TO_UPDATE`

```json
{
  "name": "Updated Marketing Channel",
  "description": "Updated description for marketing materials",
  "asset_types": ["image", "video", "document", "audio"],
  "visibility": {
    "is_public": false
  }
}
```

**Headers:**
```
Authorization: Bearer YOUR_JWT_TOKEN_HERE
Content-Type: application/json
```

### 8. Test Error Cases

#### Try to create duplicate name
**POST** `http://localhost:3000/channel/create`

```json
{
  "verse_id": "YOUR_VERSE_ID_HERE",
  "name": "Marketing",
  "type": "channel",
  "description": "Duplicate name test"
}
```

#### Try to create folder without permission
Use a different user token without admin permissions.

#### Try to create public folder in private parent
First create a private channel, then try to create a public folder inside it.

### 9. Delete Channel/Folder
**DELETE** `http://localhost:3000/channel/CHANNEL_ID_TO_DELETE`

**Headers:**
```
Authorization: Bearer YOUR_JWT_TOKEN_HERE
```

## Expected Responses

### Successful Creation (201)
```json
{
  "message": "Channel created successfully",
  "channel": {
    "_id": "60f7b3b3b3b3b3b3b3b3b3b3",
    "name": "Marketing",
    "type": "channel",
    "description": "Marketing materials and campaigns",
    "parent_channel_id": null,
    "path": "Marketing",
    "asset_types": ["image", "video", "document"],
    "visibility": {
      "is_public": true,
      "inherited_from_parent": false
    },
    "folder_settings": {
      "allow_subfolders": true,
      "max_depth": 10
    },
    "created_by": "USER_ID",
    "created_at": "2023-07-20T10:30:00.000Z"
  }
}
```

### Channel Contents (200)
```json
{
  "channel": {
    "_id": "60f7b3b3b3b3b3b3b3b3b3b3",
    "name": "Corporate Design",
    "type": "channel",
    "description": "Corporate branding and design assets",
    "path": "Corporate Design",
    "asset_types": ["image", "document"],
    "visibility": {
      "is_public": true,
      "inherited_from_parent": false
    },
    "created_by": {
      "_id": "USER_ID",
      "first_name": "John",
      "last_name": "Doe"
    },
    "created_at": "2023-07-20T10:30:00.000Z",
    "children_count": 2
  },
  "contents": {
    "folders": [
      {
        "_id": "60f7b3b3b3b3b3b3b3b3b3b4",
        "name": "Logos",
        "type": "folder",
        "created_at": "2023-07-20T10:35:00.000Z"
      },
      {
        "_id": "60f7b3b3b3b3b3b3b3b3b3b5",
        "name": "Color Palettes",
        "type": "folder",
        "created_at": "2023-07-20T10:40:00.000Z"
      }
    ],
    "channels": [],
    "assets": []
  },
  "stats": {
    "total_folders": 2,
    "total_channels": 0,
    "total_assets": 0,
    "total_children": 2
  }
}
```

### Verse Structure (200)
```json
{
  "verse_id": "YOUR_VERSE_ID_HERE",
  "structure": [
    {
      "_id": "60f7b3b3b3b3b3b3b3b3b3b3",
      "name": "Marketing",
      "type": "channel",
      "children": [
        {
          "_id": "60f7b3b3b3b3b3b3b3b3b3b6",
          "name": "Social Media Assets",
          "type": "folder",
          "children": []
        }
      ]
    },
    {
      "_id": "60f7b3b3b3b3b3b3b3b3b3b4",
      "name": "Corporate Design",
      "type": "channel",
      "children": [
        {
          "_id": "60f7b3b3b3b3b3b3b3b3b3b7",
          "name": "Logos",
          "type": "folder",
          "children": []
        },
        {
          "_id": "60f7b3b3b3b3b3b3b3b3b3b8",
          "name": "Color Palettes",
          "type": "folder",
          "children": []
        }
      ]
    }
  ],
  "stats": {
    "total_channels": 2,
    "total_folders": 3,
    "total_items": 5
  }
}
```

## Error Responses

### Duplicate Name (400)
```json
{
  "message": "A channel with this name already exists in the selected location"
}
```

### Permission Denied (403)
```json
{
  "message": "You do not have permission to create folders in this verse"
}
```

### Parent Not Found (404)
```json
{
  "message": "Parent channel not found"
}
```

## Testing Workflow

1. **Start with root channels**: Create 2-3 root-level channels
2. **Create subfolders**: Add folders inside each channel
3. **Create nested folders**: Add subfolders inside existing folders
4. **Test content retrieval**: Use the contents and structure endpoints
5. **Test updates**: Modify channel/folder properties
6. **Test deletions**: Remove empty folders first, then channels
7. **Test error cases**: Try invalid operations

## Notes

- **Root channels**: Set `type: "channel"` and omit `parent_channel_id`
- **Folders**: Set `type: "folder"` and specify `parent_channel_id`
- **Asset types**: Use lowercase: `["image", "video", "document"]`
- **Visibility**: `is_public: true` for public, `false` for private
- **Channels vs Folders**: Channels are typically top-level containers, folders are for organization within channels
