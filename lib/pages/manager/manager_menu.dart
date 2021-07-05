import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:atoi/permissions.dart';

/// 超管菜单页面类
///
class ManagerMenu extends StatefulWidget {
  _ManagerMenuState createState() => new _ManagerMenuState();
}

class _ManagerMenuState extends State<ManagerMenu> {

  Map techPermission;
  Map specialPermission;

  void getPermission() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    Permission permissionInstance = new Permission();
    permissionInstance.prefs = _prefs;
    permissionInstance.initPermissions();
    techPermission = permissionInstance.getTechPermissions('Operations', 'Request');
    specialPermission = permissionInstance.getSpecialPermissions('Operations', 'Request');
  }

  void initState() {
    getPermission();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    Column buildIconColumn(IconData icon, String title, String type) {
      Color color = Theme.of(context).accentColor;

      return new Column(
        mainAxisSize: MainAxisSize.values[1],
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          new IconButton(
            icon: new Icon(icon),
            onPressed: () {
              if (!techPermission['Add']) {
                print('you shall not pass!');
                return;
              }
              Navigator.of(context).pushNamed(type);
            },
            color: color,
            iconSize: 50.0,
          ),
          new Container(
            margin: const EdgeInsets.only(top: 8.0),
            child: new Text(
              title,
              style: new TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w400,
                color: new Color(0xff000000),
              ),
            ),
          ),
        ],
      );
    }

    return new Container(
      //child: new Padding(
      //  padding: const EdgeInsets.symmetric(vertical: 40.0),
      //  child: new Column(
      //    children: <Widget>[
      //      new Row(
      //        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //        children: <Widget>[
      //          buildIconColumn(Icons.build, '维修'),
      //          buildIconColumn(Icons.assignment_turned_in, '保养'),
      //          buildIconColumn(Icons.people, '巡检'),
      //        ],
      //      ),
      //    ],
      //  ),
      //),
      child: new Column(
        children: <Widget>[
          new Padding(
            padding: const EdgeInsets.symmetric(vertical: 30.0),
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Expanded(
                  flex: 4,
                  child: buildIconColumn(Icons.build, '维修', 'repair-request'),
                ),
                Expanded(
                  flex: 3,
                  child: buildIconColumn(Icons.assignment_turned_in, '保养', 'maintain-request'),
                ),
                Expanded(
                  flex: 4,
                  child: buildIconColumn(Icons.people, '巡检', 'patrol-request'),
                )
              ],
            ),
          ),
          new Padding(
            padding: const EdgeInsets.symmetric(vertical: 30.0),
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Expanded(
                  flex: 4,
                  child: buildIconColumn(Icons.bookmark, '其它服务', 'other-request'),
                ),
                Expanded(
                  flex: 3,
                  child: buildIconColumn(Icons.store, '强检', 'mandatory-request'),
                ),
                Expanded(
                  flex: 4,
                  child: buildIconColumn(Icons.remove_red_eye, '校准', 'correction-request'),
                )
              ],
            ),
          ),
          new Padding(
            padding: const EdgeInsets.symmetric(vertical: 30.0),
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Expanded(
                  flex: 4,
                  child: buildIconColumn(Icons.queue, '设备新增', 'equipment-request'),
                ),
                Expanded(
                  flex: 3,
                  child: new Column(
                    mainAxisSize: MainAxisSize.values[1],
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      new IconButton(
                        icon: new Icon(Icons.insert_chart),
                        onPressed: () {
                          if (!techPermission['Add']) {
                            return;
                          }
                          showModalBottomSheet(
                              context: context,
                              builder: (context) {
                                return ListView(
                                  shrinkWrap: true,
                                  children:<Widget>[
                                    Card(
                                      child: ListTile(
                                        title: new Center(
                                          child: Text(
                                            '合同档案',
                                            style: new TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16.0,
                                                color: Colors.blue
                                            ),
                                          ),
                                        ),
                                        onTap: () {
                                          Navigator.of(context).pushNamed('equipment-archive');
                                        },
                                      ),
                                    ),
                                    Card(
                                      child: ListTile(
                                        title: new Center(
                                          child: Text('验收安装',
                                            style: new TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16.0,
                                                color: Colors.blue
                                            ),
                                          ),
                                        ),
                                        onTap: () {
                                          Navigator.of(context).pushNamed('equipment-install');
                                        },
                                      ),
                                    ),
                                    Card(
                                      child: ListTile(
                                        title: new Center(
                                          child: Text('调拨',
                                            style: new TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16.0,
                                                color: Colors.blue
                                            ),
                                          ),
                                        ),
                                        onTap: () {
                                          Navigator.of(context).pushNamed('equipment-transfer');
                                        },
                                      ),
                                    ),
                                    Card(
                                      child: ListTile(
                                        title: new Center(
                                          child: Text('借用',
                                            style: new TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16.0,
                                                color: Colors.blue
                                            ),
                                          ),
                                        ),
                                        onTap: () {
                                          Navigator.of(context).pushNamed('equipment-lending');
                                        },
                                      ),
                                    ),
                                    Card(
                                      child: ListTile(
                                        title: new Center(
                                          child: Text('盘点',
                                            style: new TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16.0,
                                                color: Colors.blue
                                            ),
                                          ),
                                        ),
                                        onTap: () {
                                          Navigator.of(context).pushNamed('equipment-check');
                                        },
                                      ),
                                    ),
                                    Card(
                                      child: ListTile(
                                        title: new Center(
                                          child: Text('报废',
                                            style: new TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16.0,
                                                color: Colors.blue
                                            ),
                                          ),
                                        ),
                                        onTap: () {
                                          Navigator.of(context).pushNamed('equipment-scrap');
                                        },
                                      ),
                                    ),
                                  ],
                                );
                              }
                          );
                        },
                        color: Theme.of(context).accentColor,
                        iconSize: 50.0,
                      ),
                      new Container(
                        margin: const EdgeInsets.only(top: 8.0),
                        child: new Text(
                          '生命周期管理',
                          style: new TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w400,
                            color: new Color(0xff000000),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: buildIconColumn(Icons.event_busy, '不良事件', 'bad-request'),
                )
              ],
            )
          )
        ],
      ),
    );
  }
}