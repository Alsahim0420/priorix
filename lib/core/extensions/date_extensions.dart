import 'package:intl/intl.dart';

const _locale = 'es';

String _clean(String value) => value.replaceAll('.', '');

extension DateFormatting on DateTime {
  DateTime get dateOnly => DateTime(year, month, day);

  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  bool get isToday => isSameDay(DateTime.now());

  bool get isTomorrow => isSameDay(DateTime.now().add(const Duration(days: 1)));

  /// "18:00"
  String get time => DateFormat('HH:mm', _locale).format(this);

  /// "24 oct"
  String get dayMonth => _clean(DateFormat('d MMM', _locale).format(this));

  /// "vie 24 oct"
  String get weekdayDayMonth =>
      _clean(DateFormat('EEE d MMM', _locale).format(this));

  /// "viernes, 24 de octubre"
  String get longDate => DateFormat("EEEE, d 'de' MMMM", _locale).format(this);

  /// "vie 24 oct, 18:00" — safe to show at any later moment.
  String get absoluteLabel => '$weekdayDayMonth, $time';

  /// "Hoy, 18:00" / "Mañana, 09:00" / "vie 24 oct, 18:00"
  String smartLabel(DateTime now) {
    final today = now.dateOnly;
    final day = dateOnly;
    final diff = day.difference(today).inDays;
    final prefix = switch (diff) {
      0 => 'Hoy',
      1 => 'Mañana',
      -1 => 'Ayer',
      _ => weekdayDayMonth,
    };
    return '$prefix, $time';
  }

  /// "en 3 h" / "hace 2 d"
  String relativeTo(DateTime now) {
    final diff = difference(now);
    final label = diff.abs().compact;
    return diff.isNegative ? 'hace $label' : 'en $label';
  }
}

extension DurationFormatting on Duration {
  /// "2 d 4 h", "3 h 20 min", "12 min"
  String get compact {
    final value = abs();
    final days = value.inDays;
    final hours = value.inHours % 24;
    final minutes = value.inMinutes % 60;
    if (days >= 1) return hours == 0 ? '$days d' : '$days d $hours h';
    if (value.inHours >= 1) {
      return minutes == 0 ? '$hours h' : '$hours h $minutes min';
    }
    if (value.inMinutes >= 1) return '${value.inMinutes} min';
    return '<1 min';
  }
}

String capitalize(String value) =>
    value.isEmpty ? value : value[0].toUpperCase() + value.substring(1);
