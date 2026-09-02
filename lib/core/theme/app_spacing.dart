/// 8pt spacing grid (spec section 9).
///
/// Every gap, pad and inset in the app resolves to one of these values so
/// rhythm stays consistent across screens and future studio apps.
abstract final class AppSpacing {
  const AppSpacing._();

  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  /// Horizontal page gutter. Wide enough to breathe, narrow enough that lists
  /// still feel full-bleed on small phones.
  static const double pageGutter = 20;

  /// Minimum tap target, in logical points (spec section 9).
  static const double minTapTarget = 44;

  /// Extra bottom padding so a floating primary action never covers content.
  static const double floatingActionClearance = 96;
}

/// Corner radii. Rounded cards are part of the visual signature.
abstract final class AppRadius {
  const AppRadius._();

  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double pill = 999;
}

/// Animation durations. Every one of these is bypassed when the platform
/// reports `disableAnimations`; see [ReducedMotion].
abstract final class AppDuration {
  const AppDuration._();

  static const Duration instant = Duration.zero;
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
}
