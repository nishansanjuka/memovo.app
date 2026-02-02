import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:mobile/core/config/app_config.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/home/presentation/pages/home_page.dart';
import 'package:mobile/features/landing/presentation/pages/landing_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Debug print config
  AppConfig.debugPrint();

  runApp(const MemovoApp());
}

class MemovoApp extends StatelessWidget {
  const MemovoApp({super.key});

  @override
  Widget build(BuildContext context) {
    if (!AppConfig.isValid) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 64),
                const SizedBox(height: 24),
                const Text(
                  'Configuration Error',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Missing CLERK_PUBLISHABLE_KEY!\n\n'
                  'Please run with:\n'
                  'flutter run --dart-define-from-file=config/dev.json',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ClerkAuth(
      config: ClerkAuthConfig(publishableKey: AppConfig.clerkPublishableKey),
      child: MaterialApp(
        title: 'Memovo',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: ClerkErrorListener(
          child: ClerkAuthBuilder(
            signedInBuilder: (context, authState) => const HomePage(),
            signedOutBuilder: (context, authState) => const LandingPage(),
          ),
        ),
      ),
    );
  }
}
