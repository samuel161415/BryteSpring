const Channel = require('../models/Channel');
const Verse = require('../models/Verse');
const User = require('../models/User');
const UserRole = require('../models/UserRole');
const Role = require('../models/Role');
const ActivityLog = require('../models/ActivityLog');
const { validationResult } = require('express-validator');

// Debug endpoint to test role population
exports.debugUserRole = async (req, res) => {
  try {
    const userId = req.user._id;
    const { verse_id } = req.params;

    console.log('Debug - User ID:', userId);
    console.log('Debug - Verse ID:', verse_id);

    // Test 1: Find UserRole without population
    const userRoleWithoutPopulate = await UserRole.findOne({ 
      user_id: userId, 
      verse_id,
      is_active: true 
    });

    console.log('Debug - UserRole without populate:', userRoleWithoutPopulate);

    // Test 2: Find UserRole with population
    const userRoleWithPopulate = await UserRole.findOne({ 
      user_id: userId, 
      verse_id,
      is_active: true 
    }).populate('role_id');

    console.log('Debug - UserRole with populate:', userRoleWithPopulate);
    console.log('Debug - Role data:', userRoleWithPopulate && userRoleWithPopulate.role_id ? {
      name: userRoleWithPopulate.role_id.name,
      permissions: userRoleWithPopulate.role_id.permissions
    } : 'No role data');

    // Test 3: Find Role directly
    if (userRoleWithoutPopulate && userRoleWithoutPopulate.role_id) {
      const directRole = await Role.findById(userRoleWithoutPopulate.role_id);
      console.log('Debug - Direct Role lookup:', directRole);
    }

    res.json({
      message: 'Debug information logged to console',
      userRoleWithoutPopulate: userRoleWithoutPopulate,
      userRoleWithPopulate: userRoleWithPopulate,
      roleData: userRoleWithPopulate && userRoleWithPopulate.role_id ? {
        name: userRoleWithPopulate.role_id.name,
        permissions: userRoleWithPopulate.role_id.permissions
      } : null
    });

  } catch (error) {
    console.error('Debug error:', error);
    res.status(500).json({ message: 'Debug error', error: error.message });
  }
};

// Create a new folder/channel
exports.createChannel = async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const {
      verse_id,
      name,
      parent_channel_id,
      type = 'folder', // Default to folder, can be 'channel' or 'folder'
      asset_types = [],
      is_public,
      description
    } = req.body;

    const userId = req.user._id;

    // Verify user has permission to create folders in this verse
    const userRole = await UserRole.findOne({ 
      user_id: userId, 
      verse_id,
      is_active: true 
    }).populate('role_id');

    console.log('UserRole found:', userRole ? 'Yes' : 'No');
    console.log('Role populated:', userRole && userRole.role_id ? 'Yes' : 'No');
    console.log('Role data:', userRole && userRole.role_id ? {
      name: userRole.role_id.name,
      permissions: userRole.role_id.permissions
    } : 'No role data');

    if (!userRole || !userRole.role_id) {
      return res.status(403).json({ message: 'You do not have permission to create folders in this verse' });
    }

    // Check if user has manage_channels permission or is Administrator
    const role = userRole.role_id;
    
    // Additional validation to ensure role is properly populated
    if (!role.name) {
      console.error('Role not properly populated:', role);
      return res.status(500).json({ message: 'Role data not properly loaded' });
    }
    
    const hasPermission = role.name === 'Administrator' || 
                         (role.permissions && role.permissions.manage_channels);
    
    if (!hasPermission) {
      return res.status(403).json({ message: 'Insufficient permissions to create folders' });
    }

    // Check if parent channel exists and belongs to the same verse
    let parentChannel = null;
    let parentVisibility = { is_public: true, inherited_from_parent: false };

    // For root channels, parent_channel_id should be null or not provided
    if (parent_channel_id) {
      parentChannel = await Channel.findOne({ 
        _id: parent_channel_id, 
        verse_id,
        type: { $in: ['channel', 'folder'] }
      });

      if (!parentChannel) {
        return res.status(404).json({ message: 'Parent channel not found' });
      }

      // Get parent's visibility settings
      parentVisibility = {
        is_public: parentChannel.visibility.is_public,
        inherited_from_parent: parentChannel.visibility.is_public
      };

      // Check if parent allows subfolders (only for folders, channels can always have children)
      if (type === 'folder' && !parentChannel.folder_settings.allow_subfolders) {
        return res.status(400).json({ message: 'Parent channel does not allow subfolders' });
      }
    } else if (type === 'channel') {
      // For root channels, no parent validation needed
      parentChannel = null;
    }

    // Check if a channel/folder with the same name already exists in the same parent
    const existingChannel = await Channel.findOne({
      verse_id,
      parent_channel_id: parent_channel_id || null,
      name: { $regex: new RegExp(`^${name}$`, 'i') },
      type: type
    });

    if (existingChannel) {
      return res.status(400).json({ message: `A ${type} with this name already exists in the selected location` });
    }

    // Determine visibility settings
    let folderVisibility;
    if (is_public !== undefined) {
      // If parent is private, child cannot be public
      if (!parentVisibility.is_public && is_public) {
        return res.status(400).json({ 
          message: 'Cannot create public folder in a private parent. Private folders inherit privacy from their parent.' 
        });
      }
      folderVisibility = {
        is_public: is_public,
        inherited_from_parent: !parentVisibility.is_public && !is_public
      };
    } else {
      // Default to parent's visibility
      folderVisibility = {
        is_public: parentVisibility.is_public,
        inherited_from_parent: parentVisibility.is_public
      };
    }

    // Build the channel/folder path
    let channelPath = name;
    if (parentChannel) {
      const parentPath = await parentChannel.buildPath();
      channelPath = `${parentPath}/${name}`;
    }

    // Create the channel/folder
    const channel = new Channel({
      verse_id,
      name,
      type: type, // 'channel' or 'folder'
      description,
      parent_channel_id: parent_channel_id || null,
      path: channelPath,
      asset_types: asset_types.map(assetType => assetType.toLowerCase()),
      visibility: folderVisibility,
      created_by: userId,
      folder_settings: type === 'folder' ? {
        allow_subfolders: true,
        max_depth: parentChannel ? Math.max(1, parentChannel.folder_settings.max_depth - 1) : 5
      } : {
        allow_subfolders: true, // Channels can always have children
        max_depth: 10 // Channels have higher depth limit
      }
    });

    await channel.save();

    // Populate the created_by field for the response
    await channel.populate('created_by', 'first_name last_name');

    // Log the activity
    const activityLog = new ActivityLog({
      verse_id,
      user_id: userId,
      action: 'create',
      resource_type: type,
      resource_id: channel._id,
      timestamp: new Date(),
      details: {
        channel_name: name,
        channel_type: type,
        parent_channel_id: parent_channel_id || null,
        asset_types,
        visibility: folderVisibility,
        path: channelPath
      }
    });
    await activityLog.save();

    res.status(201).json({
      message: `${type === 'channel' ? 'Channel' : 'Folder'} created successfully`,
      channel: {
        _id: channel._id,
        name: channel.name,
        type: channel.type,
        description: channel.description,
        parent_channel_id: channel.parent_channel_id,
        path: channel.path,
        asset_types: channel.asset_types,
        visibility: channel.visibility,
        folder_settings: channel.folder_settings,
        created_by: channel.created_by,
        created_at: channel.created_at
      }
    });

  } catch (error) {
    console.error('Error creating channel:', error);
    res.status(500).json({ message: 'Server error creating channel', error: error.message });
  }
};

