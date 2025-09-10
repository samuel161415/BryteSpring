const Verse = require('../models/Verse');
const Channel = require('../models/Channel');
const User = require('../models/User');
const Role = require('../models/Role');
const UserRole = require('../models/UserRole');
const ActivityLog = require('../models/ActivityLog');
const Invitation = require('../models/Invitation');
const { v4: uuidv4 } = require('uuid');
const { validationResult } = require('express-validator');

// Create initial verse (for superadmin)
// Create initial verse (for superadmin)
exports.createInitialVerse = async (req, res) => {
  console.log("Creating initial verse");
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }
  
      const { name, admin_email, first_name, last_name, position } = req.body;
      const superadminId = req.user._id;
  
      // Check if superadmin
      const superadmin = await User.findById(superadminId);
      if (!superadmin || !superadmin.is_superadmin) {
        return res.status(403).json({ message: 'Only superadmins can create initial verses' });
      }
  
      // Optionally check if admin email already exists as a user (not required to proceed)
      const adminUser = await User.findOne({ email: admin_email.toLowerCase() });
  
      const verse = new Verse({
        name,
        admin_email: admin_email.toLowerCase(),
        created_by: adminUser ? adminUser._id : null,
        is_setup_complete: false
      });
  
      await verse.save();

      // Ensure Administrator role exists for this verse (idempotent)
      const adminRole = await Role.findOneAndUpdate(
        { verse_id: verse._id, name: 'Administrator' },
        {
          $setOnInsert: {
            permissions: {
              manage_users: true,
              manage_assets: true,
              manage_channels: true,
              manage_verse: true,
              invite_users: true
            },
            description: 'Full administrative access to the verse',
            is_system_role: true
          }
        },
        { new: true, upsert: true }
      );
  
      // Create an invitation for the admin (user may not exist yet)
      const token = uuidv4();
      const now = new Date();
      const expires_at = new Date(now.getTime() + 7 * 24 * 60 * 60 * 1000); // default 7 days

      const invitation = new Invitation({
        verse_id: verse._id,
        email: admin_email.toLowerCase(),
        role_id: adminRole._id,
        token,
        invited_by: superadminId,
        is_accepted: false,
        created_at: now,
        expires_at,
        first_name: first_name || '',
        last_name: last_name || '',
        position: position || ''
      });
      await invitation.save();
  
      // Log the activity
      const activityLog = new ActivityLog({
        verse_id: verse._id,
        user_id: superadminId,
        action: 'create',
        resource_type: 'verse',
        resource_id: verse._id,
        timestamp: new Date(),
        details: {
          verse_name: name,
          admin_email: admin_email,
          action: 'verse_created_by_superadmin',
          invitation_token: token
        }
      });
      await activityLog.save();
  
      res.status(201).json({
        message: 'Verse created successfully. Invitation created for admin.',
        verse: {
          _id: verse._id,
          name: verse.name,
          admin_email: verse.admin_email,
          created_by: verse.created_by,
          is_setup_complete: verse.is_setup_complete,
          created_at: verse.created_at
        },
        invitation: {
          _id: invitation._id,
          token: invitation.token,
          email: invitation.email,
          expires_at: invitation.expires_at,
          role_id: adminRole._id
        }
      });
    } catch (error) {
      console.error('Error creating initial verse:', error);
      res.status(500).json({ message: 'Server error creating verse', error: error.message });
    }
  };

