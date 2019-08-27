import 'package:shared_preferences/shared_preferences.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:atoi/utils/http_request.dart';

class ManagerModel extends Model {
  String _badgeA = '0';
  String _badgeB = '0';
  String _badgeC = '0';
  List<dynamic> _requests = [];
  List<dynamic> _dispatches = [];
  List<dynamic> _todos = [];

  get badgeA => _badgeA;
  get badgeB => _badgeB;
  get badgeC => _badgeC;
  get requests => _requests;
  get dispatches => _dispatches;
  get todos => _todos;


  Future<Null> getCount() async {
    var resp = await HttpRequest.request(
      '/User/GetAdminCount',
      method: HttpRequest.GET,
    );
    print(resp);
    if (resp['ResultCode'] == '00') {
      _badgeA = resp['Data']['newCount'].toString();
      _badgeB = resp['Data']['dispatchCount'].toString();
      _badgeC = resp['Data']['unfinishedCount'].toString();
    }
    notifyListeners();
  }

  Future<Null> getRequests() async {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    var prefs = await _prefs;
    var userID = await prefs.getInt('userID');
    var resp = await HttpRequest.request(
      '/Request/GetRequests?userID=${userID}&statusID=1&statusID=5&statusID=6&statusID=7&typeID=0',
      method: HttpRequest.GET,
    );
    print(resp);
    if (resp['ResultCode'] == '00') {
      _requests = resp['Data'];
      _badgeA = _requests.length.toString();
    }
    notifyListeners();
  }

  Future<Null> getDispatches() async {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    var prefs = await _prefs;
    var userID = await prefs.getInt('userID');
    var resp = await HttpRequest.request(
      '/Dispatch/GetDispatchs',
      method: HttpRequest.GET,
      params: {
        'userID': userID,
        'statusIDs': 3
      }
    );
    print(resp);
    if (resp['ResultCode'] == '00') {
      _dispatches = resp['Data'];
      _badgeB = _dispatches.length.toString();
    }
    notifyListeners();
  }

  Future<Null> getTodos() async {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    var prefs = await _prefs;
    var userID = await prefs.getInt('userID');
    Map<String, dynamic> params = {
      'userID': userID,
      'statusID': 98,
      'typeID': 0
    };
    var resp = await HttpRequest.request(
        '/Request/GetRequests',
        method: HttpRequest.GET,
        params: params
    );
    print(resp);
    if (resp['ResultCode'] == '00') {
      _todos = resp['Data'];
      _badgeC = _todos.length.toString();
    }
    notifyListeners();
  }
}