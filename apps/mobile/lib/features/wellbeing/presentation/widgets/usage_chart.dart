import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/features/wellbeing/data/models/usage_stats.dart';

class UsageChart extends StatelessWidget {
  final List<AppUsage> usage;

  const UsageChart({super.key, required this.usage});

  @override
  Widget build(BuildContext context) {
    if (usage.isEmpty) return const SizedBox.shrink();

    // Find the max duration for scaling
    final int maxDuration = usage.fold(
      0,
      (max, e) => e.durationMinutes > max ? e.durationMinutes : max,
    );
    final int totalMinutes = usage.fold(0, (sum, e) => sum + e.durationMinutes);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Today's Screen Time: ${totalMinutes ~/ 60}h ${totalMinutes % 60}m",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.subText(context),
          ),
        ),
        const Gap(24),
        ...usage.map((app) {
          final double percentage = app.durationMinutes / maxDuration;
          return Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      app.appName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.text(context),
                      ),
                    ),
                    Text(
                      "${app.durationMinutes}m",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AppTheme.subText(context),
                      ),
                    ),
                  ],
                ),
                const Gap(8),
                Stack(
                  children: [
                    // Background bar
                    Container(
                      height: 8,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppTheme.secondary(context).withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    // Value bar
                    FractionallySizedBox(
                      widthFactor: percentage,
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _getCategoryColor(app.category),
                              _getCategoryColor(app.category).withOpacity(0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: _getCategoryColor(
                                app.category,
                              ).withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'social':
        return Colors.pinkAccent;
      case 'productivity':
        return Colors.blueAccent;
      case 'entertainment':
        return Colors.orangeAccent;
      case 'wellness':
        return Colors.greenAccent;
      default:
        return Colors.grey;
    }
  }
}
