/// String extension methods used throughout ShopWave.
extension StringExt on String {
  // ── Validation ─────────────────────────────────────────────────
  bool get isEmail => RegExp(
        r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+'
        r'@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?'
        r'(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$',
      ).hasMatch(this);

  bool get isPhone => RegExp(r'^[+]?[0-9]{9,15}$').hasMatch(this);
  bool get isNotBlank => trim().isNotEmpty;

  // ── Formatting ─────────────────────────────────────────────────
  String get capitalize => isEmpty
      ? this
      : '${this[0].toUpperCase()}${substring(1).toLowerCase()}';

  String get titleCase => split(' ')
      .map((word) => word.isEmpty ? word : word.capitalize)
      .join(' ');

  /// Truncates text and appends '...' if longer than [maxLength].
  String truncate(int maxLength) =>
      length <= maxLength ? this : '${substring(0, maxLength)}...';

  // ── Parsing ────────────────────────────────────────────────────
  double? get toDoubleOrNull => double.tryParse(this);
  int? get toIntOrNull => int.tryParse(this);
}

/// Nullable String extension for safe operations.
extension NullableStringExt on String? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;
  bool get isNotNullOrEmpty => !isNullOrEmpty;
  String get orEmpty => this ?? '';
}
