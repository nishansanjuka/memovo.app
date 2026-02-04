import 'dart:io';
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usage_stats/usage_stats.dart';
import 'package:mobile/core/config/app_config.dart';
import 'package:mobile/features/wellbeing/data/models/usage_stats.dart';
import 'package:mobile/features/wellbeing/data/models/wellbeing_insight.dart';
import 'package:mobile/features/wellbeing/data/repositories/wellbeing_repository.dart';
import 'package:mobile/features/settings/presentation/providers/external_content_provider.dart';
import 'package:mobile/features/settings/data/models/external_content.dart';
import 'package:mobile/features/settings/data/repositories/external_content_repository.dart';

final wellbeingRepositoryProvider =
    Provider.family<WellbeingRepository, ClerkAuthState>((ref, auth) {
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

      return WellbeingRepository(dio);
    });

class WellbeingState {
  final List<AppUsage> usage;
  final WellbeingInsight? insight;
  final bool isLoading;
  final String? error;

  WellbeingState({
    required this.usage,
    this.insight,
    this.isLoading = false,
    this.error,
  });

  WellbeingState copyWith({
    List<AppUsage>? usage,
    WellbeingInsight? insight,
    bool? isLoading,
    String? error,
  }) {
    return WellbeingState(
      usage: usage ?? this.usage,
      insight: insight ?? this.insight,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class WellbeingNotifier extends StateNotifier<WellbeingState> {
  final WellbeingRepository _repository;
  final ExternalContentRepository? _externalRepository;
  final String _userId;

  WellbeingNotifier(this._repository, this._externalRepository, this._userId)
    : super(WellbeingState(usage: [])) {
    _init();
  }

  Future<void> _init() async {
    await fetchUsageAndInsights();
  }

  Future<void> fetchUsageAndInsights() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      List<AppUsage> realUsage = [];

      if (Platform.isAndroid) {
        // 1. Check and request Usage Access permission
        bool isPermissionGranted =
            await UsageStats.checkUsagePermission() ?? false;
        if (!isPermissionGranted) {
          await UsageStats.grantUsagePermission();
          // Give user time to return from settings
          state = state.copyWith(
            isLoading: false,
            error: "Please grant Usage Access to see real stats.",
          );
          return;
        }

        // 2. Fetch real stats for the last 24 hours
        DateTime endDate = DateTime.now();
        DateTime startDate = endDate.subtract(const Duration(days: 1));

        List<UsageInfo> tUsage = await UsageStats.queryUsageStats(
          startDate,
          endDate,
        );

        // Map native stats to our AppUsage model
        // We filter for apps with more than 1 minute of usage to keep it clean
        realUsage = tUsage
            .where(
              (info) =>
                  (int.tryParse(info.totalTimeInForeground ?? '0') ?? 0) >
                  60000,
            )
            .map((info) {
              // Extract a readable app name from package (simplified)
              String name = info.packageName?.split('.').last ?? 'Unknown';
              name = name[0].toUpperCase() + name.substring(1);

              int minutes =
                  (int.tryParse(info.totalTimeInForeground ?? '0') ?? 0) ~/
                  60000;

              return AppUsage(
                appName: name,
                durationMinutes: minutes,
                category: _guessCategory(info.packageName ?? ''),
              );
            })
            .toList();

        // Sort by usage time
        realUsage.sort(
          (a, b) => b.durationMinutes.compareTo(a.durationMinutes),
        );
        // Take top 5
        if (realUsage.length > 5) realUsage = realUsage.sublist(0, 5);
      } else {
        // iOS version still mock due to Apple's strict sandboxing (requires DeviceActivity entitlements)
        realUsage = [
          AppUsage(
            appName: 'Messaging',
            durationMinutes: 45,
            category: 'Social',
          ),
          AppUsage(
            appName: 'Productivity',
            durationMinutes: 120,
            category: 'Productivity',
          ),
          AppUsage(
            appName: 'Health',
            durationMinutes: 30,
            category: 'Wellness',
          ),
        ];
      }

      // 3. Fetch External Content (Spotify/YouTube) if available
      List<ExternalContent>? externalContent;
      if (_externalRepository != null) {
        try {
          final spotify = await _externalRepository.getRecentContent(
            ExternalPlatform.spotify,
          );
          final youtube = await _externalRepository.getRecentContent(
            ExternalPlatform.youtube,
          );
          externalContent = [...spotify, ...youtube];
        } catch (_) {
          // Ignore if integrations not connected
        }
      }

      // 4. Fetch Real Insights from Backend using REAL usage and content
      final insight = await _repository.getInsights(
        _userId,
        realUsage,
        externalContent: externalContent,
      );

      state = state.copyWith(
        usage: realUsage,
        insight: insight,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  String _guessCategory(String packageName) {
    if (packageName.contains('social') ||
        packageName.contains('instagram') ||
        packageName.contains('facebook') ||
        packageName.contains('twitter') ||
        packageName.contains('whatsapp')) {
      return 'Social';
    }
    if (packageName.contains('work') ||
        packageName.contains('office') ||
        packageName.contains('code') ||
        packageName.contains('notion') ||
        packageName.contains('mail')) {
      return 'Productivity';
    }
    if (packageName.contains('game') ||
        packageName.contains('video') ||
        packageName.contains('youtube') ||
        packageName.contains('netflix') ||
        packageName.contains('player')) {
      return 'Entertainment';
    }
    if (packageName.contains('health') ||
        packageName.contains('fit') ||
        packageName.contains('mind') ||
        packageName.contains('calm') ||
        packageName.contains('yoga')) {
      return 'Wellness';
    }
    return 'Other';
  }
}

final wellbeingProvider =
    StateNotifierProvider.family<
      WellbeingNotifier,
      WellbeingState,
      ({String userId, ClerkAuthState auth})
    >((ref, arg) {
      final repo = ref.watch(wellbeingRepositoryProvider(arg.auth));
      final externalRepo = ref.watch(
        externalContentRepositoryProvider(arg.auth),
      );
      return WellbeingNotifier(repo, externalRepo, arg.userId);
    });
