const axios = require('axios');

// CleverReach configuration
const CLEVERREACH_BASE_URL = 'https://rest.cleverreach.com/v3';
const CLIENT_ID = process.env.CLEVERREACH_CLIENT_ID || 'fJJZuUT29g';
const CLIENT_SECRET = process.env.CLEVERREACH_CLIENT_SECRET || 'akjRdeKHfCzJyh0TeUq8CTs4R3WXRpAO';
const GROUP_ID = process.env.CLEVERREACH_GROUP_ID; // You'll need to create a group and set this
const FROM_EMAIL = process.env.EMAIL_FROM || 'samuelnegalign19@gmail.com';
const FROM_NAME = process.env.FROM_NAME || 'BRYTE VERSE';

// Store access token (in production, you might want to store this in a database)
let accessToken = null;
let tokenExpiry = null;

/**
 * Get OAuth access token from CleverReach
 */
async function getAccessToken() {
  try {
    // Check if we have a valid token
    if (accessToken && tokenExpiry && new Date() < tokenExpiry) {
      return accessToken;
    }

    // Get new token
    const response = await axios.post('https://rest.cleverreach.com/oauth/token.php', {
      grant_type: 'client_credentials',
      client_id: CLIENT_ID,
      client_secret: CLIENT_SECRET
    }, {
      headers: {
        'Content-Type': 'application/json'
      }
    });

    accessToken = response.data.access_token;
    const expiresIn = response.data.expires_in || 3600; // Default to 1 hour
    tokenExpiry = new Date(Date.now() + (expiresIn - 60) * 1000); // Subtract 60 seconds for safety

    console.log('CleverReach access token obtained successfully');
    return accessToken;
  } catch (error) {
    console.error('Failed to get CleverReach access token:', error.response?.data || error.message);
    throw new Error('Failed to authenticate with CleverReach');
  }
}

/**
 * Build invitation link
 */
function buildInviteLink({ token, subdomain }) {
  const baseUrl = process.env.INVITE_BASE_URL || 'http://localhost:3000';
  const url = new URL(baseUrl);
  url.pathname = '/invite';
  url.searchParams.set('token', token);
  if (subdomain) {
    url.searchParams.set('subdomain', String(subdomain));
  }
  return url.toString();
}

/**
 * Create or get CleverReach group for invitations
 */
async function ensureInvitationGroup() {
  try {
    const token = await getAccessToken();
    
    // Try to find existing invitation group
    const groupsResponse = await axios.get(`${CLEVERREACH_BASE_URL}/groups.json`, {
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      }
    });

    // Look for existing invitation group
    const invitationGroup = groupsResponse.data.find(group => 
      group.name === 'BRYTE VERSE Invitations'
    );

    if (invitationGroup) {
      return invitationGroup.id;
    }

    // Create new group if not found
    const createResponse = await axios.post(`${CLEVERREACH_BASE_URL}/groups.json`, {
      name: 'BRYTE VERSE Invitations',
      description: 'Group for verse invitation emails'
    }, {
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      }
    });

    console.log('Created CleverReach invitation group:', createResponse.data.id);
    return createResponse.data.id;
  } catch (error) {
    console.error('Failed to ensure invitation group:', error.response?.data || error.message);
    throw error;
  }
}

/**
 * Send invitation email using CleverReach
 */
