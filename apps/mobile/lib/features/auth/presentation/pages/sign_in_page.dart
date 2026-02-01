import 'dart:async';

import 'package:clerk_auth/clerk_auth.dart' as clerk;
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/auth/presentation/pages/sign_up_page.dart';
import 'package:mobile/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:mobile/features/auth/presentation/widgets/social_button.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _codeController = TextEditingController();

  bool _isLoading = false;
  bool _needsCode = false;
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
    // Check if we need to verify with a code
    if (_authState.signIn?.status == clerk.Status.needsFirstFactor &&
        _authState.signIn?.factors.any((f) => f.strategy.requiresCode) ==
            true) {
      setState(() => _needsCode = true);
    }
  }

  void _onError(dynamic error) {
    setState(() {
      _errorMessage = error.message?.toString() ?? error.toString();
      _isLoading = false;
    });
  }

  Future<void> _signInWithPassword() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() => _errorMessage = 'Please fill in all fields');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authState.attemptSignIn(
        strategy: clerk.Strategy.password,
        identifier: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithEmailCode() async {
    if (_emailController.text.isEmpty) {
      setState(() => _errorMessage = 'Please enter your email');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authState.attemptSignIn(
        strategy: clerk.Strategy.emailCode,
        identifier: _emailController.text.trim(),
      );
      setState(() => _needsCode = true);
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyCode() async {
    if (_codeController.text.isEmpty) {
      setState(() => _errorMessage = 'Please enter the verification code');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authState.attemptSignIn(
        strategy: clerk.Strategy.emailCode,
        code: _codeController.text.trim(),
      );
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authState.ssoSignIn(context, clerk.Strategy.oauthGoogle);
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
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
                'Welcome Back',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor,
                ),
              ).animate().fade(duration: 400.ms).slideX(begin: -0.1),
              const Gap(8),
              Text(
                    'Sign in to continue your journey',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      color: AppTheme.subTextColor,
                    ),
                  )
                  .animate()
                  .fade(duration: 400.ms, delay: 100.ms)
                  .slideX(begin: -0.1),

              const Gap(40),

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
                const Gap(20),
              ],

              // Form
              if (!_needsCode) ...[
                // Email Field
                CustomTextField(
                      label: 'Email',
                      hint: 'Enter your email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                    )
                    .animate()
                    .fade(duration: 400.ms, delay: 200.ms)
                    .slideY(begin: 0.2),

                const Gap(16),

                // Password Field
                CustomTextField(
                      label: 'Password',
                      hint: 'Enter your password',
                      controller: _passwordController,
                      isPassword: true,
                    )
                    .animate()
                    .fade(duration: 400.ms, delay: 300.ms)
                    .slideY(begin: 0.2),

                const Gap(24),

                // Sign In Button
                _GradientButton(
                      text: 'Sign In',
                      isLoading: _isLoading,
                      onPressed: _signInWithPassword,
                    )
                    .animate()
                    .fade(duration: 400.ms, delay: 400.ms)
                    .slideY(begin: 0.2),

                const Gap(16),

                // Or use code
                Center(
                  child: TextButton(
                    onPressed: _isLoading ? null : _signInWithEmailCode,
                    child: Text(
                      'Sign in with email code instead',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ).animate().fade(duration: 400.ms, delay: 450.ms),

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
                        'or continue with',
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
                ).animate().fade(duration: 400.ms, delay: 500.ms),

                const Gap(24),

                // Google Sign In
                SocialButton(
                      text: 'Continue with Google',
                      isGoogle: true,
                      onPressed: _isLoading ? () {} : _signInWithGoogle,
                    )
                    .animate()
                    .fade(duration: 400.ms, delay: 600.ms)
                    .slideY(begin: 0.2),
              ] else ...[
                // Code Verification
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
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
                  'Check your email',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textColor,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fade(delay: 100.ms),

                const Gap(8),

                Text(
                  'We sent a verification code to\n${_emailController.text}',
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
                  text: 'Verify',
                  isLoading: _isLoading,
                  onPressed: _verifyCode,
                ).animate().fade(delay: 400.ms).slideY(begin: 0.2),

                const Gap(16),

                Center(
                  child: TextButton(
                    onPressed: () => setState(() => _needsCode = false),
                    child: Text(
                      'Back to sign in',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ).animate().fade(delay: 500.ms),
              ],

              const Gap(32),

              // Sign Up Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: GoogleFonts.plusJakartaSans(
                      color: AppTheme.subTextColor,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const SignUpPage()),
                      );
                    },
                    child: Text(
                      'Sign Up',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ).animate().fade(duration: 400.ms, delay: 700.ms),

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
