/// Tolerant readers for values that arrive from JSON blobs.
///
/// Trip options, saved templates and the bundled rules asset are all decoded
/// from text that could have been written by an older build or corrupted on
/// disk. Spec section 5 requires that to degrade gracefully rather than throw,
/// so every one of those paths reads numbers through here instead of casting.
library;

/// Reads an int from an int, a num, or a numeric string. Null otherwise.
int? asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim());
  return null;
}

/// Reads a double from a num or a numeric string. Null otherwise.
double? asDouble(Object? value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.trim());
  return null;
}

/// Reads a non-empty trimmed string. Null for anything else.
String? asText(Object? value) {
  if (value is! String) return null;
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
