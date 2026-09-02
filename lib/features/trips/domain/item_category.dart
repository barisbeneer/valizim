/// Checklist sections, in the order they are presented.
///
/// Ordering is part of the product: documents first because forgetting them
/// ends a trip, misc last because it is the least urgent.
enum ItemCategory {
  documents('documents', 0),
  clothing('clothing', 1),
  toiletries('toiletries', 2),
  health('health', 3),
  electronics('electronics', 4),
  gear('gear', 5),
  misc('misc', 6);

  const ItemCategory(this.id, this.order);

  final String id;

  /// Position of the section within a generated list.
  final int order;

  static ItemCategory fromId(String? id) {
    for (final category in ItemCategory.values) {
      if (category.id == id) return category;
    }
    return ItemCategory.misc;
  }

  /// Sections sorted for display.
  static List<ItemCategory> get ordered =>
      List<ItemCategory>.from(ItemCategory.values)
        ..sort((a, b) => a.order.compareTo(b.order));
}
