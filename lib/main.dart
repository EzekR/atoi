import 'package:flutter/material.dart';
import 'package:atoi/home_page.dart';
import 'package:atoi/login_page.dart';
import 'package:atoi/pages/manager/manager_assign_page.dart';
import 'package:atoi/pages/manager/manager_audit_voucher_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:atoi/pages/manager/manager_audit_report_page.dart';
import 'package:atoi/engineer_home_page.dart';
import 'package:atoi/pages/engineer/engineer_start_page.dart';
import 'package:atoi/pages/engineer/engineer_voucher_page.dart';
import 'package:atoi/pages/engineer/engineer_report_page.dart';
import 'package:atoi/pages/manager/manager_complete_page.dart';
import 'package:atoi/user_home_page.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:atoi/models/models.dart';
import 'package:atoi/pages/user/user_scan_page.dart';
import 'package:atoi/pages/user/user_repair_page.dart';
import 'package:atoi/pages/engineer/signature_page.dart';
import 'package:atoi/pages/request/repair_request.dart';
import 'package:atoi/pages/request/bad_request.dart';
import 'package:atoi/pages/request/correction_request.dart';
import 'package:atoi/pages/request/equipment_request.dart';
import 'package:atoi/pages/request/maintain_request.dart';
import 'package:atoi/pages/request/mandatory_request.dart';
import 'package:atoi/pages/request/other_request.dart';
import 'package:atoi/pages/request/patrol_request.dart';
import 'package:atoi/pages/lifecycle/equipment_check.dart';
import 'package:atoi/pages/lifecycle/equipment_contract.dart';
import 'package:atoi/pages/lifecycle/equipment_install.dart';
import 'package:atoi/pages/lifecycle/equipment_lending.dart';
import 'package:atoi/pages/lifecycle/equipment_scrap.dart';
import 'package:atoi/pages/lifecycle/equipment_transfer.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
//import 'package:jpush_flutter/jpush_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_jpush/flutter_jpush.dart';


class AtoiApp extends StatefulWidget{
  _AtoiAppState createState() => _AtoiAppState();
}

class _AtoiAppState extends State<AtoiApp> {
  final routes = <String, WidgetBuilder>{
    LoginPage.tag: (context) => LoginPage(),
    HomePage.tag: (context) => HomePage(),
    EngineerHomePage.tag: (context) => EngineerHomePage(),
    ManagerAssignPage.tag: (context) => ManagerAssignPage(),
    ManagerAuditVoucherPage.tag: (context) => ManagerAuditVoucherPage(),
    ManagerAuditReportPage.tag: (context) => ManagerAuditReportPage(),
    EngineerStartPage.tag: (context) => EngineerStartPage(),
    EngineerVoucherPage.tag: (context) => EngineerVoucherPage(),
    EngineerReportPage.tag: (context) => EngineerReportPage(),
    ManagerCompletePage.tag: (context) => ManagerCompletePage(),
    UserHomePage.tag: (context) => UserHomePage(),
    UserScanPage.tag: (context) => UserScanPage(),
    UserRepairPage.tag: (context) => UserRepairPage(),
    SignaturePage.tag: (context) => SignaturePage(),
    RepairRequest.tag: (context) => RepairRequest(),
    BadRequest.tag: (context) => BadRequest(),
    CorrectionRequest.tag: (context) => CorrectionRequest(),
    EquipmentRequest.tag: (context) => EquipmentRequest(),
    MaintainRequest.tag: (context) => MaintainRequest(),
    MandatoryRequest.tag: (context) => MandatoryRequest(),
    OtherRequest.tag: (context) => OtherRequest(),
    PatrolRequest.tag: (context) => PatrolRequest(),
    EquipmentCheck.tag: (context) => EquipmentCheck(),
    EquipmentContract.tag: (context) => EquipmentContract(),
    EquipmentInstall.tag: (context) => EquipmentInstall(),
    EquipmentLending.tag: (context) => EquipmentLending(),
    EquipmentScrap.tag: (context) => EquipmentScrap(),
    EquipmentTransfer.tag: (context) => EquipmentTransfer()
  };

