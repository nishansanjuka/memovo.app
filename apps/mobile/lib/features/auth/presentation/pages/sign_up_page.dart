import 'dart:async';

import 'package:clerk_auth/clerk_auth.dart' as clerk;
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/auth/presentation/pages/sign_in_page.dart';
import 'package:mobile/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:mobile/features/auth/presentation/widgets/social_button.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _codeController = TextEditingController();

  bool _isLoading = false;
  bool _needsVerification = false;
  String? _errorMessage;

  late ClerkAuthState _authState;
  StreamSubscription<dynamic>? _errorSubscription;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _authState = ClerkAuth.of(context);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authState = ClerkAuth.of(context);
      _authState.addListener(_authListener);
      _errorSubscription = _authState.errorStream.listen(_onError);
    });
  }

  void _authListener() {
    if (_authState.user != null && mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  void _onError(dynamic error) {
    setState(() {
      _errorMessage = error.message?.toString() ?? error.toString();
      _isLoading = false;
    });
  }

  Future<void> _signUp() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() => _errorMessage = 'Please fill in all required fields');
      return;
    }

    if (_passwordController.text.length < 8) {
      setState(() => _errorMessage = 'Password must be at least 8 characters');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authState.attemptSignUp(
        strategy: clerk.Strategy.password,
        firstName: _firstNameController.text.trim().isNotEmpty
            ? _firstNameController.text.trim()
            : null,
        lastName: _lastNameController.text.trim().isNotEmpty
            ? _lastNameController.text.trim()
            : null,
        emailAddress: _emailController.text.trim(),
        password: _passwordController.text,
        passwordConfirmation: _passwordController.text,
      );

      // Check if verification is needed
      final signUp = _authState.signUp;
      if (signUp != null &&
          (signUp.status == clerk.Status.missingRequirements ||
              signUp.unverifiedFields.isNotEmpty) &&
          signUp.unverifiedFields.contains(clerk.Field.emailAddress)) {
        // Prepare email verification (sends the code)
        // We call this ONLY if we aren't already in the verification flow
        await _authState.attemptSignUp(strategy: clerk.Strategy.emailCode);
        if (mounted) {
          setState(() {
            _errorMessage = null; // Clear any transient error during transition
            _needsVerification = true;
          });
        }
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyEmail() async {
    if (_codeController.text.isEmpty) {
      setState(() => _errorMessage = 'Please enter the verification code');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authState.attemptSignUp(
        strategy: clerk.Strategy.emailCode,
        code: _codeController.text.trim(),
      );
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signUpWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authState.ssoSignUp(context, clerk.Strategy.oauthGoogle);
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _codeController.dispose();
    _authState.removeListener(_authListener);
    _errorSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Gap(20),

              // Header
              Text(
                'Create Account',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor,
                ),
              ).animate().fade(duration: 400.ms).slideX(begin: -0.1),
              const Gap(8),
              Text(
                    'Start your journey with Memovo',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      color: AppTheme.subTextColor,
                    ),
                  )
                  .animate()
                  .fade(duration: 400.ms, delay: 100.ms)
                  .slideX(begin: -0.1),

              const Gap(32),

              // Error Message
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red.shade700,
                        size: 20,
                      ),
                      const Gap(8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.red.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().shake(),
                const Gap(16),
              ],

              if (!_needsVerification) ...[
                // Google Sign Up - Primary Option
                SocialButton(
                      text: 'Continue with Google',
                      isGoogle: true,
                      onPressed: _isLoading ? () {} : _signUpWithGoogle,
                    )
                    .animate()
                    .fade(duration: 400.ms, delay: 200.ms)
                    .slideY(begin: 0.2),

                const Gap(24),

                // Divider
                Row(
                  children: [
                    const Expanded(
                      child: Divider(color: AppTheme.secondaryColor),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'or sign up with email',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppTheme.subTextColor,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Divider(color: AppTheme.secondaryColor),
                    ),
                  ],
                ).animate().fade(duration: 400.ms, delay: 300.ms),

                const Gap(24),

                // Name Row
                Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            label: 'First Name',
                            hint: 'John',
                            controller: _firstNameController,
                          ),
                        ),
                        const Gap(12),
                        Expanded(
                          child: CustomTextField(
                            label: 'Last Name',
                            hint: 'Doe',
                            controller: _lastNameController,
                          ),
                        ),
                      ],
                    )
                    .animate()
                    .fade(duration: 400.ms, delay: 350.ms)
                    .slideY(begin: 0.2),

                const Gap(16),

                // Email Field
                CustomTextField(
                      label: 'Email',
                      hint: 'john@example.com',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                    )
                    .animate()
                    .fade(duration: 400.ms, delay: 400.ms)
                    .slideY(begin: 0.2),

                const Gap(16),

                // Password Field
                CustomTextField(
                      label: 'Password',
                      hint: 'At least 8 characters',
                      controller: _passwordController,
                      isPassword: true,
                    )
                    .animate()
                    .fade(duration: 400.ms, delay: 450.ms)
                    .slideY(begin: 0.2),

                const Gap(8),

                // Password hint
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 14,
                      color: AppTheme.subTextColor,
                    ),
                    const Gap(6),
                    Text(
                      'Password must be at least 8 characters',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppTheme.subTextColor,
                      ),
                    ),
                  ],
                ).animate().fade(duration: 400.ms, delay: 500.ms),

                const Gap(24),

                // Sign Up Button
                _GradientButton(
                      text: 'Create Account',
                      isLoading: _isLoading,
                      onPressed: _signUp,
                    )
                    .animate()
                    .fade(duration: 400.ms, delay: 550.ms)
                    .slideY(begin: 0.2),
              ] else ...[
                // Email Verification
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.email_outlined,
                      size: 48,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ).animate().scale(duration: 400.ms),

                const Gap(24),

                Text(
                  'Verify your email',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textColor,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fade(delay: 100.ms),

                const Gap(8),

                Text(
                  'We\'ve sent a verification code to\n${_emailController.text}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: AppTheme.subTextColor,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fade(delay: 200.ms),

                const Gap(32),

                CustomTextField(
                  label: 'Verification Code',
                  hint: 'Enter 6-digit code',
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                ).animate().fade(delay: 300.ms).slideY(begin: 0.2),

                const Gap(24),

                _GradientButton(
                  text: 'Verify Email',
                  isLoading: _isLoading,
                  onPressed: _verifyEmail,
                ).animate().fade(delay: 400.ms).slideY(begin: 0.2),

                const Gap(16),

                Center(
                  child: TextButton(
                    onPressed: () async {
                      // Resend code
                      setState(() => _isLoading = true);
                      try {
                        await _authState.attemptSignUp(
                          strategy: clerk.Strategy.emailCode,
                        );
                      } finally {
                        if (mounted) setState(() => _isLoading = false);
                      }
                    },
                    child: Text(
                      'Resend code',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ).animate().fade(delay: 500.ms),
              ],

              const Gap(32),

              // Sign In Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppTheme.subTextColor,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const SignInPage()),
                      );
                    },
                    child: Text(
                      'Sign In',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ).animate().fade(duration: 400.ms, delay: 600.ms),

              const Gap(40),
            ],
          ),
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String text;
  final bool isLoading;
  final VoidCallback onPressed;

  const _GradientButton({
    required this.text,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryColor, Color(0xFF8B7FFF)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                text,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
