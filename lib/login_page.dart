import 'package:flutter/material.dart';
import 'package:atoi/home_page.dart';
import 'package:atoi/engineer_home_page.dart';
import 'package:atoi/user_home_page.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:atoi/utils/http_request.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:connectivity/connectivity.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter_jpush/flutter_jpush.dart';
import 'package:permission_handler/permission_handler.dart';

class LoginPage extends StatefulWidget {
  static String tag = 'login-page';
  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  TextEditingController phoneController = new TextEditingController();
  TextEditingController regPhoneController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  TextEditingController verificationController = new TextEditingController();
  TextEditingController nameController = new TextEditingController();
  TextEditingController confirmPass = new TextEditingController();
  bool _loading = false;
  Future<SharedPreferences> prefs = SharedPreferences.getInstance();
  var _stage = 'login';
  Timer _timer;
  int _countdownTime = 0;
  bool _validPhone = false;
  String _regId = '';
  
  Future<Null> isLogin() async {
    var _prefs = await prefs;
    var _isLogin = await _prefs.getBool('isLogin');
    if (_isLogin != null && _isLogin) {
      var _role = await _prefs.getInt('role');
      switch (_role) {
        case 1:
          Navigator.of(context).pushNamed(HomePage.tag);
          break;
        case 2:
          Navigator.of(context).pushNamed(EngineerHomePage.tag);
          break;
        case 4:
          Navigator.of(context).pushNamed(UserHomePage.tag);
          break;
        default:
          return;
      }
    }
  }

