const Role = require('../models/Role');
const UserRole = require('../models/UserRole');
const ActivityLog = require('../models/ActivityLog');
const { validationResult } = require('express-validator');
const Invitation = require('../models/Invitation');

// Get role by ID
exports.getRole = async (req, res) => {
  console.log("hello I am in get role by id")
  try {
    const { id } = req.params;
    const userId = req.user._id;

    const role = await Role.findById(id).populate('verse_id', 'name subdomain');
    
    if (!role) {
      return res.status(404).json({ message: 'Role not found' });
    }

    // Check if user has access to this verse
    const userRole = await UserRole.findOne({ 
      user_id: userId, 
      verse_id: role.verse_id,
      is_active: true 
    }).populate('role_id');

    // If user has a role in this verse, check permissions
    if (userRole && userRole.role_id) {
      console.log("user already has role ")
      const userRoleDoc = userRole.role_id;
      const canViewRoles = userRoleDoc.name === 'Administrator' || 
                          (userRoleDoc.permissions && userRoleDoc.permissions.manage_users);

      if (!canViewRoles) {
        return res.status(403).json({ message: 'You do not have permission to view roles' });
      }
    } else {
      console.log("user has no role ")
      // User doesn't have a role yet - check if they have an invitation for this verse
      const invitation = await Invitation.findOne({
        email: req.user.email,
        verse_id: role.verse_id,
        // is_accepted: false // Not yet accepted
      });

      if (!invitation) {
        return res.status(403).json({ message: 'You do not have access to this verse' });
      }
    }

    res.json(role);
  } catch (error) {
    console.error('Error fetching role:', error);
    res.status(500).json({ message: 'Server error fetching role', error: error.message });
  }
};

// List roles by verse_id
exports.listRolesByVerse = async (req, res) => {
  try {
    const { verse_id } = req.params;
    const { for_join = false } = req.query; // Query parameter to indicate this is for join process
    const userId = req.user._id;

    // Check if user has access to this verse
    const userRole = await UserRole.findOne({ 
      user_id: userId, 
      verse_id: verse_id,
      is_active: true 
    }).populate('role_id');

    // If user has a role in this verse, check permissions
    if (userRole && userRole.role_id) {
      const userRoleDoc = userRole.role_id;
      const canViewRoles = userRoleDoc.name === 'Administrator' || 
                          (userRoleDoc.permissions && userRoleDoc.permissions.manage_users);

      if (!canViewRoles && !for_join) {
        return res.status(403).json({ message: 'You do not have permission to view roles' });
      }
    } else {
      // User doesn't have a role yet - check if they have an invitation for this verse
      const invitation = await Invitation.findOne({
        email: req.user.email,
        verse_id: verse_id,
        is_accepted: false // Not yet accepted
      });

      if (!invitation && !for_join) {
        return res.status(403).json({ message: 'You do not have access to this verse' });
      }
    }

    const roles = await Role.find({ verse_id: verse_id })
      .populate('verse_id', 'name subdomain')
      .sort({ name: 1 });

    res.json({
      roles,
      count: roles.length,
      verse_id: verse_id
    });
  } catch (error) {
    console.error('Error listing roles by verse:', error);
    res.status(500).json({ message: 'Server error listing roles', error: error.message });
  }
};

// Create new role
exports.createRole = async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { verse_id, name, permissions, description, is_system_role = false } = req.body;
    const userId = req.user._id;

    // Check if user has access to this verse
    const userRole = await UserRole.findOne({ 
      user_id: userId, 
      verse_id: verse_id,
      is_active: true 
    }).populate('role_id');

    if (!userRole || !userRole.role_id) {
      return res.status(403).json({ message: 'You do not have access to this verse' });
    }

    // Check if user can create roles (Administrator or manage_users permission)
    const userRoleDoc = userRole.role_id;
    const canCreateRoles = userRoleDoc.name === 'Administrator' || 
                          (userRoleDoc.permissions && userRoleDoc.permissions.manage_users);

    if (!canCreateRoles) {
      return res.status(403).json({ message: 'You do not have permission to create roles' });
    }

    // Check if role name already exists for this verse
    const existingRole = await Role.findOne({ verse_id: verse_id, name: name });
    if (existingRole) {
      return res.status(400).json({ message: 'Role with this name already exists in this verse' });
    }

    // Validate role name
    const validRoleNames = ['Administrator', 'Editor', 'Expert'];
    if (!validRoleNames.includes(name)) {
      return res.status(400).json({ 
        message: 'Invalid role name. Must be one of: Administrator, Editor, Expert' 
      });
    }

    // Create the role
    const role = new Role({
      verse_id,
      name,
      permissions: permissions || {},
      description: description || '',
      is_system_role
    });

    await role.save();

    // Log the activity
    const activityLog = new ActivityLog({
      verse_id: verse_id,
      user_id: userId,
      action: 'create',
      resource_type: 'role',
      resource_id: role._id,
      timestamp: new Date(),
      details: {
        role_name: name,
        role_description: description,
        is_system_role: is_system_role,
        permissions: permissions
      }
    });
    await activityLog.save();

    res.status(201).json({
      message: 'Role created successfully',
      role: {
        _id: role._id,
        verse_id: role.verse_id,
        name: role.name,
        permissions: role.permissions,
        description: role.description,
        is_system_role: role.is_system_role,
        created_at: role.created_at
      }
    });
  } catch (error) {
    console.error('Error creating role:', error);
    res.status(500).json({ message: 'Server error creating role', error: error.message });
  }
};

