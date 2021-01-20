import 'package:shared_preferences/shared_preferences.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:atoi/utils/http_request.dart';
import 'package:atoi/permissions.dart';

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
  Map requestPermission;
  Map dispatchPermission;

  void clearCache() {
    _requests.clear();
    _dispatches.clear();
    _todos.clear();
  }

  Future<Null> getPermission() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    Permission permissionInstance = new Permission();
    permissionInstance.prefs = _prefs;
    permissionInstance.initPermissions();
    requestPermission = permissionInstance.getTechPermissions('Operations', 'Request');
    dispatchPermission = permissionInstance.getTechPermissions('Operations', 'Dispatch');
  }

  int get offset => _offset;

  set offset(int value) {
    _offset = value;
  } // filter
  String _text = '';
  String _field = 'r.ID';
  String _startDate = '';
  String _endDate = '';
  int _statusId = 98;
  int _typeId = 0;
  List _typeList = [];
  int _assetType = 0;

  int get assetType => _assetType;

  set assetType(int value) {
    _assetType = value;
  }

  List get typeList => _typeList;

  set typeList(List value) {
    _typeList = value;
  }

  bool _recall = false;
  int _departmentId = -1;
  int _urgencyId = 0;
  bool _overDue = false;
  int _dispatchStatusId = 3;
  int _source = 0;

  set source(int value) {
    _source = value;
  }

  int get source => _source;

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
    await getPermission();
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    var prefs = await _prefs;
    var userID = await prefs.getInt('userID');
    var resp = await HttpRequest.request(
      '/User/GetAdminCount',
      method: HttpRequest.GET,
      params: <String, dynamic> {
        'userID': userID
      }
    );
    print(resp);
    if (resp['ResultCode'] == '00') {
      _badgeA = resp['Data']['newCount'].toString();
      _badgeB = resp['Data']['dispatchCount'].toString();
      _badgeC = resp['Data']['unfinishedCount'].toString();
    }
    if (!requestPermission['View']) {
      _badgeA = '0';
      _badgeC = '0';
    }
    if (!dispatchPermission['View']) {
      _badgeB = '0';
    }
    notifyListeners();
  }

  /// 获取请求
  Future<Null> getRequests() async {
    await getPermission();
    if (!requestPermission['View']) {
      return;
    }
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    var prefs = await _prefs;
    var userID = await prefs.getInt('userID');
    String _urlType = 'typeID=$_typeId';
    if (_typeList.isNotEmpty) {
      _urlType = _typeList.map((item) => 'typeID=$item').join('&');
    }
    var resp = await HttpRequest.request(
      '/Request/GetRequests?userID=${userID}&PageSize=10&CurRowNum=0&statusID=$_statusId&isRecall=$_recall&department=$_departmentId&urgency=$_urgencyId&overDue=$_overDue&startDate=$_startDate&endDate=$_endDate&filterField=$_field&filterText=$_text&source=$_source&$_urlType&assetTypeID=$_assetType',
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
    await getPermission();
    if (!requestPermission['View']) {
      return;
    }
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    var prefs = await _prefs;
    var userID = await prefs.getInt('userID');
    String _urlType = 'typeID=$_typeId';
    if (_typeList.isNotEmpty) {
      _urlType = _typeList.map((item) => 'typeID=$item').join('&');
    }
    var resp = await HttpRequest.request(
      '/Request/GetRequests?userID=${userID}&PageSize=10&CurRowNum=$_offset&statusID=$_statusId&isRecall=$_recall&department=$_departmentId&urgency=$_urgencyId&overDue=$_overDue&startDate=$_startDate&endDate=$_endDate&filterField=$_field&filterText=$_text&source=$_source&$_urlType&assetTypeID=$_assetType',
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
    await getPermission();
    if (!dispatchPermission['View']) {
      return;
    }
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    var prefs = await _prefs;
    var userID = await prefs.getInt('userID');
    String _urlType = 'typeIDs=$_typeId';
    if (_typeList.isNotEmpty) {
      _urlType = _typeList.map((item) => 'typeIDs=$item').join('&');
    }
    Map<String, dynamic> _params = {
      'userID': userID,
      'urgency': _urgencyId,
      'pageSize': 10,
      'curRowNum': 0,
      'assetTypeID': assetType
    };
    if (_text != '') {
      _params['filterText'] = _text;
      _params['filterField'] = _field;
    }
    var resp = await HttpRequest.request(
      _dispatchStatusId==0?'/Dispatch/GetDispatchs?statusIDs=2&statusIDs=3&$_urlType':'/Dispatch/GetDispatchs?statusIDs=$_dispatchStatusId&$_urlType',
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
    await getPermission();
    if (!dispatchPermission['View']) {
      return;
    }
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    var prefs = await _prefs;
    var userID = await prefs.getInt('userID');
    String _urlType = 'typeIDs=$_typeId';
    if (_typeList.isNotEmpty) {
      _urlType = _typeList.map((item) => 'typeIDs=$item').join('&');
    }
    Map<String, dynamic> _params = {
      'userID': userID,
      'urgency': _urgencyId,
      'pageSize': 10,
      'curRowNum': _offsetDispatch,
      'assetTypeID': _assetType
    };
    if (_text != '') {
      _params['filterText'] = _text;
      _params['filterField'] = _field;
    }
    var resp = await HttpRequest.request(
        _dispatchStatusId==0?'/Dispatch/GetDispatchs?statusIDs=2&statusIDs=3&$_urlType':'/Dispatch/GetDispatchs?statusIDs=$_dispatchStatusId&$_urlType',
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
    await getPermission();
    if (!requestPermission['View']) {
      return;
    }
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    var prefs = await _prefs;
    var userID = await prefs.getInt('userID');
    String _urlType = 'typeID=$_typeId';
    if (_typeList.isNotEmpty) {
      _urlType = _typeList.map((item) => 'typeID=$item').join('&');
    }
    Map<String, dynamic> params = {
      'userID': userID,
      'statusID': _statusId,
      'pageSize': 10,
      'curRowNum': 0,
      'isRecall': _recall,
      'department': _departmentId,
      'urgency': _urgencyId,
      'overDue': _overDue,
      'startDate': _startDate,
      'endDate': _endDate,
      'filterField': _field,
      'filterText': _text,
      'source': _source,
      'assetTypeID': _assetType
    };
    var resp = await HttpRequest.request(
        '/Request/GetRequests?$_urlType',
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
    await getPermission();
    if (!requestPermission['View']) {
      return;
    }
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    var prefs = await _prefs;
    var userID = await prefs.getInt('userID');
    String _urlType = 'typeID=$_typeId';
    if (_typeList.isNotEmpty) {
      _urlType = _typeList.map((item) => 'typeID=$item').join('&');
    }
    Map<String, dynamic> params = {
      'userID': userID,
      'statusID': _statusId,
      'pageSize': 10,
      'curRowNum': _offsetTodo,
      'isRecall': _recall,
      'department': _departmentId,
      'urgency': _urgencyId,
      'overDue': _overDue,
      'startDate': _startDate,
      'endDate': _endDate,
      'filterField': _field,
      'filterText': _text,
      'assetTypeID': _assetType,
      'source': _source
    };
    var resp = await HttpRequest.request(
        '/Request/GetRequests?$_urlType',
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