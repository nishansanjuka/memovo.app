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

  if (!AppConfig.isValid) {
    throw Exception(
      'Missing CLERK_PUBLISHABLE_KEY!\n'
      'Run with: flutter run --dart-define-from-file=config/dev.json',
    );
  }

  runApp(const MemovoApp());
}

class MemovoApp extends StatelessWidget {
  const MemovoApp({super.key});

  @override
  Widget build(BuildContext context) {
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
