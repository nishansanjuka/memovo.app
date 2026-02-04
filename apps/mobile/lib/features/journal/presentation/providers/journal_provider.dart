import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/config/app_config.dart';
import 'package:mobile/features/journal/data/models/journal_model.dart';
import 'package:mobile/features/journal/data/repositories/journal_repository.dart';
import 'package:mobile/features/therapy/data/repositories/therapy_repository.dart';
import 'package:mobile/features/therapy/presentation/providers/therapy_provider.dart';

final journalRepositoryProvider =
    Provider.family<JournalRepository, ClerkAuthState>((ref, auth) {
      final dio = Dio(
        BaseOptions(
          baseUrl: AppConfig.gatewayUrl,
          connectTimeout: AppConfig.connectTimeout,
          receiveTimeout: AppConfig.receiveTimeout,
        ),
      );

      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            print(
              'DEBUG: Journal API Request -> ${options.method} ${options.uri}',
            );
            final session = auth.session;
            if (session != null) {
              try {
                final token = await auth.sessionToken();
                final tokenStr = token.jwt;
                if (tokenStr.isNotEmpty) {
                  options.headers['Authorization'] = 'Bearer $tokenStr';
                  print(
                    'DEBUG: Applied Bearer Token (length: ${tokenStr.length})',
                  );
                } else {
                  print('DEBUG: Token retrieved is NULL or EMPTY');
                }
              } catch (e) {
                print('DEBUG: Auth Error getting token: $e');
              }
            } else {
              print('DEBUG: No active Clerk session found');
            }
            return handler.next(options);
          },
        ),
      );

      return JournalRepository(dio);
    });

class JournalNotifier extends StateNotifier<AsyncValue<List<JournalEntry>>> {
  final JournalRepository _repository;
  final TherapyRepository _therapyRepository;
  final String _userId;

  JournalNotifier(this._repository, this._therapyRepository, this._userId)
    : super(const AsyncValue.loading()) {
    loadJournals();
  }

  Future<void> loadJournals() async {
    state = const AsyncValue.loading();
    try {
      final journals = await _repository.getJournals(_userId);
      state = AsyncValue.data(journals);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addEntry(
    String title,
    String content, {
    String? mood,
    List<String> tags = const [],
  }) async {
    try {
      final newEntry = JournalEntry(
        userId: _userId,
        title: title,
        content: content,
        mood: mood,
        tags: tags,
      );
      final created = await _repository.createJournal(newEntry);

      state.whenData((journals) {
        state = AsyncValue.data([created, ...journals]);
      });

      // Also create semantic memory
      _therapyRepository
          .createSemanticMemory(
            userId: _userId,
            content: "Journal Entry: $title\n\n$content",
            metadata: {
              'type': 'journal',
              'journal_id': created.id,
              'mood': mood,
              'tags': tags,
            },
          )
          .catchError((e) {
            print('DEBUG: Failed to create semantic memory for journal: $e');
          });
    } catch (e) {
      // Handle error
    }
  }

  Future<void> updateEntry(JournalEntry entry) async {
    try {
      final updated = await _repository.updateJournal(entry.id!, entry);
      state.whenData((journals) {
        state = AsyncValue.data(
          journals.map((e) => e.id == updated.id ? updated : e).toList(),
        );
      });
    } catch (e) {
      // Handle error
    }
  }

  Future<void> deleteEntry(String id) async {
    try {
      await _repository.deleteJournal(id);
      state.whenData((journals) {
        state = AsyncValue.data(journals.where((e) => e.id != id).toList());
      });
    } catch (e) {
      // Handle error
    }
  }
}

final journalProvider =
    StateNotifierProvider.family<
      JournalNotifier,
      AsyncValue<List<JournalEntry>>,
      ClerkAuthState
    >((ref, auth) {
      final repo = ref.watch(journalRepositoryProvider(auth));
      final therapyRepo = ref.watch(therapyRepositoryProvider(auth));
      final userId = auth.user?.id ?? '';
      return JournalNotifier(repo, therapyRepo, userId);
    });
