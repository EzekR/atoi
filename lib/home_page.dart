import 'package:flutter/material.dart';
import 'package:atoi/pages/manager/manager_menu.dart';
import 'package:atoi/pages/manager/manager_to_assign.dart';
import 'package:atoi/pages/manager/manager_to_audit.dart';
import 'package:atoi/pages/manager/manager_to_complete.dart';
import 'package:badges/badges.dart';


class HomePage extends StatefulWidget {
  static String tag = 'home-page';
  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage>
  with SingleTickerProviderStateMixin{
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(length: 4, vsync: this, initialIndex: 0);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('资产管理系统'),
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
              icon: new Icon(Icons.view_module),
              text: '首页'
            ),
            new Tab(
              icon: new Badge(
                badgeContent: Text(
                  '3',
                  style: new TextStyle(
                    color: Colors.white
                  ),
                ),
                child: new Icon(Icons.assignment_late),
              ),
              text: '待派工'
            ),
            new Tab(
              icon: new Badge(
                badgeContent: Text(
                  '2',
                  style: new TextStyle(
                      color: Colors.white
                  ),
                ),
                child: new Icon(Icons.hourglass_full),
              ),
              text: '待审核',
            ),
            new Tab(
              icon: new Badge(
                badgeContent: Text(
                  '1',
                  style: new TextStyle(
                      color: Colors.white
                  ),
                ),
                child: new Icon(Icons.event_note),
              ),
              text: '待完成'
            )
          ],
        ),
        actions: <Widget>[
          new Icon(Icons.face),
          new Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 19.0),
              child: const Text('Jin'),
          ),
        ],
      ),
      body: new TabBarView(
        controller: _tabController,
        children: <Widget>[
          new ManagerMenu(),
          new ManagerToAssign(),
          new ManagerToAudit(),
          new ManagerToComplete()
        ],
      )
    );
  }
}