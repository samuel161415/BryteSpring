const { sendInvitationEmail, sendTestEmail, getAccountInfo } = require('../services/mailjetEmail');

/**
 * Test basic email sending with Mailjet
 */
exports.sendTestEmailController = async (req, res) => {
  try {
    const { to, from, subject, htmlContent, textContent } = req.body;

    if (!to) {
      return res.status(400).json({ 
        message: 'Recipient email (to) is required',
        example: {
          to: 'test@example.com',
          from: 'sender@example.com', // optional
          subject: 'Test Subject', // optional
          htmlContent: '<h1>Test HTML</h1>', // optional
          textContent: 'Test plain text' // optional
        }
      });
    }


    const result = await sendTestEmail({ to, from, subject, htmlContent, textContent });

    if (result.ok) {
      return res.status(200).json({
        message: 'Test email sent successfully via Mailjet',
        result: {
          messageId: result.messageId,
          status: result.status,
          recipient: to,
          sender: from || process.env.EMAIL_FROM
        }
      });
    } else {
      return res.status(500).json({
        message: 'Failed to send test email via Mailjet',
        error: result.error,
        statusCode: result.statusCode
      });
    }
  } catch (error) {
    console.error('Error in sendTestEmail controller:', error);
    return res.status(500).json({ 
      message: 'Server error sending test email', 
      error: error.message 
    });
  }
};

/**
 * Test invitation email sending with Mailjet
 */
exports.sendTestInvitation = async (req, res) => {
  try {
    const { 
      to, 
      verseName, 
      roleName, 
      token, 
      subdomain, 
      fromEmail 
    } = req.body;

    if (!to) {
      return res.status(400).json({ 
        message: 'Recipient email (to) is required',
        example: {
          to: 'test@example.com',
          verseName: 'Test Verse', // optional
          roleName: 'Administrator', // optional
          token: 'test-token-123', // optional - will generate if not provided
          subdomain: 'test.example.com', // optional
          fromEmail: 'sender@example.com' // optional
        }
      });
    }

    // Generate a test token if not provided
    const invitationToken = token || `test-token-${Date.now()}`;

    
    const result = await sendInvitationEmail({ 
      to, 
      verseName: verseName || 'Test Verse',
      roleName: roleName || 'Test Role',
      token: invitationToken,
      subdomain,
      fromEmail
    });

    if (result.ok) {
      return res.status(200).json({
        message: 'Test invitation email sent successfully via Mailjet',
        result: {
          messageId: result.messageId,
          status: result.status,
          recipient: to,
          sender: fromEmail || process.env.EMAIL_FROM,
          verseName: verseName || 'Test Verse',
          roleName: roleName || 'Test Role',
          token: invitationToken
        }
      });
    } else {
      return res.status(500).json({
        message: 'Failed to send test invitation email via Mailjet',
        error: result.error,
        statusCode: result.statusCode
      });
    }
  } catch (error) {
    console.error('Error in sendTestInvitation controller:', error);
    return res.status(500).json({ 
      message: 'Server error sending test invitation email', 
      error: error.message 
    });
  }
};

/**
 * Get Mailjet account information
 */
exports.getAccountInfo = async (req, res) => {
  try {
    const result = await getAccountInfo();

    if (result.ok) {
      return res.status(200).json({
        message: 'Mailjet account information retrieved successfully',
        account: result.data
      });
    } else {
      return res.status(500).json({
        message: 'Failed to get Mailjet account information',
        error: result.error
      });
    }
  } catch (error) {
    console.error('Error in getAccountInfo controller:', error);
    return res.status(500).json({ 
      message: 'Server error getting account information', 
      error: error.message 
    });
  }
};

/**
 * Test Mailjet configuration
 */
exports.testConfiguration = async (req, res) => {
  try {
    // Check environment variables
    const requiredVars = ['MAILJET_API_KEY', 'MAILJET_SECRET_KEY', 'EMAIL_FROM'];
    const missing = requiredVars.filter(varName => !process.env[varName]);
    
    const config = {
      hasApiKey: !!process.env.MAILJET_API_KEY,
      hasSecretKey: !!process.env.MAILJET_SECRET_KEY,
      hasFromEmail: !!process.env.EMAIL_FROM,
      fromEmail: process.env.EMAIL_FROM,
      fromName: process.env.FROM_NAME || 'BRYTE VERSE',
      inviteBaseUrl: process.env.INVITE_BASE_URL || 'http://localhost:3000'
    };

    if (missing.length > 0) {
      return res.status(400).json({
        message: 'Mailjet configuration incomplete',
        missing: missing,
        current: config,
        instructions: {
          message: 'Please set the following environment variables:',
          variables: {
            MAILJET_API_KEY: 'Your Mailjet API key',
            MAILJET_SECRET_KEY: 'Your Mailjet secret key',
            EMAIL_FROM: 'Your verified sender email address',
            FROM_NAME: 'Your sender name (optional)',
            INVITE_BASE_URL: 'Your application base URL (optional)'
          }
        }
      });
    }

    // Test account access
    const accountResult = await getAccountInfo();
    
    return res.status(200).json({
      message: 'Mailjet configuration is complete',
      config: config,
      accountTest: {
        success: accountResult.ok,
        error: accountResult.error || null
      },
      nextSteps: [
        'Use POST /mailjet-test/send-test to send a basic test email',
        'Use POST /mailjet-test/send-invitation to test invitation email template',
        'Integrate with your invitation system'
      ]
    });

  } catch (error) {
    console.error('Error in testConfiguration controller:', error);
    return res.status(500).json({ 
      message: 'Server error testing configuration', 
      error: error.message 
    });
  }
};
