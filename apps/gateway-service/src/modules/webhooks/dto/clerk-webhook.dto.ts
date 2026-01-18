import { ApiProperty } from '@nestjs/swagger';

export class ClerkHttpRequestDto {
  @ApiProperty({ example: '192.168.1.100', required: false })
  client_ip?: string;

  @ApiProperty({
    example:
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36',
    required: false,
  })
  user_agent?: string;
}

export class ClerkEventAttributesDto {
  @ApiProperty({ type: () => ClerkHttpRequestDto, required: false })
  http_request?: ClerkHttpRequestDto;
}

export class ClerkUserDto {
  @ApiProperty()
  backup_code_enabled: boolean;
  @ApiProperty()
  banned: boolean;
  @ApiProperty()
  create_organization_enabled: boolean;
  @ApiProperty({ nullable: true })
  create_organizations_limit: number | null;
  @ApiProperty()
  created_at: number;
  @ApiProperty()
  delete_self_enabled: boolean;
  @ApiProperty({ type: [String] })
  email_addresses: string[];
  @ApiProperty({ type: [Object] })
  enterprise_accounts: any[];
  @ApiProperty({ type: [Object] })
  external_accounts: any[];
  @ApiProperty({ nullable: true })
  external_id: string | null;
  @ApiProperty()
  first_name: string;
  @ApiProperty()
  has_image: boolean;
  @ApiProperty()
  id: string;
  @ApiProperty()
  image_url: string;
  @ApiProperty()
  last_active_at: number;
  @ApiProperty()
  last_name: string;
  @ApiProperty()
  last_sign_in_at: number;
  @ApiProperty()
  legal_accepted_at: number;
  @ApiProperty()
  locked: boolean;
  @ApiProperty({ nullable: true })
  lockout_expires_in_seconds: number | null;
  @ApiProperty({ nullable: true })
  mfa_disabled_at: number | null;
  @ApiProperty({ nullable: true })
  mfa_enabled_at: number | null;
  @ApiProperty()
  object: string;
  @ApiProperty({ type: [Object] })
  passkeys: any[];
  @ApiProperty()
  password_enabled: boolean;
  @ApiProperty({ type: [String] })
  phone_numbers: string[];
  @ApiProperty({ nullable: true })
  primary_email_address_id: string | null;
  @ApiProperty({ nullable: true })
  primary_phone_number_id: string | null;
  @ApiProperty({ nullable: true })
  primary_web3_wallet_id: string | null;
  @ApiProperty({ nullable: true })
  private_metadata: any;
  @ApiProperty()
  profile_image_url: string;
  @ApiProperty({ type: Object })
  public_metadata: any;
  @ApiProperty({ type: [Object] })
  saml_accounts: any[];
  @ApiProperty()
  totp_enabled: boolean;
  @ApiProperty()
  two_factor_enabled: boolean;
  @ApiProperty({ type: Object })
  unsafe_metadata: any;
  @ApiProperty()
  updated_at: number;
  @ApiProperty({ nullable: true })
  username: string | null;
  @ApiProperty({ nullable: true })
  verification_attempts_remaining: number | null;
  @ApiProperty({ type: [Object] })
  web3_wallets: any[];
  @ApiProperty({ nullable: true })
  deleted?: boolean;
}

export class ClerkWebhookDto {
  @ApiProperty({ example: 'event' })
  object: string;

  @ApiProperty({ example: 'user.created' })
  type: string;

  @ApiProperty({ example: 1716883200 })
  timestamp: number;

  @ApiProperty({ example: 'ins_2g7np7Hrk0SN6kj5EDMLDaKNL0S', required: false })
  instance_id?: string;

  @ApiProperty({ type: () => ClerkUserDto })
  data: ClerkUserDto;

  @ApiProperty({
    required: false,
    type: () => ClerkEventAttributesDto,
    example: {
      http_request: {
        client_ip: '192.168.1.100',
        user_agent:
          'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36',
      },
    },
  })
  event_attributes?: ClerkEventAttributesDto;
}
