import 'package:dio/dio.dart';
import 'package:mobile/features/settings/data/models/external_content.dart';
import '../models/usage_stats.dart';
import '../models/wellbeing_insight.dart';

class WellbeingRepository {
  final Dio _dio;

  WellbeingRepository(this._dio);

  Future<WellbeingInsight> getInsights(
    String userId,
    List<AppUsage> currentUsage, {
    List<ExternalContent>? externalContent,
  }) async {
    final response = await _dio.post(
      '/llm/wellbeing/insights',
      data: {
        'userId': 'me', // Gateway injects real userId
        'currentUsage': currentUsage.map((u) => u.toJson()).toList(),
        if (externalContent != null)
          'externalContent': externalContent
              .map(
                (c) => {
                  'id': c.id,
                  'title': c.title,
                  'artistOrChannel': c.artistOrChannel,
                  'thumbnailUrl': c.thumbnailUrl,
                  'externalUrl': c.externalUrl,
                  'platform': c.platform.name.toUpperCase(),
                },
              )
              .toList(),
      },
    );
    return WellbeingInsight.fromJson(response.data);
  }
}
