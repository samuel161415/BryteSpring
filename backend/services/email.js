const { Resend } = require('resend');

const RESEND_API_KEY = process.env.RESEND_API_KEY;
const INVITE_BASE_URL = process.env.INVITE_BASE_URL || 'http://localhost:3000';
const FROM_ADDRESS = process.env.EMAIL_FROM || 'onboarding@resend.dev';

const resend = new Resend(RESEND_API_KEY);

function buildInviteLink({ token, subdomain }) {
  const url = new URL(INVITE_BASE_URL);
  url.pathname = '/invite';
  url.searchParams.set('token', token);
  if (subdomain) {
    url.searchParams.set('subdomain', String(subdomain));
  }
  return url.toString();
}

async function sendInvitationEmail({ to, verseName, roleName, token, subdomain, fromEmail }) {
  const inviteLink = buildInviteLink({ token, subdomain });
  const subject = `Invitation to join ${verseName || 'a verse'} as ${roleName || 'member'}`;
  const html = `
    <div style="font-family: Arial, sans-serif; line-height: 1.5;">
      <h2>You are invited${verseName ? ` to ${verseName}` : ''}</h2>
      <p>You have been invited to join${verseName ? ` <strong>${verseName}</strong>` : ' a verse'} as <strong>${roleName || 'member'}</strong>.</p>
      ${subdomain ? `<p>Verse subdomain: <strong>${subdomain}</strong></p>` : ''}
      <p>Please click the link below to accept your invitation:</p>
      <p><a href="${inviteLink}" target="_blank" rel="noopener noreferrer">Accept Invitation</a></p>
      <p>If the button does not work, copy and paste this URL into your browser:</p>
      <p style="word-break: break-all;">${inviteLink}</p>
    </div>
  `;

  try {
    console.log("Sending invitation email to:", to);
    console.log("From email:", fromEmail || FROM_ADDRESS);
    console.log("Subject:", subject);
    console.log("HTML:", html);
    const response = await resend.emails.send({
      from: fromEmail || FROM_ADDRESS,
      to,
      subject,
      html,
    });
    console.log("Response:", response);
    return { ok: true };
  } catch (err) {
    console.error('Failed to send invitation email:', err?.message || err);
    return { ok: false, error: err?.message || String(err) };
  }
}

module.exports = {
  sendInvitationEmail,
};
