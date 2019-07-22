import 'package:scoped_model/scoped_model.dart';

class SearchModel extends Model{
  Map<String, String> _result = {
    'equipNo': '',
    'equipLevel': '',
    'name': '',
    'model': '',
    'department': '',
    'location': '',
    'manufacturer': '',
    'guarantee': ''
  };

  get result => _result;

  void setResult (Map result){
      _result = result;
      notifyListeners();
  }

  String _badgeA = '0';
  String _badgeB = '0';
  String _badgeC = '0';
  String _badgeEA = '0';
  String _badgeEB = '0';

  get badgeA => _badgeA;
  get badgeB => _badgeB;
  get badgeC => _badgeC;
  get badgeEA => _badgeEA;
  get badgeEB => _badgeEB;

  void setBadge (String badge, String type) {
    switch (type) {
      case 'A':
        _badgeA = badge;
        break;
      case 'B':
        _badgeB = badge;
        break;
      case 'C':
        _badgeC = badge;
        break;
      case 'EA':
        _badgeEA = badge;
        break;
      case 'EB':
        _badgeEB = badge;
        break;
    }
    notifyListeners();
  }
}