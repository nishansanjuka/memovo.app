import 'package:dio/dio.dart';
import 'package:mobile/features/journal/data/models/journal_model.dart';
import 'package:mobile/core/config/app_config.dart';

class JournalRepository {
  final Dio _dio;
  final String _baseUrl = '${AppConfig.gatewayUrl}/api/v1/journals';

  JournalRepository(this._dio);

  Future<List<JournalEntry>> getJournals(String userId) async {
    try {
      print('DEBUG: JournalRepo.getJournals -> Attempting call to $_baseUrl');
      final response = await _dio.get(
        _baseUrl,
        queryParameters: {'userId': userId},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        print(
          'DEBUG: JournalRepo.getJournals SUCCESS -> Received ${data.length} entries',
        );
        return data.map((json) => JournalEntry.fromJson(json)).toList();
      }
      throw Exception('Failed to load journals: ${response.statusCode}');
    } catch (e, st) {
      print('DEBUG: JournalRepo.getJournals ERROR: $e');
      print('DEBUG: JournalRepo.getJournals STACK: $st');
      rethrow;
    }
  }

  Future<JournalEntry> createJournal(JournalEntry entry) async {
    try {
      final response = await _dio.post(_baseUrl, data: entry.toJson());
      if (response.statusCode == 201) {
        return JournalEntry.fromJson(response.data);
      }
      throw Exception('Failed to create journal');
    } catch (e) {
      rethrow;
    }
  }

  Future<JournalEntry> updateJournal(
    String journalId,
    JournalEntry entry,
  ) async {
    try {
      final response = await _dio.put(
        '$_baseUrl/$journalId',
        data: entry.toJson(),
      );
      if (response.statusCode == 200) {
        return JournalEntry.fromJson(response.data);
      }
      throw Exception('Failed to update journal');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteJournal(String journalId) async {
    try {
      final response = await _dio.delete('$_baseUrl/$journalId');
      if (response.statusCode != 204 && response.statusCode != 200) {
        throw Exception('Failed to delete journal');
      }
    } catch (e) {
      rethrow;
    }
  }
}
