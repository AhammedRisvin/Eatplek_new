String formatPrice(num? value) {
  return (value ?? 0).toDouble().toStringAsFixed(2);
}

String formatCurrency(num? value, {String symbol = '₹', bool space = false}) {
  final separator = space ? ' ' : '';
  return '$symbol$separator${formatPrice(value)}';
}
