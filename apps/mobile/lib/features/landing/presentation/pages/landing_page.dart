import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/auth/presentation/pages/sign_in_page.dart';
import 'package:mobile/features/auth/presentation/pages/sign_up_page.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    // using LayoutBuilder to be responsive if needed, but for mobile usually safe.
    // Safe area for notches.
    return Scaffold(
      backgroundColor: AppTheme.background(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 2),
              // Logo Section
              Center(
                child: Image.asset(
                  'assets/logo.png',
                  height: 120, // Adjust height as needed
                  fit: BoxFit.contain,
                ).animate().fade(duration: 600.ms).scale(delay: 200.ms),
              ),
              const Gap(40),

              // Text Content
              Text(
                    "Invite Your Day,\nFeel Your Way",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                      color: AppTheme.text(context),
                    ),
                  )
                  .animate()
                  .fade(duration: 600.ms, delay: 300.ms)
                  .slideY(begin: 0.3),
              const Gap(16),
              Text(
                "Experience a new way to capture memories and navigate your daily life with ease and style.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.subText(context),
                  height: 1.5,
                ),
              ).animate().fade(duration: 600.ms, delay: 400.ms).slideY(begin: 0.3),

              const Spacer(flex: 3),

              // Actions - Two buttons for Sign Up and Sign In
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignUpPage()),
                      );
                    },
                    child: const Text("Get Started"),
                  ).animate().fade(delay: 600.ms).slideY(begin: 1.0, end: 0),
                  const Gap(16),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignInPage()),
                      );
                    },
                    child: const Text("I already have an account"),
                  ).animate().fade(delay: 800.ms),
                ],
              ),
              const Gap(20),
            ],
          ),
        ),
      ),
    );
  }
}
