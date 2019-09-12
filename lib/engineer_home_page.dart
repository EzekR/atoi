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


class EngineerHomePage extends StatefulWidget {
  static String tag = 'engineer-home-page';
  @override
  _EngineerHomePageState createState() => new _EngineerHomePageState();
}

class _EngineerHomePageState extends State<EngineerHomePage>
    with SingleTickerProviderStateMixin{
  TabController _tabController;
  GlobalKey<ScaffoldState> _scaffoldKeyManager = new GlobalKey();

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

  void startTimer() {
  }

  @override
  void initState() {
    getRole();
    super.initState();
    _tabController = new TabController(length: 3, vsync: this, initialIndex: 0);
    EngineerModel model = MainModel.of(context);
    model.getTasksToStart();
    model.getTasksToReport();
    //model.getCountEngineer();
    //_timer = new Timer.periodic(new Duration(seconds: 10), (timer) {
    //  model.getCountEngineer();
    //});
  }

  void deactivate() {
    super.deactivate();
  }

  void dispose() {
    //_timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (context, child, model) {
        return new WillPopScope(
            child: new Scaffold(
                appBar: new AppBar(
                  leading: new Container(),
                  title: new Align(
                    alignment: Alignment(-2.0, 0),
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
                    new Padding(
                      padding: const EdgeInsets.symmetric(vertical: 19.0),
                      child: Text(_userName),
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
