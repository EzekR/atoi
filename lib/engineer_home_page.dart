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
  int dispatchTypeId = 0;
  List dispatchTypeList = [];
  int dispatchStatusId = 0;
  List dispatchStatusList = [];
  List urgencyList = [];
  int urgencyId = 0;
  String field = 'd.ID';
  TextEditingController filterText = new TextEditingController();
  EngineerModel model;
  ConstantsModel cModel;
  int currentTabIndex = 0;

  /// 获取用户信息
  Future<Null> getRole() async {
    var _prefs = await prefs;
    var userInfo = _prefs.getString('userInfo');
    var decoded = jsonDecode(userInfo);
    setState(() {
      _userName = decoded['Name'];
    });
  }

  void initFilter () {
    setState(() {
      model.urgencyId = 0;
      model.dispatchUrgencyId = 0;
      model.dispatchTypeId = 0;
      model.engineerDispatchStatusId = 0;
      model.engineerField = 'd.ID';
      model.filterText = '';
      dispatchTypeList = initList(cModel.RequestType);
      dispatchTypeId = 0;
      urgencyList = initList(cModel.UrgencyID);
      urgencyId = 0;
      dispatchStatusList = initList(cModel.DispatchStatus);
      dispatchStatusId = 0;
      model.offset = 10;
      model.offsetReport = 10;
      filterText.clear();
    });
    switch (currentTabIndex) {
      case 0:
        model.getTasksToStart();
        break;
      case 1:
        model.getTasksToReport();
        break;
    }
  }

  List initList(Map _map) {
    List _list = [];
    _list.add({
      'value': 0,
      'text': '全部'
    });
    _map.forEach((key, val) {
      _list.add({
        'value': val,
        'text': key
      });
    });
    return _list;
  }

  void setFilter() {
    setState(() {
      model.engineerField = field;
      model.filterText = filterText.text;
      model.urgencyId = urgencyId;
      model.dispatchTypeId = dispatchTypeId;
      model.dispatchUrgencyId = urgencyId;
      model.engineerDispatchStatusId = dispatchStatusId;
    });
    currentTabIndex==0?model.getTasksToStart():model.getTasksToReport();
  }

  @override
  void initState() {
    getRole();
    super.initState();
    _tabController = new TabController(length: 3, vsync: this, initialIndex: 0);
    _tabController.addListener(_handleTabChange);
    model = MainModel.of(context);
    cModel = MainModel.of(context);
    cModel.getConstants();
    model.getTasksToStart();
    model.getTasksToReport();
    model.getCountEngineer();
    initFilter();
    _timer = new Timer.periodic(new Duration(seconds: 10), (timer) {
      model.getCountEngineer();
    });
  }

  _handleTabChange() {
    setState(() {
      currentTabIndex = _tabController.index;
    });
    initFilter();
  }

  void deactivate() {
    super.deactivate();
  }

  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void showSheet(BuildContext context) {
    showModalBottomSheet(context: context, builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return ListView(
            children: <Widget>[
              SizedBox(height: 18.0,),
              Row(
                children: <Widget>[
                  SizedBox(width: 16.0,),
                  Text('搜索', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),)
                ],
              ),
              SizedBox(height: 6.0,),
              Row(
                children: <Widget>[
                  SizedBox(width: 16.0,),
                  Container(
                      width: 230.0,
                      height: 40.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: Color(0xfff2f2f2),
                      ),
                      child: Row(
                        children: <Widget>[
                          SizedBox(width: 10.0,),
                          Icon(Icons.search, color: Color(0xffaaaaaa),),
                          SizedBox(width: 10.0,),
                          Container(
                              width: 150.0,
                              child: Align(
                                alignment: Alignment(0.0, -0.5),
                                child: TextField(
                                  decoration: InputDecoration.collapsed(hintText: ''),
                                  controller: filterText,
                                ),
                              )
                          ),
                        ],
                      )
                  ),
                  SizedBox(width: 16.0,),
                  Container(
                    width: 130.0,
                    height: 40.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      color: Color(0xfff2f2f2),
                    ),
                    child: Row(
                      children: <Widget>[
                        SizedBox(width: 6.0,),
                        DropdownButton(
                          value: field,
                          underline: Container(),
                          items: <DropdownMenuItem>[
                            DropdownMenuItem(
                              value: 'd.RequestID',
                              child: Text('请求编号'),
                            ),
                            DropdownMenuItem(
                              value: 'd.ID',
                              child: Text('派工单编号'),
                            ),
                          ],
                          onChanged: (val) {
                            setState(() {
                              field = val;
                            });
                          },
                        ),
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(height: 18.0,),
              Row(
                children: <Widget>[
                  SizedBox(width: 16.0,),
                  Text('派工类型', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),)
                ],
              ),
              SizedBox(height: 6.0,),
              Row(
                children: <Widget>[
                  SizedBox(width: 16.0,),
                  Container(
                      width: 230.0,
                      height: 40.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: Color(0xfff2f2f2),
                      ),
                      child: Row(
                        children: <Widget>[
                          SizedBox(width: 6.0,),
                          DropdownButton(
                            value: dispatchTypeId,
                            underline: Container(),
                            items: dispatchTypeList.map<DropdownMenuItem>((item) {
                              return DropdownMenuItem(
                                value: item['value'],
                                child: Text(item['text']),
                              );
                            }).toList(),
                            onChanged: (val) {
                              print(val);
                              setState(() {
                                dispatchTypeId = val;
                              });
                            },
                          )
                        ],
                      )
                  ),
                ],
              ),
              currentTabIndex==1?SizedBox(height: 18.0,):Container(),
              currentTabIndex==1?Row(
                children: <Widget>[
                  SizedBox(width: 16.0,),
                  Text('审批状态', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),)
                ],
              ):Container(),
              currentTabIndex==1?SizedBox(height: 6.0,):Container(),
              currentTabIndex==1?Row(
                children: <Widget>[
                  SizedBox(width: 16.0,),
                  Container(
                      width: 230.0,
                      height: 40.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: Color(0xfff2f2f2),
                      ),
                      child: Row(
                        children: <Widget>[
                          SizedBox(width: 6.0,),
                          DropdownButton(
                            value: dispatchStatusId,
                            underline: Container(),
                            items: dispatchStatusList.map<DropdownMenuItem>((item) {
                              return DropdownMenuItem(
                                value: item['value'],
                                child: Text(item['text']),
                              );
                            }).toList(),
                            onChanged: (val) {
                              print(val);
                              setState(() {
                                dispatchStatusId = val;
                              });
                            },
                          )
                        ],
                      )
                  ),
                ],
              ):Container(),
              SizedBox(height: 18.0,),
              Row(
                children: <Widget>[
                  SizedBox(width: 16.0,),
                  Text('紧急程度', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),)
                ],
              ),
              SizedBox(height: 6.0,),
              Row(
                children: <Widget>[
                  SizedBox(width: 16.0,),
                  Container(
                      width: 200.0,
                      height: 40.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: Color(0xfff2f2f2),
                      ),
                      child: Row(
                        children: <Widget>[
                          SizedBox(width: 6.0,),
                          DropdownButton(
                            value: urgencyId,
                            underline: Container(),
                            items: urgencyList.map<DropdownMenuItem>((item) {
                              return DropdownMenuItem(
                                value: item['value'],
                                child: Text(item['text']),
                              );
                            }).toList(),
                            onChanged: (val) {
                              print(val);
                              setState(() {
                                urgencyId = val;
                              });
                            },
                          )
                        ],
                      )
                  ),
                ],
              ),
              SizedBox(height: 30.0,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    width: 100.0,
                    height: 40.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      border: Border.all(
                          color: Color(0xff3394B9),
                          width: 1.0
                      ),
                      color: Color(0xffEBF9FF),
                    ),
                    child: Center(
                      child: FlatButton(onPressed: () {
                        setState(() {
                          filterText.clear();
                          field = 'd.ID';
                          urgencyId = urgencyList[0]['value'];
                          dispatchTypeId = dispatchTypeList[0]['value'];
                          dispatchStatusId = dispatchStatusList[0]['value'];
                        });
                        initFilter();
                      }, child: Text('重置')),
                    ),
                  ),
                  Container(
                    width: 100.0,
                    height: 40.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      color: Color(0xff3394B9),
                    ),
                    child: Center(
                      child: FlatButton(onPressed: () {
                        setFilter();
                        Navigator.of(context).pop();
                      }, child: Text('确认', style: TextStyle(color: Colors.white),)),
                    ),
                  ),
                ],
              )
            ],
          );
        },
      );
    });
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
                    onTap: (val) {
                      setState(() {
                        currentTabIndex = val;
                      });
                      initFilter();
                    },
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
              floatingActionButton: currentTabIndex==2?Container():FloatingActionButton(
                  onPressed: () {
                    showSheet(context);
                  },
                  child: Icon(Icons.search),
                  backgroundColor: Colors.blueAccent,
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
                        var _server = await _prefs.getString('serverUrl');
                        await _prefs.clear();
                        await _prefs.setString('serverUrl', _server);
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
