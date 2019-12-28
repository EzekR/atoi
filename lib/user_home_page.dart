import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'dart:async';
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

class UserHomePage extends StatefulWidget{
  static String tag = 'user-home-page';
  @override
  _UserHomePageState createState() => new _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {

  String barcode = '';

  Future<SharedPreferences> prefs = SharedPreferences.getInstance();
  var _userName;
  var _mobile;

  Future<Null> getRole() async {
    var _prefs = await prefs;
    var userName = _prefs.getString('userName');
    var mobile = _prefs.getString('mobile');
    setState(() {
      _userName = userName;
      _mobile = mobile;
    });
  }

  void initState() {
    getRole();
    ConstantsModel model = MainModel.of(context);
    model.getConstants();
    super.initState();
  }

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
      showDialog(context: context, builder: (context) => AlertDialog(title: new Text(resp['ResultMessage']),));
    }
  }

  Column buildIconColumn(IconData icon, String label) {
    Color color = label=='Repair Request'?Colors.orange:Theme.of(context).primaryColor;
    return new Column(
      mainAxisSize: MainAxisSize.values[1],
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        new IconButton(
          icon: new Icon(icon,),
          onPressed: () {
            //Navigator.of(context).push(new MaterialPageRoute(builder: (context) {
            //  return label=='其他服务'?OtherRequest():RequestHistory();
            //}));
            switch (label) {
              case '扫码报修':
                scan();
                break;
              case '其他服务':
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

  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
        child: new Scaffold(
          key: _scaffoldKey,
          appBar: new AppBar(
            leading: new Container(),
            title: new Align(
              alignment: Alignment(-0.0, 0),
              child: new Text('ATOI医疗设备管理系统'),
            ),
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
              new Padding(
                  padding: const EdgeInsets.symmetric(vertical: 19.0),
                  child: new GestureDetector(
                    onTap: () {
                      _scaffoldKey.currentState.openEndDrawer();
                    },
                    child: new Text(_userName),
                  )
              ),
              new SizedBox(width: 10.0,)
            ],
          ),
          body: new Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              //CarouselSlider(
              //  viewportFraction: 2.0,
              //  items: <Widget>[
              //    new Container(
              //      width: MediaQuery.of(context).size.width,
              //      height: 600.0,
              //      child: Image.asset('assets/bg_01.jpg'),
              //    )
              //  ]
              //),
              new Center(
                child: new Container(
                  child: new Image.asset('assets/bg.jpg'),
                ),
              ),
              //new Padding(
              //  padding: EdgeInsets.symmetric(vertical: 30.0),
              //  child: new Column(
              //    crossAxisAlignment: CrossAxisAlignment.center,
              //    children: <Widget>[
              //      new IconButton(
              //          icon: new Icon(Icons.crop_free),
              //          iconSize: 100.0,
              //          color: Colors.orange,
              //          onPressed: () {
              //            scan();
              //          }
              //      ),
              //      new Container(
              //        margin: const EdgeInsets.only(top: 8.0),
              //        child: new Text(
              //          '扫码报修',
              //          style: new TextStyle(
              //            fontSize: 16.0,
              //            fontWeight: FontWeight.w400,
              //            color: new Color(0xff000000),
              //          ),
              //        ),
              //      ),
              //    ],
              //  ),
              //),
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
                      child: buildIconColumn(Icons.extension, '其他服务'),
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
//              child: CircleAvatar(
//                backgroundColor: Colors.transparent,
//                radius: 48.0,
//                child: Image.asset('assets/alucard.jpg'),
//              ),
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
                    }));
                  },
                ),
                ListTile(
                  leading: new Icon(Icons.exit_to_app),
                  title: Text('登出'),
                  onTap: () async {
                    var _prefs = await prefs;
                    await _prefs.clear();
                    Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
                      return new LoginPage();
                    }
                    ));
                  },
                )
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