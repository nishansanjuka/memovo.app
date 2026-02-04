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
  String? _errorMessage;

  // Sign-in flow states
  _SignInStep _currentStep = _SignInStep.email;

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
    // Check for session instead of user for faster transition
    if (_authState.session != null && mounted) {
      // Small delay to ensure state settling before navigation
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      });
    }
  }

  void _onError(dynamic error) {
    if (mounted) {
      setState(() {
        _errorMessage = error.message?.toString() ?? error.toString();
        _isLoading = false;
      });
    }
  }

  /// Step 1: Validate email and move to password step (no API call yet)
  void _submitEmail() {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() => _errorMessage = 'Please enter your email');
      return;
    }

    // Basic email validation
    if (!email.contains('@') || !email.contains('.')) {
      setState(() => _errorMessage = 'Please enter a valid email');
      return;
    }

    // Just move to password step - no API call needed
    setState(() {
      _errorMessage = null;
      _currentStep = _SignInStep.password;
    });
  }

  /// Step 2: Submit email + password together to Clerk
  Future<void> _submitPassword() async {
    if (_passwordController.text.isEmpty) {
      setState(() => _errorMessage = 'Please enter your password');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Send both email and password together - this is how Clerk works
      await _authState.attemptSignIn(
        strategy: clerk.Strategy.password,
        identifier: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Check if we need second factor (2FA/OTP)
      // For 2FA/MFA, we MUST explicitly prepare the second factor
      final signIn = _authState.signIn;
      if (signIn != null && signIn.status == clerk.Status.needsSecondFactor) {
        try {
          // Explicitly request the email code for the second factor
          await _authState.attemptSignIn(strategy: clerk.Strategy.emailCode);
          if (mounted) {
            setState(() {
              _errorMessage =
                  null; // Clear any transient error during transition
              _currentStep = _SignInStep.passwordOtp;
            });
          }
        } catch (preparationError) {
          if (mounted) {
            setState(
              () => _errorMessage =
                  "Error sending verification code: $preparationError",
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = e.toString());
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Step 3: Submit OTP code after password verification
  Future<void> _submitPasswordOtp() async {
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
      if (mounted) setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Alternative: Use email code instead of password
  Future<void> _requestEmailCode() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authState.attemptSignIn(
        strategy: clerk.Strategy.emailCode,
        identifier: _emailController.text.trim(),
      );
      if (mounted) setState(() => _currentStep = _SignInStep.code);
    } catch (e) {
      if (mounted) setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Submit verification code (for email code flow)
  Future<void> _submitCode() async {
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
      if (mounted) setState(() => _errorMessage = e.toString());
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

  void _goBack() {
    setState(() {
      if (_currentStep == _SignInStep.passwordOtp) {
        // Go back to password step
        _currentStep = _SignInStep.password;
        _codeController.clear();
      } else {
        // Go back to email step
        _currentStep = _SignInStep.email;
        _passwordController.clear();
        _codeController.clear();
      }
      _errorMessage = null;
    });
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
      backgroundColor: AppTheme.background(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppTheme.text(context)),
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
                  color: AppTheme.text(context),
                ),
              ).animate().fade(duration: 400.ms).slideX(begin: -0.1),
              const Gap(8),
              Text(
                    'Sign in to continue your journey',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      color: AppTheme.subText(context),
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
                    color: AppTheme.surface(context),
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
              if (_currentStep == _SignInStep.email) ...[
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

                const Gap(24),

                // Continue Button
                _GradientButton(
                      text: 'Continue',
                      isLoading: _isLoading,
                      onPressed: _submitEmail,
                    )
                    .animate()
                    .fade(duration: 400.ms, delay: 300.ms)
                    .slideY(begin: 0.2),

                const Gap(24),

                // Divider
                Row(
                  children: [
                    Expanded(
                      child: Divider(color: AppTheme.secondary(context)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'or continue with',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppTheme.subText(context),
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(color: AppTheme.secondary(context)),
                    ),
                  ],
                ).animate().fade(duration: 400.ms, delay: 400.ms),

                const Gap(24),

                // Google Sign In
                SocialButton(
                      text: 'Continue with Google',
                      isGoogle: true,
                      onPressed: _isLoading ? () {} : _signInWithGoogle,
                    )
                    .animate()
                    .fade(duration: 400.ms, delay: 500.ms)
                    .slideY(begin: 0.2),
              ] else if (_currentStep == _SignInStep.password) ...[
                // Show email as readonly info
                _EmailBadge(email: _emailController.text, onEdit: _goBack),

                const Gap(24),

                // Password Field
                CustomTextField(
                  label: 'Password',
                  hint: 'Enter your password',
                  controller: _passwordController,
                  isPassword: true,
                ).animate().fade(duration: 400.ms).slideY(begin: 0.2),

                const Gap(24),

                // Sign In Button
                _GradientButton(
                      text: 'Sign In',
                      isLoading: _isLoading,
                      onPressed: _submitPassword,
                    )
                    .animate()
                    .fade(duration: 400.ms, delay: 100.ms)
                    .slideY(begin: 0.2),

                const Gap(16),

                // Use email code instead
                Center(
                  child: TextButton(
                    onPressed: _isLoading ? null : _requestEmailCode,
                    child: Text(
                      'Use email code instead',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppTheme.primary(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ).animate().fade(duration: 400.ms, delay: 200.ms),
              ] else if (_currentStep == _SignInStep.passwordOtp) ...[
                // OTP Verification after password
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.primary(context).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.verified_user_outlined,
                      size: 48,
                      color: AppTheme.primary(context),
                    ),
                  ),
                ).animate().scale(duration: 400.ms),

                const Gap(24),

                Text(
                  'Verify your identity',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.text(context),
                  ),
                  textAlign: TextAlign.center,
                ).animate().fade(delay: 100.ms),

                const Gap(8),

                Text(
                  'We sent a verification code to\n${_emailController.text}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: AppTheme.subText(context),
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
                  text: 'Verify & Sign In',
                  isLoading: _isLoading,
                  onPressed: _submitPasswordOtp,
                ).animate().fade(delay: 400.ms).slideY(begin: 0.2),

                const Gap(16),

                Center(
                  child: TextButton(
                    onPressed: _goBack,
                    child: Text(
                      'Back',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppTheme.primary(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ).animate().fade(delay: 500.ms),
              ] else if (_currentStep == _SignInStep.code) ...[
                // Code Verification
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.primary(context).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.email_outlined,
                      size: 48,
                      color: AppTheme.primary(context),
                    ),
                  ),
                ).animate().scale(duration: 400.ms),

                const Gap(24),

                Text(
                  'Check your email',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.text(context),
                  ),
                  textAlign: TextAlign.center,
                ).animate().fade(delay: 100.ms),

                const Gap(8),

                Text(
                  'We sent a verification code to\n${_emailController.text}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: AppTheme.subText(context),
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
                  onPressed: _submitCode,
                ).animate().fade(delay: 400.ms).slideY(begin: 0.2),

                const Gap(16),

                Center(
                  child: TextButton(
                    onPressed: _goBack,
                    child: Text(
                      'Back to sign in',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppTheme.primary(context),
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
                      color: AppTheme.subText(context),
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
                        color: AppTheme.primary(context),
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
        gradient: LinearGradient(
          colors: [AppTheme.primary(context), const Color(0xFF8B7FFF)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary(context).withOpacity(0.3),
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

/// Shows the email with an edit button to go back
class _EmailBadge extends StatelessWidget {
  final String email;
  final VoidCallback onEdit;

  const _EmailBadge({required this.email, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.email_outlined, color: AppTheme.primaryColor, size: 20),
          const Gap(12),
          Expanded(
            child: Text(
              email,
              style: GoogleFonts.plusJakartaSans(
                color: AppTheme.text(context),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          GestureDetector(
            onTap: onEdit,
            child: Text(
              'Edit',
              style: GoogleFonts.plusJakartaSans(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Sign-in flow steps
/// Flow: email -> password -> passwordOtp (after password verification)
/// Alternative: email -> code (email code only, no password)
enum _SignInStep { email, password, passwordOtp, code }
