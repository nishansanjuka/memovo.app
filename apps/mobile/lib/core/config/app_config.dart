/// Environment configuration using compile-time variables.
///
/// Usage: Run with --dart-define-from-file=config/dev.json
/// or individual: --dart-define=CLERK_PUBLISHABLE_KEY=pk_test_xxx
///
/// This is more secure than .env files because:
/// 1. Variables are compiled into the binary, not bundled as readable assets
/// 2. Cannot be easily extracted from APK/IPA
/// 3. Supports different configs per build flavor (dev/staging/prod)
class AppConfig {
  /// Clerk publishable key - injected at compile time
  static const String clerkPublishableKey = String.fromEnvironment(
    'CLERK_PUBLISHABLE_KEY',
    defaultValue: '',
  );

  /// Google Web Client ID for OAuth (optional)
  static const String googleClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue: '',
  );

  /// Check if all required config is present
  static bool get isValid => clerkPublishableKey.isNotEmpty;

  /// Debug print configuration (only in debug mode)
  static void debugPrint() {
    assert(() {
      print('=== APP CONFIG ===');
      final keyDisplay = clerkPublishableKey.length >= 20
          ? '${clerkPublishableKey.substring(0, 20)}...'
          : (clerkPublishableKey.isNotEmpty ? 'SET (SHORT)' : 'NOT SET');
      print('Clerk Key: $keyDisplay');
      print(
        'Google Client ID: ${googleClientId.isNotEmpty ? "SET" : "NOT SET"}',
      );
      print('Config Valid: $isValid');
      print('==================');
      return true;
    }());
  }
}
