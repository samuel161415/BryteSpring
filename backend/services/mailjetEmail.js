const Mailjet = require("node-mailjet");

// Mailjet configuration
const MAILJET_API_KEY = process.env.MJ_API_KEY;
const MAILJET_SECRET_KEY = process.env.MJ_SECRET_KEY;
const FROM_EMAIL = process.env.MJ_FROM_EMAIL;
const FROM_NAME = process.env.FROM_NAME || "BRYTE VERSE";

// Initialize Mailjet client
const mailjet = new Mailjet({
  apiKey: MAILJET_API_KEY,
  apiSecret: MAILJET_SECRET_KEY,
});

/**
 * Build invitation link
 */
function buildInviteLink({ token, subdomain }) {
  // https://bryte-spring-vnv1.vercel.app/#/invitation-validation?token=INVITATION_TOKEN
  const baseUrl = "https://bryte-spring-vnv1.vercel.app";
  const url = new URL(baseUrl);
  url.pathname = "/invitation-validation";
  url.searchParams.set("token", token);
  if (subdomain) {
    url.searchParams.set("subdomain", String(subdomain));
  }
  // Add the '#' character before the path by reconstructing the URL
  const finalUrl = `${url.origin}/#${url.pathname}${url.search}`;
  return finalUrl;
}

/**
 * Send invitation email using Mailjet
 */
async function sendInvitationEmail({
  to,
  verseName,
  roleName,
  token,
  subdomain,
  fromEmail,
}) {
  try {
  
    const inviteLink = buildInviteLink({ token, subdomain });
    const subject = `Invitation to join ${verseName || "a verse"} as ${
      roleName || "member"
    }`;

    // HTML content for the invitation email
    const htmlContent = `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Invitation to Join ${verseName || "BRYTE VERSE"}</title>
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; margin: 0; padding: 20px; background-color: #f4f4f4; }
          .container { max-width: 600px; margin: 0 auto; background: #ffffff; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
          .header { background: #E44D2E; color: white; padding: 30px 20px; text-align: center; }
          .content { padding: 30px 20px; }
          .button { display: inline-block; background: #E44D2E; color: #ffffff !important; padding: 15px 30px; text-decoration: none !important; border-radius: 5px; font-weight: bold; margin: 20px 0; }
          .button:hover { background: #C73E1D; color: #ffffff !important; }
          a.button { color: #ffffff !important; text-decoration: none !important; }
          a.button:visited { color: #ffffff !important; }
          a.button:active { color: #ffffff !important; }
          .footer { background: #f8f9fa; padding: 20px; text-align: center; color: #666; font-size: 14px; }
          .verse-info { background: #f0f9ff; padding: 15px; border-radius: 5px; margin: 20px 0; border-left: 4px solid #E44D2E; }
          .link-fallback { word-break: break-all; background: #f8f9fa; padding: 10px; border-radius: 4px; font-family: monospace; font-size: 12px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>BRYTE VERSE</h1>
            <h2>You're Invited!</h2>
          </div>
          
          <div class="content">
            <p>Hello,</p>
            
            <p>You have been invited to join${
              verseName ? ` <strong>${verseName}</strong>` : " a verse"
            } as <strong>${roleName || "member"}</strong>.</p>
            
            ${
              subdomain
                ? `
            <div class="verse-info">
              <strong>Verse Details:</strong><br>
              <strong>Subdomain:</strong> ${subdomain}
            </div>
            `
                : ""
            }
            
            <p>Please click the button below to accept your invitation and create your account:</p>
            
            <div style="text-align: center;">
              <a href="${inviteLink}" class="button">Accept Invitation</a>
            </div>
            
            <p>If the button doesn't work, you can copy and paste this link into your browser:</p>
            <div class="link-fallback">
              ${inviteLink}
            </div>
            
            <p><strong>Important:</strong> This invitation will expire in 7 days.</p>
            
            <p>If you have any questions, please don't hesitate to reach out.</p>
            
            <p>Welcome to BRYTE VERSE!</p>
          </div>
          
          <div class="footer">
            <p>This invitation was sent from BRYTE VERSE.</p>
            <p>If you didn't expect this email, please ignore it.</p>
          </div>
        </div>
      </body>
      </html>
    `;

    // Plain text version for better compatibility
    const textContent = `
BRYTE VERSE - You're Invited!

Hello,

You have been invited to join ${verseName ? verseName : "a verse"} as ${
      roleName || "member"
    }.

${subdomain ? `Verse Details:\nSubdomain: ${subdomain}\n\n` : ""}

Please click the link below to accept your invitation and create your account:
${inviteLink}

Important: This invitation will expire in 7 days.

If you have any questions, please don't hesitate to reach out.

Welcome to BRYTE VERSE!

---
This invitation was sent from BRYTE VERSE. If you didn't expect this email, please ignore it.
    `.trim();

    // Send email using Mailjet v3.1 API
    const request = mailjet.post("send", { version: "v3.1" }).request({
      Messages: [
        {
          From: {
            Email: FROM_EMAIL,
            Name: FROM_NAME,
          },
          To: [
            {
              Email: to,
              Name: to.split("@")[0], // Use email username as fallback name
            },
          ],
          Subject: subject,
          TextPart: textContent,
          HTMLPart: htmlContent,
        },
      ],
    });

    const result = await request;


    return {
      ok: true,
      messageId: result.body.Messages[0].To[0].MessageID,
      status: result.body.Messages[0].Status,
    };
  } catch (error) {
    console.error(
      "Failed to send Mailjet email:",
      error.statusCode || error.message
    );

    // Log detailed error information
    if (error.response && error.response.body) {
      console.error(
        "Mailjet API Error Details:",
        JSON.stringify(error.response.body, null, 2)
      );
    }

    return {
      ok: false,
      error:
        error.response?.body?.ErrorMessage || error.message || "Unknown error",
      statusCode: error.statusCode,
    };
  }
}

