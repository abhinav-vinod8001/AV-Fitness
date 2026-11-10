class UnitConverter {
  static const double _kgToLbsRatio = 2.20462;

  /// Converts a weight value from the database (always kg) to the user's preferred unit for display.
  static double toDisplayWeight(double weightInKg, String currentUnit) {
    if (currentUnit == 'lbs') {
      return weightInKg * _kgToLbsRatio;
    }
    return weightInKg;
  }

  /// Converts a weight value from the user's preferred unit back to kg for storage in the database.
  static double toStorageWeight(double displayWeight, String currentUnit) {
    if (currentUnit == 'lbs') {
      return displayWeight / _kgToLbsRatio;
    }
    return displayWeight;
  }
}
