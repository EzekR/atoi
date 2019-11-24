import 'package:flutter/material.dart';
import 'package:atoi/pages/manager/manager_menu.dart';
import 'package:atoi/pages/manager/manager_to_assign.dart';
import 'package:atoi/pages/manager/manager_to_audit_page.dart';
import 'package:atoi/pages/manager/manager_to_complete.dart';
import 'package:badges/badges.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:atoi/models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:atoi/login_page.dart';
import 'dart:async';
import 'package:atoi/complete_info.dart';
import 'package:atoi/pages/equipments/equipments_list.dart';
import 'package:atoi/pages/reports/report_list.dart';
import 'package:atoi/pages/equipments/equipment_contract.dart';
import 'package:atoi/pages/equipments/vendors_list.dart';
import 'package:atoi/pages/equipments/contract_list.dart';

class HomePage extends StatefulWidget {
  static String tag = 'home-page';
  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  Future<SharedPreferences> prefs = SharedPreferences.getInstance();
  String _userName = '';
  String _mobile = '';
  Timer _timer;

  Future<Null> getRole() async {
    var _prefs = await prefs;
    var userName = _prefs.getString('userName');
    var mobile = _prefs.getString('mobile');
    setState(() {
      _userName = userName;
      _mobile = mobile;
    });
  }

  @override
  void initState() {
    getRole();
    _tabController = new TabController(length: 4, vsync: this, initialIndex: 0);
    super.initState();
    ManagerModel model = MainModel.of(context);
    ConstantsModel cModel = MainModel.of(context);
    cModel.getConstants();
    model.getDispatches();
    model.getRequests();
    model.getTodos();
    model.getCount();
    _timer = new Timer.periodic(new Duration(seconds: 10), (timer) {
      print('polling');
      model.getCount();
    });
  }

  void deactivate() {
    super.deactivate();
  }

  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  GlobalKey<ScaffoldState> _scaffoldKeyManager = new GlobalKey();

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (context, child, model) {
        return new WillPopScope(
            child: new Scaffold(
              backgroundColor: new Color(0xfffafafa),
              appBar: new AppBar(
                leading: new Container(),
                title: new Align(
                  alignment: Alignment(-1.0, 0),
                  child: new Text('ATOI医疗设备管理系统',
                    textAlign: TextAlign.left,
                  ),
                ),
                centerTitle: false,
                elevation: 0.7,
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Theme.of(context).accentColor,
                        new Color(0xff4e8faf)
                      ],
                    ),
                  ),
                ),
                bottom: new TabBar(
                  indicatorColor: Colors.white,
                  controller: _tabController,
                  tabs: <Widget>[
                    new Tab(icon: new Icon(Icons.view_module), text: '首页'),
                    new Tab(
                        icon: new Badge(
                          badgeContent: Text(
                            model.badgeA,
                            style: new TextStyle(
                                color: Colors.white, fontSize: 12.0),
                          ),
                          child: new Icon(Icons.assignment_late),
                        ),
                        text: '待派工'),
                    new Tab(
                      icon: new Badge(
                        badgeContent: Text(
                          model.badgeB,
                          style: new TextStyle(
                              color: Colors.white, fontSize: 12.0),
                        ),
                        child: new Icon(Icons.hourglass_full),
                      ),
                      text: '待审核',
                    ),
                    new Tab(
                        icon: new Badge(
                          badgeContent: Text(
                            model.badgeC,
                            style: new TextStyle(
                                color: Colors.white, fontSize: 12.0),
                          ),
                          child: new Icon(Icons.event_note),
                        ),
                        text: '未完成')
                  ],
                ),
                actions: <Widget>[
                  new Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 0.0, vertical: 19.0),
                    child: new GestureDetector(
                      onTap: () {
                        _scaffoldKeyManager.currentState.openEndDrawer();
                      },
                      child: new Text(
                        _userName,
                        style: new TextStyle(fontSize: 16.0),
                      ),
                    ),
                  ),
                  new SizedBox(width: 10.0,)
                ],
              ),
              body: new TabBarView(
                controller: _tabController,
                children: <Widget>[
                  new ManagerMenu(),
                  new ManagerToAssign(),
                  new ManagerToAuditPage(),
                  new ManagerToComplete()
                ],
              ),
              endDrawer: Drawer(
                child: ListView(
                  // Important: Remove any padding from the ListView.
                  padding: EdgeInsets.zero,
                  children: <Widget>[
                    DrawerHeader(
                      child: CircleAvatar(
                        backgroundColor: Colors.transparent,
                        radius: 48.0,
                        child: new Container(),
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).accentColor,
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.person),
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
                      leading: Icon(Icons.list),
                      title: Text('设备列表',
                        style: new TextStyle(
                            color: Colors.blue
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
                          return new EquipmentsList();
                        }));
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.store),
                      title: Text('供应商列表',
                        style: new TextStyle(
                            color: Colors.blue
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
                          return new VendorsList();
                        }));
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.event_note),
                      title: Text('合同管理',
                        style: new TextStyle(
                            color: Colors.blue
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
                          return new ContractList();
                        }));
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.insert_chart),
                      title: Text('报表',
                        style: new TextStyle(
                            color: Colors.blue
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
                          return new ReportList();
                        }));
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.exit_to_app),
                      title: Text('登出'),
                      onTap: () async {
                        var _prefs = await prefs;
                        await _prefs.clear();
                        Navigator.of(context).pushNamed(LoginPage.tag);
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
      },
    );
  }
}
