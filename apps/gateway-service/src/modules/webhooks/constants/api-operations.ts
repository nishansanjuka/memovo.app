export const WEBHOOK_API_OPERATIONS = {
  CLERK: {
    operationId: 'handleClerkWebhook',
    description:
      'Handles Clerk webhook events for user authentication and management. This endpoint receives events from Clerk and processes them to update user states, synchronize authentication data, or trigger business logic based on the event type.',
    apiBody: {
      description: 'Clerk webhook event payload',
      required: true,
      examples: {
        userCreated: {
          summary: 'User Created Event',
          value: {
            object: 'event',
            type: 'user.created',
            timestamp: 1716883200,
            instance_id: 'ins_2g7np7Hrk0SN6kj5EDMLDaKNL0S',
            data: {
              backup_code_enabled: false,
              banned: false,
              create_organization_enabled: true,
              create_organizations_limit: null,
              object: 'user',
              passkeys: [],
              password_enabled: true,
              phone_numbers: [],
              primary_email_address_id: 'idn_2g7np7Hrk0SN6kj5EDMLDaKNL0S',
              primary_phone_number_id: null,
              primary_web3_wallet_id: null,
              private_metadata: null,
              profile_image_url: 'https://img.clerk.com/xxxxxx',
              public_metadata: {},
              saml_accounts: [],
              totp_enabled: false,
              two_factor_enabled: false,
              unsafe_metadata: {},
              updated_at: 1716883200000,
              username: null,
              verification_attempts_remaining: null,
              web3_wallets: [],
            },
            event_attributes: {
              http_request: {
                client_ip: '192.168.1.100',
                user_agent:
                  'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36',
              },
            },
          },
        },
        userUpdated: {
          summary: 'User Updated Event',
          value: {
            object: 'event',
            type: 'user.updated',
            timestamp: 1716883200,
            instance_id: 'ins_2g7np7Hrk0SN6kj5EDMLDaKNL0S',
            data: {
              id: 'user_2g7np7Hrk0SN6kj5EDMLDaKNL0S',
              first_name: 'John',
              last_name: 'Doe',
              updated_at: 1716883200000,
              // ...other user fields as above
            },
            event_attributes: {
              http_request: {
                client_ip: '192.168.1.100',
                user_agent:
                  'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36',
              },
            },
          },
        },
        userDeleted: {
          summary: 'User Deleted Event',
          value: {
            object: 'event',
            type: 'user.deleted',
            timestamp: 1661861640000,
            data: {
              deleted: true,
              id: 'user_29wBMCtzATuFJut8jO2VNTVekS4',
              object: 'user',
            },
            event_attributes: {
              http_request: {
                client_ip: '0.0.0.0',
                user_agent:
                  'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36',
              },
            },
          },
        },
      },
    },
  },
} as const;
