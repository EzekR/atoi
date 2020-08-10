import 'package:flutter/material.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:atoi/pages/user/user_repair_page.dart';
import 'package:atoi/utils/http_request.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:atoi/login_page.dart';
import 'package:atoi/complete_info.dart';
import 'package:atoi/pages/request/other_request.dart';
import 'package:atoi/pages/user/request_history.dart';
import 'package:flutter/cupertino.dart';
import 'package:atoi/models/models.dart';
import 'package:atoi/utils/event_bus.dart';

/// 用户首页类
class UserHomePage extends StatefulWidget{
  static String tag = 'user-home-page';
  @override
  _UserHomePageState createState() => new _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {

  String barcode = '';

  Future<SharedPreferences> prefs = SharedPreferences.getInstance();
  var _userName;
  EventBus bus = new EventBus();

  /// 获取用户信息
  Future<Null> getRole() async {
    var _prefs = await prefs;
    var userInfo = _prefs.getString('userInfo');
    var decoded = jsonDecode(userInfo);
    setState(() {
      _userName = decoded['Name'];
    });
  }

  void logout() async {
    var _prefs = await prefs;
    var _server = await _prefs.getString('serverUrl');
    await _prefs.clear();
    await _prefs.setString('serverUrl', _server);
    Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
      return new LoginPage();
    }
    ));
  }

  void initState() {
    getRole();
    ConstantsModel model = MainModel.of(context);
    model.getConstants();
    super.initState();
    bus.on('invalid_sid', (params) {
      print('invalid sessionid');
      showDialog(context: context, builder: (_) => CupertinoAlertDialog(
        title: Text('用户已在其他设备登陆'),
      )).then((result) => logout());
    });
  }

  /// 扫描二维码
  Future scan() async {
    try {
      String barcode = await BarcodeScanner.scan();
      setState(() {
        return this.barcode = barcode;
      });
      await getDevice();
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          return this.barcode = 'The user did not grant the camera permission!';
        });
      } else {
        setState(() {
          return this.barcode = 'Unknown error: $e';
        });
      }
    } on FormatException{
      setState(() => this.barcode = 'null (User returned using the "back"-button before scanning anything. Result)');
    } catch (e) {
      setState(() => this.barcode = 'Unknown error: $e');
    }
  }

  /// 根据二维码获取设备信息
  Future<Null> getDevice() async {
    Map<String, dynamic> params = {
      'codeContent': barcode,
    };
    var resp = await HttpRequest.request(
        '/Equipment/GetDeviceByQRCode',
        method: HttpRequest.GET,
        params: params
    );

    if (resp['ResultCode'] == '00') {
      Navigator.of(context).push(new MaterialPageRoute(builder: (_){
        return new UserRepairPage(equipment: resp['Data']);
      }));
    } else {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(title: new Text(resp['ResultMessage']),));
    }
  }

  Column buildIconColumn(IconData icon, String label) {
    Color color = label=='扫码报修'?Colors.orange:Theme.of(context).primaryColor;
    return new Column(
      mainAxisSize: MainAxisSize.values[1],
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        new IconButton(
          icon: new Icon(icon,),
          onPressed: () {
            //Navigator.of(context).push(new MaterialPageRoute(builder: (context) {
            //  return label=='其它服务'?OtherRequest():RequestHistory();
            //}));
            switch (label) {
              case '扫码报修':
                scan();
                break;
              case '其它服务':
                Navigator.of(context).push(new MaterialPageRoute(builder: (context) {
                  return OtherRequest();
                }));
                break;
              default:
                Navigator.of(context).push(new MaterialPageRoute(builder: (context) {
                  return RequestHistory();
                }));
                break;
            }
          },
          color: label=='扫码保修'?Colors.orange:color,
          iconSize: 50.0,
        ),
        new Container(
          margin: const EdgeInsets.only(top: 8.0),
          child: new Text(
            label,
            style: new TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w400,
              color: new Color(0xff000000),
            ),
          ),
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
        child: new Scaffold(
          appBar: new AppBar(
            title: new Align(
              alignment: Alignment(-1.0, 0),
              child: new Text('ATOI医疗设备管理系统'),
            ),
            automaticallyImplyLeading: false,
            centerTitle: false,
            elevation: 0.7,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).accentColor
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              new Center(
                child: new Text(_userName??''),
              ),
              new SizedBox(width: 10.0,)
            ],
          ),
          body: new Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              new Center(
                child: new Container(
                  child: new Image.asset('assets/bg_01.jpg'),
                ),
              ),
              new Padding(
                padding: EdgeInsets.symmetric(vertical: 100.0),
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    new Expanded(
                      flex: 4,
                      child: buildIconColumn(Icons.crop_free, '扫码报修'),
                    ),
                    new Expanded(
                      flex: 4,
                      child: buildIconColumn(Icons.extension, '其它服务'),
                    ),
                    new Expanded(
                      flex: 4,
                      child: buildIconColumn(Icons.history, '历史记录'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          endDrawer: Drawer(
            child: ListView(
              // Important: Remove any padding from the ListView.
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Theme.of(context).accentColor,
                  ),
                ),
                ListTile(
                  leading: new Icon(Icons.person),
                  title: Text('个人信息',
                    style: new TextStyle(
                        color: Colors.blue
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
                      return new CompleteInfo();
                    })).then((result) => getRole());
                  },
                ),
                ListTile(
                  leading: new Icon(Icons.exit_to_app),
                  title: Text('登出'),
                  onTap: () async {
                    logout();
                  },
                ),
              ],
            ),
          ),
        ),
        onWillPop: () async {
          return false;
        }
    );
  }
}