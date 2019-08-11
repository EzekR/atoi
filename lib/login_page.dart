import 'package:flutter/material.dart';
import 'package:atoi/home_page.dart';
import 'package:atoi/engineer_home_page.dart';
import 'package:atoi/user_home_page.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:atoi/utils/http_request.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  static String tag = 'login-page';
  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  TextEditingController phoneController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  bool _loading = false;

  Future _doLogin() async {
    setState(() {
      _loading = !_loading;
    });
    var _data = await HttpRequest.request(
      '/User/Login',
      method: HttpRequest.POST,
      data: {
        'LoginID': phoneController.text,
        'LoginPwd': passwordController.text,
        'DeviceToken': 'test token',
        'OSName': 'iOS'
      }
    );
    setState(() {
      _loading = !_loading;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_data['ResultCode'] == '00') {
      print(_data);
      prefs.setInt('userID', _data['Data']['ID']);
      prefs.setInt('role', _data['Data']['Role']['ID']);
      prefs.setString('roleName', _data['Data']['Role']['Name']);
      prefs.setString('userName', _data['Data']['Name']);
      switch (_data['Data']['Role']['ID']) {
        case 1:
          Navigator.of(context).pushNamed(HomePage.tag);
          break;
        case 2:
          Navigator.of(context).pushNamed(EngineerHomePage.tag);
          break;
        case 4:
          Navigator.of(context).pushNamed(UserHomePage.tag);
          break;
      }
    } else {
      showDialog(context: context, builder: (context) => AlertDialog(title: new Text(_data['ResultMessage']),));
    }
  }

  @override
  void deactivate() {
    print('移除时：deactivate');
    super.deactivate();
  }

  @override
  void dispose() {
    print('移除时：dispose');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logo = Hero(
      tag: 'hero',
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 48.0,
        child: Image.asset('assets/atoi.png'),
      ),
    );

    final phone = TextFormField(
      keyboardType: TextInputType.text,
      controller: phoneController,
      autofocus: false,
      decoration: InputDecoration(
        hintText: '用户名',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final password = TextFormField(
      autofocus: false,
      controller: passwordController,
      obscureText: true,
      decoration: InputDecoration(
        hintText: '密码',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final loginButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        onPressed: () {
          _doLogin();
        },
        padding: EdgeInsets.all(12),
        color: new Color(0xff183dca),
        child: Text('登录', style: TextStyle(color: Colors.white)),
      ),
    );

    final forgotLabel = FlatButton(
      child: Text(
        '忘记密码?',
        style: TextStyle(color: Colors.black54),
      ),
      onPressed: () {},
    );

    final userRegister = FlatButton(
      child: Text(
        '注册',
        style: TextStyle(color: Colors.blue),
      ),
      onPressed: () {

      },
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 24.0, right: 24.0),
          children: <Widget>[
            logo,
            _loading?SpinKitRotatingPlain(color: Colors.blue):SizedBox(height: 50.0),
            phone,
            SizedBox(height: 8.0),
            password,
            SizedBox(height: 24.0),
            loginButton,
            userRegister,
            forgotLabel,
          ],
        ),
      ),
    );
  }
}
