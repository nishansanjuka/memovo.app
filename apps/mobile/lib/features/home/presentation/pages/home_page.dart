import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/providers/app_state_provider.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/home/presentation/pages/profile_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Access the current user safely
    final user = ClerkAuth.userOf(context);

    // Handle null user case
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final String userName = user.firstName ?? user.username ?? "User";

    return Scaffold(
      backgroundColor: AppTheme.background(context),
      appBar: AppBar(
        backgroundColor: AppTheme.surface(context),
        elevation: 0,
        title: Text(
          'Memovo',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            color: AppTheme.text(context),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none, color: AppTheme.text(context)),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primary(context), const Color(0xFF8B7FFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary(context).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome back,",
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    "$userName!",
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Gap(24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProfilePage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primary(context),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "View Profile",
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().slideY(begin: 0.1, duration: 400.ms).fade(),

            const Gap(24),

            // Quick Actions
            Row(
                  children: [
                    Expanded(
                      child: _QuickActionCard(
                        title: "Journal",
                        subtitle: "Write your thoughts",
                        icon: Icons.edit_note_rounded,
                        color: Colors.orange,
                        onTap: () {
                          ref.read(bottomNavProvider.notifier).state = 1;
                        },
                      ),
                    ),
                    const Gap(16),
                    Expanded(
                      child: _QuickActionCard(
                        title: "Therapy",
                        subtitle: "Chat with AI",
                        icon: Icons.psychology_rounded,
                        color: AppTheme.primary(context),
                        onTap: () {
                          ref.read(bottomNavProvider.notifier).state = 2;
                        },
                      ),
                    ),
                  ],
                )
                .animate()
                .fade(delay: 200.ms)
                .slideY(begin: 0.1, duration: 400.ms),

            const Gap(32),

            Text(
              "Recent Activities",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.text(context),
              ),
            ).animate().fade(delay: 200.ms),

            const Gap(16),

            // Placeholder content
            Center(
              child: Column(
                children: [
                  const Gap(40),
                  Icon(
                    Icons.auto_awesome_outlined,
                    size: 64,
                    color: AppTheme.subText(context).withOpacity(0.3),
                  ),
                  const Gap(16),
                  Text(
                    "Your memories will appear here.",
                    style: GoogleFonts.plusJakartaSans(
                      color: AppTheme.subText(context),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ).animate().fade(delay: 400.ms),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surface(context),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.secondary(context), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const Gap(16),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppTheme.text(context),
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: AppTheme.subText(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
