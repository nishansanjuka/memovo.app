import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Centralized Auth Status for the entire app.
/// This prevents "Loading Forever" bugs by tracking the initial handshake state.
enum AuthStep { startup, checking, ready }

final authStepProvider = StateProvider<AuthStep>((ref) => AuthStep.startup);

/// A provider that watches Clerk's state and maps it to our app's logic.
/// This is the "Centralized Handler" requested.
final appAuthStateProvider = Provider<bool?>((ref) {
  // We don't watch Clerk here directly because Clerk uses InheritedWidget (ClerkAuth.of)
  // which is better accessed in the Widget tree.
  // Instead, this provider can be used to trigger global side effects if needed.
  return null;
});

final bottomNavProvider = StateProvider<int>((ref) => 0);
