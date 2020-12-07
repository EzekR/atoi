import 'package:scoped_model/scoped_model.dart';
import 'package:atoi/utils/http_request.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 工程师模型类
class EngineerModel extends Model {

  List<dynamic> _tasksToStart = [];
  List<dynamic> _tasksToReport = [];
  String _badgeEA = '0';
  String _badgeEB = '0';
  int _offset = 10;
  int _offsetReport = 10;
  int _dispatchUrgencyId = 0;
  int _engineerDispatchStatusId = 0;

  int get engineerDispatchStatusId => _engineerDispatchStatusId;

  set engineerDispatchStatusId(int value) {
    _engineerDispatchStatusId = value;
  }

  int get dispatchUrgencyId => _dispatchUrgencyId;

  set dispatchUrgencyId(int value) {
    _dispatchUrgencyId = value;
  }

  int get offsetReport => _offsetReport;

  set offsetReport(int value) {
    _offsetReport = value;
  }

  int _dispatchTypeId = 0;

  set offset(int value) {
    _offset = value;
  }

  int _urgencyId = 0;
  String _engineerField = 'd.RequestID';
  String _filterText = '';

  int get dispatchTypeId => _dispatchTypeId;

  set dispatchTypeId(int value) {
    _dispatchTypeId = value;
  }

  int get urgencyId => _urgencyId;

  set urgencyId(int value) {
    _urgencyId = value;
  }

  String get filterText => _filterText;

  set filterText(String value) {
    _filterText = value;
  }

  String get engineerField => _engineerField;

  set engineerField(String value) {
    _engineerField = value;
  }

  get badgeEA => _badgeEA;
  get badgeEB => _badgeEB;
  get offset => _offset;

  get tasksToStart => _tasksToStart;
  get tasksToReport => _tasksToReport;

  /// 获取任务数量
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

  /// 获取待开始工单
  Future<Null> getTasksToStart() async {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    var prefs = await _prefs;
    var userID = await prefs.getInt('userID');
    Map<String, dynamic> _params = {
      'userID': userID,
      'statusIDs': 1,
      'PageSize': 10,
      'CurRowNum': 0,
      'urgency': _dispatchUrgencyId,
      'typeIDs': _dispatchTypeId
    };
    if (_filterText != '') {
      _params['filterText'] = _filterText;
      _params['filterField'] = _engineerField;
    }
    var resp = await HttpRequest.request(
      '/Dispatch/GetDispatchs',
      method: HttpRequest.GET,
      params: _params
    );
    print('model call');
    print(resp);
    if (resp['ResultCode'] == '00') {
      _tasksToStart = resp['Data'];
      _offset = 10;
    }
    notifyListeners();
  }

  /// 获取更多待开始工单
  Future<Null> getMoreTasksToStart() async {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    var prefs = await _prefs;
    var userID = await prefs.getInt('userID');
    Map<String, dynamic> _params = {
      'userID': userID,
      'statusIDs': 1,
      'PageSize': 10,
      'CurRowNum': _offset,
      'urgency': _dispatchUrgencyId,
      'typeIDs': _dispatchTypeId
    };
    if (_filterText != '') {
      _params['filterText'] = _filterText;
      _params['filterField'] = _engineerField;
    }
    var resp = await HttpRequest.request(
        '/Dispatch/GetDispatchs',
        method: HttpRequest.GET,
        params: _params
    );
    print(resp);
    if (resp['ResultCode'] == '00') {
      _tasksToStart.addAll(resp['Data']);
      _offset = _offset + 10;
    }
    notifyListeners();
  }

  /// 获取待上传报告工单
  Future<Null> getTasksToReport() async {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    var prefs = await _prefs;
    var userID = await prefs.getInt('userID');
    Map<String, dynamic> _params = {
      'urgency': _dispatchUrgencyId,
      'typeIDs': _dispatchTypeId,
    };
    if (_filterText != '') {
      _params['filterText'] = _filterText;
      _params['filterField'] = _engineerField;
    }
    var resp = await HttpRequest.request(
      _engineerDispatchStatusId==0?'/Dispatch/GetDispatchs?userID=${userID}&pageSize=10&curRowNum=0&statusIDs=2&statusIDs=3':'/Dispatch/GetDispatchs?userID=${userID}&pageSize=10&curRowNum=0&statusIDs=$_engineerDispatchStatusId',
      method: HttpRequest.GET,
      params: _params
    );
    print(resp);
    if (resp['ResultCode'] == '00') {
      _tasksToReport = resp['Data'];
      _offsetReport = 10;
    }
    notifyListeners();
  }

  /// 获取更多待上传报告工单
  Future<Null> getMoreTasksToReport() async {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    var prefs = await _prefs;
    var userID = await prefs.getInt('userID');
    Map<String, dynamic> _params = {
      'urgency': _dispatchUrgencyId,
      'typeIDs': _dispatchTypeId,
    };
    if (_filterText != '') {
      _params['filterText'] = _filterText;
      _params['filterField'] = _engineerField;
    }
    var resp = await HttpRequest.request(
        _engineerDispatchStatusId==0?'/Dispatch/GetDispatchs?userID=${userID}&pageSize=10&curRowNum=$_offsetReport&statusIDs=2&statusIDs=3':'/Dispatch/GetDispatchs?userID=${userID}&pageSize=10&curRowNum=$_offsetReport&statusIDs=$_engineerDispatchStatusId',
      method: HttpRequest.GET,
      params: _params
    );
    print(resp);
    if (resp['ResultCode'] == '00') {
      _tasksToReport.addAll(resp['Data']);
      _offsetReport = _offsetReport + 10;
    }
    notifyListeners();
  }
}