/// Date and time as Horizont writes them: day headers as Kennung, times in
/// Mono with tabular figures. German, without a locale initialization.
library;

import '../l10n/strings.dart';

const _weekdays = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
const _months = ['Jan', 'Feb', 'Mär', 'Apr', 'Mai', 'Jun', 'Jul', 'Aug', 'Sep', 'Okt', 'Nov', 'Dez'];
const _monthsLong = ['Januar', 'Februar', 'März', 'April', 'Mai', 'Juni', 'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember'];

String _two(int n) => n.toString().padLeft(2, '0');

/// "Heute", "Gestern" or "Mo · 9. Nov" (the Kennung uppercases it).
String dayLabel(DateTime day, {DateTime? now}) {
  final n = now ?? DateTime.now();
  final today = DateTime(n.year, n.month, n.day);
  final d = DateTime(day.year, day.month, day.day);
  final diff = today.difference(d).inDays;
  if (diff == 0) return S.today;
  if (diff == 1) return S.yesterday;
  final base = '${_weekdays[d.weekday - 1]} · ${d.day}. ${_months[d.month - 1]}';
  return d.year == today.year ? base : '$base ${d.year}';
}

/// "07:42" today, else "9. Nov" or "9. Nov 2025".
String shortTime(DateTime t, {DateTime? now}) {
  final l = t.toLocal();
  final n = now ?? DateTime.now();
  if (l.year == n.year && l.month == n.month && l.day == n.day) return '${_two(l.hour)}:${_two(l.minute)}';
  final base = '${l.day}. ${_months[l.month - 1]}';
  return l.year == n.year ? base : '$base ${l.year}';
}

/// "9. November 2026, 07:42".
String longDate(DateTime t) {
  final l = t.toLocal();
  return '${l.day}. ${_monthsLong[l.month - 1]} ${l.year}, ${_two(l.hour)}:${_two(l.minute)}';
}

/// "11.11.2026".
String numericDate(DateTime t) {
  final l = t.toLocal();
  return '${_two(l.day)}.${_two(l.month)}.${l.year}';
}

/// "07:30" from minutes after midnight.
String clock(int minutes) => '${_two(minutes ~/ 60)}:${_two(minutes % 60)}';

/// A month's short name, for the Jahresernte axis.
String monthShort(int month) => _months[month - 1];
