import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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
import 'package:atoi/utils/event_bus.dart';
import 'package:atoi/pages/inventory/stocktaking_list.dart';
import 'package:atoi/pages/inventory/po_list.dart';
import 'package:atoi/permissions.dart';

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
  EventBus bus = new EventBus();
  bool showEquip = false;
  bool showTable = false;
  bool limited = false;
  bool showWare = false;
  Map requestTechPermission;
  Map dispatchTechPermission;
  Map medicalPermission;
  Map measurePermission;
  Map otherPermission;
  Map contractPermission;
  Map supplierPermission;
  Map invComponentPermission;
  Map invConsumablePermission;
  Map invServicePermission;
  Map invSparePermission;
  Map invStockPermission;
  Map invPOPermission;

  /// 获取用户信息
  Future<Null> getRole() async {
    var _prefs = await prefs;
    var userInfo = _prefs.getString('userInfo');
    var decoded = jsonDecode(userInfo);
    limited = _prefs.getBool('limitEngineer');
    setState(() {
      _userName = decoded['Name'];
    });
  }

  Future<Null> getPermission() async {
    SharedPreferences _prefs = await prefs;
    Permission permissionInstance = new Permission();
    permissionInstance.prefs = _prefs;
    permissionInstance.initPermissions();
    requestTechPermission = permissionInstance.getTechPermissions('Operations', 'Request');
    dispatchTechPermission = permissionInstance.getTechPermissions('Operations', 'Dispatch');
    medicalPermission = permissionInstance.getTechPermissions("Asset", "Equipment");
    measurePermission = permissionInstance.getTechPermissions("Asset", "MeasInstrum");
    otherPermission = permissionInstance.getTechPermissions("Asset", "OtherEqpt");
    contractPermission = permissionInstance.getTechPermissions("Asset", "Contract");
    supplierPermission = permissionInstance.getTechPermissions("Asset", "Supplier");
    invComponentPermission = permissionInstance.getTechPermissions("Inv", "InvComponent");
    invConsumablePermission = permissionInstance.getTechPermissions("Inv", "InvConsumable");
    invServicePermission = permissionInstance.getTechPermissions("Inv", "InvService");
    invSparePermission = permissionInstance.getTechPermissions("Inv", "InvSpare");
    invStockPermission = permissionInstance.getTechPermissions("Inv", "Stocktaking");
    invPOPermission = permissionInstance.getTechPermissions("Inv", "PurchaseOrder");
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
      dispatchStatusList.removeWhere((item) => item['value'] == -1 || item['value'] == 1 || item['value'] ==4);
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

  void logout() async {
    var _prefs = await prefs;
    var _server = await _prefs.getString('serverUrl');
    await _prefs.clear();
    await _prefs.setString('serverUrl', _server);
    _timer.cancel();
    print("cancel timer");
    Navigator.of(context).push(new MaterialPageRoute(builder: (_) => new LoginPage()));
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
    getPermission();
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
    bus.on('timeout', (params) {
      print('catch timeout event');
      showDialog(context: context, builder: (_) => CupertinoAlertDialog(
        title: Text('网络超时'),
      ));
    });
    bus.on('invalid_sid', (params) {
      print('invalid session');
      _timer.cancel();
      showDialog(context: context, builder: (_) => CupertinoAlertDialog(
        title: Text('用户已在其他设备登陆'),
      )).then((result) => logout());
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
          return Column(
            children: <Widget>[
              SizedBox(height: 8.0,),
              Container(
                height: 300.0,
                child: ListView(
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
                                  FocusScope.of(context).requestFocus(new FocusNode());
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
                                      child: Container(
                                        width: 160.0,
                                        child: Text(item['text']),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    print(val);
                                    FocusScope.of(context).requestFocus(new FocusNode());
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
                                      child: Container(
                                        width: 160.0,
                                        child: Text(item['text']),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    print(val);
                                    FocusScope.of(context).requestFocus(new FocusNode());
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
                                      child: Container(
                                        width: 160.0,
                                        child: Text(item['text']),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    print(val);
                                    FocusScope.of(context).requestFocus(new FocusNode());
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
                  ],
                ),
              ),
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
              ),
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
                    new EngineerMenu(limited: limited),
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
                      title: Text('资产管理',
                        style: new TextStyle(
                            color: Colors.blue
                        ),
                      ),
                      trailing: showEquip?Icon(Icons.keyboard_arrow_down):Icon(Icons.keyboard_arrow_right),
                      onTap: () {
                        setState(() {
                          showEquip = !showEquip;
                        });
                      },
                    ),
                    AnimatedContainer(
                      height: showEquip?200.0:0.0,
                      duration: Duration(milliseconds: 200),
                      child: Column(
                        children: <Widget>[
                          Container(
                            height: 40.0,
                            child: FlatButton(
                              onPressed: () {
                                if (!medicalPermission['View']) {
                                  showDialog(context: context, builder: (context) => CupertinoAlertDialog(
                                    title: Text("无权限"),
                                  ));
                                  return;
                                }
                                Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
                                  return new EquipmentsList(equipmentType: EquipmentType.MEDICAL,);
                                }));
                              },
                              child: Row(
                                children: <Widget>[
                                  SizedBox(
                                    width: 60.0,
                                  ),
                                  Icon(Icons.computer, color: Colors.grey, size: 16.0,),
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                  Text(
                                    '医疗设备',
                                    style: TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.black54
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Container(
                            height: 40.0,
                            child: FlatButton(
                              onPressed: () {
                                if (!measurePermission['View']) {
                                  showDialog(context: context, builder: (context) => CupertinoAlertDialog(
                                    title: Text("无权限"),
                                  ));
                                  return;
                                }
                                Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
                                  return new EquipmentsList(equipmentType: EquipmentType.MEASURE,);
                                }));
                              },
                              child: Row(
                                children: <Widget>[
                                  SizedBox(
                                    width: 60.0,
                                  ),
                                  Icon(Icons.straighten, color: Colors.grey, size: 16.0,),
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                  Text(
                                    '计量器具',
                                    style: TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.black54
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Container(
                            height: 40.0,
                            child: FlatButton(
                              onPressed: () {
                                if (!otherPermission['View']) {
                                  showDialog(context: context, builder: (context) => CupertinoAlertDialog(
                                    title: Text("无权限"),
                                  ));
                                  return;
                                }
                                Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
                                  return new EquipmentsList(equipmentType: EquipmentType.OTHER,);
                                }));
                              },
                              child: Row(
                                children: <Widget>[
                                  SizedBox(
                                    width: 60.0,
                                  ),
                                  Icon(Icons.devices_other, color: Colors.grey, size: 16.0,),
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                  Text(
                                    '其他设备',
                                    style: TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.black54
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Container(
                            height: 40.0,
                            child: FlatButton(
                              onPressed: () {
                                if (!contractPermission['View']) {
                                  showDialog(context: context, builder: (context) => CupertinoAlertDialog(
                                    title: Text("无权限"),
                                  ));
                                  return;
                                }
                                Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
                                  return new ContractList();
                                }));
                              },
                              child: Row(
                                children: <Widget>[
                                  SizedBox(
                                    width: 60.0,
                                  ),
                                  Icon(Icons.event_note, color: Colors.grey, size: 16.0,),
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                  Text('服务合同',
                                    style: TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.black54
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Container(
                            height: 40.0,
                            child: FlatButton(
                              onPressed: () {
                                if (!supplierPermission['View']) {
                                  showDialog(context: context, builder: (context) => CupertinoAlertDialog(
                                    title: Text("无权限"),
                                  ));
                                  return;
                                }
                                Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
                                  return new VendorsList();
                                }));
                              },
                              child: Row(
                                children: <Widget>[
                                  SizedBox(
                                    width: 60.0,
                                  ),
                                  Icon(Icons.store, color: Colors.grey, size: 16.0,),
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                  Text('供应商',
                                    style: TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.black54
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.insert_chart),
                      title: Text('报表管理',
                        style: new TextStyle(
                            color: Colors.blue
                        ),
                      ),
                      trailing: showTable?Icon(Icons.keyboard_arrow_down):Icon(Icons.keyboard_arrow_right),
                      onTap: () {
                        //Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
                        //  return new ReportList();
                        //}));
                        setState(() {
                          showTable = !showTable;
                        });
                      },
                    ),
                    AnimatedContainer(
                      height: showTable?40.0:0.0,
                      duration: Duration(milliseconds: 200),
                      child: Column(
                        children: <Widget>[
                          Container(
                            height: 40.0,
                            child: FlatButton(
                              onPressed: () {
                                Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
                                  return new ReportList();
                                }));
                              },
                              child: Row(
                                children: <Widget>[
                                  SizedBox(
                                    width: 60.0,
                                  ),
                                  Icon(Icons.insert_chart, color: Colors.grey, size: 16.0,),
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                  Text(
                                    '报表',
                                    style: TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.black54
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.business),
                      title: Text('库存管理',
                        style: new TextStyle(
                            color: Colors.blue
                        ),
                      ),
                      trailing: showWare?Icon(Icons.keyboard_arrow_down):Icon(Icons.keyboard_arrow_right),
                      onTap: () {
                        //Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
                        //  return new ReportList();
                        //}));
                        setState(() {
                          showWare = !showWare;
                        });
                      },
                    ),
                    AnimatedContainer(
                      height: showWare?80.0:0.0,
                      duration: Duration(milliseconds: 200),
                      child: Column(
                        children: <Widget>[
                          Container(
                            height: 40.0,
                            child: FlatButton(
                              onPressed: () {
                                if (invStockPermission == null || !invStockPermission['View']) {
                                  showDialog(context: context, builder: (context) => CupertinoAlertDialog(
                                    title: Text("无权限"),
                                  ));
                                  return;
                                }
                                Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
                                  return new StocktakingList();
                                }));
                              },
                              child: Row(
                                children: <Widget>[
                                  SizedBox(
                                    width: 60.0,
                                  ),
                                  Icon(Icons.playlist_add_check, color: Colors.grey, size: 16.0,),
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                  Text(
                                    '库存盘点',
                                    style: TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.black54
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Container(
                            height: 40.0,
                            child: FlatButton(
                              onPressed: () {
                                if (invPOPermission == null || !invPOPermission['View']) {
                                  showDialog(context: context, builder: (context) => CupertinoAlertDialog(
                                    title: Text("无权限"),
                                  ));
                                  return;
                                }
                                Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
                                  return new POList();
                                }));
                              },
                              child: Row(
                                children: <Widget>[
                                  SizedBox(
                                    width: 60.0,
                                  ),
                                  Icon(Icons.note_add, color: Colors.grey, size: 16.0,),
                                  SizedBox(
                                    width: 10.0,
                                  ),
                                  Text(
                                    '采购单',
                                    style: TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.black54
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ListTile(
                      leading: Icon(Icons.exit_to_app),
                      title: Text('登出'),
                      onTap: () async {
                        logout();
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
