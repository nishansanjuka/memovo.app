import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mobile/core/providers/app_state_provider.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/home/presentation/pages/home_page.dart';
import 'package:mobile/features/home/presentation/pages/profile_page.dart';
import 'package:mobile/features/journal/presentation/pages/journal_book_page.dart';
import 'package:mobile/features/therapy/presentation/pages/therapy_page.dart';

class MainScaffold extends ConsumerWidget {
  const MainScaffold({super.key});

  final List<Widget> _pages = const [
    HomePage(),
    JournalBookPage(),
    TherapyPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavProvider);

    return Scaffold(
      body: IndexedStack(index: currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface(context),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_rounded,
                  label: "Home",
                  isActive: currentIndex == 0,
                  onTap: () => ref.read(bottomNavProvider.notifier).state = 0,
                ),
                _NavItem(
                  icon: Icons.book_rounded,
                  label: "Journals",
                  isActive: currentIndex == 1,
                  onTap: () => ref.read(bottomNavProvider.notifier).state = 1,
                ),
                _NavItem(
                  icon: Icons.auto_awesome_rounded,
                  label: "Therapy",
                  isActive: currentIndex == 2,
                  onTap: () => ref.read(bottomNavProvider.notifier).state = 2,
                ),
                _NavItem(
                  icon: Icons.person_rounded,
                  label: "Settings",
                  isActive: currentIndex == 3,
                  onTap: () => ref.read(bottomNavProvider.notifier).state = 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: 300.ms,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.primary(context).withOpacity(0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive
                  ? AppTheme.primary(context)
                  : AppTheme.subText(context).withOpacity(0.5),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive
                    ? AppTheme.primary(context)
                    : AppTheme.subText(context).withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
