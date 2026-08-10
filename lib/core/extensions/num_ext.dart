import 'package:intl/intl.dart';

/// Number extension methods for price and quantity formatting.
extension NumExt on num {
  /// Formats a number as SAR currency.
  /// Example: 1299.5 → 'SAR 1,299.50'
  String toCurrency({String symbol = 'SAR', String locale = 'en_US'}) =>
      NumberFormat.currency(
        locale: locale,
        symbol: '$symbol ',
        decimalDigits: 2,
      ).format(this);

  /// Formats as SAR for Arabic display.
  String toCurrencyAr() => toCurrency(symbol: 'ر.س', locale: 'ar_SA');

  /// Formats as compact number.
  /// Example: 1200 → '1.2K'
  String toCompact() => NumberFormat.compact().format(this);

  /// Converts to a percentage string.
  /// Example: 25 → '25%'
  String get toPercent => '$this%';

  bool get isPositive => this > 0;
  bool get isNegative => this < 0;
  bool get isZero => this == 0;
}

/// Double-specific extensions.
extension DoubleExt on double {
  /// Rounds to [places] decimal places.
  double roundTo(int places) {
    final mod = pow10(places);
    return (this * mod).round() / mod;
  }
}

double pow10(int n) {
  var result = 1.0;
  for (var i = 0; i < n; i++) {
    result *= 10;
  }
  return result;
}
