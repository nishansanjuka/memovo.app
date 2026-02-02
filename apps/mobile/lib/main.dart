import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/config/app_config.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/home/presentation/pages/main_scaffold.dart';
import 'package:mobile/features/landing/presentation/pages/landing_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Debug print config
  AppConfig.debugPrint();

  runApp(const ProviderScope(child: MemovoApp()));
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
        home: const AppAuthGate(),
      ),
    );
  }
}

/// The Centralized Auth Handler (Expert UI/UX Optimized)
/// This widget manages the three core states: Startup, SignedIn, and SignedOut.
class AppAuthGate extends ConsumerStatefulWidget {
  const AppAuthGate({super.key});

  @override
  ConsumerState<AppAuthGate> createState() => _AppAuthGateState();
}

class _AppAuthGateState extends ConsumerState<AppAuthGate> {
  bool _handshakeComplete = false;

  @override
  Widget build(BuildContext context) {
    final auth = ClerkAuth.of(context);

    // 1. If we already have a session/user, we've recovered it (likely from cache).
    // Transition to MainScaffold immediately and mark handshake as done.
    if (auth.session != null || auth.user != null) {
      _handshakeComplete = true;
      return const MainScaffold();
    }

    // 2. If handshake was previously marked complete (e.g., after signout),
    // we show the LandingPage immediately.
    if (_handshakeComplete) {
      return const LandingPage();
    }

    // 3. Handshake in progress: We use StreamBuilder to wait for Clerk's definitive answer.
    return StreamBuilder<dynamic>(
      stream: auth.sessionTokenStream,
      builder: (context, snapshot) {
        // Reactive check: Did we get a session while waiting?
        if (auth.session != null || auth.user != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _handshakeComplete = true);
          });
          return const MainScaffold();
        }

        // If the stream is active (emitted at least once) and still no session,
        // it means we are definitively signed out.
        if (snapshot.connectionState == ConnectionState.active ||
            snapshot.connectionState == ConnectionState.done) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _handshakeComplete = true);
          });
          return const LandingPage();
        }

        // Default: The loading screen stays until the very first stream emission.
        return const _LoadingScreen();
      },
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Cheesy Premium Logo Animation
            Image.asset(
                  'assets/logo.png',
                  height: 100,
                  errorBuilder: (context, _, __) => const Icon(
                    Icons.auto_awesome,
                    size: 64,
                    color: AppTheme.primaryColor,
                  ),
                )
                .animate(onPlay: (controller) => controller.repeat())
                .shimmer(duration: 2.seconds, color: Colors.white24)
                .shake(hz: 2, curve: Curves.easeInOut),

            const Gap(40),

            // Minimalist custom loader
            Container(
              width: 200,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: const LinearProgressIndicator(
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryColor,
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 500.ms),

            const Gap(16),

            Text(
              "Memovo is initializing...",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AppTheme.subTextColor,
                letterSpacing: 1,
              ),
            ).animate().fade(delay: 800.ms),
          ],
        ),
      ),
    );
  }
}
