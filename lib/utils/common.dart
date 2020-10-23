import 'package:intl/intl.dart';
import 'package:date_format/date_format.dart';

class CommonUtil {

  static String CurrencyForm(double number, {int times, int digits}) {
    print(number.runtimeType);
    if (number.runtimeType!=double) {
      number = 0.0;
    }
    times = times??10000;
    digits = digits??1;
    double _num = double.tryParse((number/times).floor().toString());
    NumberFormat _format = NumberFormat.currency(locale: 'en_US', symbol: '', decimalDigits: digits);
    return _format.format(_num);
  }

  static String TimeForm(String time, String format) {
    var _date = DateTime.tryParse(time);
    if (_date != null) {
      if (format == 'yyyy-mm-dd') {
        return formatDate(_date, [yyyy,'-',mm,'-',dd]);
      } else {
        return formatDate(_date, [yyyy,'-',mm,'-',dd,' ',HH,':',nn]);
      }
    } else {
      return '';
    }
  }

  bool isNumber<T>(T num) {
    switch (num.runtimeType) {
      case double:
        return true;
        break;
      case int:
        return true;
        break;
      default:
        return false;
    }
  }
}