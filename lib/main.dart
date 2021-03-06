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

void main() {
  runApp(new MyApp());
}

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
