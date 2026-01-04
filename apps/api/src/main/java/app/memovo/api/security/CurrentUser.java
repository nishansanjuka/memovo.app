package app.memovo.api.security;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * Annotation to inject the authenticated Clerk user into controller methods
 * 
 * Usage:
 * @GetMapping("/profile")
 * public ResponseEntity<?> getProfile(@CurrentUser ClerkUser user) {
 *     return ResponseEntity.ok(user);
 * }
 */
@Target(ElementType.PARAMETER)
@Retention(RetentionPolicy.RUNTIME)
public @interface CurrentUser {
}