// Get folder/channel contents (children and assets)
exports.getChannelContents = async (req, res) => {
  try {
    const { channel_id } = req.params;
    const userId = req.user._id;

    // Find the channel
    const channel = await Channel.findById(channel_id)
      .populate('created_by', 'first_name last_name email');

    if (!channel) {
      return res.status(404).json({ message: 'Channel not found' });
    }

    // Check if user has access to this verse
    const userRole = await UserRole.findOne({ 
      user_id: userId, 
      verse_id: channel.verse_id,
      is_active: true 
    });

    if (!userRole) {
      return res.status(403).json({ message: 'You do not have access to this verse' });
    }

    // Get child folders/channels
    const childChannels = await Channel.find({
      parent_channel_id: channel_id,
      verse_id: channel.verse_id
    })
    .populate('created_by', 'first_name last_name')
    .sort({ type: 1, name: 1 }); // Channels first, then folders, alphabetically

    // Get direct assets (if you have an Asset model, you would query it here)
    // For now, we'll return empty array as placeholder
    const directAssets = [];

    // Build response with folder structure
    const response = {
      channel: {
        _id: channel._id,
        name: channel.name,
        type: channel.type,
        description: channel.description,
        path: channel.path,
        asset_types: channel.asset_types,
        visibility: channel.visibility,
        created_by: channel.created_by,
        created_at: channel.created_at,
        children_count: childChannels.length
      },
      contents: {
        folders: childChannels.filter(child => child.type === 'folder'),
        channels: childChannels.filter(child => child.type === 'channel'),
        assets: directAssets
      },
      stats: {
        total_folders: childChannels.filter(child => child.type === 'folder').length,
        total_channels: childChannels.filter(child => child.type === 'channel').length,
        total_assets: directAssets.length,
        total_children: childChannels.length
      }
    };

    res.json(response);

  } catch (error) {
    console.error('Error fetching channel contents:', error);
    res.status(500).json({ message: 'Server error fetching channel contents', error: error.message });
  }
};

