import 'dart:io';
import 'package:clerk_auth/clerk_auth.dart' as clerk;
import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for the current Clerk User
/// This basically bridges ClerkAuth with Riverpod for easier access
final userProvider = Provider<clerk.User?>((ref) {
  // We'll pass the user from the UI layer to keep it synchronized with Clerk's InheritedWidget
  return null;
});

/// State notifier for profile editing
class ProfileEditNotifier extends StateNotifier<AsyncValue<void>> {
  final ClerkAuthState authState;

  ProfileEditNotifier(this.authState) : super(const AsyncValue.data(null));

  Future<void> updateProfile({String? firstName, String? lastName}) async {
    state = const AsyncValue.loading();
    try {
      await authState.updateUser(firstName: firstName, lastName: lastName);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateProfileImage(File imageFile) async {
    state = const AsyncValue.loading();
    try {
      await authState.updateUserImage(imageFile);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final profileEditProvider =
    StateNotifierProvider.family<
      ProfileEditNotifier,
      AsyncValue<void>,
      ClerkAuthState
    >((ref, auth) {
      return ProfileEditNotifier(auth);
    });
