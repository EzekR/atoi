import 'package:scoped_model/scoped_model.dart';
import 'package:atoi/utils/http_request.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EngineerModel extends Model {

  List<dynamic> _tasksToStart = [];
  List<dynamic> _tasksToReport = [];
  String _badgeEA = '0';
  String _badgeEB = '0';
  int _offset = 10;
  int _offsetReport = 10;

  get badgeEA => _badgeEA;
  get badgeEB => _badgeEB;
  get offset => _offset;

  get tasksToStart => _tasksToStart;
  get tasksToReport => _tasksToReport;


  Future<Null> getCountEngineer() async {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    var prefs = await _prefs;
    var userID = await prefs.getInt('userID');
    var resp = await HttpRequest.request(
      '/User/GetEngineerCount',
      method: HttpRequest.GET,
      params: {
        'userID': userID
      }
    );
    print(resp);
    if (resp['ResultCode'] == '00') {
      _badgeEA = resp['Data']['newdispatchCount'].toString();
      _badgeEB = resp['Data']['pendingDispatchCount'].toString();
    }
    notifyListeners();
  }

  Future<Null> getTasksToStart() async {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    var prefs = await _prefs;
    var userID = await prefs.getInt('userID');
    var resp = await HttpRequest.request(
      '/Dispatch/GetDispatchs',
      method: HttpRequest.GET,
      params: {
        'userID': userID,
        'statusIDs': 1,
        'PageSize': 10,
        'CurRowNum': 0
      }
    );
    print('model call');
    print(resp);
    if (resp['ResultCode'] == '00') {
      _tasksToStart = resp['Data'];
      _offset = 10;
    }
    notifyListeners();
  }

  Future<Null> getMoreTasksToStart() async {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    var prefs = await _prefs;
    var userID = await prefs.getInt('userID');
    var resp = await HttpRequest.request(
        '/Dispatch/GetDispatchs',
        method: HttpRequest.GET,
        params: {
          'userID': userID,
          'statusIDs': 1,
          'PageSize': 10,
          'CurRowNum': _offset
        }
    );
    print(resp);
    if (resp['ResultCode'] == '00') {
      _tasksToStart.addAll(resp['Data']);
      _offset = _offset + 10;
    }
    notifyListeners();
  }

  Future<Null> getTasksToReport() async {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    var prefs = await _prefs;
    var userID = await prefs.getInt('userID');
    var resp = await HttpRequest.request(
      '/Dispatch/GetDispatchs?userID=${userID}&statusIDs=2&statusIDs=3&pageSize=10&curRowNum=0}',
      method: HttpRequest.GET,
    );
    print(resp);
    if (resp['ResultCode'] == '00') {
      _tasksToReport = resp['Data'];
      _offsetReport = 10;
    }
    notifyListeners();
  }

  Future<Null> getMoreTasksToReport() async {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    var prefs = await _prefs;
    var userID = await prefs.getInt('userID');
    var resp = await HttpRequest.request(
      '/Dispatch/GetDispatchs?userID=${userID}&statusIDs=2&statusIDs=3&pageSize=10&curRowNum=${_offsetReport}',
      method: HttpRequest.GET,
    );
    print(resp);
    if (resp['ResultCode'] == '00') {
      _tasksToReport.addAll(resp['Data']);
      _offsetReport = _offsetReport + 10;
    }
    notifyListeners();
  }
}