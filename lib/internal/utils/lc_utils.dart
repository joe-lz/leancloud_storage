part of leancloud_storage;

bool isNullOrEmpty(String? str) {
  return str == null || str.length == 0;
}

String? toLCDateTimeString(DateTime? dateTime) {
  if (dateTime == null) {
    return null;
  }
  int year = dateTime.year;
  int month = dateTime.month;
  int day = dateTime.day;
  int hour = dateTime.hour;
  int minute = dateTime.minute;
  int second = dateTime.second;
  int millisecond = dateTime.millisecond;
  String y =
      (year >= -9999 && year <= 9999) ? _fourDigits(year) : _sixDigits(year);
  String m = _twoDigits(month);
  String d = _twoDigits(day);
  String h = _twoDigits(hour);
  String min = _twoDigits(minute);
  String sec = _twoDigits(second);
  String ms = _threeDigits(millisecond);
  if (dateTime.isUtc) {
    return "$y-$m-${d}T$h:$min:$sec.${ms}Z";
  } else {
    return "$y-$m-${d}T$h:$min:$sec.$ms";
  }
}

String _fourDigits(int n) {
  int absN = n.abs();
  String sign = n < 0 ? "-" : "";
  if (absN >= 1000) return "$n";
  if (absN >= 100) return "${sign}0$absN";
  if (absN >= 10) return "${sign}00$absN";
  return "${sign}000$absN";
}

String _sixDigits(int n) {
  assert(n < -9999 || n > 9999);
  int absN = n.abs();
  String sign = n < 0 ? "-" : "+";
  if (absN >= 100000) return "$sign$absN";
  return "${sign}0$absN";
}

String _threeDigits(int n) {
  if (n >= 100) return "$n";
  if (n >= 10) return "0$n";
  return "00$n";
}

String _twoDigits(int n) {
  if (n >= 10) return "$n";
  return "0$n";
}
