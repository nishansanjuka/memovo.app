import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/home/presentation/pages/edit_profile_page.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ClerkAuth.userOf(context);
    final authState = ClerkAuth.of(context);

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final String fullName = '${user.firstName ?? ""} ${user.lastName ?? ""}'
        .trim();
    final String email =
        user.emailAddresses?.firstOrNull?.emailAddress ?? "No email";
    final String? imageUrl = user.imageUrl;
    final String initials =
        (user.firstName?.isNotEmpty == true ? user.firstName![0] : "") +
        (user.lastName?.isNotEmpty == true ? user.lastName![0] : "");

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Profile',
          style: GoogleFonts.plusJakartaSans(
            color: AppTheme.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfilePage()),
              );
            },
            child: Text(
              "Edit",
              style: GoogleFonts.plusJakartaSans(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Gap(8),
        ],
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
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
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.white,
                      backgroundImage: imageUrl != null
                          ? NetworkImage(imageUrl)
                          : null,
                      child: imageUrl == null
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
                  Positioned(
                    bottom: 0,
                    right: 4,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EditProfilePage(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),

            const Gap(16),

            Text(
              fullName.isNotEmpty ? fullName : "Memovo User",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor,
              ),
            ).animate().fade(delay: 200.ms),

            Text(
              email,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: AppTheme.subTextColor,
              ),
            ).animate().fade(delay: 300.ms),

            const Gap(40),

            // Profile Options
            _ProfileSection(
              title: "Account Information",
              items: [
                _ProfileItem(
                  icon: Icons.person_outlined,
                  label: "Name",
                  value: fullName,
                ),
                _ProfileItem(
                  icon: Icons.email_outlined,
                  label: "Email",
                  value: email,
                ),
              ],
            ).animate().slideY(begin: 0.1, delay: 400.ms).fade(),

            const Gap(24),

            _ProfileSection(
              title: "Settings",
              items: [
                _ProfileItem(
                  icon: Icons.notifications_outlined,
                  label: "Notifications",
                  hasNavigation: true,
                ),
                _ProfileItem(
                  icon: Icons.lock_outlined,
                  label: "Privacy & Security",
                  hasNavigation: true,
                ),
                _ProfileItem(
                  icon: Icons.help_outline,
                  label: "Help Center",
                  hasNavigation: true,
                ),
              ],
            ).animate().slideY(begin: 0.1, delay: 500.ms).fade(),

            const Gap(40),

            // Logout Button
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.withOpacity(0.1)),
              ),
              child: TextButton(
                onPressed: () async {
                  await authState.signOut();
                  if (context.mounted) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.logout, color: Colors.red, size: 20),
                    const Gap(8),
                    Text(
                      "Sign Out",
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().shake(delay: 800.ms, duration: 400.ms),

            const Gap(40),
          ],
        ),
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final String title;
  final List<_ProfileItem> items;

  const _ProfileSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.subTextColor.withOpacity(0.8),
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final idx = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  item,
                  if (idx < items.length - 1)
                    Divider(
                      height: 1,
                      indent: 50,
                      color: AppTheme.secondaryColor.withOpacity(0.5),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final bool hasNavigation;

  const _ProfileItem({
    required this.icon,
    required this.label,
    this.value,
    this.hasNavigation = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 20),
          ),
          const Gap(16),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppTheme.textColor,
              ),
            ),
          ),
          if (value != null)
            Text(
              value!,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: AppTheme.subTextColor,
              ),
            ),
          if (hasNavigation)
            Icon(
              Icons.arrow_forward_ios,
              color: AppTheme.subTextColor.withOpacity(0.5),
              size: 14,
            ),
        ],
      ),
    );
  }
}
