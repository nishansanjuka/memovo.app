import 'dart:async';
import 'dart:convert';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/config/app_config.dart';
import 'package:mobile/features/therapy/data/models/chat_message.dart';
import 'package:mobile/features/therapy/data/models/chat_session.dart';
import 'package:mobile/features/therapy/data/repositories/therapy_repository.dart';
import 'package:uuid/uuid.dart';

class TherapyProviderKey {
  final String userId;
  final ClerkAuthState auth;

  TherapyProviderKey({required this.userId, required this.auth});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TherapyProviderKey &&
          runtimeType == other.runtimeType &&
          userId == other.userId;

  @override
  int get hashCode => userId.hashCode;
}

final therapyRepositoryProvider =
    Provider.family<TherapyRepository, ClerkAuthState>((ref, auth) {
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
            final token = await auth.sessionToken();
            final tokenStr = token.jwt;
            if (tokenStr.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $tokenStr';
            }
            return handler.next(options);
          },
        ),
      );

      return TherapyRepository(dio);
    });

class ChatState {
  final List<ChatMessage> messages;
  final List<ChatSession> sessions;
  final String? currentChatId;
  final bool isGenerating;
  final String status;

  ChatState({
    required this.messages,
    this.sessions = const [],
    this.currentChatId,
    this.isGenerating = false,
    this.status = '',
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    List<ChatSession>? sessions,
    String? currentChatId,
    bool? isGenerating,
    String? status,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      sessions: sessions ?? this.sessions,
      currentChatId: currentChatId ?? this.currentChatId,
      isGenerating: isGenerating ?? this.isGenerating,
      status: status ?? this.status,
    );
  }
}

class TherapyNotifier extends StateNotifier<ChatState> {
  final TherapyRepository _repository;
  final String _userId;

  TherapyNotifier(this._repository, this._userId)
    : super(ChatState(messages: [], currentChatId: null)) {
    _init();
  }

  Future<void> _init() async {
    if (_userId.isEmpty) return;

    await loadSessions();

    if (state.currentChatId == null) {
      if (state.sessions.isNotEmpty) {
        await switchChat(state.sessions.first.id);
      } else {
        await newChat();
      }
    } else {
      await loadHistory();
    }
  }

  Future<void> loadSessions() async {
    try {
      final sessions = await _repository.getSessions(_userId);
      state = state.copyWith(sessions: sessions);
    } catch (e) {
      print('Error loading sessions: $e');
    }
  }

  Future<void> switchChat(String chatId) async {
    if (state.currentChatId == chatId) return;
    state = state.copyWith(currentChatId: chatId, messages: [], status: '');
    await loadHistory();
  }

  Future<void> loadHistory() async {
    if (state.currentChatId == null) return;
    try {
      final messages = await _repository.getHistory(
        _userId,
        chatId: state.currentChatId!,
      );
      messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      state = state.copyWith(messages: messages);
    } catch (e) {
      print('Error loading history: $e');
    }
  }

  Future<void> newChat() async {
    final newId = const Uuid().v4();
    state = state.copyWith(currentChatId: newId, messages: [], status: '');
    // No need to create on server yet, it happens on first message
    // but update sessions list to show it if needed
    await loadSessions();
  }

  Future<void> deleteChat(String chatId) async {
    try {
      await _repository.deleteSession(chatId);
      final newSessions = state.sessions.where((s) => s.id != chatId).toList();
      String? nextChatId;
      if (state.currentChatId == chatId) {
        nextChatId = newSessions.isNotEmpty ? newSessions.first.id : null;
      } else {
        nextChatId = state.currentChatId;
      }

      state = state.copyWith(
        sessions: newSessions,
        currentChatId: nextChatId,
        messages: nextChatId == null ? [] : state.messages,
      );

      if (nextChatId != null && nextChatId != state.currentChatId) {
        await loadHistory();
      } else if (nextChatId == null) {
        await newChat();
      }
    } catch (e) {
      print('Error deleting chat: $e');
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessage(
      id: const Uuid().v4(),
      content: text,
      sender: 'user',
      createdAt: DateTime.now(),
    );

    final aiPlaceholder = ChatMessage(
      id: 'ai-typing',
      content: '',
      sender: 'ai',
      createdAt: DateTime.now(),
      isStreaming: true,
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage, aiPlaceholder],
      isGenerating: true,
      status: 'Initializing...',
    );

    String fullAiContent = '';

    try {
      final stream = _repository.chatStream(
        userId: _userId,
        chatId: state.currentChatId ?? 'default',
        message: text,
      );

      await for (final line in stream) {
        final lines = line.split('\n');
        for (var rawLine in lines) {
          if (rawLine.trim().isEmpty) continue;

          try {
            final data = json.decode(rawLine);
            final type = data['type'];

            if (type == 'status') {
              final statusMsg = data['message'] ?? '';
              state = state.copyWith(status: statusMsg);
              if (data['status'] == 'retrieving_working') {
                await loadSessions();
              }
            } else if (type == 'chunk') {
              final chunk = data['content'] ?? '';
              fullAiContent += chunk;
              _updateAiMessage(fullAiContent);
            } else if (type == 'data' && data['key'] == 'working_memory') {
              // Only sync history once at the beginning to avoid duplication
              final List<dynamic> memoryData = data['value'];
              final synced = memoryData.map((json) {
                final chat = json['chat'] ?? {};
                return ChatMessage(
                  id: json['id'],
                  content: chat['content'] ?? '',
                  sender: chat['role'] == 'user' ? 'user' : 'ai',
                  createdAt:
                      DateTime.tryParse(chat['timestamp'] ?? '') ??
                      DateTime.now(),
                );
              }).toList();
              synced.sort((a, b) => a.createdAt.compareTo(b.createdAt));

              state = state.copyWith(
                messages: [
                  ...synced,
                  if (state.isGenerating)
                    aiPlaceholder.copyWith(content: fullAiContent),
                ],
              );
            }
          } catch (e) {
            print('Error decoding stream line: $e');
          }
        }
      }

      // Finalize the localized streaming message
      final finalizedMessages = state.messages.map((m) {
        if (m.id == 'ai-typing') {
          return m.copyWith(
            id: const Uuid().v4(),
            content: fullAiContent,
            isStreaming: false,
          );
        }
        return m;
      }).toList();

      state = state.copyWith(
        messages: finalizedMessages,
        isGenerating: false,
        status: '',
      );

      await loadSessions();
    } catch (e) {
      state = state.copyWith(
        isGenerating: false,
        status: 'Error: ${e.toString()}',
      );
    }
  }

  void _updateAiMessage(String content) {
    bool found = false;
    final newMessages = state.messages.map((m) {
      if (m.id == 'ai-typing') {
        found = true;
        return m.copyWith(content: content);
      }
      return m;
    }).toList();

    if (found) {
      state = state.copyWith(messages: newMessages);
    } else {
      state = state.copyWith(
        messages: [
          ...state.messages,
          ChatMessage(
            id: 'ai-typing',
            content: content,
            sender: 'ai',
            createdAt: DateTime.now(),
            isStreaming: true,
          ),
        ],
      );
    }
  }
}

final therapyProvider =
    StateNotifierProvider.family<
      TherapyNotifier,
      ChatState,
      TherapyProviderKey
    >((ref, key) {
      final repo = ref.watch(therapyRepositoryProvider(key.auth));
      return TherapyNotifier(repo, key.userId);
    });
