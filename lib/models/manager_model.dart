import 'package:shared_preferences/shared_preferences.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:atoi/utils/http_request.dart';

/// 超管模型类
class ManagerModel extends Model {
  String _badgeA = '0';
  String _badgeB = '0';
  String _badgeC = '0';
  List<dynamic> _requests = [];
  List<dynamic> _dispatches = [];
  List<dynamic> _todos = [];
  int _offset = 10;
  int _offsetDispatch = 10;
  int _offsetTodo = 10;

  int get offset => _offset;

  set offset(int value) {
    _offset = value;
  } // filter
  String _text = '';
  String _field = 'r.ID';
  String _startDate = '';
  String _endDate = '';
  int _statusId = 98;
  int _typeId =0;
  bool _recall = false;
  int _departmentId = 0;
  int _urgencyId = 0;
  bool _overDue = false;
  int _dispatchStatusId = 3;

  int get dispatchStatusId => _dispatchStatusId;

  set dispatchStatusId(int value) {
    _dispatchStatusId = value;
  }

  get badgeA => _badgeA;
  get badgeB => _badgeB;
  get badgeC => _badgeC;
  get requests => _requests;
  get dispatches => _dispatches;
  get todos => _todos;

  int get urgencyId => _urgencyId;

  String get field => _field;

  String get startDate => _startDate;

  String get endDate => _endDate;

  int get statusId => _statusId;

  set statusId(int value) {
    _statusId = value;
  }

  bool get overDue => _overDue;

  String get text => _text;

  set text(String value) {
    _text = value;
  }

  int get departmentId => _departmentId;

  bool get recall => _recall;

  int get typeId => _typeId;

  set typeId(int value) {
    _typeId = value;
  }

  set recall(bool value) {
    _recall = value;
  }

  set departmentId(int value) {
    _departmentId = value;
  }

  set overDue(bool value) {
    _overDue = value;
  }

  set endDate(String value) {
    _endDate = value;
  }

  set startDate(String value) {
    _startDate = value;
  }

  set field(String value) {
    _field = value;
  }

  set urgencyId(int value) {
    _urgencyId = value;
  }

  int get offsetDispatch => _offsetDispatch;

  set offsetDispatch(int value) {
    _offsetDispatch = value;
  }
  /// 获取任务数量
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

  /// 获取请求
  Future<Null> getRequests() async {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    var prefs = await _prefs;
    var userID = await prefs.getInt('userID');
    var resp = await HttpRequest.request(
      '/Request/GetRequests?userID=${userID}&PageSize=10&CurRowNum=0&statusID=$_statusId&typeID=$_typeId&isRecall=$_recall&department=$_departmentId&urgency=$_urgencyId&overDue=$_overDue&startDate=$_startDate&endDate=$_endDate&filterField=$_field&filterText=$_text',
      method: HttpRequest.GET,
    );
    print(resp);
    if (resp['ResultCode'] == '00') {
      _requests = resp['Data'];
      _offset = 10;
      //_badgeA = _requests.length.toString();
    }
    notifyListeners();
  }


  /// 获取更多请求
  Future<Null> getMoreRequests() async {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    var prefs = await _prefs;
    var userID = await prefs.getInt('userID');
    var resp = await HttpRequest.request(
      '/Request/GetRequests?userID=${userID}&PageSize=10&CurRowNum=$_offset&statusID=$_statusId&typeID=$_typeId&isRecall=$_recall&department=$_departmentId&urgency=$_urgencyId&overDue=$_overDue&startDate=$_startDate&endDate=$_endDate&filterField=$_field&filterText=$_text',
      method: HttpRequest.GET,
    );
    print(resp);
    if (resp['ResultCode'] == '00') {
      _requests.addAll(resp['Data']);
      _offset = _offset + 10;
      //_badgeA = _requests.length.toString();
    }
    notifyListeners();
  }

  /// 获取派工单
  Future<Null> getDispatches() async {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    var prefs = await _prefs;
    var userID = await prefs.getInt('userID');
    Map<String, dynamic> _params = {
      'userID': userID,
      'urgency': _urgencyId,
      'type': _typeId,
      'pageSize': 10,
      'curRowNum': 0,
    };
    if (_text != '') {
      _params['filterText'] = _text;
      _params['filterField'] = _field;
    }
    var resp = await HttpRequest.request(
      _dispatchStatusId==0?'/Dispatch/GetDispatchs?statusIDs=2&statusIDs=3':'/Dispatch/GetDispatchs?statusIDs=$_dispatchStatusId',
      method: HttpRequest.GET,
      params: _params
    );
    print(resp);
    if (resp['ResultCode'] == '00') {
      _dispatches = resp['Data'];
      _offsetDispatch = 10;
    }
    notifyListeners();
  }

  /// 获取更多派工单
  Future<Null> getMoreDispatches() async {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    var prefs = await _prefs;
    var userID = await prefs.getInt('userID');
    Map<String, dynamic> _params = {
      'userID': userID,
      'urgency': _urgencyId,
      'type': _typeId,
      'pageSize': 10,
      'curRowNum': _offsetDispatch,
    };
    if (_text != '') {
      _params['filterText'] = _text;
      _params['filterField'] = _field;
    }
    var resp = await HttpRequest.request(
        _dispatchStatusId==0?'/Dispatch/GetDispatchs?statusIDs=2&statusIDs=3':'/Dispatch/GetDispatchs?statusIDs=$_dispatchStatusId',
        method: HttpRequest.GET,
        params: _params
    );
    print(resp);
    if (resp['ResultCode'] == '00') {
      _dispatches.addAll(resp['Data']);
      _offsetDispatch = _offsetDispatch + 10;
    }
    notifyListeners();
  }

  /// 获取未完成请求
  Future<Null> getTodos() async {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    var prefs = await _prefs;
    var userID = await prefs.getInt('userID');
    Map<String, dynamic> params = {
      'userID': userID,
      'statusID': _statusId,
      'typeID': 0,
      'pageSize': 10,
      'curRowNum': 0,
      'typeID': _typeId,
      'isRecall': _recall,
      'department': _departmentId,
      'urgency': _urgencyId,
      'overDue': _overDue,
      'startDate': _startDate,
      'endDate': _endDate,
      'filterField': _field,
      'filterText': _text
    };
    var resp = await HttpRequest.request(
        '/Request/GetRequests',
        method: HttpRequest.GET,
        params: params
    );
    print(resp);
    if (resp['ResultCode'] == '00') {
      _todos = resp['Data'];
      _offsetTodo = 10;
    }
    notifyListeners();
  }

  /// 获取更多未完成请求
  Future<Null> getMoreTodos() async {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    var prefs = await _prefs;
    var userID = await prefs.getInt('userID');
    Map<String, dynamic> params = {
      'userID': userID,
      'statusID': _statusId,
      'typeID': 0,
      'pageSize': 10,
      'curRowNum': _offsetTodo,
      'typeID': _typeId,
      'isRecall': _recall,
      'department': _departmentId,
      'urgency': _urgencyId,
      'overDue': _overDue,
      'startDate': _startDate,
      'endDate': _endDate,
      'filterField': _field,
      'filterText': _text
    };
    var resp = await HttpRequest.request(
        '/Request/GetRequests',
        method: HttpRequest.GET,
        params: params
    );
    print(resp);
    if (resp['ResultCode'] == '00') {
      _todos.addAll(resp['Data']);
      _offsetTodo = _offsetTodo + 10;
    }
    notifyListeners();
  }
}