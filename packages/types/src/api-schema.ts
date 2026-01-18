// Auto-generated from OpenAPI spec
export interface UserRequest {
  /** User's unique identifier */
  id: string;
  /** User's first name */
  firstName: string;
  /** User's last name */
  lastName?: string;
  /** User's email address */
  email: string;
}

export interface UserResponse {
  /** User's unique identifier */
  id: string;
  /** User's first name */
  firstName: string;
  /** User's last name */
  lastName: string;
  /** User's email address */
  email: string;
  /** Timestamp when the user was created */
  createdAt: string;
  /** Timestamp when the user was last updated */
  updatedAt: string;
}
