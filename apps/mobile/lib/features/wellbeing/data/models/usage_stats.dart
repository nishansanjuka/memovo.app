class AppUsage {
  final String appName;
  final int durationMinutes;
  final String category;

  AppUsage({
    required this.appName,
    required this.durationMinutes,
    required this.category,
  });

  Map<String, dynamic> toJson() => {
    'appName': appName,
    'durationMinutes': durationMinutes,
    'category': category,
  };

  factory AppUsage.fromJson(Map<String, dynamic> json) => AppUsage(
    appName: json['appName'],
    durationMinutes: json['durationMinutes'],
    category: json['category'],
  );
}