/**
 * Send a simple test email
 */
async function sendTestEmail({ to, from, subject, htmlContent, textContent }) {
  try {


    const request = mailjet.post("send", { version: "v3.1" }).request({
      Messages: [
        {
          From: {
            Email: from || FROM_EMAIL,
            Name: FROM_NAME,
          },
          To: [
            {
              Email: to,
              Name: to.split("@")[0],
            },
          ],
          Subject: subject || "Test Email from BRYTE VERSE",
          TextPart: textContent || "This is a test email from BRYTE VERSE.",
          HTMLPart:
            htmlContent ||
            "<h3>This is a test email from BRYTE VERSE.</h3><p>If you received this, Mailjet is working correctly!</p>",
        },
      ],
    });

    const result = await request;



    return {
      ok: true,
      messageId: result.body.Messages[0].To[0].MessageID,
      status: result.body.Messages[0].Status,
    };
  } catch (error) {
    console.error(
      "Failed to send Mailjet test email:",
      error.statusCode || error.message
    );

    if (error.response && error.response.body) {
      console.error(
        "Mailjet API Error Details:",
        JSON.stringify(error.response.body, null, 2)
      );
    }

    return {
      ok: false,
      error:
        error.response?.body?.ErrorMessage || error.message || "Unknown error",
      statusCode: error.statusCode,
    };
  }
}

/**
 * Get Mailjet account information
 */
async function getAccountInfo() {
  try {
    const request = mailjet.get("myprofile").request();

    const result = await request;
    return { ok: true, data: result.body };
  } catch (error) {
    console.error("Failed to get Mailjet account info:", error.message);
    return {
      ok: false,
      error: error.response?.body?.ErrorMessage || error.message,
    };
  }
}

module.exports = {
  sendInvitationEmail,
  sendTestEmail,
  getAccountInfo,
};
