const Verse = require('../models/Verse');
const User = require('../models/User');
const UserRole = require('../models/UserRole');
const Role = require('../models/Role');
const Invitation = require('../models/Invitation');
const Channel = require('../models/Channel');
const ActivityLog = require('../models/ActivityLog');

/**
 * Get dashboard data based on user role and verse access
 */
const getDashboard = async (req, res) => {
  try {
    const userId = req.user._id;
    const { verse_id } = req.params;

    // Get user's role in this verse
    const userRole = await UserRole.findOne({ 
      user_id: userId, 
      verse_id,
      is_active: true 
    }).populate('role_id');

    if (!userRole || !userRole.role_id) {
      return res.status(403).json({ message: 'You do not have access to this verse' });
    }

    // Get verse information
    const verse = await Verse.findById(verse_id)
      .populate('created_by', 'first_name last_name email')
      .populate('setup_completed_by', 'first_name last_name email');

    if (!verse) {
      return res.status(404).json({ message: 'Verse not found' });
    }

    // Get current user information
    const currentUser = await User.findById(userId).select('-password_hash');

    const role = userRole.role_id;
    const roleName = role.name;
    const permissions = role.permissions;

    // Build base dashboard response
    const dashboardData = {
      user: {
        _id: currentUser._id,
        first_name: currentUser.first_name,
        last_name: currentUser.last_name,
        email: currentUser.email,
        avatar_url: currentUser.avatar_url
      },
      verse: {
        _id: verse._id,
        name: verse.name,
        subdomain: verse.subdomain,
        organization_name: verse.organization_name,
        branding: verse.branding,
        is_setup_complete: verse.is_setup_complete,
        created_by: verse.created_by,
        setup_completed_by: verse.setup_completed_by
      },
      role: {
        _id: role._id,
        name: role.name,
        description: role.description,
        permissions: permissions
      },
      timestamp: new Date()
    };

    // Role-specific data
    if (roleName === 'Administrator') {
      // Admin dashboard - includes user management, invitations, settings
      dashboardData.adminData = await getAdminDashboardData(verse_id, userId);
    } else if (roleName === 'Editor') {
      // Editor dashboard - includes content management, approval workflows
      dashboardData.editorData = await getEditorDashboardData(verse_id, userId);
    } else if (roleName === 'Expert') {
      // Expert dashboard - includes asset management, content preparation
      dashboardData.expertData = await getExpertDashboardData(verse_id, userId);
    }

    // Common data for all roles
    dashboardData.commonData = await getCommonDashboardData(verse_id, userId);

    res.json({
      message: 'Dashboard data retrieved successfully',
      data: dashboardData
    });

  } catch (error) {
    console.error('Error fetching dashboard data:', error);
    res.status(500).json({ message: 'Server error fetching dashboard data', error: error.message });
  }
};

/**
 * Get admin-specific dashboard data
 */
async function getAdminDashboardData(verse_id, userId) {
  try {
    // Get pending invitations
    const pendingInvitations = await Invitation.find({
      verse_id,
      is_accepted: false,
      expires_at: { $gt: new Date() }
    })
    .populate('invited_by', 'first_name last_name email')
    .populate('role_id', 'name description')
    .sort({ created_at: -1 })
    .limit(10);

    // Get recent invitations (accepted)
    const recentInvitations = await Invitation.find({
      verse_id,
      is_accepted: true
    })
    .populate('invited_by', 'first_name last_name email')
    .populate('role_id', 'name description')
    .sort({ accepted_at: -1 })
    .limit(10);

    // Get verse members count
    const memberCount = await UserRole.countDocuments({
      verse_id,
      is_active: true
    });

    // Get recent activity logs
    const recentActivity = await ActivityLog.find({
      verse_id,
      action: { $in: ['create', 'update', 'delete', 'setup_complete'] }
    })
    .populate('user_id', 'first_name last_name email')
    .sort({ timestamp: -1 })
    .limit(20);

    // Get verse statistics
    const channelCount = await Channel.countDocuments({
      verse_id,
      is_active: { $ne: false }
    });

    return {
      invitations: {
        pending: pendingInvitations.map(inv => ({
          _id: inv._id,
          email: inv.email,
          first_name: inv.first_name,
          last_name: inv.last_name,
          position: inv.position,
          role: {
            _id: inv.role_id._id,
            name: inv.role_id.name,
            description: inv.role_id.description
          },
          invited_by: inv.invited_by,
          created_at: inv.created_at,
          expires_at: inv.expires_at,
          status: 'pending'
        })),
        recent: recentInvitations.map(inv => ({
          _id: inv._id,
          email: inv.email,
          first_name: inv.first_name,
          last_name: inv.last_name,
          position: inv.position,
          role: {
            _id: inv.role_id._id,
            name: inv.role_id.name,
            description: inv.role_id.description
          },
          invited_by: inv.invited_by,
          accepted_at: inv.accepted_at,
          status: 'accepted'
        }))
      },
      statistics: {
        total_members: memberCount,
        total_channels: channelCount,
        pending_invitations: pendingInvitations.length
      },
      recent_activity: recentActivity.map(activity => ({
        _id: activity._id,
        action: activity.action,
        resource_type: activity.resource_type,
        user: activity.user_id,
        timestamp: activity.timestamp,
        details: activity.details
      })),
      admin_actions: [
        { name: 'Einstellungen', description: 'Verse settings and configuration', endpoint: '/settings' },
        { name: 'Verknüpfungen', description: 'Shortcuts and links management', endpoint: '/shortcuts' },
        { name: 'Statistiken', description: 'Detailed analytics and reports', endpoint: '/statistics' },
        { name: 'Nutzer hinzufügen', description: 'Invite new users to the verse', endpoint: '/invite-user' }
      ]
    };
  } catch (error) {
    console.error('Error fetching admin dashboard data:', error);
    return null;
  }
}

