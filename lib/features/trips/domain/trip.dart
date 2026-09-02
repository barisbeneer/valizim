import '../../../core/utils/trip_date.dart';
import 'item_category.dart';
import 'trip_options.dart';
import 'trip_type.dart';

/// A trip as the UI sees it: database columns with the options blob already
/// decoded.
class Trip {
  const Trip({
    required this.id,
    required this.name,
    required this.tripType,
    required this.durationDays,
    required this.travelerCount,
    required this.settings,
    required this.createdAt,
    required this.updatedAt,
    this.startDate,
    this.archived = false,
  });

  final String id;
  final String name;
  final TripType tripType;

  /// UTC midnight of the departure calendar day. See [TripDate].
  final DateTime? startDate;

  final int durationDays;
  final int travelerCount;
  final TripSettings settings;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool archived;

  PackingOptions get options => settings.packing;

  ReminderSettings get reminders => settings.reminders;

  bool get hasStartDate => startDate != null;

  /// Days until departure, or null when no date is set.
  int? daysUntilStart({DateTime? now}) {
    final start = startDate;
    return start == null ? null : TripDate.daysFromToday(start, now: now);
  }

  /// A trip is "past" once its final day is behind us. Archived trips are
  /// always treated as past regardless of date.
  bool isPast({DateTime? now}) {
    if (archived) return true;
    final start = startDate;
    if (start == null) return false;
    return TripDate.isPast(start, durationDays, now: now);
  }

  Trip copyWith({
    String? name,
    TripType? tripType,
    Object? startDate = _unset,
    int? durationDays,
    int? travelerCount,
    TripSettings? settings,
    DateTime? updatedAt,
    bool? archived,
  }) {
    return Trip(
      id: id,
      name: name ?? this.name,
      tripType: tripType ?? this.tripType,
      startDate:
          identical(startDate, _unset) ? this.startDate : startDate as DateTime?,
      durationDays: durationDays ?? this.durationDays,
      travelerCount: travelerCount ?? this.travelerCount,
      settings: settings ?? this.settings,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archived: archived ?? this.archived,
    );
  }

  static const Object _unset = Object();
}

/// One checklist row.
class TripItem {
  const TripItem({
    required this.id,
    required this.tripId,
    required this.label,
    required this.category,
    required this.quantity,
    required this.sortOrder,
    this.checked = false,
    this.isEssential = false,
    this.ruleKey,
  });

  final String id;
  final String tripId;

  /// Stored label. For generated rows this is the English fallback; prefer
  /// resolving through [ruleKey] when a localized catalogue is available.
  final String label;

  final ItemCategory category;
  final int quantity;
  final bool checked;
  final bool isEssential;
  final int sortOrder;

  /// Null for rows the user typed themselves.
  final String? ruleKey;

  bool get isUserAdded => ruleKey == null;

  TripItem copyWith({
    String? label,
    ItemCategory? category,
    int? quantity,
    bool? checked,
    bool? isEssential,
    int? sortOrder,
  }) {
    return TripItem(
      id: id,
      tripId: tripId,
      label: label ?? this.label,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      checked: checked ?? this.checked,
      isEssential: isEssential ?? this.isEssential,
      sortOrder: sortOrder ?? this.sortOrder,
      ruleKey: ruleKey,
    );
  }
}

/// A trip plus its items, which is what every list screen actually needs.
class TripWithItems {
  const TripWithItems({required this.trip, required this.items});

  final Trip trip;
  final List<TripItem> items;

  int get total => items.length;

  int get packed => items.where((TripItem item) => item.checked).length;

  int get remaining => total - packed;

  bool get isComplete => total > 0 && packed == total;

  /// 0.0 to 1.0. An empty list reads as 0, never NaN.
  double get progress => total == 0 ? 0 : packed / total;

  /// Percentage rounded for display. Only reaches 100 when genuinely complete,
  /// so a 199/200 list does not claim to be finished.
  int get progressPercent {
    if (total == 0) return 0;
    if (packed == total) return 100;
    final value = (progress * 100).floor();
    return value >= 100 ? 99 : value;
  }

  /// Items grouped into sections, in display order, skipping empty sections.
  Map<ItemCategory, List<TripItem>> get grouped {
    final map = <ItemCategory, List<TripItem>>{};
    for (final category in ItemCategory.ordered) {
      final matching =
          items.where((TripItem item) => item.category == category).toList();
      if (matching.isNotEmpty) map[category] = matching;
    }
    return map;
  }

  /// Essentials the user has not ticked yet - the "don't leave without this"
  /// set used by reminders and the share card.
  List<TripItem> get unpackedEssentials => items
      .where((TripItem item) => item.isEssential && !item.checked)
      .toList();
}
