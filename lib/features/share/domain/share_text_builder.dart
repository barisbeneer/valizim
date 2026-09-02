import '../../trips/domain/item_category.dart';
import '../../trips/domain/trip.dart';

/// Labels the builder needs, supplied by the caller so this stays pure Dart and
/// unit-testable with no Flutter or localization imports.
class ShareTextLabels {
  const ShareTextLabels({
    required this.header,
    required this.meta,
    required this.progress,
    required this.footer,
    required this.categoryLabel,
  });

  /// Trip name line.
  final String header;

  /// Days and travellers, already formatted.
  final String meta;

  /// "n of m packed", already formatted.
  final String progress;

  final String footer;

  /// Section heading for a category.
  final String Function(ItemCategory) categoryLabel;
}

/// Builds the plain-text share payload.
///
/// Contains only what the user can see on screen: trip name, section names,
/// item labels, quantities and tick state. No ids, no timestamps, no debug
/// information (spec section 3).
abstract final class ShareTextBuilder {
  const ShareTextBuilder._();

  static String build({
    required TripWithItems data,
    required ShareTextLabels labels,
    required String Function(TripItem) labelFor,
  }) {
    final buffer = StringBuffer()
      ..writeln(labels.header)
      ..writeln(labels.meta)
      ..writeln(labels.progress);

    for (final entry in data.grouped.entries) {
      buffer
        ..writeln()
        ..writeln('${labels.categoryLabel(entry.key)}:');
      for (final item in entry.value) {
        final tick = item.checked ? '[x]' : '[ ]';
        final quantity = item.quantity > 1 ? ' x${item.quantity}' : '';
        buffer.writeln('$tick ${labelFor(item)}$quantity');
      }
    }

    buffer
      ..writeln()
      ..write(labels.footer);
    return buffer.toString();
  }
}
