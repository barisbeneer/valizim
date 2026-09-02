import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';

/// User defaults that pre-fill the trip wizard.
@immutable
class AppPreferences {
  const AppPreferences({
    this.defaultTravelerCount = 1,
    this.defaultDurationDays = 3,
  });

  final int defaultTravelerCount;
  final int defaultDurationDays;

  AppPreferences copyWith({int? defaultTravelerCount, int? defaultDurationDays}) {
    return AppPreferences(
      defaultTravelerCount: defaultTravelerCount ?? this.defaultTravelerCount,
      defaultDurationDays: defaultDurationDays ?? this.defaultDurationDays,
    );
  }
}

/// Persistence for [AppPreferences].
///
/// Values are clamped on read as well as write: a preferences file edited by
/// hand, or written by a build with different limits, must not be able to push
/// the wizard outside its valid range.
class AppPreferencesStore {
  AppPreferencesStore(this._prefs);

  static const String _travelersKey = 'prefs.default_travelers';
  static const String _durationKey = 'prefs.default_duration';

  final SharedPreferences _prefs;

  AppPreferences read() => AppPreferences(
        defaultTravelerCount: (_prefs.getInt(_travelersKey) ?? 1)
            .clamp(AppConfig.minTravelerCount, AppConfig.maxTravelerCount),
        defaultDurationDays: (_prefs.getInt(_durationKey) ?? 3)
            .clamp(AppConfig.minDurationDays, AppConfig.maxDurationDays),
      );

  Future<void> setDefaultTravelerCount(int value) async {
    await _prefs.setInt(
      _travelersKey,
      value.clamp(AppConfig.minTravelerCount, AppConfig.maxTravelerCount),
    );
  }

  Future<void> setDefaultDurationDays(int value) async {
    await _prefs.setInt(
      _durationKey,
      value.clamp(AppConfig.minDurationDays, AppConfig.maxDurationDays),
    );
  }

  Future<void> reset() async {
    await _prefs.remove(_travelersKey);
    await _prefs.remove(_durationKey);
  }
}