  Future<Null> getPermissions() async {
    PermissionStatus permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.contacts);
    print(permission);
  }

  void _startupJpush() async {
    print("初始化jpush");
    await FlutterJPush.startup();
    print("初始化jpush成功");

    FlutterJPush.getRegistrationID().then((rid) {
      print("get regid： ${rid}");
      setState(() {
        _regId = rid;
      });
    });

    FlutterJPush.addnetworkDidLoginListener((String registrationId) {
      setState(() {
        /// 用于推送
        print("收到设备号:$registrationId");
        //this.registrationId = registrationId;
      });
    });

    FlutterJPush.addReceiveNotificationListener((JPushNotification notification) {
      print("收到推送提醒: $notification");
      setState(() {
        /// 收到推送
        //notificationList.add(notification);
      });
    });

    FlutterJPush.addReceiveCustomMsgListener((JPushMessage msg) {
      setState(() {
        print("收到推送消息提醒: $msg");
        /// 打开了推送提醒
        //notificationList.add(msg);
      });
    });
  }

  Future<Null> isConnected() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      showDialog(context: context,
        builder: (context) => AlertDialog(
          title: new Text('请连接网络',
            style: new TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w400,
                color: Colors.black54
            ),
          ),
        )
      );
    }
  }

  void startCountdownTimer() {
    const oneSec = const Duration(seconds: 1);
    var callback = (timer) =>
      setState(() {
        if (_countdownTime < 1) {
          _timer.cancel();
        } else {
          _countdownTime = _countdownTime - 1;
        }
      });
    _timer = Timer.periodic(oneSec, callback);
  }

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
        'RegistrationID': _regId,
        'OSName': 'android'
      }
    );
    setState(() {
      _loading = !_loading;
    });
    if (_data['ResultCode'] == '00') {
      print(_data);
      var _prefs = await prefs;
      await _prefs.setString('userInfo', jsonEncode(_data['Data']));
      await _prefs.setInt('userID', _data['Data']['ID']);
      await _prefs.setInt('role', _data['Data']['Role']['ID']);
      await _prefs.setBool('isLogin', true);
      await _prefs.setString('roleName', _data['Data']['Role']['Name']);
      await _prefs.setString('userName', _data['Data']['Name']);
      await _prefs.setString('mobile', _data['Data']['Mobile']);
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
      showDialog(context: context, builder: (context) => AlertDialog(
        title: new Text(
            _data['ResultMessage'],
          style: new TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w400,
            color: Colors.black54
          ),
        ),
      ));
    }
  }

  Future<Null> _userReg() async {
    if (passwordController.text.isEmpty) {
      showDialog(context: context,
          builder: (context) => AlertDialog(
            title: new Text('密码不可为空',
              style: new TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w400,
                  color: Colors.black54
              ),
            ),
          )
      );
      return;
    }
    if (regPhoneController.text.isEmpty) {
      showDialog(context: context,
          builder: (context) => AlertDialog(
            title: new Text('手机号不可为空',
              style: new TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w400,
                  color: Colors.black54
              ),
            ),
          )
      );
      return;
    }
    if (nameController.text.isEmpty) {
      showDialog(context: context,
          builder: (context) => AlertDialog(
            title: new Text('姓名不可为空',
              style: new TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w400,
                  color: Colors.black54
              ),
            ),
          )
      );
      return;
    }
    if (verificationController.text.isEmpty) {
      showDialog(context: context,
          builder: (context) => AlertDialog(
            title: new Text('验证码不可为空',
              style: new TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w400,
                  color: Colors.black54
              ),
            ),
          )
      );
      return;
    }
    var resp = await HttpRequest.request(
      '/User/Register',
      method: HttpRequest.POST,
      data: {
        'info': {
          'LoginID': regPhoneController.text,
          'Name': nameController.text,
          'LoginPwd': passwordController.text,
          'Department': {
            'ID': 1
          }
        },
        'VerificationCode': verificationController.text.toString()
      }
    );
    print(resp);
    if (resp['ResultCode'] == '00') {
      showDialog(context: context,
          builder: (context) => AlertDialog(
            title: new Text('注册成功',
              style: new TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w400,
                  color: Colors.black54
              ),
            ),
          )
      );
      setState(() {
        _stage = 'login';
        phoneController.text = regPhoneController.text;
        passwordController.text = '';
      });
    } else {
      showDialog(context: context,
          builder: (context) => AlertDialog(
            title: new Text(resp['ResultMessage'],
              style: new TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w400,
                  color: Colors.black54
              ),
            ),
          )
      );
    }
  }

  void initState() {
    isLogin();
    //isConnected();
    _startupJpush();
    super.initState();
    getPermissions();
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

  Future<Null> getVerificationCode() async {
    if (regPhoneController.text.isEmpty || regPhoneController.text.length!=11) {
      showDialog(context: context,
        builder: (context) => AlertDialog(
          title: new Text('请输入正确的手机号',
            style: new TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w400,
                color: Colors.black54
            ),
          ),
        )
      );
      return;
    }
    var resp = await HttpRequest.request(
      '/User/GetVerificationCode',
      method: HttpRequest.GET,
      params: {
        'mobilePhone': regPhoneController.text
      }
    );
    print(resp);
    if (resp['ResultCode'] == '00') {
      showDialog(context: context,
          builder: (context) => AlertDialog(
        title: new Text('验证码已发送',
          style: new TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w400,
              color: Colors.black54
          ),
        ),
      )
    );
      setState(() {
        _countdownTime = 60;
      });
      startCountdownTimer();
    } else {
      showDialog(context: context,
          builder: (context) => AlertDialog(
            title: new Text(resp['ResultMessage'],
              style: new TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w400,
                  color: Colors.black54
              ),
            ),
          )
      );
    }
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

    var phone = TextFormField(
      keyboardType: TextInputType.text,
      controller: phoneController,
      autofocus: false,
      decoration: InputDecoration(
        hintText: _stage=='login'?'用户名/手机号':'手机号',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
      validator: (value) {
        return value.length>20?'用户名过长':null;
      },
    );

    var name = TextFormField(
      keyboardType: TextInputType.text,
      controller: nameController,
      autofocus: false,
      decoration: InputDecoration(
        hintText: '姓名',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    var regPhone = TextFormField(
      keyboardType: TextInputType.number,
      controller: regPhoneController,
      autofocus: false,
      decoration: InputDecoration(
        hintText: '手机号',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    var verification = Row(
      children: <Widget>[
        new Container(
          width: 175.0,
          child: TextField(
            keyboardType: TextInputType.number,
            controller: verificationController,
            autofocus: false,
            decoration: InputDecoration(
              hintText: '验证码',
              contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
            ),
            onChanged: (value) {
              if (value.length == 6) {
                setState(() {
                  _validPhone = true;
                });
              }
            },
          ),
        ),
        SizedBox(width: 8.0,),
        new Container(
          width: 125,
          child: RaisedButton(
            color: Colors.blue,
            child: Text(
              _countdownTime>0?'$_countdownTime后重新获取':'获取验证码',
              style: new TextStyle(
                  color: Colors.white
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            disabledColor: Colors.blueAccent,
            onPressed: () {
              _countdownTime>0?null:getVerificationCode();
            },
          ),
        ),
      ],
    );

    var password = TextFormField(
      autofocus: false,
      controller: passwordController,
      obscureText: true,
      enabled: _stage=='login'?true:_validPhone,
      decoration: InputDecoration(
        hintText: '密码',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    var confirmPassword = TextFormField(
      autofocus: false,
      controller: confirmPass,
      obscureText: true,
      enabled: _validPhone,
      decoration: InputDecoration(
        hintText: '确认密码',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    var loginButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        onPressed: () {
          _stage=='login'?_doLogin():_userReg();
        },
        padding: EdgeInsets.all(12),
        color: new Color(0xff183dca),
        child: Text(
            _stage=='login'?'登录':'注册', style: TextStyle(color: Colors.white)),
      ),
    );

    var forgotLabel = FlatButton(
      child: Text(
        '忘记密码?',
        style: TextStyle(color: Colors.black54),
      ),
      onPressed: () {},
    );

    var userRegister = FlatButton(
      child: Text(
        _stage=='login'?'报修用户注册':'返回登录',
        style: TextStyle(color: Colors.blue),
      ),
      onPressed: () {
        setState(() {
          _stage=='login'?_stage='reg':_stage='login';
          phoneController.text = '';
          regPhoneController.text = '';
          passwordController.text = '';
          verificationController.text = '';
          nameController.text = '';
        });
      },
    );

    List<Widget> buildLogin() {
      List<Widget> _list = [];
      if (_stage == 'login') {
        _list.addAll(
            [
              logo,
              _loading?SpinKitRotatingPlain(color: Colors.blue):SizedBox(height: 50.0),
              phone,
              SizedBox(height: 8.0),
              password,
              SizedBox(height: 8.0),
              loginButton,
              userRegister,
            ]
        );
      } else {
        _list.addAll([
          logo,
          _loading?SpinKitRotatingPlain(color: Colors.blue):SizedBox(height: 50.0),
          regPhone,
          SizedBox(height: 8.0,),
          verification,
          SizedBox(height: 8.0,),
          password,
          SizedBox(height: 8.0,),
          confirmPassword,
          SizedBox(height: 8.0,),
          name,
          SizedBox(height: 8.0,),
          loginButton,
          userRegister,
        ]);
      }
      return _list;
    }

    return new WillPopScope(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.only(left: 24.0, right: 24.0),
              children: buildLogin()
            ),
          ),
        ),
        onWillPop: () async {
          return false;
        }
    );
  }
}
