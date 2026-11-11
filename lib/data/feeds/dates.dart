/// Lenient date parsing for feeds: RFC 822/1123 (RSS) and ISO 8601 (Atom,
/// JSON Feed), as they occur in the wild.
library;

const _months = {
  'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6,
  'jul': 7, 'aug': 8, 'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12,
  // German month names turn up in hand-written feeds.
  'mär': 3, 'mai': 5, 'okt': 10, 'dez': 12,
};

const _zones = {
  'UT': 0, 'UTC': 0, 'GMT': 0, 'Z': 0,
  'EST': -5, 'EDT': -4, 'CST': -6, 'CDT': -5,
  'MST': -7, 'MDT': -6, 'PST': -8, 'PDT': -7,
  'CET': 1, 'CEST': 2, 'MEZ': 1, 'MESZ': 2,
};

final _rfc822 = RegExp(
  r'(?:\w+,?\s+)?(\d{1,2})\s+([A-Za-zäÄ]{3})[a-zä]*\.?\s+(\d{2,4})'
  r'(?:\s+(\d{1,2}):(\d{2})(?::(\d{2}))?)?\s*([+-]\d{2}:?\d{2}|[A-Za-z]{1,5})?',
);

/// Parses [input] as a feed date and returns it in UTC, or null when it is
/// not a date at all. Never throws.
DateTime? parseFeedDate(String? input) {
  final s = input?.trim();
  if (s == null || s.isEmpty) return null;
  final iso = DateTime.tryParse(s);
  if (iso != null) return iso.toUtc();
  // ISO with a space instead of T, or without seconds.
  final isoish = DateTime.tryParse(s.replaceFirst(' ', 'T'));
  if (isoish != null) return isoish.toUtc();

  final m = _rfc822.firstMatch(s);
  if (m == null) return null;
  final day = int.parse(m.group(1)!);
  final month = _months[m.group(2)!.toLowerCase()];
  if (month == null) return null;
  var year = int.parse(m.group(3)!);
  if (year < 100) year += year < 70 ? 2000 : 1900;
  final hour = int.tryParse(m.group(4) ?? '') ?? 0;
  final minute = int.tryParse(m.group(5) ?? '') ?? 0;
  final second = int.tryParse(m.group(6) ?? '') ?? 0;
  final zone = m.group(7);
  var offset = Duration.zero;
  if (zone != null) {
    if (zone.startsWith('+') || zone.startsWith('-')) {
      final digits = zone.replaceAll(':', '');
      final sign = digits.startsWith('-') ? -1 : 1;
      final h = int.parse(digits.substring(1, 3));
      final mm = int.parse(digits.substring(3, 5));
      offset = Duration(hours: h, minutes: mm) * sign;
    } else {
      offset = Duration(hours: _zones[zone.toUpperCase()] ?? 0);
    }
  }
  final utc = DateTime.utc(year, month, day, hour, minute, second);
  return utc.subtract(offset);
}
