import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../domain/item_category.dart';
import '../domain/trip_type.dart';

/// Presentation-only lookups for domain enums.
///
/// Kept out of the domain layer so `TripType` and `ItemCategory` stay free of
/// Flutter imports and remain testable as pure Dart.
extension TripTypeDisplay on TripType {
  String label(AppL10n l10n) => switch (this) {
        TripType.beach => l10n.tripTypeBeach,
        TripType.city => l10n.tripTypeCity,
        TripType.business => l10n.tripTypeBusiness,
        TripType.camping => l10n.tripTypeCamping,
        TripType.winter => l10n.tripTypeWinter,
        TripType.general => l10n.tripTypeGeneral,
      };

  String hint(AppL10n l10n) => switch (this) {
        TripType.beach => l10n.tripTypeBeachHint,
        TripType.city => l10n.tripTypeCityHint,
        TripType.business => l10n.tripTypeBusinessHint,
        TripType.camping => l10n.tripTypeCampingHint,
        TripType.winter => l10n.tripTypeWinterHint,
        TripType.general => l10n.tripTypeGeneralHint,
      };

  IconData get icon => switch (this) {
        TripType.beach => Icons.beach_access_rounded,
        TripType.city => Icons.location_city_rounded,
        TripType.business => Icons.work_outline_rounded,
        TripType.camping => Icons.forest_rounded,
        TripType.winter => Icons.ac_unit_rounded,
        TripType.general => Icons.luggage_rounded,
      };
}

extension ItemCategoryDisplay on ItemCategory {
  String label(AppL10n l10n) => switch (this) {
        ItemCategory.documents => l10n.categoryDocuments,
        ItemCategory.clothing => l10n.categoryClothing,
        ItemCategory.toiletries => l10n.categoryToiletries,
        ItemCategory.health => l10n.categoryHealth,
        ItemCategory.electronics => l10n.categoryElectronics,
        ItemCategory.gear => l10n.categoryGear,
        ItemCategory.misc => l10n.categoryMisc,
      };

  IconData get icon => switch (this) {
        ItemCategory.documents => Icons.badge_outlined,
        ItemCategory.clothing => Icons.checkroom_rounded,
        ItemCategory.toiletries => Icons.soap_rounded,
        ItemCategory.health => Icons.medical_services_outlined,
        ItemCategory.electronics => Icons.devices_rounded,
        ItemCategory.gear => Icons.backpack_rounded,
        ItemCategory.misc => Icons.category_rounded,
      };
}
