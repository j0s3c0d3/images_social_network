import 'package:intl/intl.dart';

class DateFormats {

  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  static String format(DateTime date) {
    return _dateFormat.format(date);
  }

  static DateTime parse(String dateString) {
    return _dateFormat.parse(dateString);
  }

  static DateTime truncateTime(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}