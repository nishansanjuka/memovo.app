// package app.memovo.api.controller;

// import org.springframework.http.ResponseEntity;
// import org.springframework.web.bind.annotation.GetMapping;
// import org.springframework.web.bind.annotation.RequestMapping;
// import org.springframework.web.bind.annotation.RestController;

// import app.memovo.api.controller.docs.UserApiDocs;
// import app.memovo.api.controller.dto.ProtectedResponse;
// import app.memovo.api.controller.dto.UserProfileResponse;
// import app.memovo.api.security.ClerkUser;
// import app.memovo.api.security.CurrentUser;
// import io.swagger.v3.oas.annotations.Parameter;
// import io.swagger.v3.oas.annotations.tags.Tag;

// /**
//  * User Management API
//  *
//  * Provides endpoints for user profile and authentication-protected operations.
//  * All endpoints require Clerk JWT authentication via Bearer token in
//  * Authorization header.
//  *
//  * @author Memovo Team
//  * @version 0.0.1
//  * @since 0.0.1
//  */
// @RestController
// @RequestMapping("/api/v1")
// @Tag(name = "Users", description = "Authenticated user profile and protected examples")
// public class UserController {

//     /**
//      * Get User Profile
//      *
//      * Retrieves the authenticated user's profile information including user ID,
//      * email, and status. This endpoint demonstrates how to access authenticated
//      * user details via @CurrentUser annotation.
//      *
//      * @param user The authenticated Clerk user (automatically injected from JWT
//      * token)
//      * @return ResponseEntity containing user profile data
//      * @apiNote Requires valid Clerk JWT token in Authorization header
//      * @author Memovo Team
//      * @since 0.0.1
//      */
//     @UserApiDocs.GetProfileOperation
//     @GetMapping("/profile")
//     public ResponseEntity<UserProfileResponse> getProfile(@Parameter(hidden = true) @CurrentUser ClerkUser user) {
//         return ResponseEntity.ok(new UserProfileResponse(user.getId(), user.getEmail()));
//     }

//     /**
//      * Protected Endpoint Example
//      *
//      * A sample protected endpoint that returns a message along with the
//      * authenticated user's ID. Demonstrates the authentication middleware in
//      * action.
//      *
//      * @param user The authenticated Clerk user (automatically injected from JWT
//      * token)
//      * @return ResponseEntity with success message and user ID
//      * @apiNote All /api/v1/** endpoints are automatically protected by
//      * ClerkAuthenticationFilter
//      * @author Memovo Team
//      * @since 0.0.1
//      */
//     @UserApiDocs.ProtectedEndpointOperation
//     @GetMapping("/protected")
//     public ResponseEntity<ProtectedResponse> protectedEndpoint(@Parameter(hidden = true) @CurrentUser ClerkUser user) {
//         return ResponseEntity.ok(new ProtectedResponse("This is a protected endpoint", user.getId()));
//     }
// }
