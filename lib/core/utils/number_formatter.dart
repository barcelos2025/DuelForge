import 'package:intl/intl.dart';

class NumberFormatter {
  static final _formatter = NumberFormat.decimalPattern('pt_BR');

  static String format(num value) {
    return _formatter.format(value);
  }

  static String formatDecimal(double value, int fractionDigits) {
    final formatter = NumberFormat.decimalPatternDigits(locale: 'pt_BR', decimalDigits: fractionDigits);
    return formatter.format(value);
  }
}
