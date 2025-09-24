const Invitation = require('../models/Invitation');

/**
 * Get pending invitations for a user
 * Returns invitations that are accepted but user hasn't joined the verse yet
 * @param {Object} user - The user object
 * @returns {Array} Array of pending invitations
 */
const getPendingInvitations = async (user) => {
  try {
    // Get pending invitations for this user (if any)
    // This includes invitations that are accepted but user hasn't joined the verse yet
    const pendingInvitations = await Invitation.find({
      email: user.email,
      is_accepted: true
    })
    .sort({ created_at: -1 });

    // Filter for verses that user hasn't joined yet
    const filteredPendingInvitations = pendingInvitations.filter(invitation => {
      if (!invitation.verse_id) return false;
      return !user.joined_verse.some(verseId => 
        verseId.toString() === invitation.verse_id._id.toString()
      );
    });

    return filteredPendingInvitations;
  } catch (error) {
    console.error('Error getting pending invitations:', error);
    return [];
  }
};

/**
 * Build user response with pending invitations
 * @param {Object} user - The user object
 * @param {string} token - JWT token (optional)
 * @returns {Object} User response object with pending invitations
 */
const buildUserResponse = async (user, token = null) => {
  const pendingInvitations = await getPendingInvitations(user);
  
  const response = {
    _id: user._id,
    first_name: user.first_name,
    last_name: user.last_name,
    position: user.position,
    email: user.email,
    avatar_url: user.avatar_url,
    joined_verse: user.joined_verse,
    is_active: user.is_active,
    created_at: user.created_at,
    pending_invitations: pendingInvitations
  };

  // Add token if provided
  if (token) {
    response.token = token;
  }

  return response;
};

module.exports = {
  getPendingInvitations,
  buildUserResponse
};
