/// Defensive JSON value parsers.
///
/// NestJS returns native types (int, bool, string) but be tolerant of edge
/// cases: numeric strings, snake_case from legacy bridges, nullable Booleans.
library;

int? parseInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v.trim());
  return null;
}

int parseIntOr(dynamic v, int fallback) => parseInt(v) ?? fallback;

double? parseDouble(dynamic v) {
  if (v == null) return null;
  if (v is double) return v;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v.trim());
  return null;
}

bool parseBool(dynamic v, {bool fallback = false}) {
  if (v == null) return fallback;
  if (v is bool) return v;
  if (v is num) return v != 0;
  if (v is String) {
    final s = v.trim().toLowerCase();
    if (s == 'true' || s == '1' || s == 'yes') return true;
    if (s == 'false' || s == '0' || s == 'no') return false;
  }
  return fallback;
}

String? parseString(dynamic v) {
  if (v == null) return null;
  if (v is String) return v;
  return v.toString();
}

String parseStringOr(dynamic v, String fallback) =>
    parseString(v) ?? fallback;

DateTime? parseDateTime(dynamic v) {
  if (v == null) return null;
  if (v is DateTime) return v;
  if (v is String) return DateTime.tryParse(v);
  if (v is int) {
    // milliseconds since epoch heuristic
    return DateTime.fromMillisecondsSinceEpoch(v, isUtc: true);
  }
  return null;
}
