import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Permission {
  SharedPreferences _prefs;

  SharedPreferences get prefs => _prefs;

  set prefs(SharedPreferences value) {
    _prefs = value;
  }

  Map _permissions;

  void initPermissions() {
    _permissions = jsonDecode(_prefs.getString('userPermissions'));
  }

  Map getTechPermissions(String type, String key) {
    Map techPermissions = _permissions[type][key]['technicalPermissions'];
    return techPermissions;
  }

  Map getSpecialPermissions(String type, String key) {
    Map specialPermissions = _permissions[type][key]['specialPermissions'];
    return specialPermissions;
  }
}