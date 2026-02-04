class WellbeingInsight {
  final String insight;
  final String moodAnalysis;
  final List<String> suggestions;
  final Map<String, dynamic> usageStats;

  WellbeingInsight({
    required this.insight,
    required this.moodAnalysis,
    required this.suggestions,
    required this.usageStats,
  });

  factory WellbeingInsight.fromJson(Map<String, dynamic> json) =>
      WellbeingInsight(
        insight: json['insight'] ?? '',
        moodAnalysis: json['moodAnalysis'] ?? '',
        suggestions: List<String>.from(json['suggestions'] ?? []),
        usageStats: json['usageStats'] ?? {},
      );
}
