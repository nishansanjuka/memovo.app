import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/wellbeing/presentation/providers/wellbeing_provider.dart';
import 'package:mobile/features/wellbeing/presentation/widgets/wellbeing_card.dart';
import 'package:mobile/features/wellbeing/presentation/widgets/usage_chart.dart';

class WellbeingPage extends ConsumerWidget {
  const WellbeingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ClerkAuth.of(context);
    final user = auth.user;
    if (user == null)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final wellbeing = ref.watch(
      wellbeingProvider((userId: user.id, auth: auth)),
    );

    return Scaffold(
      backgroundColor: AppTheme.background(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Digital Wellbeing',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            color: AppTheme.text(context),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: AppTheme.text(context)),
            onPressed: () => ref
                .read(wellbeingProvider((userId: user.id, auth: auth)).notifier)
                .fetchUsageAndInsights(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref
            .read(wellbeingProvider((userId: user.id, auth: auth)).notifier)
            .fetchUsageAndInsights(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const WellbeingCard(),

              const Gap(32),

              Text(
                "Usage Breakdown",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.text(context),
                ),
              ).animate().fade(delay: 200.ms),

              const Gap(24),

              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.surface(context),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppTheme.secondary(context),
                    width: 1,
                  ),
                ),
                child: UsageChart(usage: wellbeing.usage),
              ).animate().fade(delay: 400.ms).slideY(begin: 0.05),

              const Gap(32),

              // Tip Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFF6C63FF), const Color(0xFF3F3D56)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.lightbulb_outline_rounded,
                      color: Colors.yellow,
                      size: 32,
                    ),
                    const Gap(16),
                    Expanded(
                      child: Text(
                        "Did you know? Even 5 minutes of focused breathing can lower your cortisol levels by up to 20%.",
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fade(delay: 600.ms),

              const Gap(40),
            ],
          ),
        ),
      ),
    );
  }
}
