import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';

/// Confirmation dialogs, in one place so destructive actions always look and
/// behave the same (spec: every destructive action is reversible or confirmed).
abstract final class AppDialogs {
  const AppDialogs._();

  /// Returns true only if the user explicitly confirms.
  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    bool destructive = false,
  }) async {
    final l10n = AppL10n.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        final scheme = Theme.of(context).colorScheme;
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.actionCancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: destructive
                  ? TextButton.styleFrom(foregroundColor: scheme.error)
                  : null,
              child: Text(confirmLabel),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }
}

/// Snack bars with a consistent shape. Returns the controller so callers can
/// await dismissal when they need to.
extension MessengerX on BuildContext {
  void showMessage(String message, {SnackBarAction? action}) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          action: action,
          duration: action == null
              ? const Duration(seconds: 3)
              : const Duration(seconds: 6),
        ),
      );
  }
}
