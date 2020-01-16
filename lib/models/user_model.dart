import 'package:scoped_model/scoped_model.dart';

/// 用户模型
class UserModel extends Model {
  Map<String, dynamic> _userInfo = {
    'user_name': '',
    'telephone': '',
    'user_role': '',
    'device_token': ''
  };

  get userInfo => _userInfo;

  void setUser(Map userInfo) {
    _userInfo = userInfo;
    notifyListeners();
  }
}