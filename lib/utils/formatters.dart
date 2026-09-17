import 'package:intl/intl.dart';

class Formatters {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static final NumberFormat _compactCurrencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  /// Format amount as ₹ 1,234.50 (or ₹ 1,234 if whole number)
  static String formatCurrency(double amount, {bool showDecimals = false}) {
    if (showDecimals || amount % 1 != 0) {
      return _currencyFormat.format(amount);
    }
    return _compactCurrencyFormat.format(amount);
  }

  /// Format as 1,234.50 without symbol
  static String formatNumber(double number) {
    if (number % 1 == 0) {
      return number.toInt().toString();
    }
    return number.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
  }

  /// Format date as DD/MM/YYYY
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Format date with time as DD/MM/YYYY hh:mm a
  static String formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy, hh:mm a').format(date);
  }
}