  final MainModel mainModel = MainModel();
  String _homeScreenText = "Waiting for token...";
  String _messageText = "Waiting for message...";
  String debugLable = '';

  Future<SharedPreferences> prefs = SharedPreferences.getInstance();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  //final JPush jpush = new JPush();

  void _startupJpush() async {
    print("初始化jpush");
    await FlutterJPush.startup();
    print("初始化jpush成功");
    var _prefs = await prefs;

    FlutterJPush.getRegistrationID().then((rid) {
      print("get regid： ${rid}");
      _prefs.setString('regId', rid);
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

//  Future<void> initPlatformState() async {
//    String platformVersion;
//    var prefs = await _prefs;
//    // Platform messages may fail, so we use a try/catch PlatformException.
//    jpush.setBadge(66).then((map) {
//      print(map);
//    });
//    jpush.getRegistrationID().then((rid) {
//      print(rid);
//      prefs.setString('regId', rid);
//      setState(() {
//        debugLable = "flutter getRegistrationID: $rid";
//      });
//    });
//    jpush.setup(
//      appKey: "3f7f5523e972c577860e6181",
//      production: false,
//      debug: true,
//    );
//    jpush.applyPushAuthority(new NotificationSettingsIOS(
//        sound: true,
//        alert: true,
//        badge: true));
//    try {
//      jpush.addEventHandler(
//        onReceiveNotification: (Map<String, dynamic> message) async {
//          print("flutter onReceiveNotification: $message");
//          setState(() {
//            debugLable = "flutter onReceiveNotification: $message";
//          });
//        },
//        onOpenNotification: (Map<String, dynamic> message) async {
//          print("flutter onOpenNotification: $message");
//          setState(() {
//            debugLable = "flutter onOpenNotification: $message";
//          });
//        },
//        onReceiveMessage: (Map<String, dynamic> message) async {
//          print("flutter onReceiveMessage: $message");
//          setState(() {
//            debugLable = "flutter onReceiveMessage: $message";
//          });
//        },
//      );
//    } on PlatformException {
//      platformVersion = 'Failed to get platform version.';
//    }
//    // If the widget was removed from the tree while the asynchronous platform
//    // message was in flight, we want to discard the reply rather than calling
//    // setState to update our non-existent appearance.
//    if (!mounted) return;
//    setState(() {
//      debugLable = platformVersion;
//    });
//  }

  Future<Null> firebaseInit() async {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        setState(() {
          _messageText = "Push Messaging message: $message";
        });
        print("onMessage: $message");
      },
      onLaunch: (Map<String, dynamic> message) async {
        setState(() {
          _messageText = "Push Messaging message: $message";
        });
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        setState(() {
          _messageText = "Push Messaging message: $message";
        });
        print("onResume: $message");
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
    _firebaseMessaging.getToken().then((String token) {
      assert(token != null);
      setState(() {
        _homeScreenText = "Push Messaging token: $token";
      });
      print(_homeScreenText);
    });
  }
  @override
  void initState() {
    super.initState();
    //initPlatformState();
    //firebaseInit();
    //_startupJpush();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown
    ]);
    return ScopedModel<MainModel>(
      model: mainModel,
      child: new MaterialApp(
          title: 'ATOI医疗设备管理系统',
          theme: new ThemeData(
              primaryColor: new Color(0xff3b4674),
              accentColor: new Color(0xff2c5c85),
              buttonColor: new Color(0xff2E94B9)
          ),
          home: new LoginPage(),
          routes: routes,
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: [
            const Locale('zh', 'CH'),
            const Locale('en', 'US'),
          ]
      )
    );
  }

}

void main() {
  runApp(new AtoiApp());
}