// Get all channels/folders for a verse (hierarchical structure)
exports.getVerseChannelStructure = async (req, res) => {
  try {
    const { verse_id } = req.params;
    const userId = req.user._id;

    // Check if user has access to this verse
    const userRole = await UserRole.findOne({ 
      user_id: userId, 
      verse_id,
      is_active: true 
    });

    if (!userRole) {
      return res.status(403).json({ message: 'You do not have access to this verse' });
    }

    // Get all channels and folders for this verse
    const channels = await Channel.find({ verse_id })
      .populate('created_by', 'first_name last_name')
      .sort({ type: 1, name: 1 });

    // Build hierarchical structure
    const channelMap = new Map();
    const rootChannels = [];

    // First pass: create map and identify root channels
    channels.forEach(channel => {
      channelMap.set(channel._id.toString(), {
        ...channel.toObject(),
        children: []
      });
    });

    // Second pass: build hierarchy
    channels.forEach(channel => {
      const channelObj = channelMap.get(channel._id.toString());
      if (channel.parent_channel_id) {
        const parent = channelMap.get(channel.parent_channel_id.toString());
        if (parent) {
          parent.children.push(channelObj);
        }
      } else {
        rootChannels.push(channelObj);
      }
    });

    res.json({
      verse_id,
      structure: rootChannels,
      stats: {
        total_channels: channels.filter(c => c.type === 'channel').length,
        total_folders: channels.filter(c => c.type === 'folder').length,
        total_items: channels.length
      }
    });

  } catch (error) {
    console.error('Error fetching verse channel structure:', error);
    res.status(500).json({ message: 'Server error fetching channel structure', error: error.message });
  }
};

// Update folder/channel
exports.updateChannel = async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { id } = req.params;
    const updates = req.body;
    const userId = req.user._id;

    const channel = await Channel.findById(id);
    if (!channel) {
      return res.status(404).json({ message: 'Channel not found' });
    }

    // Check permissions
    const userRole = await UserRole.findOne({ 
      user_id: userId, 
      verse_id: channel.verse_id,
      is_active: true 
    }).populate('role_id');

    if (!userRole) {
      return res.status(403).json({ message: 'You do not have permission to update this channel' });
    }

    const role = userRole.role_id;
    const hasPermission = role.name === 'Administrator' || 
                         (role.permissions && role.permissions.manage_channels);
    
    if (!hasPermission) {
      return res.status(403).json({ message: 'Insufficient permissions to update channels' });
    }

    // Capture pre-update state for audit
    const before = channel.toObject();

    // Update allowed fields
    const allowedUpdates = ['name', 'description', 'asset_types', 'visibility', 'folder_settings'];
    allowedUpdates.forEach(field => {
      if (updates[field] !== undefined) {
        channel[field] = updates[field];
      }
    });

    // Rebuild path if name or parent changed
    if (updates.name || updates.parent_channel_id) {
      const newPath = await channel.buildPath();
      channel.path = newPath;
    }

    await channel.save();

    // Build changed fields map
    const changed = {};
    allowedUpdates.forEach(field => {
      if (updates[field] !== undefined) {
        changed[field] = { old: before[field], new: channel[field] };
      }
    });

    // Log the update activity
    const updateLog = new ActivityLog({
      verse_id: channel.verse_id,
      user_id: userId,
      action: 'update',
      resource_type: channel.type === 'folder' ? 'folder' : 'channel',
      resource_id: channel._id,
      timestamp: new Date(),
      details: {
        updated_fields: changed
      }
    });
    await updateLog.save();

    res.json({
      message: 'Channel updated successfully',
      channel
    });

  } catch (error) {
    console.error('Error updating channel:', error);
    res.status(500).json({ message: 'Server error updating channel', error: error.message });
  }
};

// Delete folder/channel (soft delete)
exports.deleteChannel = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user._id;

    const channel = await Channel.findById(id);
    if (!channel) {
      return res.status(404).json({ message: 'Channel not found' });
    }

    // Check permissions
    const userRole = await UserRole.findOne({ 
      user_id: userId, 
      verse_id: channel.verse_id,
      is_active: true 
    }).populate('role_id');

    if (!userRole) {
      return res.status(403).json({ message: 'You do not have permission to delete this channel' });
    }

    const role = userRole.role_id;
    const hasPermission = role.name === 'Administrator' || 
                         (role.permissions && role.permissions.manage_channels);
    
    if (!hasPermission) {
      return res.status(403).json({ message: 'Insufficient permissions to delete channels' });
    }

    // Check if channel has children
    const childrenCount = await Channel.countDocuments({ parent_channel_id: id });
    if (childrenCount > 0) {
      return res.status(400).json({ 
        message: 'Cannot delete channel with subfolders. Please delete or move subfolders first.' 
      });
    }

    // Soft delete - add a deleted flag or timestamp
    channel.deleted_at = new Date();
    channel.is_active = false;
    await channel.save();

    // Log the delete activity
    const deleteLog = new ActivityLog({
      verse_id: channel.verse_id,
      user_id: userId,
      action: 'delete',
      resource_type: channel.type === 'folder' ? 'folder' : 'channel',
      resource_id: channel._id,
      timestamp: new Date(),
      details: {
        channel_name: channel.name,
        channel_type: channel.type,
        method: 'soft_delete'
      }
    });
    await deleteLog.save();

    res.json({ message: 'Channel deleted successfully' });

  } catch (error) {
    console.error('Error deleting channel:', error);
    res.status(500).json({ message: 'Server error deleting channel', error: error.message });
  }
};