async function sendInvitationEmail({ to, verseName, roleName, token, subdomain, fromEmail }) {
  try {
    const token_auth = await getAccessToken();
    const groupId = await ensureInvitationGroup();
    console.log("groupId", groupId);
    console.log("token_auth", token_auth);
    
    const inviteLink = buildInviteLink({ token, subdomain });
    const subject = `Invitation to join ${verseName || 'a verse'} as ${roleName || 'member'}`;
    
    // HTML content for the invitation email
    const htmlContent = `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Invitation to Join ${verseName || 'BRYTE VERSE'}</title>
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; margin: 0; padding: 20px; }
          .container { max-width: 600px; margin: 0 auto; background: #ffffff; border-radius: 8px; overflow: hidden; }
          .header { background: #3B82F6; color: white; padding: 30px 20px; text-align: center; }
          .content { padding: 30px 20px; }
          .button { display: inline-block; background: #3B82F6; color: white; padding: 15px 30px; text-decoration: none; border-radius: 5px; font-weight: bold; margin: 20px 0; }
          .footer { background: #f8f9fa; padding: 20px; text-align: center; color: #666; font-size: 14px; }
          .verse-info { background: #f0f9ff; padding: 15px; border-radius: 5px; margin: 20px 0; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>BRYTE VERSE</h1>
            <h2>You are invited!</h2>
          </div>
          
          <div class="content">
            <p>Hello,</p>
            
            <p>You have been invited to join${verseName ? ` <strong>${verseName}</strong>` : ' a verse'} as <strong>${roleName || 'member'}</strong>.</p>
            
            ${subdomain ? `
            <div class="verse-info">
              <strong>Verse Details:</strong><br>
              Subdomain: ${subdomain}
            </div>
            ` : ''}
            
            <p>Please click the button below to accept your invitation and create your account:</p>
            
            <div style="text-align: center;">
              <a href="${inviteLink}" class="button">Accept Invitation</a>
            </div>
            
            <p>If the button doesn't work, you can copy and paste this link into your browser:</p>
            <p style="word-break: break-all; background: #f8f9fa; padding: 10px; border-radius: 4px; font-family: monospace;">
              ${inviteLink}
            </p>
            
            <p>This invitation will expire in 7 days.</p>
          </div>
          
          <div class="footer">
            <p>This invitation was sent from BRYTE VERSE. If you didn't expect this email, please ignore it.</p>
          </div>
        </div>
      </body>
      </html>
    `;

    // First, add recipient to the group
    try {
      await axios.post(
        `${CLEVERREACH_BASE_URL}/groups.json/${groupId}/receivers`,
        {
          email: to.toLowerCase(),
          activated: true,
          attributes: {
            firstname: '', // We don't have this yet
            lastname: '', // We don't have this yet
            verse_name: verseName || '',
            role_name: roleName || '',
            invitation_token: token
          }
        },
        {
          headers: {
            'Authorization': `Bearer ${token_auth}`,
            'Content-Type': 'application/json'
          }
        }
      );
      console.log(`Added recipient ${to} to CleverReach group ${groupId}`);
    } catch (error) {
      // Recipient might already exist, continue with sending
      if (error.response?.status !== 409) { // 409 = Conflict (already exists)
        console.warn('Failed to add recipient to group:', error.response?.data || error.message);
      }
    }

    // Use the working CleverReach approach: Create mailing and send it
    try {
      console.log('Creating CleverReach mailing...');
      
      // Step 1: Create a mailing
      const mailingResponse = await axios.post(
        `${CLEVERREACH_BASE_URL}/mailings.json`,
        {
          name: `Invitation: ${verseName || 'BRYTE VERSE'} - ${roleName || 'member'}`,
          subject: subject,
          html_body: htmlContent,
          sender_email: fromEmail || FROM_EMAIL, // Fixed: use sender_email instead of from_email
          sender_name: FROM_NAME,
          reply_to: fromEmail || FROM_EMAIL,
          group_id: parseInt(groupId)
        },
        {
          headers: {
            'Authorization': `Bearer ${token_auth}`,
            'Content-Type': 'application/json'
          }
        }
      );

      console.log('CleverReach mailing created:', mailingResponse.data);
      const mailingId = mailingResponse.data.id;

      // Step 2: Send the mailing to specific recipients
      const sendResponse = await axios.post(
        `${CLEVERREACH_BASE_URL}/mailings.json/${mailingId}/send`,
        {
          group_id: parseInt(groupId),
          recipients: [to.toLowerCase()]
        },
        {
          headers: {
            'Authorization': `Bearer ${token_auth}`,
            'Content-Type': 'application/json'
          }
        }
      );

      console.log('CleverReach email sent successfully:', sendResponse.data);
      return { ok: true, type: 'mailing', mailingId: mailingId };

    } catch (error) {
      console.error('Failed to send CleverReach email:', error.response?.data || error.message);
      
      // If mailing approach fails, try alternative: Send to group directly
      try {
        console.log('Trying alternative approach: Send to group...');
        
        const alternativeResponse = await axios.post(
          `${CLEVERREACH_BASE_URL}/mailings.json`,
          {
            name: `Invitation: ${verseName || 'BRYTE VERSE'} - ${roleName || 'member'}`,
            subject: subject,
            html_body: htmlContent,
            sender_email: fromEmail || FROM_EMAIL, // Fixed: use sender_email instead of from_email
            sender_name: FROM_NAME,
            reply_to: fromEmail || FROM_EMAIL,
            group_id: parseInt(groupId),
            send_settings: {
              send_time: 'immediate'
            }
          },
          {
            headers: {
              'Authorization': `Bearer ${token_auth}`,
              'Content-Type': 'application/json'
            }
          }
        );

        console.log('CleverReach alternative email sent successfully:', alternativeResponse.data);
        return { ok: true, type: 'alternative', mailingId: alternativeResponse.data.id };

      } catch (error2) {
        console.error('Alternative approach also failed:', error2.response?.data || error2.message);
        throw error2;
      }
    }

  } catch (error) {
    console.error('Failed to send CleverReach email:', error.response?.data || error.message);
    return { 
      ok: false, 
      error: error.response?.data?.message || error.message || 'Unknown error' 
    };
  }
}

/**
 * Get campaign status
 */
async function getCampaignStatus(campaignId) {
  try {
    const token = await getAccessToken();
    const response = await axios.get(
      `${CLEVERREACH_BASE_URL}/send.json/${campaignId}`,
      {
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      }
    );
    return response.data;
  } catch (error) {
    console.error('Failed to get campaign status:', error.response?.data || error.message);
    throw error;
  }
}

/**
 * Get groups list
 */
async function getGroups() {
  try {
    const token = await getAccessToken();
    const response = await axios.get(`${CLEVERREACH_BASE_URL}/groups.json`, {
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      }
    });
    return response.data;
  } catch (error) {
    console.error('Failed to get groups:', error.response?.data || error.message);
    throw error;
  }
}

module.exports = {
  sendInvitationEmail,
  getCampaignStatus,
  getGroups,
  getAccessToken
};
