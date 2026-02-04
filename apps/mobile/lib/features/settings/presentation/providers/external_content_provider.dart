import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/config/app_config.dart';
import 'package:mobile/features/settings/data/models/external_content.dart';
import 'package:mobile/features/settings/data/repositories/external_content_repository.dart';

final externalContentRepositoryProvider =
    Provider.family<ExternalContentRepository, ClerkAuthState>((ref, auth) {
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
            if (token.jwt.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer ${token.jwt}';
            }
            return handler.next(options);
          },
        ),
      );

      return ExternalContentRepository(dio);
    });

class ExternalContentState {
  final List<ExternalContent> spotifyContent;
  final List<ExternalContent> youtubeContent;
  final bool isLoading;
  final String? error;

  ExternalContentState({
    this.spotifyContent = const [],
    this.youtubeContent = const [],
    this.isLoading = false,
    this.error,
  });

  ExternalContentState copyWith({
    List<ExternalContent>? spotifyContent,
    List<ExternalContent>? youtubeContent,
    bool? isLoading,
    String? error,
  }) {
    return ExternalContentState(
      spotifyContent: spotifyContent ?? this.spotifyContent,
      youtubeContent: youtubeContent ?? this.youtubeContent,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class ExternalContentNotifier extends StateNotifier<ExternalContentState> {
  final ExternalContentRepository _repository;

  ExternalContentNotifier(this._repository) : super(ExternalContentState());

  Future<void> refreshContent() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final spotify = await _repository.getRecentContent(
        ExternalPlatform.spotify,
      );
      final youtube = await _repository.getRecentContent(
        ExternalPlatform.youtube,
      );

      state = state.copyWith(
        spotifyContent: spotify,
        youtubeContent: youtube,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  String getAuthUrl(ExternalPlatform platform) {
    return AppConfig.gatewayUrl + _repository.getAuthorizeUrl(platform);
  }
}

final externalContentProvider =
    StateNotifierProvider.family<
      ExternalContentNotifier,
      ExternalContentState,
      ClerkAuthState
    >((ref, auth) {
      final repo = ref.watch(externalContentRepositoryProvider(auth));
      return ExternalContentNotifier(repo);
    });
