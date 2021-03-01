import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:atoi/utils/http_request.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:atoi/pages/equipments/print_qrcode.dart';
import 'package:atoi/widgets/build_widget.dart';
import 'package:atoi/pages/equipments/equipment_detail.dart';
import 'package:timeline_list/timeline_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:atoi/pages/manager/manager_complete_page.dart';
import 'package:atoi/models/models.dart';
import 'dart:convert';
import 'package:atoi/widgets/search_department.dart';
import 'package:atoi/pages/superuser/dashboard.dart';
import 'package:atoi/permissions.dart';

/// 设备列表页面类
class EquipmentsList extends StatefulWidget{
  final String equipmentId;
  final EquipmentType equipmentType;
  final int assetType;
  EquipmentsList({Key key, this.equipmentId, this.equipmentType, this.assetType}):super(key: key);
  _EquipmentsListState createState() => _EquipmentsListState();
}

class _EquipmentsListState extends State<EquipmentsList> {

  List<dynamic> _equipments = [];

  List<Step> timeline = [];

  bool isSearchState = false;
  bool _loading = false;
  bool _editable = true;
  ConstantsModel cModel;
  String cardHead;

  TextEditingController _keywords = new TextEditingController();
  String searchFilter = 'e.ID';
  TextEditingController _deviceName = new TextEditingController();
  TextEditingController _deviceCode = new TextEditingController();
  List machineStatusList = [];
  int machineStatusId = 0;
  int warrantyId = 0;
  List departmentList = [];
  int departmentId = -1;
  List fujiClass2List = [];
  int fujiClass2 = 0;
  bool usageStatus = false;
  Future<SharedPreferences> prefs = SharedPreferences.getInstance();
  String prefix;
  String pageTitle;

  ScrollController _scrollController = new ScrollController();
  bool _noMore = false;
  int offset = 0;
  int role;
  bool limited = false;
  // permission
  Map techPermission;
  Map specialPermission;
  EquipmentType eType;

  Future<Null> getRole() async {
    var _prefs = await prefs;
    role = _prefs.getInt('role');
    limited = _prefs.getBool('limitEngineer');
    _editable = role==1;
  }

  Future<Null> getPermission() async {
    SharedPreferences _prefs = await prefs;
    Permission permissionInstance = new Permission();
    permissionInstance.prefs = _prefs;
    permissionInstance.initPermissions();
    String _type;
    if (widget.equipmentType != null) {
      eType = widget.equipmentType;
    }
    switch (eType) {
      case EquipmentType.MEDICAL:
        _type = "Equipment";
        break;
      case EquipmentType.MEASURE:
        _type = "MeasInstrum";
        break;
      case EquipmentType.OTHER:
        _type = "OtherEqpt";
        break;
    }
    log("$_type");
    techPermission = permissionInstance.getTechPermissions('Asset', _type);
    specialPermission = permissionInstance.getSpecialPermissions('Asset', _type);
  }

