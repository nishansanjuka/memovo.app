// Pre-request Script

const clerkSecretKey = pm.environment.get('CLERK_SECRET_KEY');
const userId = pm.environment.get('TEST_CLERK_USER_ID');
const apiKey = pm.environment.get('API_KEY');

if ((!clerkSecretKey || !userId) && !apiKey) {
  console.log('CLERK_SECRET_KEY/TEST_CLERK_USER_ID or API_KEY is missing!');
  return;
}

// Prefer Bearer if present, else use x-api-key
let authHeaders = { 'Content-Type': 'application/json' };
if (clerkSecretKey && userId) {
  authHeaders['Authorization'] = `Bearer ${clerkSecretKey}`;
} else if (apiKey) {
  authHeaders['x-api-key'] = apiKey;
}

// Helper: safe JSON parse
function tryParseJSON(response) {
  try {
    return response.json();
  } catch (e) {
    console.log('Response is not JSON:', response.text());
    return null;
  }
}

// Step 1: Create session (if using Clerk)
if (clerkSecretKey && userId) {
  pm.sendRequest(
    {
      url: `https://api.clerk.com/v1/sessions`,
      method: 'POST',
      header: authHeaders,
      body: {
        mode: 'raw',
        raw: JSON.stringify({ user_id: userId }),
      },
    },
    (err, response) => {
      if (err) {
        console.log('Error creating session:', err);
        return;
      }

      const session = tryParseJSON(response);
      if (!session || !session.id) {
        console.log('Failed to create session.');
        return;
      }

      const sessionId = session.id;
      console.log('Session ID:', sessionId);

      // Check if session already has an active organization
      if (session.organization) {
        console.log('Organization already active in session');
        getToken(sessionId);
        return;
      }

      // Step 2: Get organizations for this user
      pm.sendRequest(
        {
// ...existing code...
// If using API key only, set bearerToken to empty and skip Clerk session/token logic
} else if (apiKey) {
  pm.environment.set('bearerToken', '');
}
        url: `https://api.clerk.com/v1/users/${userId}/organizations`,
        method: 'GET',
        header: clerkHeaders,
      },
      (orgErr, orgResponse) => {
        if (orgErr) {
          console.log('Error fetching organizations:', orgErr);
          return;
        }

        const organizations = tryParseJSON(orgResponse);
        if (!organizations) {
          console.log(
            'No organizations returned (non-JSON response). Proceeding without activation.',
          );
          getToken(sessionId);
          return;
        }

        if (organizations.length === 0) {
          console.log(
            'User has no organizations. Proceeding without activation.',
          );
          getToken(sessionId);
          return;
        }

        const defaultOrgId = organizations[0].id;
        console.log('Activating default organization:', defaultOrgId);

        // Step 3: Activate organization in the session
        pm.sendRequest(
          {
            url: `https://api.clerk.com/v1/sessions/${sessionId}/organization_memberships/${defaultOrgId}/activate`,
            method: 'POST',
            header: clerkHeaders,
          },
          (activateErr, activateResponse) => {
            if (activateErr) {
              console.log('Error activating organization:', activateErr);
            } else {
              const activateData = tryParseJSON(activateResponse);
              console.log(
                'Organization activated for session:',
                activateData || activateResponse.text(),
              );
            }
            getToken(sessionId); // Continue token creation regardless
          },
        );
      },
    );
  },
);

// Step 4: Function to get session token
function getToken(sessionId) {
  pm.sendRequest(
    {
      url: `https://api.clerk.com/v1/sessions/${sessionId}/tokens`,
      method: 'POST',
      header: clerkHeaders,
      body: {
        mode: 'raw',
        raw: JSON.stringify({ template: 'default' }),
      },
    },
    (err, tokenResponse) => {
      if (err) {
        console.log('Error getting token:', err);
        return;
      }

      const tokenData = tryParseJSON(tokenResponse);
      if (!tokenData || !tokenData.jwt) {
        console.log('Failed to get token:', tokenResponse.text());
        return;
      }

      const token = tokenData.jwt;
      console.log('Token obtained:', token);
      pm.environment.set('bearerToken', token);
    },
  );
}