// Update role
exports.updateRole = async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { id } = req.params;
    const { name, permissions, description, is_system_role } = req.body;
    const userId = req.user._id;

    const role = await Role.findById(id);
    if (!role) {
      return res.status(404).json({ message: 'Role not found' });
    }

    // Check if user has access to this verse
    const userRole = await UserRole.findOne({ 
      user_id: userId, 
      verse_id: role.verse_id,
      is_active: true 
    }).populate('role_id');

    if (!userRole || !userRole.role_id) {
      return res.status(403).json({ message: 'You do not have access to this verse' });
    }

    // Check if user can update roles (Administrator or manage_users permission)
    const userRoleDoc = userRole.role_id;
    const canUpdateRoles = userRoleDoc.name === 'Administrator' || 
                          (userRoleDoc.permissions && userRoleDoc.permissions.manage_users);

    if (!canUpdateRoles) {
      return res.status(403).json({ message: 'You do not have permission to update roles' });
    }

    // Prevent updating system roles unless user is Administrator
    if (role.is_system_role && userRoleDoc.name !== 'Administrator') {
      return res.status(403).json({ message: 'Only Administrators can update system roles' });
    }

    // Check if role name already exists for this verse (if name is being changed)
    if (name && name !== role.name) {
      const existingRole = await Role.findOne({ 
        verse_id: role.verse_id, 
        name: name,
        _id: { $ne: id }
      });
      if (existingRole) {
        return res.status(400).json({ message: 'Role with this name already exists in this verse' });
      }

      // Validate role name
      const validRoleNames = ['Administrator', 'Editor', 'Expert'];
      if (!validRoleNames.includes(name)) {
        return res.status(400).json({ 
          message: 'Invalid role name. Must be one of: Administrator, Editor, Expert' 
        });
      }
    }

    // Capture pre-update state for audit
    const before = role.toObject();

    // Update the role
    if (name !== undefined) role.name = name;
    if (permissions !== undefined) role.permissions = permissions;
    if (description !== undefined) role.description = description;
    if (is_system_role !== undefined) role.is_system_role = is_system_role;

    await role.save();

    // Log the activity
    const activityLog = new ActivityLog({
      verse_id: role.verse_id,
      user_id: userId,
      action: 'update',
      resource_type: 'role',
      resource_id: role._id,
      timestamp: new Date(),
      details: {
        role_name: role.name,
        updated_fields: {
          name: name !== undefined ? { old: before.name, new: role.name } : undefined,
          permissions: permissions !== undefined ? { old: before.permissions, new: role.permissions } : undefined,
          description: description !== undefined ? { old: before.description, new: role.description } : undefined,
          is_system_role: is_system_role !== undefined ? { old: before.is_system_role, new: role.is_system_role } : undefined
        }
      }
    });
    await activityLog.save();

    res.json({
      message: 'Role updated successfully',
      role: {
        _id: role._id,
        verse_id: role.verse_id,
        name: role.name,
        permissions: role.permissions,
        description: role.description,
        is_system_role: role.is_system_role,
        updated_at: role.updated_at
      }
    });
  } catch (error) {
    console.error('Error updating role:', error);
    res.status(500).json({ message: 'Server error updating role', error: error.message });
  }
};

