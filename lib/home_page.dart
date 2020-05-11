import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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
import 'package:atoi/pages/equipments/vendors_list.dart';
import 'package:atoi/pages/equipments/contract_list.dart';
import 'dart:convert';
import 'package:date_format/date_format.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:atoi/utils/event_bus.dart';

/// 超管首页类
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
  Timer _timer;
  ManagerModel model;
  ConstantsModel cModel;
  int _currentTabIndex = 0;

  // request params
  int typeId = 0;
  int statusId = 0;
  bool recall = false;
  int departmentId = 0;
  int urgencyId = 0;
  int dispatchStatusId = 3;
  bool overDue = false;
  String startDate = '';
  String endDate = '';
  String field = 'r.ID';
  TextEditingController filterText = new TextEditingController();
  List typeList = [];
  List statusList = [];
  List departmentList = [];
  List urgencyList = [];
  List dispatchList = [];
  EventBus bus = new EventBus();

  Future<Null> getRole() async {
    var _prefs = await prefs;
    var userInfo = _prefs.getString('userInfo');
    var decoded = jsonDecode(userInfo);
    setState(() {
      _userName = decoded['Name'];
    });
  }

  Container buildButton() {
    return Container(
      width: 100.0,
      height: 40.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        color: Color(0xfff2f2f2),
      ),
      child: Center(
        child: Text('开始日期'),
      ),
    );
  }

  void changeState<T>(T target, T val) {
    setState(() {
      target = val;
    });
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

  void initFilter() async {
    var _start = DateTime.now().add(new Duration(days: -30));
    var _end = DateTime.now();
    await cModel.getConstants();
    model.startDate = formatDate(_start, [yyyy, '-', mm, '-', dd]);
    model.endDate = formatDate(_end, [yyyy, '-', mm, '-', dd]);
    model.typeId = 0;
    model.statusId = 98;
    model.field = 'r.ID';
    model.text = '';
    model.recall = false;
    model.overDue = false;
    model.urgencyId = 0;
    model.departmentId = 0;
    model.offset = 10;
    model.dispatchStatusId = 3;
    model.offset = 10;
    setState(() {
      startDate = formatDate(_start, [yyyy, '-', mm, '-', dd]);
      endDate = formatDate(_end, [yyyy, '-', mm, '-', dd]);
      typeList = initList(cModel.RequestType);
      typeId = typeList[0]['value'];
      statusList = initList(cModel.RequestStatus);
      statusList.removeWhere((item) => item['value'] == -1 || item['value'] == 99);
      statusId = statusList[0]['value'];
      departmentList = initList(cModel.Departments);
      departmentId = departmentList[0]['value'];
      urgencyList = initList(cModel.UrgencyID);
      urgencyId = urgencyList[0]['value'];
      dispatchList = initList(cModel.DispatchStatus);
      dispatchList.removeWhere((item) => item['value'] == -1 || item['value'] == 1 || item['value'] == 4);
      dispatchStatusId = 3;
      filterText.clear();
      _currentTabIndex==2?field='d.ID':field='r.ID';
    });
    _currentTabIndex==2?model.getDispatches():model.getRequests();
  }

  void setFilter() {
    statusId == 0?model.statusId=98:model.statusId=statusId;
    model.field = field;
    model.text = filterText.text;
    model.startDate = startDate;
    model.endDate = endDate;
    model.typeId = typeId;
    model.recall = recall;
    model.departmentId = departmentId;
    model.urgencyId = urgencyId;
    model.overDue = overDue;
    model.offset = 10;
    model.dispatchStatusId = dispatchStatusId;
    switch (_currentTabIndex) {
      case 1:
        model.getRequests();
        break;
      case 2:
        model.getDispatches();
        break;
      case 3:
        model.getTodos();
        break;
    }
  }

  @override
  void initState() {
    getRole();
    _tabController = new TabController(length: 4, vsync: this, initialIndex: 0);
    _tabController.addListener(_handleTabChange);
    super.initState();
    model = MainModel.of(context);
    cModel = MainModel.of(context);
    initFilter();
    model.getDispatches();
    model.getRequests();
    model.getTodos();
    model.getCount();
    _timer = new Timer.periodic(new Duration(seconds: 10), (timer) {
      print('polling');
      model.getCount();
    });
    bus.on('timeout', (params) {
      print('catch timeout event');
      showDialog(context: context, builder: (_) => CupertinoAlertDialog(
        title: Text('网络超时'),
      ));
    });
  }

  _handleTabChange() {
    setState(() {
      _currentTabIndex = _tabController.index;
    });
    initFilter();
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
                          items: _currentTabIndex==1||_currentTabIndex==3?<DropdownMenuItem>[
                            DropdownMenuItem(
                              value: 'r.ID',
                              child: Text('请求编号'),
                            ),
                            DropdownMenuItem(
                              value: 'e.ID',
                              child: Text('设备系统编号'),
                            ),
                            DropdownMenuItem(
                              value: 'e.Name',
                              child: Text('设备名称'),
                            ),
                            DropdownMenuItem(
                              value: 'r.RequestUserName',
                              child: Text('请求人'),
                            ),
                          ]:<DropdownMenuItem>[
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
              _currentTabIndex==2?Container():Row(
                children: <Widget>[
                  SizedBox(width: 16.0,),
                  Text('请求日期', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),)
                ],
              ),
              _currentTabIndex==2?Container():SizedBox(height: 6.0,),
              _currentTabIndex==2?Container():Row(
                children: <Widget>[
                  SizedBox(width: 16.0,),
                  Container(
                    width: 116.0,
                    height: 40.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      color: Color(0xfff2f2f2),
                    ),
                    child: Center(
                      child: FlatButton(
                          onPressed: () {
                            DatePicker.showDatePicker(
                              context,
                              pickerTheme: DateTimePickerTheme(
                                showTitle: true,
                                confirm: Text('确认', style: TextStyle(color: Colors.blueAccent)),
                                cancel: Text('取消', style: TextStyle(color: Colors.redAccent)),
                              ),
                              minDateTime: DateTime.parse('2000-01-01'),
                              maxDateTime: DateTime.parse('2030-01-01'),
                              initialDateTime: DateTime.parse(startDate),
                              dateFormat: 'yyyy-MM-dd',
                              locale: DateTimePickerLocale.en_us,
                              onClose: () => print(""),
                              onCancel: () => print('onCancel'),
                              onChange: (dateTime, List<int> index) {
                              },
                              onConfirm: (dateTime, List<int> index) {
                                setState(() {
                                  startDate = formatDate(dateTime, [yyyy,'-', mm, '-', dd]);
                                });
                              },
                            );
                          },
                          child: Text(startDate, style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12.0),)
                      ),
                    ),
                  ),
                  Text('   -   '),
                  Container(
                    width: 116.0,
                    height: 40.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      color: Color(0xfff2f2f2),
                    ),
                    child: Center(
                      child: FlatButton(
                          onPressed: () {
                            DatePicker.showDatePicker(
                              context,
                              pickerTheme: DateTimePickerTheme(
                                showTitle: true,
                                confirm: Text('确认', style: TextStyle(color: Colors.blueAccent)),
                                cancel: Text('取消', style: TextStyle(color: Colors.redAccent)),
                              ),
                              minDateTime: DateTime.parse('2000-01-01'),
                              maxDateTime: DateTime.parse('2030-01-01'),
                              initialDateTime: DateTime.parse(endDate),
                              dateFormat: 'yyyy-MM-dd',
                              locale: DateTimePickerLocale.en_us,
                              onClose: () => print(""),
                              onCancel: () => print('onCancel'),
                              onChange: (dateTime, List<int> index) {
                              },
                              onConfirm: (dateTime, List<int> index) {
                                setState(() {
                                  endDate = formatDate(dateTime, [yyyy,'-', mm, '-', dd]);
                                });
                              },
                            );
                          },
                          child: Text(endDate, style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12.0),)
                      ),
                    ),
                  ),
                ],
              ),
              _currentTabIndex==2?Container():SizedBox(height: 18.0,),
              _currentTabIndex==2?Container():Row(
                children: <Widget>[
                  SizedBox(width: 16.0,),
                  Text('请求状态', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),)
                ],
              ),
              _currentTabIndex==2?Container():SizedBox(height: 6.0,),
              _currentTabIndex==2?Container():Row(
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
                            value: statusId,
                            underline: Container(),
                            items: statusList.map<DropdownMenuItem>((item) {
                              return DropdownMenuItem(
                                value: item['value'],
                                child: Text(item['text']),
                              );
                            }).toList(),
                            onChanged: (val) {
                              print(val);
                              setState(() {
                                statusId = val;
                              });
                            },
                          )
                        ],
                      )
                  ),
                ],
              ),
              SizedBox(height: 18.0,),
              Row(
                children: <Widget>[
                  SizedBox(width: 16.0,),
                  Text(_currentTabIndex==2?'派工类型':'请求类型', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),)
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
                            value: typeId,
                            underline: Container(),
                            items: typeList.map<DropdownMenuItem>((item) {
                              return DropdownMenuItem(
                                value: item['value'],
                                child: Text(item['text']),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() {
                                typeId = val;
                              });
                            },
                          )
                        ],
                      )
                  ),
                ],
              ),
              _currentTabIndex==2?Container():SizedBox(height: 18.0,),
              _currentTabIndex==2?Container():Row(
                children: <Widget>[
                  SizedBox(width: 16.0,),
                  Text('是否召回', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),)
                ],
              ),
              _currentTabIndex==2?Container():SizedBox(height: 6.0,),
              _currentTabIndex==2?Container():Row(
                children: <Widget>[
                  SizedBox(width: 16.0,),
                  Container(
                    width: 100.0,
                    height: 40.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      color: Color(0xfff2f2f2),
                    ),
                    child: Center(
                      child: Switch(
                        value: recall,
                        onChanged: (val) {
                          setState(() {
                            recall = val;
                          });
                        },
                      ),
                    ),
                  )
                ],
              ),
              _currentTabIndex==2?Container():SizedBox(height: 18.0,),
              _currentTabIndex==2?Container():Row(
                children: <Widget>[
                  SizedBox(width: 16.0,),
                  Text('科室', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),)
                ],
              ),
              _currentTabIndex==2?Container():SizedBox(height: 6.0,),
              _currentTabIndex==2?Container():Row(
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
                            value: departmentId,
                            underline: Container(),
                            items: departmentList.map<DropdownMenuItem>((item) {
                              return DropdownMenuItem(
                                value: item['value'],
                                child: Text(item['text']),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() {
                                departmentId = val;
                              });
                            },
                          )
                        ],
                      )
                  ),
                ],
              ),
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
              _currentTabIndex==2?Container():SizedBox(height: 18.0,),
              _currentTabIndex==2?Container():Row(
                children: <Widget>[
                  SizedBox(width: 16.0,),
                  Text('是否超期', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),)
                ],
              ),
              _currentTabIndex==2?Container():SizedBox(height: 6.0,),
              _currentTabIndex==2?Container():Row(
                children: <Widget>[
                  SizedBox(width: 16.0,),
                  Container(
                    width: 100.0,
                    height: 40.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      color: Color(0xfff2f2f2),
                    ),
                    child: Center(
                      child: Switch(
                        value: overDue,
                        onChanged: (val) {
                          setState(() {
                            overDue = val;
                          });
                        },
                      ),
                    ),
                  )
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
                          field = _currentTabIndex==2?'d.ID':'r.ID';
                          recall = false;
                          overDue = false;
                          startDate = formatDate(DateTime.now().add(new Duration(days: -30)), [yyyy, '-', mm, '-', dd]);
                          endDate = formatDate(DateTime.now(), [yyyy, '-', mm, '-', dd]);
                          typeId = typeList[0]['value'];
                          dispatchStatusId = 3;
                          statusId = statusList[0]['value'];
                          departmentId = departmentList[0]['value'];
                          urgencyId = urgencyList[0]['value'];
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
              backgroundColor: new Color(0xfffafafa),
              appBar: new AppBar(
                title: new Align(
                  alignment: Alignment(-1.0, 0),
                  child: new Text('ATOI医疗设备管理系统',
                    textAlign: TextAlign.left,
                  ),
                ),
                automaticallyImplyLeading: false,
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
                  onTap: (index) {
                    setState(() {
                      _currentTabIndex = index;
                    });
                    initFilter();
                  },
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
                  new ManagerMenu(),
                  new ManagerToAssign(),
                  new ManagerToAuditPage(),
                  new ManagerToComplete()
                ],
              ),
              floatingActionButton: _currentTabIndex!=0?FloatingActionButton(
                onPressed: () {
                  showSheet(context);
                },
                child: Icon(Icons.search),
                backgroundColor: Colors.blue,
              ):Container(),
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
