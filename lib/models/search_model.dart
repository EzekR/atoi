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
}