// These are some helpful functions
// used for
//across the app

// string to a double

import 'package:intl/intl.dart';

double convertStringToDouble(String string) {
  double? amount = double.tryParse(string);
  return amount ?? 0;
}

// format double amount into dollars & cents
String formatAmount(double amount) {
  final format =
      NumberFormat.currency(locale: "en_us", symbol: "\&", decimalDigits: 2);
  return format.format(amount);
}