/**
 * Get editor-specific dashboard data
 */
async function getEditorDashboardData(verse_id, userId) {
  try {
    // Get content pending approval
    const pendingApproval = await ActivityLog.find({
      verse_id,
      action: 'submit_for_approval',
      resource_type: 'asset'
    })
    .populate('user_id', 'first_name last_name email')
    .sort({ timestamp: -1 })
    .limit(10);

    // Get recently edited content
    const recentEdits = await ActivityLog.find({
      verse_id,
      action: 'update',
      resource_type: { $in: ['asset', 'channel'] }
    })
    .populate('user_id', 'first_name last_name email')
    .sort({ timestamp: -1 })
    .limit(10);

    // Get content statistics
    const contentStats = await ActivityLog.aggregate([
      {
        $match: {
          verse_id: verse_id,
          action: { $in: ['create', 'update'] },
          resource_type: 'asset'
        }
      },
      {
        $group: {
          _id: '$action',
          count: { $sum: 1 }
        }
      }
    ]);

    return {
      content_management: {
        pending_approval: pendingApproval.map(item => ({
          _id: item._id,
          resource_id: item.resource_id,
          user: item.user_id,
          timestamp: item.timestamp,
          details: item.details
        })),
        recent_edits: recentEdits.map(item => ({
          _id: item._id,
          resource_type: item.resource_type,
          resource_id: item.resource_id,
          user: item.user_id,
          timestamp: item.timestamp,
          details: item.details
        }))
      },
      statistics: {
        content_created: contentStats.find(stat => stat._id === 'create')?.count || 0,
        content_updated: contentStats.find(stat => stat._id === 'update')?.count || 0,
        pending_approvals: pendingApproval.length
      },
      editor_actions: [
        { name: 'Content verwalten', description: 'Manage and edit content', endpoint: '/content' },
        { name: 'Assets bearbeiten', description: 'Edit and enrich assets', endpoint: '/assets' },
        { name: 'Approval Workflow', description: 'Review and approve content', endpoint: '/approvals' },
        { name: 'Metadata verwalten', description: 'Manage content metadata', endpoint: '/metadata' }
      ]
    };
  } catch (error) {
    console.error('Error fetching editor dashboard data:', error);
    return null;
  }
}

/**
 * Get expert-specific dashboard data
 */
