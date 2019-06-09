import 'package:flutter/material.dart';
import 'package:atoi/home_page.dart';
import 'package:atoi/login_page.dart';


void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  final routes = <String, WidgetBuilder>{
    LoginPage.tag: (context) => LoginPage(),
    HomePage.tag: (context) => HomePage()
  };

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: '资产管理系统',
      theme: new ThemeData(
          primaryColor: new Color(0xff3b4674),
          accentColor: new Color(0xff2c5c85),
      ),
      home: new LoginPage(),
      routes: routes,
    );
  }
}
