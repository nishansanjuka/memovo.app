const clerkSecretKey = pm.environment.get('CLERK_SECRET_KEY');
const userId = pm.environment.get('TEST_CLERK_USER_ID');
const apiKey = pm.environment.get('API_KEY');

if (!apiKey && (!clerkSecretKey || !userId)) {
  console.log(
    'Missing authentication. Provide either API_KEY or (CLERK_SECRET_KEY + TEST_CLERK_USER_ID).',
  );
} else {
  runAuth();
}

function tryParseJSON(response) {
  try {
    return response.json();
  } catch (e) {
    console.log('Non-JSON response:', response.text());
    return null;
  }
}

function runAuth() {
  if (apiKey && (!clerkSecretKey || !userId)) {
    pm.environment.set('bearerToken', '');
    console.log('Using x-api-key authentication only.');
    return;
  }

  const clerkHeaders = {
    'Content-Type': 'application/json',
    Authorization: `Bearer ${clerkSecretKey}`,
  };

  pm.sendRequest(
    {
      url: 'https://api.clerk.com/v1/sessions',
      method: 'POST',
      header: clerkHeaders,
      body: {
        mode: 'raw',
        raw: JSON.stringify({
          user_id: userId,
        }),
      },
    },
    (err, response) => {
      if (err) {
        console.log('Session creation failed:', err);
        return;
      }

      const session = tryParseJSON(response);

      if (!session || !session.id) {
        console.log('Invalid session response:', response.text());
        return;
      }

      const sessionId = session.id;

      if (session.organization) {
        getToken(sessionId, clerkHeaders);
        return;
      }

      pm.sendRequest(
        {
          url: `https://api.clerk.com/v1/users/${userId}/organizations`,
          method: 'GET',
          header: clerkHeaders,
        },
        (orgErr, orgResponse) => {
          if (orgErr) {
            getToken(sessionId, clerkHeaders);
            return;
          }

          const organizations = tryParseJSON(orgResponse);

          if (!organizations || organizations.length === 0) {
            getToken(sessionId, clerkHeaders);
            return;
          }

          const orgId = organizations[0].id;

          pm.sendRequest(
            {
              url: `https://api.clerk.com/v1/sessions/${sessionId}/organization_memberships/${orgId}/activate`,
              method: 'POST',
              header: clerkHeaders,
            },
            () => {
              getToken(sessionId, clerkHeaders);
            },
          );
        },
      );
    },
  );
}

function getToken(sessionId, clerkHeaders) {
  pm.sendRequest(
    {
      url: `https://api.clerk.com/v1/sessions/${sessionId}/tokens`,
      method: 'POST',
      header: clerkHeaders,
      body: {
        mode: 'raw',
        raw: JSON.stringify({
          template: 'default',
        }),
      },
    },
    (err, response) => {
      if (err) {
        console.log('Token request failed:', err);
        return;
      }

      const tokenData = tryParseJSON(response);

      if (!tokenData || !tokenData.jwt) {
        console.log('Token not returned:', response.text());
        return;
      }

      pm.environment.set('bearerToken', tokenData.jwt);
    },
  );
}
