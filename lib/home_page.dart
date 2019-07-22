import 'package:flutter/material.dart';
import 'package:atoi/pages/manager/manager_menu.dart';
import 'package:atoi/pages/manager/manager_to_assign.dart';
import 'package:atoi/pages/manager/manager_to_audit_page.dart';
import 'package:atoi/pages/manager/manager_to_complete.dart';
import 'package:badges/badges.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:atoi/models/models.dart';


class HomePage extends StatefulWidget {
  static String tag = 'home-page';
  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage>
  with SingleTickerProviderStateMixin{
  TabController _tabController;
  String badgeA;
  String badgeB;
  String badgeC;

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<Null> getCount() async {
    var prefs = await _prefs;
    badgeA = prefs.getString('badgeA');
    badgeB = prefs.getString('badgeB');
    badgeC = prefs.getString('badgeC');
  }

  @override
  void initState() {
    _tabController = new TabController(length: 4, vsync: this, initialIndex: 0);
    getCount();
    super.initState();
  }

  GlobalKey<ScaffoldState> _scaffoldKeyManager = new GlobalKey();

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (context, child, model){
        return new Scaffold(
          backgroundColor: new Color(0xfffafafa),
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
                    icon: new Icon(Icons.view_module),
                    text: '首页'
                ),
                new Tab(
                    icon: new Badge(
                      badgeContent: Text(
                        model.badgeA,
                        style: new TextStyle(
                            color: Colors.white,
                            fontSize: 12.0
                        ),
                      ),
                      child: new Icon(Icons.assignment_late),
                    ),
                    text: '待派工'
                ),
                new Tab(
                  icon: new Badge(
                    badgeContent: Text(
                      model.badgeB,
                      style: new TextStyle(
                          color: Colors.white,
                          fontSize: 12.0
                      ),
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
                            color: Colors.white,
                            fontSize: 12.0
                        ),
                      ),
                      child: new Icon(Icons.event_note),
                    ),
                    text: '未完成'
                )
              ],
            ),
            actions: <Widget>[
              new Icon(Icons.face),
              new Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 19.0),
                child: new GestureDetector(
                  onTap: () {
                    _scaffoldKeyManager.currentState.openEndDrawer();
                  },
                  child: new Text('上杉谦信'),
                ),
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
                    _scaffoldKeyManager.currentState.showBottomSheet((BuildContext context) {
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
      },
    );
  }
}