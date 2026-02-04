import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/wellbeing/presentation/providers/wellbeing_provider.dart';

class WellbeingCard extends ConsumerWidget {
  const WellbeingCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ClerkAuth.of(context);
    final user = auth.user;
    if (user == null) return const SizedBox.shrink();

    final wellbeing = ref.watch(
      wellbeingProvider((userId: user.id, auth: auth)),
    );

    if (wellbeing.isLoading) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.surface(context),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.secondary(context)),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final insight = wellbeing.insight;
    if (insight == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surface(context),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.secondary(context), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.spa_rounded,
                  color: Colors.green,
                  size: 24,
                ),
              ),
              const Gap(12),
              Text(
                "Digital Wellbeing",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.text(context),
                ),
              ),
            ],
          ),
          const Gap(20),

          Text(
            insight.insight,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              height: 1.5,
              color: AppTheme.text(context).withOpacity(0.9),
            ),
          ),

          const Gap(16),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primary(context).withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.face_retouching_natural_rounded,
                  color: AppTheme.primary(context),
                  size: 20,
                ),
                const Gap(12),
                Expanded(
                  child: Text(
                    insight.moodAnalysis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: AppTheme.subText(context),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Gap(20),

          Text(
            "What to do today?",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.text(context),
            ),
          ),

          const Gap(12),

          ...insight.suggestions.map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: AppTheme.primary(context),
                    size: 16,
                  ),
                  const Gap(8),
                  Expanded(
                    child: Text(
                      s,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: AppTheme.subText(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.05);
  }
}
