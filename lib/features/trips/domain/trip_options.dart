import 'dart:convert';

import '../../../core/config/app_config.dart';
import '../../../core/utils/parse.dart';

/// Toggles from the trip wizard that change what gets generated.
class PackingOptions {
  const PackingOptions({
    this.swimming = false,
    this.formalEvent = false,
    this.work = false,
    this.laundry = false,
  });

  final bool swimming;
  final bool formalEvent;
  final bool work;

  /// Laundry access caps day-scaled clothing instead of adding more of it.
  final bool laundry;

  /// Option ids, in a fixed order, so generation stays deterministic.
  List<String> get enabledIds => <String>[
        if (swimming) 'swimming',
        if (formalEvent) 'formalEvent',
        if (work) 'work',
        if (laundry) 'laundry',
      ];

  PackingOptions copyWith({
    bool? swimming,
    bool? formalEvent,
    bool? work,
    bool? laundry,
  }) {
    return PackingOptions(
      swimming: swimming ?? this.swimming,
      formalEvent: formalEvent ?? this.formalEvent,
      work: work ?? this.work,
      laundry: laundry ?? this.laundry,
    );
  }

  Map<String, Object?> toMap() => <String, Object?>{
        'swimming': swimming,
        'formalEvent': formalEvent,
        'work': work,
        'laundry': laundry,
      };

  static PackingOptions fromMap(Map<String, Object?> map) => PackingOptions(
        swimming: map['swimming'] == true,
        formalEvent: map['formalEvent'] == true,
        work: map['work'] == true,
        laundry: map['laundry'] == true,
      );

  @override
  bool operator ==(Object other) =>
      other is PackingOptions &&
      other.swimming == swimming &&
      other.formalEvent == formalEvent &&
      other.work == work &&
      other.laundry == laundry;

  @override
  int get hashCode => Object.hash(swimming, formalEvent, work, laundry);
}

/// Per-trip local reminder preferences.
///
/// The departure time is only ever surfaced in the reminder sheet: it exists to
/// anchor notifications, not to complicate the create flow.
class ReminderSettings {
  const ReminderSettings({
    this.dayBefore = false,
    this.hoursBefore = false,
    this.departureHour = AppConfig.defaultDepartureHour,
    this.departureMinute = AppConfig.defaultDepartureMinute,
  });

  /// 24 hours before departure.
  final bool dayBefore;

  /// 3 hours before departure.
  final bool hoursBefore;

  final int departureHour;
  final int departureMinute;

  bool get anyEnabled => dayBefore || hoursBefore;

  ReminderSettings copyWith({
    bool? dayBefore,
    bool? hoursBefore,
    int? departureHour,
    int? departureMinute,
  }) {
    return ReminderSettings(
      dayBefore: dayBefore ?? this.dayBefore,
      hoursBefore: hoursBefore ?? this.hoursBefore,
      departureHour: departureHour ?? this.departureHour,
      departureMinute: departureMinute ?? this.departureMinute,
    );
  }

  Map<String, Object?> toMap() => <String, Object?>{
        'dayBefore': dayBefore,
        'hoursBefore': hoursBefore,
        'departureHour': departureHour,
        'departureMinute': departureMinute,
      };

  static ReminderSettings fromMap(Map<String, Object?> map) {
    final hour = asInt(map['departureHour']) ?? AppConfig.defaultDepartureHour;
    final minute =
        asInt(map['departureMinute']) ?? AppConfig.defaultDepartureMinute;
    return ReminderSettings(
      dayBefore: map['dayBefore'] == true,
      hoursBefore: map['hoursBefore'] == true,
      departureHour: hour.clamp(0, 23),
      departureMinute: minute.clamp(0, 59),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ReminderSettings &&
      other.dayBefore == dayBefore &&
      other.hoursBefore == hoursBefore &&
      other.departureHour == departureHour &&
      other.departureMinute == departureMinute;

  @override
  int get hashCode =>
      Object.hash(dayBefore, hoursBefore, departureHour, departureMinute);
}

/// Everything stored in `Trips.optionsJson`.
///
/// Serialization is versioned and defensive: an unreadable or partially written
/// blob degrades to defaults rather than throwing, because a corrupt options
/// field must never make a trip unopenable (spec section 5).
class TripSettings {
  const TripSettings({
    this.packing = const PackingOptions(),
    this.reminders = const ReminderSettings(),
  });

  static const int _version = 1;

  final PackingOptions packing;
  final ReminderSettings reminders;

  TripSettings copyWith({
    PackingOptions? packing,
    ReminderSettings? reminders,
  }) {
    return TripSettings(
      packing: packing ?? this.packing,
      reminders: reminders ?? this.reminders,
    );
  }

  String encode() => jsonEncode(<String, Object?>{
        'v': _version,
        'packing': packing.toMap(),
        'reminders': reminders.toMap(),
      });

  static TripSettings decode(String? raw) {
    if (raw == null || raw.isEmpty) return const TripSettings();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, Object?>) return const TripSettings();
      final packing = decoded['packing'];
      final reminders = decoded['reminders'];
      return TripSettings(
        packing: packing is Map<String, Object?>
            ? PackingOptions.fromMap(packing)
            : const PackingOptions(),
        reminders: reminders is Map<String, Object?>
            ? ReminderSettings.fromMap(reminders)
            : const ReminderSettings(),
      );
    } on FormatException {
      return const TripSettings();
    }
  }

  @override
  bool operator ==(Object other) =>
      other is TripSettings &&
      other.packing == packing &&
      other.reminders == reminders;

  @override
  int get hashCode => Object.hash(packing, reminders);
}

