import 'package:flutter/material.dart';
import 'package:atoi/pages/manager/manager_menu.dart';
import 'package:atoi/pages/manager/manager_to_assign.dart';
import 'package:atoi/pages/manager/manager_to_audit_page.dart';
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

  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: new Color(0xfffafafa),
      appBar: new AppBar(
        title: new Text('ATOI医疗设备管理系统'),
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
              text: '未完成'
            )
          ],
        ),
        actions: <Widget>[
          new IconButton(
            icon: Icon(Icons.face),
            onPressed: () {
              _scaffoldKey.currentState.openEndDrawer();
            },
          ),
          new Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 19.0),
              child: const Text('上杉谦信'),
          ),
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
                child: Image.asset('assets/alucard.jpg'),
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).accentColor,
              ),
            ),
            ListTile(
              title: Text('姓名'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('手机号'),
              onTap: () {
                _scaffoldKey.currentState.showBottomSheet((BuildContext context) {
                  return new Container(
                    decoration: BoxDecoration(
                        border: Border(top: BorderSide(color: Colors.grey))
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Text('This is a Material persistent bottom sheet. Drag downwards to dismiss it.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.indigo,
                          fontSize: 24.0,
                        ),
                      ),
                    ),
                  );
                });
              },
            ),
            ListTile(
              title: Text('修改信息'),
              onTap: () {

              },
            )
          ],
        ),
      ),
    );
  }
}