package app.memovo.api.security;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * Annotation to inject the authenticated user into controller methods
 * 
 * Usage:
 * @GetMapping("/profile")
 * public ResponseEntity<?> getProfile(@CurrentUser User user) {
 *     return ResponseEntity.ok(Map.of(
 *         "id", user.getId(),
 *         "email", user.getEmail(),
 *         "status", user.getStatus()
 *     ));
 * }
 */
@Target(ElementType.PARAMETER)
@Retention(RetentionPolicy.RUNTIME)
public @interface CurrentUser {
}
