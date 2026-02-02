import 'dart:io';
import 'dart:typed_data';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/providers/user_provider.dart';
import 'package:mobile/features/auth/presentation/widgets/custom_text_field.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  bool _initialized = false;
  Uint8List? _selectedImageBytes;
  File? _selectedImageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final user = ClerkAuth.userOf(context);
      if (user != null) {
        _firstNameController.text = user.firstName ?? "";
        _lastNameController.text = user.lastName ?? "";
        _initialized = true;
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _selectedImageBytes = bytes;
          _selectedImageFile = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    }
  }

  Future<void> _save() async {
    final authState = ClerkAuth.of(context);
    final notifier = ref.read(profileEditProvider(authState).notifier);

    try {
      // 1. Update Profile Image if selected
      if (_selectedImageFile != null) {
        await notifier.updateProfileImage(_selectedImageFile!);
      }

      // 2. Update Text Fields
      await notifier.updateProfile(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
      );

      if (mounted && !ref.read(profileEditProvider(authState)).hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      // Errors are handled by the provider state
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ClerkAuth.of(context);
    final user = ClerkAuth.userOf(context);
    final editState = ref.watch(profileEditProvider(authState));

    final String? imageUrl = user?.imageUrl;
    final String initials =
        (user?.firstName?.isNotEmpty == true ? user!.firstName![0] : "") +
        (user?.lastName?.isNotEmpty == true ? user!.lastName![0] : "");

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppTheme.textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Profile',
          style: GoogleFonts.plusJakartaSans(
            color: AppTheme.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: editState.isLoading ? null : _save,
            child: editState.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    'Save',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
          ),
          const Gap(8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Gap(20),

            // Avatar Section
            Center(
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppTheme.primaryColor, Color(0xFF8B7FFF)],
                      ),
                    ),
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.white,
                        backgroundImage: _selectedImageBytes != null
                            ? MemoryImage(_selectedImageBytes!)
                            : (imageUrl != null
                                  ? NetworkImage(imageUrl) as ImageProvider
                                  : null),
                        child: _selectedImageBytes == null && imageUrl == null
                            ? Text(
                                initials.toUpperCase(),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 4,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),

            const Gap(32),

            // Error Message
            if (editState.hasError) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 20,
                    ),
                    const Gap(8),
                    Expanded(
                      child: Text(
                        editState.error.toString(),
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.red,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().shake(),
              const Gap(24),
            ],

            Text(
              "Personal Information",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor,
              ),
            ),
            const Gap(16),

            CustomTextField(
              label: "First Name",
              hint: "First Name",
              controller: _firstNameController,
            ).animate().fadeIn(delay: 100.ms).slideX(begin: 0.1),

            const Gap(16),

            CustomTextField(
              label: "Last Name",
              hint: "Last Name",
              controller: _lastNameController,
            ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1),

            const Gap(40),

            Center(
              child: Text(
                "Tap on the image to pick a new profile photo.",
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: AppTheme.subTextColor,
                ),
              ),
            ).animate().fade(delay: 400.ms),
          ],
        ),
      ),
    );
  }
}
