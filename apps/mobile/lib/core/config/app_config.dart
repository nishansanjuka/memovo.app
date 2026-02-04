import 'dart:io';
import 'package:flutter/foundation.dart';

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
    defaultValue: 'pk_test_bW9kZXN0LWVtdS0zMy5jbGVyay5hY2NvdW50cy5kZXYk',
  );

  /// Google Web Client ID for OAuth (optional)
  static const String googleClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue: '',
  );

  /// The raw gateway URL from environment
  static const String _gatewayUrlBase = String.fromEnvironment(
    'GATEWAY_URL',
    defaultValue: 'http://192.168.8.104:4000',
  );

  /// Standard network timeouts
  static const Duration connectTimeout = Duration(seconds: 120);
  static const Duration receiveTimeout = Duration(seconds: 120);

  /// Resolved Gateway URL (handles Android Emulator localhost mapping)
  static String get gatewayUrl {
    // If it's a local address and we're on Android, we need to use 10.0.2.2
    final isLocal =
        _gatewayUrlBase.contains('localhost') ||
        _gatewayUrlBase.contains('127.0.0.1');

    if (!kIsWeb && Platform.isAndroid && isLocal) {
      return _gatewayUrlBase
          .replaceFirst('localhost', '10.0.2.2')
          .replaceFirst('127.0.0.1', '10.0.2.2');
    }

    // Fallback: If on Android and it's a 192.168.x.x address, it might be the host IP.
    // However, 10.0.2.2 is the reliable way to hit the host's localhost.
    return _gatewayUrlBase;
  }

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
      print('Gateway URL: $gatewayUrl');

      // Log network IPs for connectivity debugging
      NetworkInterface.list().then((interfaces) {
        for (var interface in interfaces) {
          for (var addr in interface.addresses) {
            print('Network IP (${interface.name}): ${addr.address}');
          }
        }
      });

      print('==================');
      return true;
    }());
  }
}
