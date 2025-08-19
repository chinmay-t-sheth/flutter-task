import 'package:intl/intl.dart';

void main() {
  DateTime now = DateTime.now();
  NumberFormat currency = NumberFormat.currency(locale: "en_IN", symbol: "₹");

  print("Date (US): ${DateFormat.yMMMMd('en_US').format(now)}");
  print("Date (India): ${DateFormat.yMMMMd('hi_IN').format(now)}");
  print("Number formatted: ${currency.format(1234567.89)}");
}