// Delete role
exports.deleteRole = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user._id;

    const role = await Role.findById(id);
    if (!role) {
      return res.status(404).json({ message: 'Role not found' });
    }

    // Check if user has access to this verse
    const userRole = await UserRole.findOne({ 
      user_id: userId, 
      verse_id: role.verse_id,
      is_active: true 
    }).populate('role_id');

    if (!userRole || !userRole.role_id) {
      return res.status(403).json({ message: 'You do not have access to this verse' });
    }

    // Check if user can delete roles (Administrator or manage_users permission)
    const userRoleDoc = userRole.role_id;
    const canDeleteRoles = userRoleDoc.name === 'Administrator' || 
                          (userRoleDoc.permissions && userRoleDoc.permissions.manage_users);

    if (!canDeleteRoles) {
      return res.status(403).json({ message: 'You do not have permission to delete roles' });
    }

    // Prevent deleting system roles unless user is Administrator
    if (role.is_system_role && userRoleDoc.name !== 'Administrator') {
      return res.status(403).json({ message: 'Only Administrators can delete system roles' });
    }

    // Check if role is being used by any users
    const usersWithRole = await UserRole.countDocuments({ 
      role_id: id, 
      is_active: true 
    });

    if (usersWithRole > 0) {
      return res.status(400).json({ 
        message: `Cannot delete role. It is currently assigned to ${usersWithRole} user(s). Please reassign users before deleting.` 
      });
    }

    await Role.findByIdAndDelete(id);

    // Log the activity
    const activityLog = new ActivityLog({
      verse_id: role.verse_id,
      user_id: userId,
      action: 'delete',
      resource_type: 'role',
      resource_id: role._id,
      timestamp: new Date(),
      details: {
        role_name: role.name,
        deleted_role: {
          name: role.name,
          description: role.description,
          is_system_role: role.is_system_role,
          permissions: role.permissions
        }
      }
    });
    await activityLog.save();

    res.json({ message: 'Role deleted successfully' });
  } catch (error) {
    console.error('Error deleting role:', error);
    res.status(500).json({ message: 'Server error deleting role', error: error.message });
  }
};

// Get user's assigned role for a verse (for join process)
exports.getUserAssignedRole = async (req, res) => {
  try {
    const { verse_id } = req.params;
    const userId = req.user._id;

    // Check if user already has a role in this verse
    const userRole = await UserRole.findOne({ 
      user_id: userId, 
      verse_id: verse_id,
      is_active: true 
    }).populate('role_id');

    if (userRole && userRole.role_id) {
      // User already has a role - return it
      return res.json({
        role: userRole.role_id,
        status: 'already_joined',
        message: 'User already has a role in this verse'
      });
    }

    // User doesn't have a role yet - check if they have an invitation
   
    const invitation = await Invitation.findOne({
      email: req.user.email,
      verse_id: verse_id,
      is_accepted: false // Not yet accepted
    }).populate('role_id');

    if (!invitation) {
      return res.status(404).json({ message: 'No invitation found for this verse' });
    }

    // Check if invitation is expired
    if (invitation.expires_at && new Date() > invitation.expires_at) {
      return res.status(400).json({ message: 'Invitation has expired' });
    }

    res.json({
      role: invitation.role_id,
      invitation: {
        _id: invitation._id,
        token: invitation.token,
        expires_at: invitation.expires_at,
        first_name: invitation.first_name,
        last_name: invitation.last_name,
        position: invitation.position
      },
      status: 'invited',
      message: 'User has an active invitation for this verse'
    });
  } catch (error) {
    console.error('Error fetching user assigned role:', error);
    res.status(500).json({ message: 'Server error fetching assigned role', error: error.message });
  }
};

// Get available permissions (helper endpoint)
exports.getAvailablePermissions = async (req, res) => {
  try {
    const availablePermissions = {
      manage_users: 'Can invite, remove, and manage user roles',
      manage_assets: 'Can upload, delete, and manage assets',
      manage_channels: 'Can create, edit, and delete channels',
      manage_verse: 'Can update verse settings and configuration',
      invite_users: 'Can send invitations to new users',
      view_analytics: 'Can access verse analytics and reports',
      moderate_content: 'Can moderate and delete content',
      manage_branding: 'Can update verse branding and appearance'
    };

    res.json({
      permissions: availablePermissions,
      description: 'Available permissions for role assignment'
    });
  } catch (error) {
    console.error('Error fetching available permissions:', error);
    res.status(500).json({ message: 'Server error fetching permissions', error: error.message });
  }
};
