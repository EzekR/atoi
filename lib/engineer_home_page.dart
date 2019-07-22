import 'package:flutter/material.dart';
import 'package:atoi/pages/engineer/engineer_menu.dart';
import 'package:atoi/pages/engineer/engineer_to_report.dart';
import 'package:badges/badges.dart';
import 'package:atoi/pages/engineer/engineer_to_start.dart';
import 'package:shared_preferences/shared_preferences.dart';


class EngineerHomePage extends StatefulWidget {
  static String tag = 'engineer-home-page';
  @override
  _EngineerHomePageState createState() => new _EngineerHomePageState();
}

class _EngineerHomePageState extends State<EngineerHomePage>
    with SingleTickerProviderStateMixin{
  TabController _tabController;

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  String badgeEA = '0';
  String badgeEB = '0';
  String badgeEC = '0';

  Future<Null> getBadge() async {
    var prefs = await _prefs;
    badgeEA = prefs.getString('badgeEA');
    badgeEB = prefs.getString('badgeEB');
    badgeEC = prefs.getString('badgeEC');
  }
  @override
  void initState() {
    super.initState();
    _tabController = new TabController(length: 3, vsync: this, initialIndex: 0);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          leading: new Container(),
          title: new Align(
            alignment: Alignment(-20.0, 0),
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
                      badgeEA,
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
                    badgeEB,
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
            new Icon(Icons.face),
            new Padding(
              padding: const EdgeInsets.symmetric(vertical: 19.0),
              child: const Text('武田信玄'),
            ),
          ],
        ),
        body: new TabBarView(
          controller: _tabController,
          children: <Widget>[
            new EngineerToStart(),
            new EngineerToReport(),
            new EngineerMenu(),
          ],
        )
    );
  }
}
