import 'package:dio/dio.dart';
import '../models/usage_stats.dart';
import '../models/wellbeing_insight.dart';

class WellbeingRepository {
  final Dio _dio;

  WellbeingRepository(this._dio);

  Future<WellbeingInsight> getInsights(
    String userId,
    List<AppUsage> currentUsage,
  ) async {
    final response = await _dio.post(
      '/llm/wellbeing/insights',
      data: {
        'userId': 'me', // Gateway injects real userId
        'currentUsage': currentUsage.map((u) => u.toJson()).toList(),
      },
    );
    return WellbeingInsight.fromJson(response.data);
  }
}
