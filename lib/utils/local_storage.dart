import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<Null> setStorage(String key, dynamic val) async {
    var prefs = await _prefs;
    switch (val.runtimeType) {
      case int:
        prefs.setInt(key, val);
        break;
      case String:
        prefs.setString(key, val);
        break;
      case bool:
        prefs.setBool(key, val);
        break;
    }
  }

  getStorage(String key, Type type) async {
    var prefs = await _prefs;
    var val;
    switch (type) {
      case int:
        val = prefs.getInt(key);
        break;
      case String:
        val = prefs.getString(key);
        break;
      case bool:
        val = prefs.getBool(key);
        break;
    }
    return val;
  }
}