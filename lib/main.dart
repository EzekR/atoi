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

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
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
    UserHomePage.tag: (context) => UserHomePage()
  };

  MainModel mainModel = MainModel();
  @override
  Widget build(BuildContext context) {
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