async function getExpertDashboardData(verse_id, userId) {
  try {
    // Get user's recent uploads
    const recentUploads = await ActivityLog.find({
      verse_id,
      user_id: userId,
      action: 'create',
      resource_type: 'asset'
    })
    .sort({ timestamp: -1 })
    .limit(10);

    // Get content awaiting approval
    const awaitingApproval = await ActivityLog.find({
      verse_id,
      user_id: userId,
      action: 'submit_for_approval'
    })
    .sort({ timestamp: -1 })
    .limit(10);

    // Get user's content statistics
    const userStats = await ActivityLog.aggregate([
      {
        $match: {
          verse_id: verse_id,
          user_id: userId,
          action: { $in: ['create', 'update', 'submit_for_approval'] }
        }
      },
      {
        $group: {
          _id: '$action',
          count: { $sum: 1 }
        }
      }
    ]);

    return {
      my_content: {
        recent_uploads: recentUploads.map(item => ({
          _id: item._id,
          resource_id: item.resource_id,
          timestamp: item.timestamp,
          details: item.details
        })),
        awaiting_approval: awaitingApproval.map(item => ({
          _id: item._id,
          resource_id: item.resource_id,
          timestamp: item.timestamp,
          details: item.details
        }))
      },
      statistics: {
        total_uploads: userStats.find(stat => stat._id === 'create')?.count || 0,
        total_updates: userStats.find(stat => stat._id === 'update')?.count || 0,
        pending_approvals: awaitingApproval.length
      },
      expert_actions: [
        { name: 'Assets hochladen', description: 'Upload new assets', endpoint: '/upload' },
        { name: 'Content bearbeiten', description: 'Edit and enrich assets', endpoint: '/edit' },
        { name: 'Assets sortieren', description: 'Sort and organize assets', endpoint: '/organize' },
        { name: 'Approval anfragen', description: 'Submit content for approval', endpoint: '/submit-approval' }
      ]
    };
  } catch (error) {
    console.error('Error fetching expert dashboard data:', error);
    return null;
  }
}

/**
 * Get common dashboard data for all roles
 */
async function getCommonDashboardData(verse_id, userId) {
  try {
    // Get root channels (main categories)
    const rootChannels = await Channel.find({
      verse_id,
      parent_channel_id: null,
      type: 'channel',
      is_active: { $ne: false }
    })
    .select('name description asset_types visibility created_at')
    .sort({ name: 1 });

    // Get recent search terms (mock data for now - you can implement actual search history)
    const recentSearches = [
      'Dirk Schroer',
      'Zitat zum Handeln',
      'Manifesto',
      'Leuchtturm Bild'
    ];

    // Get user's recent activity
    const userActivity = await ActivityLog.find({
      verse_id,
      user_id: userId
    })
    .sort({ timestamp: -1 })
    .limit(5);

    return {
      channels: rootChannels.map(channel => ({
        _id: channel._id,
        name: channel.name,
        description: channel.description,
        asset_types: channel.asset_types,
        visibility: channel.visibility,
        created_at: channel.created_at
      })),
      recent_searches: recentSearches,
      recent_activity: userActivity.map(activity => ({
        _id: activity._id,
        action: activity.action,
        resource_type: activity.resource_type,
        timestamp: activity.timestamp,
        details: activity.details
      }))
    };
  } catch (error) {
    console.error('Error fetching common dashboard data:', error);
    return null;
  }
}

/**
 * Get dashboard notifications/alerts
 */
const getDashboardNotifications = async (req, res) => {
  try {
    const userId = req.user._id;
    const { verse_id } = req.params;

    // Get user's role
    const userRole = await UserRole.findOne({ 
      user_id: userId, 
      verse_id,
      is_active: true 
    }).populate('role_id');

    if (!userRole || !userRole.role_id) {
      return res.status(403).json({ message: 'You do not have access to this verse' });
    }

    const notifications = [];

    // Admin notifications
    if (userRole.role_id.name === 'Administrator') {
      // Check for pending invitations
      const pendingCount = await Invitation.countDocuments({
        verse_id,
        is_accepted: false,
        expires_at: { $gt: new Date() }
      });

      if (pendingCount > 0) {
        notifications.push({
          type: 'invitation',
          message: `${pendingCount} invitation(s) pending acceptance`,
          priority: 'medium',
          action: '/invitations'
        });
      }
    }

    // Common notifications for all roles
    // Check for recent activity notifications
    const recentActivity = await ActivityLog.find({
      verse_id,
      timestamp: { $gte: new Date(Date.now() - 24 * 60 * 60 * 1000) }, // Last 24 hours
      user_id: { $ne: userId } // Exclude current user's activity
    }).limit(5);

    if (recentActivity.length > 0) {
      notifications.push({
        type: 'activity',
        message: `${recentActivity.length} new activity updates`,
        priority: 'low',
        action: '/activity'
      });
    }

    res.json({
      message: 'Notifications retrieved successfully',
      notifications,
      unread_count: notifications.length
    });

  } catch (error) {
    console.error('Error fetching notifications:', error);
    res.status(500).json({ message: 'Server error fetching notifications', error: error.message });
  }
};

module.exports = {
  getDashboard,
  getDashboardNotifications
};
