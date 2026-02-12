import 'package:intl/intl.dart';

String toIsoBlankUtcString(String date, String dateFormat) {
  final local = DateFormat(dateFormat).parse(date); // local
  final utc = local.toUtc();
  return DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(utc) + 'Z';
}

String toIsoBlankUtcStringFromDate(DateTime date) {
  final utc = date.toUtc();
  return DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(utc) + 'Z';
}

const String currentDateFormat = "dd/MM/yyyy";
