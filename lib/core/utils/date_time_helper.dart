import 'package:intl/intl.dart';

class DateTimeHelper {
  static String formatDateTime(DateTime dateTime, {String? format}) {
    final formatter = DateFormat(format ?? 'dd/MM/yyyy HH:mm');
    return formatter.format(dateTime);
  }
}
