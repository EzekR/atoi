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

  List<Map> _selected = [];

  get result => _result;
  get selected => _selected;

  void setResult (Map result){
      _result = result;
      notifyListeners();
  }

  void addToSelected(Map item) {
    _selected.add(item);
    print(_selected);
    notifyListeners();
  }

  void removeSelected(Map item) {
    print(item);
    _selected.remove(item);
    notifyListeners();
  }
}