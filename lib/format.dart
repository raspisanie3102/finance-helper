/// Единый форматтер валюты.
/// Во всём приложении суммы отображаются только как «X BYN».
String formatCurrency(num amount, {bool showFraction = false}) {
  final abs = amount.abs();
  final useFrac = showFraction || (abs % 1 != 0);
  final fixed = useFrac ? abs.toStringAsFixed(2) : abs.toStringAsFixed(0);
  final parts = fixed.split('.');
  final intGrouped = _group(parts[0]);
  final frac = parts.length > 1 ? ',${parts[1]}' : '';
  final sign = amount < 0 ? '\u2212' : '';
  return '$sign$intGrouped$frac BYN';
}

String _group(String digits) {
  final buf = StringBuffer();
  final n = digits.length;
  for (var i = 0; i < n; i++) {
    buf.write(digits[i]);
    final remaining = n - 1 - i;
    if (remaining > 0 && remaining % 3 == 0) buf.write('\u00A0');
  }
  return buf.toString();
}

/// «от 15 BYN», для бесплатных — «Бесплатно»
String formatFromPrice(num price) =>
    price <= 0 ? 'Бесплатно' : 'от ${formatCurrency(price)}';
