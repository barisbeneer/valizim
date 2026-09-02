import 'package:flutter/material.dart';

/// Layout decisions that depend on the user's text size.
///
/// A label-next-to-control row that fits comfortably at the default text size
/// has no room left at accessibility sizes, especially once strings are
/// translated - Turkish labels here run roughly a third longer than English.
/// Rather than shrink or truncate, those layouts stack, which is what iOS
/// itself does in Settings at large type.
abstract final class AppLayout {
  const AppLayout._();

  /// Above this scale, side-by-side layouts become stacked ones. Chosen so the
  /// switch happens before any supported label/control pair can collide.
  static const double stackAboveTextScale = 1.3;

  static double textScale(BuildContext context) =>
      MediaQuery.textScalerOf(context).scale(1);

  static bool isStacked(BuildContext context) =>
      textScale(context) > stackAboveTextScale;
}
