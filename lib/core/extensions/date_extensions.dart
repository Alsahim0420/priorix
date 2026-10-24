import 'package:intl/intl.dart';

extension DateFormatting on DateTime {
  String get mediumLabel => DateFormat('EEE, MMM d').format(this);
  String get fullLabel => DateFormat('MMMM d, yyyy').format(this);
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }
}
