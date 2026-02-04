import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:mobile/core/config/app_config.dart';
import 'package:mobile/features/therapy/data/models/chat_message.dart';
import 'package:mobile/features/therapy/data/models/chat_session.dart';

class TherapyRepository {
  final Dio _dio;
  final String _baseUrl = AppConfig.gatewayUrl;

  TherapyRepository(this._dio);

  Stream<String> chatStream({
    required String userId,
    required String chatId,
    required String message,
  }) async* {
    final response = await _dio.post(
      '$_baseUrl/llm/chat',
      data: {'userId': userId, 'chatId': chatId, 'prompt': message},
      options: Options(responseType: ResponseType.stream),
    );

    yield* (response.data.stream as Stream)
        .cast<List<int>>()
        .transform(utf8.decoder)
        .transform(const LineSplitter());
  }

  Future<List<ChatSession>> getSessions(String userId) async {
    final response = await _dio.get('$_baseUrl/llm/sessions/user/$userId');
    final List<dynamic> data = response.data;
    return data.map((json) => ChatSession.fromJson(json)).toList();
  }

  Future<List<ChatMessage>> getHistory(String userId, {String? chatId}) async {
    final url = chatId != null
        ? '$_baseUrl/llm/working-memory/user/$userId/session/$chatId'
        : '$_baseUrl/llm/working-memory/user/$userId';

    final response = await _dio.get(url);
    final List<dynamic> data = response.data;
    return data.map((json) {
      final chat = json['chat'];
      return ChatMessage(
        id: json['id'],
        content: chat['content'] ?? '',
        sender: chat['role'] == 'user' ? 'user' : 'ai',
        createdAt: DateTime.tryParse(chat['timestamp'] ?? '') ?? DateTime.now(),
      );
    }).toList();
  }

  Future<void> deleteSession(String chatId) async {
    await _dio.delete('$_baseUrl/llm/sessions/$chatId');
  }

  Future<void> createSemanticMemory({
    required String userId,
    required String content,
    Map<String, dynamic>? metadata,
  }) async {
    await _dio.post(
      '$_baseUrl/llm/semantic-memory',
      data: {'userId': userId, 'content': content, 'metadata': metadata ?? {}},
    );
  }
}
