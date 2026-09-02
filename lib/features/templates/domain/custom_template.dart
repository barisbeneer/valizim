import 'dart:convert';

import '../../../core/config/app_config.dart';
import '../../../core/utils/parse.dart';
import '../../trips/domain/item_category.dart';
import '../../trips/domain/trip.dart';
import '../../trips/domain/trip_type.dart';

/// One row inside a saved template.
///
/// A template stores resolved labels rather than rule keys, because it captures
/// a list the user shaped by hand - including items that have no rule.
class TemplateItem {
  const TemplateItem({
    required this.label,
    required this.category,
    required this.quantity,
    this.isEssential = false,
    this.sortOrder = 0,
    this.ruleKey,
  });

  final String label;
  final ItemCategory category;
  final int quantity;
  final bool isEssential;
  final int sortOrder;

  /// Preserved when present so built-in items still re-localize.
  final String? ruleKey;

  Map<String, Object?> toMap() => <String, Object?>{
        'label': label,
        'category': category.id,
        'quantity': quantity,
        'isEssential': isEssential,
        'sortOrder': sortOrder,
        if (ruleKey != null) 'ruleKey': ruleKey,
      };

  static TemplateItem? fromMap(Object? raw) {
    if (raw is! Map<String, Object?>) return null;
    final label = asText(raw['label']);
    if (label == null) return null;
    return TemplateItem(
      label: label.length > AppConfig.maxItemLabelLength
          ? label.substring(0, AppConfig.maxItemLabelLength)
          : label,
      category: ItemCategory.fromId(asText(raw['category'])),
      quantity: (asInt(raw['quantity']) ?? 1).clamp(1, AppConfig.maxItemQuantity),
      isEssential: raw['isEssential'] == true,
      sortOrder: asInt(raw['sortOrder']) ?? 0,
      ruleKey: asText(raw['ruleKey']),
    );
  }

  static TemplateItem fromTripItem(TripItem item) => TemplateItem(
        label: item.label,
        category: item.category,
        quantity: item.quantity,
        isEssential: item.isEssential,
        sortOrder: item.sortOrder,
        ruleKey: item.ruleKey,
      );
}

/// A user-saved template (Pro).
class CustomTemplate {
  const CustomTemplate({
    required this.id,
    required this.name,
    required this.items,
    required this.createdAt,
    this.tripType,
  });

  final String id;
  final String name;
  final TripType? tripType;
  final List<TemplateItem> items;
  final DateTime createdAt;

  int get itemCount => items.length;

  /// Serialises the item list for the `items_json` column.
  static String encodeItems(List<TemplateItem> items) => jsonEncode(
        items.map((TemplateItem item) => item.toMap()).toList(),
      );

  /// Decodes defensively: a malformed or partially written blob yields the
  /// rows it can read rather than throwing, so one bad template can never make
  /// the templates screen unopenable (spec section 5).
  static List<TemplateItem> decodeItems(String? raw) {
    if (raw == null || raw.isEmpty) return const <TemplateItem>[];
    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException {
      return const <TemplateItem>[];
    }
    if (decoded is! List<Object?>) return const <TemplateItem>[];
    final items = <TemplateItem>[];
    for (final entry in decoded) {
      final item = TemplateItem.fromMap(entry);
      if (item != null) items.add(item);
      if (items.length >= AppConfig.maxItemsPerTrip) break;
    }
    return items;
  }
}
