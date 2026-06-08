class ServiceType {
  static const dineIn = 'Dine in';
  static const takeaway = 'Takeaway';
  static const delivery = 'Delivery';
  static const carDineIn = 'Car Dine in';

  static const accepted = [dineIn, takeaway, delivery, carDineIn];

  static String normalize(String value) {
    final cleaned =
        value
            .replaceAll(RegExp(r'[^\w\s-]'), ' ')
            .replaceAll(RegExp(r'\s+'), ' ')
            .trim()
            .toLowerCase();

    if ((cleaned.contains('car') && cleaned.contains('dine')) ||
        cleaned.contains('specialbooking') ||
        cleaned.contains('special booking')) {
      return carDineIn;
    }
    if (cleaned.contains('takeaway') ||
        cleaned.contains('take away') ||
        cleaned.contains('pickup') ||
        cleaned.contains('pick up')) {
      return takeaway;
    }
    if (cleaned.contains('dine') && cleaned.contains('in')) {
      return dineIn;
    }
    if (cleaned.contains('delivery')) {
      return delivery;
    }

    return delivery;
  }

  static String? normalizeOrNull(String value) {
    if (value.trim().isEmpty) return null;
    return normalize(value);
  }

  static bool same(String a, String b) {
    if (a.trim().isEmpty || b.trim().isEmpty) return false;
    return normalize(a) == normalize(b);
  }
}
