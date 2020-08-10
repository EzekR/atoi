import 'package:intl/intl.dart';
import 'package:date_format/date_format.dart';

class CommonUtil {

  static String CurrencyForm(double number) {
    double _num = double.tryParse((number/10000).toString());
    NumberFormat _format = NumberFormat.currency(locale: 'en_US', symbol: '', decimalDigits: 0);
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
}