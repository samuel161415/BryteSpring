const { sendInvitationEmail, getAccessToken, getGroups } = require('../services/cleverEmail');

// Test CleverReach connection
const testCleverReachConnection = async (req, res) => {
  try {
    const token = await getAccessToken();
    const groups = await getGroups();
    
    res.json({
      message: 'CleverReach connection successful',
      token: token.substring(0, 10) + '...', // Show partial token for security
      groups: groups.map(group => ({
        id: group.id,
        name: group.name,
        stamp: group.stamp
      }))
    });
  } catch (error) {
    console.error('CleverReach connection test failed:', error);
    res.status(500).json({
      message: 'CleverReach connection failed',
      error: error.message
    });
  }
};

// Test sending invitation email
const testSendInvitation = async (req, res) => {
  try {
    const { email, verseName, roleName } = req.body;
    console.log("email", email);
    console.log("verseName", verseName);
    console.log("roleName", roleName);
    
    if (!email) {
      return res.status(400).json({ message: 'Email is required' });
    }

    const result = await sendInvitationEmail({
      to: email,
      verseName: verseName || 'Test Verse',
      roleName: roleName || 'Test Role',
      token: 'test-token-12345',
      subdomain: 'test',
      fromEmail: 'test@yourdomain.com'
    });

    if (result.ok) {
      res.json({
        message: 'Test invitation sent successfully',
        campaignId: result.campaignId
      });
    } else {
      res.status(500).json({
        message: 'Failed to send test invitation',
        error: result.error
      });
    }
  } catch (error) {
    console.error('Test send invitation failed:', error);
    res.status(500).json({
      message: 'Test send invitation failed',
      error: error.message
    });
  }
};

// Debug CleverReach API endpoints
const debugCleverReachAPI = async (req, res) => {
  try {
    const { sendInvitationEmail, getAccessToken, getGroups } = require('../services/cleverEmail');
    
    const token = await getAccessToken();
    console.log('Token obtained:', token.substring(0, 20) + '...');
    
    // Test different API endpoints
    const axios = require('axios');
    const CLEVERREACH_BASE_URL = process.env.CLEVERREACH_BASE_URL;
    
    const endpoints = [
      '/groups.json',
      '/mailings.json'
    ];
    
    const results = {};
    
    for (const endpoint of endpoints) {
      try {
        const response = await axios.get(`${CLEVERREACH_BASE_URL}${endpoint}`, {
          headers: {
            'Authorization': `Bearer ${token}`,
            'Content-Type': 'application/json'
          }
        });
        results[endpoint] = {
          status: response.status,
          data: response.data,
          success: true
        };
      } catch (error) {
        results[endpoint] = {
          status: error.response?.status || 'No response',
          error: error.response?.data || error.message,
          success: false
        };
      }
    }
    
    // Test creating a mailing
    try {
      console.log('Testing mailing creation...');
      const testMailingResponse = await axios.post(`${CLEVERREACH_BASE_URL}/mailings.json`, {
        name: 'Test Mailing - Debug',
        subject: 'Test Subject',
        html_body: '<p>Test email body</p>',
        sender_email: 'samuelnegalign2@gmail.com', // Fixed: use sender_email instead of from_email
        sender_name: 'Test Sender',
        group_id: 575474 // Use your existing group ID
      }, {
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        }
      });
      
      results['mailing_creation_test'] = {
        status: testMailingResponse.status,
        data: testMailingResponse.data,
        success: true
      };
      
      // Clean up - delete the test mailing
      try {
        await axios.delete(`${CLEVERREACH_BASE_URL}/mailings.json/${testMailingResponse.data.id}`, {
          headers: {
            'Authorization': `Bearer ${token}`,
            'Content-Type': 'application/json'
          }
        });
        console.log('Test mailing cleaned up');
      } catch (cleanupError) {
        console.warn('Failed to clean up test mailing:', cleanupError.message);
      }
      
    } catch (error) {
      results['mailing_creation_test'] = {
        status: error.response?.status || 'No response',
        error: error.response?.data || error.message,
        success: false
      };
    }
    
    res.json({
      message: 'CleverReach API debug results',
      token: token.substring(0, 20) + '...',
      endpoints: results
    });
    
  } catch (error) {
    console.error('Debug CleverReach API failed:', error);
    res.status(500).json({
      message: 'Debug CleverReach API failed',
      error: error.message
    });
  }
};

module.exports = {
  testCleverReachConnection,
  testSendInvitation,
  debugCleverReachAPI
};
