/// The six trip archetypes the generator understands (spec section 2).
///
/// [id] is the stable string persisted in the database and used as the key in
/// `assets/rules/packing_rules.json`. Renaming an enum constant must never
/// change [id], or existing trips stop resolving.
enum TripType {
  beach('beach'),
  city('city'),
  business('business'),
  camping('camping'),
  winter('winter'),
  general('general');

  const TripType(this.id);

  final String id;

  /// Falls back to [TripType.general] for unknown ids so a row written by a
  /// newer build never crashes an older one.
  static TripType fromId(String? id) {
    for (final type in TripType.values) {
      if (type.id == id) return type;
    }
    return TripType.general;
  }
}
