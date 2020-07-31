import 'dart:async';
import 'dart:io';
import 'package:intl/intl.dart';

class CommonUtil {

  static String CurrencyForm(double number) {
    double _num = double.tryParse((number/10000).toStringAsFixed(2));
    NumberFormat _format = NumberFormat.currency(locale: 'en_US', symbol: '');
    return _format.format(_num);
  }
}