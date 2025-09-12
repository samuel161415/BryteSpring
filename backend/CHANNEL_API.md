# Channel/Folder Management API Documentation

## Overview
This API provides endpoints for creating and managing folders/channels within a verse. Folders can be nested and support different asset types and visibility settings.

## Base URL
All endpoints are prefixed with `/channel`

## Authentication
All endpoints require authentication via Bearer token in the Authorization header.

## Endpoints

### 1. Create Folder
**POST** `/channel/folders`

Creates a new folder within a verse. The folder can be created at the root level or as a subfolder of an existing channel/folder.

#### Request Body
```json
{
  "verse_id": "ObjectId",
  "name": "string",
  "parent_channel_id": "ObjectId (optional)",
  "asset_types": ["image", "video", "document"] (optional),
  "is_public": true (optional),
  "description": "string (optional)"
}
```

#### Request Body Details
- `verse_id` (required): MongoDB ObjectId of the verse
- `name` (required): Folder name (1-100 characters, alphanumeric + spaces, hyphens, underscores, dots)
- `parent_channel_id` (optional): MongoDB ObjectId of parent channel/folder
- `asset_types` (optional): Array of allowed asset types
  - Valid values: `image`, `video`, `document`, `audio`, `text`, `data`
- `is_public` (optional): Boolean for folder visibility (defaults to parent's visibility)
- `description` (optional): Folder description (max 500 characters)

#### Response (201 Created)
```json
{
  "message": "Folder created successfully",
  "folder": {
    "_id": "ObjectId",
    "name": "string",
    "type": "folder",
    "description": "string",
    "parent_channel_id": "ObjectId",
    "path": "string",
    "asset_types": ["image", "video"],
    "visibility": {
      "is_public": true,
      "inherited_from_parent": false
    },
    "folder_settings": {
      "allow_subfolders": true,
      "max_depth": 4
    },
    "created_by": "ObjectId",
    "created_at": "Date"
  }
}
```

#### Error Responses
- `400`: Validation errors, parent doesn't allow subfolders, or visibility conflicts
- `403`: Insufficient permissions
- `404`: Parent channel not found

---

### 2. Get Channel Contents
**GET** `/channel/:channel_id/contents`

Retrieves the contents of a specific channel/folder, including child folders, channels, and assets.

#### URL Parameters
- `channel_id`: MongoDB ObjectId of the channel/folder

#### Response (200 OK)
```json
{
  "channel": {
    "_id": "ObjectId",
    "name": "string",
    "type": "folder",
    "description": "string",
    "path": "string",
    "asset_types": ["image", "video"],
    "visibility": {
      "is_public": true,
      "inherited_from_parent": false
    },
    "created_by": {
      "_id": "ObjectId",
      "first_name": "string",
      "last_name": "string"
    },
    "created_at": "Date",
    "children_count": 3
  },
  "contents": {
    "folders": [
      {
        "_id": "ObjectId",
        "name": "string",
        "type": "folder",
        "created_at": "Date"
      }
    ],
    "channels": [
      {
        "_id": "ObjectId",
        "name": "string",
        "type": "channel",
        "created_at": "Date"
      }
    ],
    "assets": []
  },
  "stats": {
    "total_folders": 2,
    "total_channels": 1,
    "total_assets": 0,
    "total_children": 3
  }
}
```

#### Error Responses
- `403`: No access to verse
- `404`: Channel not found

---

### 3. Get Verse Channel Structure
**GET** `/channel/verse/:verse_id/structure`

Retrieves the complete hierarchical structure of all channels and folders for a verse.

#### URL Parameters
- `verse_id`: MongoDB ObjectId of the verse

#### Response (200 OK)
```json
{
  "verse_id": "ObjectId",
  "structure": [
    {
      "_id": "ObjectId",
      "name": "Corporate Design",
      "type": "channel",
      "children": [
        {
          "_id": "ObjectId",
          "name": "Logo",
          "type": "folder",
          "children": []
        },
        {
          "_id": "ObjectId",
          "name": "Colors",
          "type": "folder",
          "children": []
        }
      ]
    }
  ],
  "stats": {
    "total_channels": 1,
    "total_folders": 2,
    "total_items": 3
  }
}
```

#### Error Responses
- `403`: No access to verse

---

### 4. Update Channel/Folder
**PUT** `/channel/:id`

Updates an existing channel or folder.

#### URL Parameters
- `id`: MongoDB ObjectId of the channel/folder

#### Request Body
```json
{
  "name": "string (optional)",
  "description": "string (optional)",
  "asset_types": ["image", "video"] (optional),
  "visibility": {
    "is_public": true (optional)
  },
  "folder_settings": {
    "allow_subfolders": true (optional),
    "max_depth": 5 (optional)
  }
}
```

#### Response (200 OK)
```json
{
  "message": "Channel updated successfully",
  "channel": {
    "_id": "ObjectId",
    "name": "string",
    "type": "folder",
    "description": "string",
    "path": "string",
    "asset_types": ["image"],
    "visibility": {
      "is_public": false,
      "inherited_from_parent": true
    },
    "folder_settings": {
      "allow_subfolders": false,
      "max_depth": 3
    },
    "created_by": "ObjectId",
    "created_at": "Date",
    "updated_at": "Date"
  }
}
```

#### Error Responses
- `400`: Validation errors
- `403`: Insufficient permissions
- `404`: Channel not found

---

### 5. Delete Channel/Folder
**DELETE** `/channel/:id`

Soft deletes a channel or folder. Cannot delete folders that contain subfolders.

#### URL Parameters
- `id`: MongoDB ObjectId of the channel/folder

#### Response (200 OK)
```json
{
  "message": "Channel deleted successfully"
}
```

#### Error Responses
- `400`: Channel has subfolders
- `403`: Insufficient permissions
- `404`: Channel not found

---

## Business Rules

### Folder Creation
1. **Permissions**: User must have `manage_channels` permission or be an Administrator
2. **Naming**: Folder names must be unique within the same parent
3. **Visibility Inheritance**: 
   - If parent is private, child cannot be public
   - If parent is public, child can be either public or private
4. **Subfolders**: Parent must allow subfolders (`allow_subfolders: true`)
5. **Depth Limit**: Cannot exceed maximum depth (default: 5 levels)

### Asset Types
- `image`: Image files (JPG, PNG, GIF, etc.)
- `video`: Video files (MP4, AVI, MOV, etc.)
- `document`: Document files (PDF, DOC, XLS, etc.)
- `audio`: Audio files (MP3, WAV, etc.)
- `text`: Text files (TXT, MD, etc.)
- `data`: Data files (JSON, CSV, etc.)

### Path Building
- Root folders: Path = folder name
- Nested folders: Path = "parent_path/folder_name"
- Automatically updated when folder is moved or renamed

## Example Usage

### Creating a Root Folder
```bash
curl -X POST http://localhost:3000/channel/folders \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "verse_id": "60f7b3b3b3b3b3b3b3b3b3b3",
    "name": "Marketing Materials",
    "asset_types": ["image", "video", "document"],
    "is_public": true,
    "description": "All marketing-related assets"
  }'
```

### Creating a Subfolder
```bash
curl -X POST http://localhost:3000/channel/folders \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "verse_id": "60f7b3b3b3b3b3b3b3b3b3b3",
    "name": "Social Media",
    "parent_channel_id": "60f7b3b3b3b3b3b3b3b3b3b4",
    "asset_types": ["image", "video"],
    "is_public": true,
    "description": "Social media assets and campaigns"
  }'
```

### Getting Folder Contents
```bash
curl -X GET http://localhost:3000/channel/60f7b3b3b3b3b3b3b3b3b3b4/contents \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Getting Complete Structure
```bash
curl -X GET http://localhost:3000/channel/verse/60f7b3b3b3b3b3b3b3b3b3b3/structure \
  -H "Authorization: Bearer YOUR_TOKEN"
```
