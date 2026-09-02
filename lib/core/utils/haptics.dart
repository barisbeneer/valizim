import 'package:flutter/services.dart';

/// Tactile feedback, in one place so it stays consistent and sparing.
///
/// Used only to confirm a state change the user caused - ticking an item,
/// completing a list, hitting a limit. Never decorative.
abstract final class Haptics {
  const Haptics._();

  /// An item was ticked or unticked.
  static void selection() => unawaited(HapticFeedback.selectionClick());

  /// A destructive or blocking outcome: a limit reached, an error.
  static void warning() => unawaited(HapticFeedback.heavyImpact());

  /// A meaningful success: the list is fully packed, a purchase completed.
  static void success() => unawaited(HapticFeedback.mediumImpact());

  static void unawaited(Future<void> future) {
    // Haptics are advisory. A platform that cannot deliver them must not
    // surface an unhandled rejection.
    future.catchError((Object _) {});
  }
}
