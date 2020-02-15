import 'package:flutter/material.dart';
import 'package:atoi/pages/engineer/engineer_menu.dart';
import 'package:atoi/pages/engineer/engineer_to_report.dart';
import 'package:badges/badges.dart';
import 'package:atoi/pages/engineer/engineer_to_start.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:atoi/models/models.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:atoi/login_page.dart';
import 'dart:async';
import 'package:atoi/complete_info.dart';
import 'dart:convert';
import 'package:atoi/pages/equipments/equipments_list.dart';
import 'package:atoi/pages/reports/report_list.dart';
import 'package:atoi/pages/equipments/vendors_list.dart';
import 'package:atoi/pages/equipments/contract_list.dart';

/// 管理员首页类
class EngineerHomePage extends StatefulWidget {
  static String tag = 'engineer-home-page';
  @override
  _EngineerHomePageState createState() => new _EngineerHomePageState();
}

class _EngineerHomePageState extends State<EngineerHomePage>
    with SingleTickerProviderStateMixin{
  TabController _tabController;

  Future<SharedPreferences> prefs = SharedPreferences.getInstance();
  String _userName = '';
  Timer _timer;

  /// 获取用户信息
  Future<Null> getRole() async {
    var _prefs = await prefs;
    var userInfo = _prefs.getString('userInfo');
    var decoded = jsonDecode(userInfo);
    setState(() {
      _userName = decoded['Name'];
    });
  }

  @override
  void initState() {
    getRole();
    super.initState();
    _tabController = new TabController(length: 3, vsync: this, initialIndex: 0);
    EngineerModel model = MainModel.of(context);
    ConstantsModel cModel = MainModel.of(context);
    cModel.getConstants();
    model.getTasksToStart();
    model.getTasksToReport();
    model.getCountEngineer();
    _timer = new Timer.periodic(new Duration(seconds: 10), (timer) {
      model.getCountEngineer();
    });
  }

  void deactivate() {
    super.deactivate();
  }

  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (context, child, model) {
        return new WillPopScope(
            child: new Scaffold(
                appBar: new AppBar(
                  title: new Align(
                    alignment: Alignment(-1.0, 0),
                    child: new Text('ATOI医疗设备管理系统'),
                  ),
                  automaticallyImplyLeading: false,
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
                  bottom: new TabBar(
                    indicatorColor: Colors.white,
                    controller: _tabController,
                    tabs: <Widget>[
                      new Tab(
                          icon: new Badge(
                            badgeContent: Text(
                              model.badgeEA,
                              style: new TextStyle(
                                  color: Colors.white
                              ),
                            ),
                            child: new Icon(Icons.assignment_late),
                          ),
                          text: '待开始工单'
                      ),
                      new Tab(
                        icon: new Badge(
                          badgeContent: Text(
                            model.badgeEB,
                            style: new TextStyle(
                                color: Colors.white
                            ),
                          ),
                          child: new Icon(Icons.hourglass_full),
                        ),
                        text: '作业中工单',
                      ),
                      new Tab(
                          icon: new Icon(Icons.add_to_photos),
                          text: '新增服务'
                      ),
                    ],
                  ),
                  actions: <Widget>[
                    new Center(
                      child: new Text(
                        _userName,
                        style: new TextStyle(fontSize: 16.0),
                      ),
                    ),
                    new SizedBox(width: 10.0,)
                  ],
                ),
                body: new TabBarView(
                  controller: _tabController,
                  children: <Widget>[
                    new EngineerToStart(),
                    new EngineerToReport(),
                    new EngineerMenu(),
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
                        })).then((result) => getRole());
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
                      leading: Icon(Icons.event_note),
                      title: Text('合同列表',
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
                    ),
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
