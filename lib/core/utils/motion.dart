import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// Reduced-motion helpers.
///
/// iOS "Reduce Motion" reaches Flutter as `MediaQuery.disableAnimations`.
/// Every animated surface in the app asks here for its duration rather than
/// using [AppDuration] directly, so honouring the setting is the default and
/// forgetting it is the exception (spec section 9).
abstract final class Motion {
  const Motion._();

  static bool isReduced(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  /// [duration], or zero when the user has asked for less motion.
  static Duration duration(BuildContext context, Duration duration) =>
      isReduced(context) ? Duration.zero : duration;

  static Duration fast(BuildContext context) =>
      duration(context, AppDuration.fast);

  static Duration normal(BuildContext context) =>
      duration(context, AppDuration.normal);

  static Duration slow(BuildContext context) =>
      duration(context, AppDuration.slow);
}