// Complete verse setup (for admin)
exports.completeVerseSetup = async (req, res) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }
  
      const {
        verse_id,
        name,
        subdomain,
        organization_name,
        branding,
        initial_channels,
        is_neutral_view = false
      } = req.body;
  
      const adminId = req.user._id;
  
      // Find the verse
      const verse = await Verse.findById(verse_id);
      if (!verse) {
        return res.status(404).json({ message: 'Verse not found' });
      }
  
      // Check if user has permission to complete setup
      if (verse.created_by.toString() !== adminId.toString()) {
        return res.status(403).json({ message: 'Not authorized to complete setup for this verse' });
      }
  
      // Check if verse setup is already complete
      if (verse.is_setup_complete) {
        return res.status(400).json({ message: 'Verse setup is already complete' });
      }
  
      // Check if subdomain is available
      if (subdomain) {
        const existingVerse = await Verse.findOne({ 
          subdomain, 
          _id: { $ne: verse_id } 
        });
        if (existingVerse) {
          return res.status(400).json({ message: 'Subdomain already taken' });
        }
      }
  
      // Update verse with provided data
      verse.name = name || verse.name;
      if (typeof subdomain === 'string' && subdomain.trim().length > 0) {
        verse.subdomain = subdomain.trim();
      }
      if (typeof organization_name === 'string') {
        verse.organization_name = organization_name;
      }
  
      if (is_neutral_view) {
        // Reset to default branding
        verse.branding = {
          logo_url: null,
          primary_color: '#3B82F6',
          color_name: 'Primary Blue'
        };
      } else if (branding) {
        verse.branding = {
          logo_url: branding.logo_url,
          primary_color: branding.primary_color,
          color_name: branding.color_name
        };
      }
  
      // Create initial channels if provided
      let createdChannels = [];
      if (initial_channels && initial_channels.length > 0) {
        const channelPromises = initial_channels.map(async (channelData) => {
          const channel = new Channel({
            verse_id: verse._id,
            name: channelData.name,
            type: channelData.type || 'channel',
            description: channelData.description,
            settings: channelData.settings || {},
            permissions: channelData.permissions || {},
            created_by: adminId
          });
          return await channel.save();
        });
        
        createdChannels = await Promise.all(channelPromises);
      }
  
      // Mark setup as complete
      verse.is_setup_complete = true;
      verse.setup_completed_at = new Date();
      verse.setup_completed_by = adminId;
  
      await verse.save();
  
      // Log the activity
      const activityLog = new ActivityLog({
        verse_id: verse._id,
        user_id: adminId,
        action: 'setup_complete',
        resource_type: 'verse',
        resource_id: verse._id,
        timestamp: new Date(),
        details: {
          verse_name: verse.name,
          subdomain: verse.subdomain,
          is_neutral_view: is_neutral_view,
          channels_created: createdChannels.length
        }
      });
      await activityLog.save();
  
      res.status(200).json({
        message: 'Verse setup completed successfully',
        verse: {
          _id: verse._id,
          name: verse.name,
          subdomain: verse.subdomain,
          organization_name: verse.organization_name,
          branding: verse.branding,
          is_setup_complete: verse.is_setup_complete,
          setup_completed_at: verse.setup_completed_at
        },
        created_channels: createdChannels.map(ch => ({
          _id: ch._id,
          name: ch.name,
          type: ch.type
        }))
      });
  
    } catch (error) {
      console.error('Error completing verse setup:', error);
      res.status(500).json({ message: 'Server error completing verse setup', error: error.message });
    }
  };

// Get verse by IDID
exports.getVerse = async (req, res) => {
  try {
    const { id } = req.params;
    const verse = await Verse.findById(id)
      .populate('created_by', 'first_name last_name email')
      .populate('setup_completed_by', 'first_name last_name');

    if (!verse) {
      return res.status(404).json({ message: 'Verse not found' });
    }

    res.json(verse);
  } catch (error) {
    console.error('Error fetching verse:', error);
    res.status(500).json({ message: 'Server error fetching verse', error: error.message });
  }
};