  List initList(Map _map, {int valueForAll}) {
    List _list = [];
    valueForAll = valueForAll??0;
    _list.add({
      'value': valueForAll,
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
    fujiClass2List.clear();
    setState(() {
      fujiClass2List.add({
        'value': 0,
        'text': '全部'
      });
      fujiClass2List.addAll(cModel.FujiClass2.map((item) {
        return {
          'value': item['ID'],
          'text': item['Name']
        };
      }).toList()
      );
      machineStatusList = initList(cModel.EquipmentStatus);
      machineStatusId = machineStatusList[0]['value'];
      departmentList = initList(cModel.Departments, valueForAll: -1);
      departmentId = departmentList[0]['value'];
      warrantyId = 0;
      _keywords.clear();
      if (widget.equipmentId != null) {
        _keywords.text = widget.equipmentId;
      }
      _deviceCode.clear();
      _deviceName.clear();
      usageStatus = false;
      searchFilter = '$prefix.ID';
    });
  }

  void setFilter() async {
    //do some stuff
    setState(() {
      offset = 0;
      _equipments.clear();
    });
    await getEquipments();
  }

  Future<Null> getEquipments({String filterText}) async {
    if (!techPermission['View']) {
      return;
    }
    filterText = filterText??'';
    String url;
    if (widget.equipmentType != null) {
      switch (widget.equipmentType) {
        case EquipmentType.MEDICAL:
          url = '/Equipment/Getdevices';
          break;
        case EquipmentType.MEASURE:
          url = '/MeasInstrum/QueryMeasInstrums';
          break;
        case EquipmentType.OTHER:
          url = '/OtherEqpt/QueryOtherEqpts';
          break;
      }
    }
    if (widget.assetType != null) {
      log("${widget.assetType}");
      switch (widget.assetType) {
        case 1:
          url = '/Equipment/Getdevices';
          break;
        case 2:
          url = '/MeasInstrum/QueryMeasInstrums';
          break;
        case 3:
          url = '/OtherEqpt/QueryOtherEqpts';
          break;
        default:
          url = '/Equipment/Getdevices';
          break;
      }
    }
    var resp = await HttpRequest.request(
      url,
      method: HttpRequest.GET,
      params: {
        'filterText': _keywords.text,
        'status': machineStatusId,
        //'warrantyStatus': warrantyId,
        'departmentID': departmentId,
        'filterTextName': _deviceName.text,
        'filterTextSerialCode': _deviceCode.text,
        'filterField': searchFilter,
        'useStatus': usageStatus,
        'PageSize': 10,
        'CurRowNum': offset,
        'sortField': searchFilter,
        'sortDirection': true,
        //'userID': userId,
        'fujiClass2ID': fujiClass2
      }
    );
    if (resp['ResultCode'] == '00') {
      setState(() {
        _equipments.addAll(resp['Data']);
      });
    }
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
                                        controller: _keywords,
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
                                value: searchFilter,
                                underline: Container(),
                                items: <DropdownMenuItem>[
                                  DropdownMenuItem(
                                    value: '$prefix.ID',
                                    child: Text('系统编号'),
                                  ),
                                  DropdownMenuItem(
                                    value: '$prefix.AssetCode',
                                    child: Text('资产编号'),
                                  ),
                                  DropdownMenuItem(
                                    value: '$prefix.ModelCode',
                                    child: Text('设备型号'),
                                  ),
                                ],
                                onChanged: (val) {
                                  FocusScope.of(context).requestFocus(new FocusNode());
                                  setState(() {
                                    searchFilter = val;
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
                        Text('设备名称', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),)
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
                                        controller: _deviceName,
                                      ),
                                    )
                                ),
                              ],
                            )
                        ),
                      ],
                    ),
                    SizedBox(height: 18.0,),
                    Row(
                      children: <Widget>[
                        SizedBox(width: 16.0,),
                        Text('设备序列号', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),)
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
                                        controller: _deviceCode,
                                      ),
                                    )
                                ),
                              ],
                            )
                        ),
                      ],
                    ),
                    SizedBox(height: 18.0,),
                    Row(
                      children: <Widget>[
                        SizedBox(width: 16.0,),
                        Text('设备状态', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),)
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
                                  value: machineStatusId,
                                  underline: Container(),
                                  items: machineStatusList.map<DropdownMenuItem>((item) {
                                    return DropdownMenuItem(
                                      value: item['value'],
                                      child: Container(
                                        width: 200,
                                        child: Text(item['text']),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    print(val);
                                    FocusScope.of(context).requestFocus(new FocusNode());
                                    setState(() {
                                      machineStatusId = val;
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
                        Text('科室', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),)
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
                                  value: departmentId,
                                  underline: Container(),
                                  items: departmentList.map<DropdownMenuItem>((item) {
                                    return DropdownMenuItem(
                                      value: item['value'],
                                      child: Container(
                                        width: 200,
                                        child: Text(item['text']),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    FocusScope.of(context).requestFocus(new FocusNode());
                                    setState(() {
                                      departmentId = val;
                                    });
                                  },
                                )
                              ],
                            )
                        ),
                        SizedBox(width: 16.0,),
                        Container(
                          width: 40.0,
                          height: 40.0,
                          child: Center(
                            child: IconButton(
                                onPressed: () {
                                  FocusScope.of(context).requestFocus(new FocusNode());
                                  showSearch(context: context, delegate: SearchBarDepartment(), hintText: '请输入科室名称/拼音/ID').then((result) {
                                    if (result != null) {
                                      var _result = jsonDecode(result);
                                      setState(() {
                                        departmentId = _result['ID'];
                                      });
                                    }
                                  });
                                },
                                icon: Icon(Icons.search)
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 18.0,),
                    Row(
                      children: <Widget>[
                        SizedBox(width: 16.0,),
                        Text('维保状态', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),)
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
                                  value: warrantyId,
                                  underline: Container(),
                                  items: <DropdownMenuItem>[
                                    DropdownMenuItem(
                                      value: 0,
                                      child: Container(
                                        width: 200.0,
                                        child: Text('全部'),
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: 1,
                                      child: Container(
                                        width: 200.0,
                                        child: Text('保外'),
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: 2,
                                      child: Container(
                                        width: 200.0,
                                        child: Text('保内'),
                                      ),
                                    ),
                                  ],
                                  onChanged: (val) {
                                    FocusScope.of(context).requestFocus(new FocusNode());
                                    setState(() {
                                      warrantyId = val;
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
                        Text('停用', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),)
                      ],
                    ),
                    SizedBox(height: 6.0,),
                    Row(
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
                              value: usageStatus,
                              onChanged: (val) {
                                FocusScope.of(context).requestFocus(new FocusNode());
                                setState(() {
                                  usageStatus = val;
                                });
                              },
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 18.0,),
                    Row(
                      children: <Widget>[
                        SizedBox(width: 16.0,),
                        Text('富士II类', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),)
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
                                  value: fujiClass2,
                                  underline: Container(),
                                  items: fujiClass2List.map<DropdownMenuItem>((item) {
                                    return DropdownMenuItem(
                                      value: item['value'],
                                      child: Container(
                                        width: 200,
                                        child: Text(item['text']),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    print(val);
                                    FocusScope.of(context).requestFocus(new FocusNode());
                                    setState(() {
                                      fujiClass2 = val;
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
                          fujiClass2 = 0;
                          machineStatusId = machineStatusList[0]['value'];
                          departmentId = departmentList[0]['value'];
                          searchFilter = 'e.ID';
                          warrantyId = 0;
                          _keywords.clear();
                          _deviceCode.clear();
                          _deviceName.clear();
                          usageStatus = false;
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


  void initState() {
    super.initState();
    if (widget.equipmentType != null) {
      switch (widget.equipmentType) {
        case EquipmentType.MEDICAL:
          prefix = 'e';
          pageTitle = '医疗设备';
          cardHead = "设备";
          break;
        case EquipmentType.MEASURE:
          prefix = 'mi';
          pageTitle = '计量器具';
          cardHead = "器具";
          break;
        case EquipmentType.OTHER:
          prefix = 'oe';
          pageTitle = '其他设备';
          cardHead = "设备";
          break;
      }
      eType = widget.equipmentType;
    }
    if (widget.assetType != null) {
      log("${widget.assetType}");
      switch (widget.assetType) {
        case 1:
          prefix = 'e';
          pageTitle = '医疗设备';
          cardHead = "设备";
          eType = EquipmentType.MEDICAL;
          break;
        case 2:
          prefix = 'mi';
          pageTitle = '计量器具';
          cardHead = "器具";
          eType = EquipmentType.MEASURE;
          break;
        case 3:
          prefix = 'oe';
          pageTitle = '其他设备';
          cardHead = "设备";
          eType = EquipmentType.OTHER;
          break;
        default:
          prefix = 'e';
          pageTitle = '医疗设备';
          cardHead = "设备";
          eType = EquipmentType.MEDICAL;
          break;
      }
    }
    cModel = MainModel.of(context);
    initFilter();
    setState(() {
      _loading = true;
    });
    getPermission().then((_) {
      getEquipments().then((result) => setState(() {
        _loading = false;
      }));
    });
    getRole();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        var _length = _equipments.length;
        offset += 10;
        getEquipments().then((result) {
          if (_equipments.length == _length) {
            setState(() {
              _noMore = true;
            });
          } else {
            setState(() {
              _noMore = false;
            });
          }
        });
      }
    });
  }

  Future<List<TimelineModel>> getTimeline(int deviceId) async {
    var resp = await HttpRequest.request(
      '/Equipment/GetTimeLine4App',
      method: HttpRequest.POST,
      data: {
        'id': deviceId
      }
    );
    if (resp['ResultCode'] == '00') {
      print(resp['Data']['Dispatches']);
      if (resp['Data']['Dispatches'] != null) {
        var _dispatches = resp['Data']['Dispatches'];
        List<TimelineModel> _timeline = [];
        for(var _item in _dispatches) {
          switch (_item['RequestType']['ID']) {
            case 1:
              _timeline.add(
                TimelineModel(
                  ListTile(
                    title: new Text(_item['TimelineDesc']),
                    subtitle: new Text(_item['EndDate'].split('T')[0]),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => ManagerCompletePage(requestId: _item['RequestID']), ));
                    },
                  ),
                  icon: Icon(Icons.build, color: Colors.white,),
                  iconBackground: Colors.redAccent,
                  position: TimelineItemPosition.right
                )
              );
              break;
            case 3:
              _timeline.add(
                  TimelineModel(
                      ListTile(
                        title: new Text(_item['TimelineDesc']),
                        subtitle: new Text(_item['EndDate'].split('T')[0]),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(builder: (_) => ManagerCompletePage(requestId: _item['RequestID']), ));
                        },
                      ),
                      icon: Icon(Icons.store, color: Colors.white,),
                      iconBackground: Colors.redAccent,
                      position: TimelineItemPosition.right
                  )
              );
              break;
            case 4:
              _timeline.add(
                  TimelineModel(
                      ListTile(
                        title: new Text(_item['TimelineDesc']),
                        subtitle: new Text(_item['EndDate'].split('T')[0]),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(builder: (_) => ManagerCompletePage(requestId: _item['RequestID']), ));
                        },
                      ),
                      icon: Icon(Icons.people, color: Colors.white,),
                      iconBackground: Colors.green,
                      position: TimelineItemPosition.right
                  )
              );
              break;
            case 5:
              _timeline.add(
                  TimelineModel(
                      ListTile(
                        title: new Text(_item['TimelineDesc']),
                        subtitle: new Text(_item['EndDate'].split('T')[0]),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(builder: (_) => ManagerCompletePage(requestId: _item['RequestID']), ));
                        },
                      ),
                      icon: Icon(Icons.remove_red_eye, color: Colors.white,),
                      iconBackground: Colors.green,
                      position: TimelineItemPosition.right
                  )
              );
              break;
            case 2:
              _timeline.add(
                  TimelineModel(
                      ListTile(
                        title: new Text(_item['TimelineDesc']),
                        subtitle: new Text(_item['EndDate'].split('T')[0]),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(builder: (_) => ManagerCompletePage(requestId: _item['RequestID']), ));
                        },
                      ),
                      icon: Icon(Icons.assignment_turned_in, color: Colors.white,),
                      iconBackground: Colors.green,
                      position: TimelineItemPosition.right
                  )
              );
              break;
            default:
              _timeline.add(
                  TimelineModel(
                      ListTile(
                        title: new Text(_item['TimelineDesc']),
                        subtitle: new Text(_item['EndDate'].split('T')[0]),
                        onTap: () {
                          if (_item['RequestType']['ID'] != 0) {
                            Navigator.of(context).push(MaterialPageRoute(builder: (_) => ManagerCompletePage(requestId: _item['RequestID']), ));
                          }
                        },
                      ),
                      icon: Icon(Icons.check, color: Colors.white,),
                      iconBackground: Colors.grey,
                      position: TimelineItemPosition.right
                  )
              );
          }
        }
        return _timeline;
      } else {
        return [];
      }
    } else {
      return [];
    }
  }

  List<Widget> _buildEquipInfo(Map item) {
    List<Widget> _list = [];
    switch (eType) {
      case EquipmentType.MEDICAL:
        _list.addAll([
          BuildWidget.buildCardRow('资产编号', item['AssetCode']),
          BuildWidget.buildCardRow('设备型号', item['ModelCode']),
          BuildWidget.buildCardRow('序列号', item['SerialCode']),
          BuildWidget.buildCardRow('厂商', item['Manufacturer']['Name']),
          BuildWidget.buildCardRow('资产等级', item['AssetLevel']['Name']),
          BuildWidget.buildCardRow('使用科室', item['Department']['Name']),
          BuildWidget.buildCardRow('设备状态', item['EquipmentStatus']['Name']),
          BuildWidget.buildCardRow('维保状态', item['WarrantyStatus']),
          BuildWidget.buildCardRow('富士II类', item['FujiClass2']['Name']),
        ]);
        break;
      case EquipmentType.MEASURE:
        _list.addAll([
          BuildWidget.buildCardRow('资产编号', item['AssetCode']),
          BuildWidget.buildCardRow('序列号', item['SerialCode']),
          BuildWidget.buildCardRow('器具型号', item['ModelCode']),
          BuildWidget.buildCardRow('厂商', item['Manufacturer']['Name']),
          BuildWidget.buildCardRow('资产等级', item['AssetLevel']['Name']),
          BuildWidget.buildCardRow('使用科室', item['Department']['Name']),
          BuildWidget.buildCardRow('器具状态', item['EquipmentStatus']['Name']),
          BuildWidget.buildCardRow('关联设备', item['Equipment']['Name']),
        ]);
        break;
      case EquipmentType.OTHER:
        _list.addAll([
          BuildWidget.buildCardRow('资产编号', item['AssetCode']),
          BuildWidget.buildCardRow('序列号', item['SerialCode']),
          BuildWidget.buildCardRow('设备型号', item['OtherEqptCode']),
          BuildWidget.buildCardRow('厂商', item['Manufacturer']['Name']),
          BuildWidget.buildCardRow('资产等级', item['AssetLevel']['Name']),
          BuildWidget.buildCardRow('使用科室', item['Department']['Name']),
          BuildWidget.buildCardRow('设备状态', item['EquipmentStatus']['Name']),
        ]);
        break;
    }
    //switch (widget.assetType) {
    //  case 1:
    //    _list.addAll([
    //      BuildWidget.buildCardRow('资产编号', item['AssetCode']),
    //      BuildWidget.buildCardRow('设备型号', item['ModelCode']),
    //      BuildWidget.buildCardRow('序列号', item['SerialCode']),
    //      BuildWidget.buildCardRow('厂商', item['Manufacturer']['Name']),
    //      BuildWidget.buildCardRow('资产等级', item['AssetLevel']['Name']),
    //      BuildWidget.buildCardRow('使用科室', item['Department']['Name']),
    //      BuildWidget.buildCardRow('设备状态', item['EquipmentStatus']['Name']),
    //      BuildWidget.buildCardRow('维保状态', item['WarrantyStatus']),
    //      BuildWidget.buildCardRow('富士II类', item['FujiClass2']['Name']),
    //    ]);
    //    break;
    //  case 2:
    //    _list.addAll([
    //      BuildWidget.buildCardRow('资产编号', item['AssetCode']),
    //      BuildWidget.buildCardRow('序列号', item['SerialCode']),
    //      BuildWidget.buildCardRow('器具型号', item['ModelCode']),
    //      BuildWidget.buildCardRow('厂商', item['Manufacturer']['Name']),
    //      BuildWidget.buildCardRow('资产等级', item['AssetLevel']['Name']),
    //      BuildWidget.buildCardRow('使用科室', item['Department']['Name']),
    //      BuildWidget.buildCardRow('器具状态', item['EquipmentStatus']['Name']),
    //      BuildWidget.buildCardRow('关联设备', item['Equipment']['Name']),
    //    ]);
    //    break;
    //  case 3:
    //    _list.addAll([
    //      BuildWidget.buildCardRow('资产编号', item['AssetCode']),
    //      BuildWidget.buildCardRow('序列号', item['SerialCode']),
    //      BuildWidget.buildCardRow('设备型号', item['OtherEqptCode']),
    //      BuildWidget.buildCardRow('厂商', item['Manufacturer']['Name']),
    //      BuildWidget.buildCardRow('资产等级', item['AssetLevel']['Name']),
    //      BuildWidget.buildCardRow('使用科室', item['Department']['Name']),
    //      BuildWidget.buildCardRow('设备状态', item['EquipmentStatus']['Name']),
    //    ]);
    //    break;
    //}
    return _list;
  }

  Card buildEquipmentCard(Map item) {
    return new Card(
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          ListTile(
            leading: IconButton(
              icon: Icon(Icons.desktop_mac, size: 36.0, color: Colors.green,),
              onPressed: () {
                Navigator.of(context).push(new MaterialPageRoute(builder: (_) => new EquipmentDetail(editable: false, equipment: item, equipmentType: widget.equipmentType??eType,)));
              },
            ),
            title: Text(
              "$cardHead名称：${item['Name']}",
              style: new TextStyle(
                  fontSize: 16.0,
                  color: Theme.of(context).primaryColor
              ),
            ),
            subtitle: Text(
              "系统编号：${item['OID']}",
              style: new TextStyle(
                  color: Theme.of(context).accentColor
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              children: _buildEquipInfo(item),
            ),
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
                specialPermission==null||!specialPermission['QRCode']?Container():new RaisedButton(
                onPressed: (){
                  CodeType codeType;
                  switch (widget.equipmentType) {
                    case EquipmentType.MEDICAL:
                      codeType = CodeType.DEVICE;
                      break;
                    case EquipmentType.MEASURE:
                      codeType = CodeType.MEASURE;
                      break;
                    case EquipmentType.OTHER:
                      codeType = CodeType.OTHER;
                      break;
                  }
                  Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
                    return new PrintQrcode(equipmentId: item['ID'], codeType: codeType,);
                  }));
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                color: new Color(0xff2E94B9),
                child: new Row(
                  children: <Widget>[
                    new Icon(
                      Icons.widgets,
                      color: Colors.white,
                    ),
                    new Text(
                      '二维码',
                      style: new TextStyle(
                          color: Colors.white
                      ),
                    )
                  ],
                ),
              ),
              new Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.0),
              ),
              techPermission==null||!techPermission['Edit']?Container():new RaisedButton(
                onPressed: (){
                  setState(() {
                    isSearchState = false;
                    _keywords.clear();
                  });
                  Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
                    return new EquipmentDetail(equipment: item, editable: _editable, equipmentType: eType,);
                  })).then((result) {
                    setState(() {
                      _loading = true;
                      offset = 0;
                      _equipments.clear();
                    });
                    getEquipments().then((result) {
                      setState(() {
                        _loading = false;
                      });
                    });
                  });
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                color: new Color(0xff2E94B9),
                child: new Row(
                  children: <Widget>[
                    new Icon(
                      _editable?Icons.edit:Icons.remove_red_eye,
                      color: Colors.white,
                    ),
                    new Text(
                      _editable?'编辑':'查看',
                      style: new TextStyle(
                          color: Colors.white
                      ),
                    )
                  ],
                ),
              ),
              new Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.0),
              ),
              specialPermission!=null&&specialPermission['TimeLine']?new RaisedButton(
                onPressed: () async {
                  if (limited&&role!=1) {
                    return;
                  }
                  Navigator.of(context).push(new MaterialPageRoute(builder: (_) => new Dashboard(equipmentId: item['ID'],)));
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                color: new Color(0xff2E94B9),
                child: new Row(
                  children: <Widget>[
                    new Icon(
                      Icons.replay,
                      color: Colors.white,
                    ),
                    new Text(
                      '生命周期',
                      style: new TextStyle(
                          color: Colors.white
                      ),
                    )
                  ],
                ),
              ):Container(),
            ],
          )
        ],
      ),
    );
  }

  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: isSearchState?TextField(
            controller: _keywords,
            style: new TextStyle(
              color: Colors.white
            ),
            decoration: new InputDecoration(
              prefixIcon: Icon(Icons.search, color: Colors.white,),
              hintText: '请输入设备名称/型号/序列号',
              hintStyle: new TextStyle(color: Colors.white)
            ),
            onChanged: (val) {
              getEquipments(filterText: val);
            },
          ):Text("$pageTitle列表"??''),
          elevation: 0.7,
          actions: <Widget>[
            isSearchState?IconButton(
              icon: Icon(Icons.cancel),
              onPressed: () {
                //setState(() {
                //  isSearchState = false;
                //});
                showSheet(context);
              },
            ):IconButton(icon: Icon(Icons.search), onPressed: () {
              //setState(() {
              //  isSearchState = true;
              //});
              showSheet(context);
            })
          ],
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
        ),
        body: _loading?new Center(child: new SpinKitThreeBounce(color: Colors.blue,),):(_equipments.length==0?Center(child: Text('无设备'),):new ListView.builder(
          itemCount: _equipments.length>10?_equipments.length+1:_equipments.length,
          controller: _scrollController,
          itemBuilder: (context, i) {
            if (i != _equipments.length) {
              return buildEquipmentCard(_equipments[i]);
            } else {
              return new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _noMore?new Center(child: new Text('没有更多设备'),):new SpinKitChasingDots(color: Colors.blue,)
                ],
              );
            }
          },
        )),
        floatingActionButton: techPermission==null||!techPermission['Add']?Container():FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
              return new EquipmentDetail(editable: true, equipmentType: widget.equipmentType,);
            })).then((result) {
              setState(() {
                offset = 0;
                _equipments.clear();
                _loading = true;
              });
              getEquipments().then((result) {
                setState(() {
                  _loading = false;
                });
              });});
          },
          child: Icon(Icons.add_circle),
          backgroundColor: Colors.blue,
        ),
    );
  }
}

enum EquipmentType {
  MEDICAL,
  MEASURE,
  OTHER,
}