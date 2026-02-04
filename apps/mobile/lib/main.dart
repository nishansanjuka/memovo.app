import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/config/app_config.dart';
import 'package:mobile/core/providers/theme_provider.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/home/presentation/pages/main_scaffold.dart';
import 'package:mobile/features/landing/presentation/pages/landing_page.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage for theme persistence
  final prefs = await SharedPreferences.getInstance();

  // Debug print config
  AppConfig.debugPrint();

  runApp(
    ProviderScope(
      overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
      child: const MemovoApp(),
    ),
  );
}

class MemovoApp extends ConsumerWidget {
  const MemovoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    if (!AppConfig.isValid) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 64),
                const Gap(24),
                const Text(
                  'Configuration Error',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const Gap(16),
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
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        home: const AppAuthGate(),
      ),
    );
  }
}

/// The Centralized Auth Handler (Expert UI/UX Optimized)
/// This widget manages the transition between Startup, SignedIn, and SignedOut states.
class AppAuthGate extends ConsumerWidget {
  const AppAuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ClerkAuthBuilder(
      builder: (context, authState) {
        // If Clerk is still rehydrating the session from storage
        if (!authState.isSignedIn) {
          return const _LoadingScreen();
        }

        // Once loaded, we can deterministically decide where to go
        if (authState.session != null) {
          return const MainScaffold();
        }

        // Definitely signed out
        return const LandingPage();
      },
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background(context),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Cheesy Premium Logo Animation
            Image.asset(
              'assets/logo.png',
              height: 100,
              errorBuilder: (context, _, __) => Icon(
                Icons.auto_awesome,
                size: 64,
                color: AppTheme.primary(context),
              ),
            ),

            const Gap(40),

            // Minimalist custom loader
            Container(
              width: 200,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.primary(context).withOpacity(0.1),
                borderRadius: BorderRadius.circular(2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.primary(context),
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 500.ms),

            const Gap(16),

            Text(
              "Memovo is initializing...",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AppTheme.subText(context),
                letterSpacing: 1,
              ),
            ).animate().fade(delay: 800.ms),
          ],
        ),
      ),
    );
  }
}
