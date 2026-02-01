import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_theme.dart';

/// Auth page using Clerk's native ClerkAuthentication widget
/// This handles Sign In, Sign Up, Google OAuth, Email/Password, etc.
class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Sign In or Sign Up',
          style: TextStyle(color: AppTheme.textColor),
        ),
      ),
      body: SafeArea(
        child: ClerkErrorListener(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ClerkAuthBuilder(
              signedInBuilder: (context, authState) {
                // User is now signed in, pop back to root
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                });
                return const Center(child: CircularProgressIndicator());
              },
              signedOutBuilder: (context, authState) {
                // Show Clerk's native authentication UI
                return const ClerkAuthentication();
              },
            ),
          ),
        ),
      ),
    );
  }
}
