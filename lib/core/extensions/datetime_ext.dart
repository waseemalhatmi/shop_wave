import 'package:intl/intl.dart';

/// DateTime extension methods for display formatting.
extension DateTimeExt on DateTime {
  /// Formats as a short date: 'Aug 5, 2026'
  String get toDateString => DateFormat('MMM d, yyyy').format(this);

  /// Formats as a short date in Arabic: '٥ أغسطس ٢٠٢٦'
  String get toDateStringAr =>
      DateFormat('d MMMM yyyy', 'ar').format(this);

  /// Formats as date + time: 'Aug 5, 2026 4:30 PM'
  String get toDateTimeString =>
      DateFormat('MMM d, yyyy h:mm a').format(this);

  /// Returns relative time: 'just now', '5 minutes ago', 'yesterday', etc.
  String get timeAgo {
    final diff = DateTime.now().difference(this);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return toDateString;
  }

  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }
}
