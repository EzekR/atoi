import 'package:scoped_model/scoped_model.dart';
import 'package:atoi/utils/http_request.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EngineerModel extends Model {

  List<dynamic> _tasksToStart = [];
  List<dynamic> _tasksToReport = [];
  String _badgeEA = '0';
  String _badgeEB = '0';

  get badgeEA => _badgeEA;
  get badgeEB => _badgeEB;

  get tasksToStart => _tasksToStart;
  get tasksToReport => _tasksToReport;

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<Null> getTasksToStart() async {
    var prefs = await _prefs;
    var userID = prefs.getInt('userID');
    var resp = await HttpRequest.request(
      '/Dispatch/GetDispatchs',
      method: HttpRequest.GET,
      params: {
        'userID': userID,
        'statusIDs': 1
      }
    );
    print('model call');
    print(resp);
    if (resp['ResultCode'] == '00') {
      _tasksToStart = resp['Data'];
      _badgeEA = _tasksToStart.length.toString();
    }
    notifyListeners();
  }

  Future<Null> getTasksToReport() async {
    var prefs = await _prefs;
    var userID = prefs.getInt('userID');
    var resp = await HttpRequest.request(
      '/Dispatch/GetDispatchs?userID=${userID}&statusIDs=2&statusIDs=3',
      method: HttpRequest.GET,
    );
    print(resp);
    if (resp['ResultCode'] == '00') {
      _tasksToReport = resp['Data'];
      _badgeEB = _tasksToReport.length.toString();
    }
    notifyListeners();
  }
}