// Update verse
exports.updateVerse = async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { id } = req.params;
    const updates = req.body;
    const userId = req.user._id;

    const verse = await Verse.findById(id);
    if (!verse) {
      return res.status(404).json({ message: 'Verse not found' });
    }

    // Authorization: superadmin OR user is member of verse and has Administrator role (or manage_verse)
    const user = await User.findById(userId);
    let isAuthorized = false;

    if (user && user.is_superadmin) {
      isAuthorized = true;
    } else if (user && Array.isArray(user.verse_ids)) {
      const isMember = user.verse_ids.map(v => v.toString()).includes(verse._id.toString());
      if (isMember) {
        const userRole = await UserRole.findOne({ user_id: userId, verse_id: verse._id }).populate('role_id');
        if (userRole && userRole.role_id) {
          const roleDoc = userRole.role_id;
          const isAdminByName = roleDoc.name === 'Administrator';
          const canManageVerse = !!(roleDoc.permissions && roleDoc.permissions.manage_verse);
          if (isAdminByName || canManageVerse) {
            isAuthorized = true;
          }
        }
      }
    }

    if (!isAuthorized) {
      return res.status(403).json({ message: 'Not authorized to update this verse' });
    }

    // Capture pre-update state for audit
    const before = verse.toObject();

    // Handle subdomain uniqueness check
    if (updates.subdomain && updates.subdomain !== verse.subdomain) {
      const existingVerse = await Verse.findOne({ 
        subdomain: updates.subdomain, 
        _id: { $ne: id } 
      });
      if (existingVerse) {
        return res.status(400).json({ message: 'Subdomain already taken' });
      }
    }

    Object.keys(updates).forEach(key => {
      if (key !== '_id' && key !== 'created_by' && key !== 'created_at') {
        verse[key] = updates[key];
      }
    });

    await verse.save();

    // Build changed fields map
    const changed = {};
    Object.keys(updates).forEach(key => {
      if (key !== '_id' && key !== 'created_by' && key !== 'created_at') {
        changed[key] = { old: before[key], new: verse[key] };
      }
    });

    // Log the update activity
    const updateLog = new ActivityLog({
      verse_id: verse._id,
      user_id: userId,
      action: 'update',
      resource_type: 'verse',
      resource_id: verse._id,
      timestamp: new Date(),
      details: {
        updated_fields: changed
      }
    });
    await updateLog.save();

    res.json({
      message: 'Verse updated successfully',
      verse
    });
  } catch (error) {
    console.error('Error updating verse:', error);
    res.status(500).json({ message: 'Server error updating verse', error: error.message });
  }
};

// Delete verse (soft delete)
exports.deleteVerse = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user._id;

    const verse = await Verse.findById(id);
    if (!verse) {
      return res.status(404).json({ message: 'Verse not found' });
    }

    // Only superadmin can delete verses
    const user = await User.findById(userId);
    if (!user.is_superadmin) {
      return res.status(403).json({ message: 'Only superadmins can delete verses' });
    }

    // Soft delete - mark as inactive instead of actual deletion
    verse.is_active = false;
    await verse.save();

    // Log the delete activity (soft delete)
    const deleteLog = new ActivityLog({
      verse_id: verse._id,
      user_id: userId,
      action: 'delete',
      resource_type: 'verse',
      resource_id: verse._id,
      timestamp: new Date(),
      details: {
        method: 'soft_delete',
        previous_is_active: true,
        new_is_active: false
      }
    });
    await deleteLog.save();

    res.json({ message: 'Verse deleted successfully' });
  } catch (error) {
    console.error('Error deleting verse:', error);
    res.status(500).json({ message: 'Server error deleting verse', error: error.message });
  }
};

// List all verses (for superadmin)
exports.listVerses = async (req, res) => {
  try {
    const rawPage = req.query.page;
    const rawLimit = req.query.limit;
    const page = Math.max(parseInt(rawPage || '1', 10), 1);
    const limit = Math.min(Math.max(parseInt(rawLimit || '10', 10), 1), 100);
    const skip = (page - 1) * limit;

    const search = req.query.search;

    let query = { is_active: true };
    if (search) {
      query.$or = [
        { name: { $regex: search, $options: 'i' } },
        { subdomain: { $regex: search, $options: 'i' } },
        { organization_name: { $regex: search, $options: 'i' } }
      ];
    }

    const verses = await Verse.find(query)
      .populate('created_by', 'first_name last_name email')
      .sort({ created_at: -1 })
      .skip(skip)
      .limit(limit);

    const total = await Verse.countDocuments(query);

    res.json({
      verses,
      pagination: {
        page,
        limit,
        total,
        pages: Math.ceil(total / limit)
      }
    });
  } catch (error) {
    console.error('Error listing verses:', error);
    res.status(500).json({ message: 'Server error listing verses', error: error.message });
  }
};