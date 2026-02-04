import 'package:dio/dio.dart';
import '../models/external_content.dart';

class ExternalContentRepository {
  final Dio _dio;

  ExternalContentRepository(this._dio);

  Future<List<ExternalContent>> getRecentContent(
    ExternalPlatform platform,
  ) async {
    final response = await _dio.get(
      '/api/v1/external-content/${platform.name.toUpperCase()}?userId=me',
    );
    final List<dynamic> data = response.data;
    return data.map((json) => ExternalContent.fromJson(json)).toList();
  }

  String getAuthorizeUrl(ExternalPlatform platform) {
    return '/api/v1/external-auth/authorize/${platform.name.toUpperCase()}?userId=me';
  }
}
