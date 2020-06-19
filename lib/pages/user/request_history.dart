import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:atoi/widgets/build_widget.dart';
import 'package:atoi/utils/http_request.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:atoi/utils/constants.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:atoi/models/models.dart';
import 'package:atoi/models/constants_model.dart';
import 'package:date_format/date_format.dart';
import 'dart:convert';
import 'package:atoi/widgets/search_department.dart';

/// 用户请求历史页面类
class RequestHistory extends StatefulWidget {
  _RequestHistoryState createState() => _RequestHistoryState();
}

class _RequestHistoryState extends State<RequestHistory> {

  var history;
  Future<SharedPreferences> prefs = SharedPreferences.getInstance();
  ConstantsModel cModel;
  int departmentId;
  List departmentList;
  int statusId;
  List statusList;
  DateTime _start = DateTime.now().add(Duration(days: -90));
  DateTime _end = DateTime.now();
  String startDate;
  String endDate;

  void initFilter() async {
    await cModel.getConstants();
    setState(() {
      departmentList = initList(cModel.Departments, valueForAll: -1);
      statusList = initList(cModel.RequestStatus);
      departmentId = departmentList[0]['value'];
      statusId = statusList[0]['value'];
      startDate = formatDate(_start, [yyyy, '-', mm, '-', dd]);
      endDate = formatDate(_end, [yyyy, '-', mm, '-', dd]);
    });
    await getUserRequests();
  }

  List initList(Map _map, {int valueForAll}) {
    valueForAll = valueForAll??0;
    List _list = [];
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

  void showSheet(BuildContext context) {
    showModalBottomSheet(context: context, builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Column(
            children: <Widget>[
              Container(
                height: 300.0,
                child: ListView(
                  children: <Widget>[
                    SizedBox(height: 18.0,),
                    Row(
                      children: <Widget>[
                        SizedBox(width: 16.0,),
                        Text('请求日期', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),)
                      ],
                    ),
                    SizedBox(height: 6.0,),
                    Row(
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
                                  FocusScope.of(context).requestFocus(new FocusNode());
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
                                  FocusScope.of(context).requestFocus(new FocusNode());
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
                    SizedBox(height: 18.0,),
                    Row(
                      children: <Widget>[
                        SizedBox(width: 16.0,),
                        Text('请求状态', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),)
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
                                  value: statusId,
                                  underline: Container(),
                                  items: statusList.map<DropdownMenuItem>((item) {
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
                        SizedBox(width: 16.0,),
                        Container(
                          width: 40.0,
                          height: 40.0,
                          child: Center(
                            child: IconButton(
                                onPressed: () {
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
                          departmentId = departmentList[0]['value'];
                          statusId = statusList[0]['value'];
                          startDate = formatDate(_start, [yyyy, '-', mm, '-', dd]);
                          endDate = formatDate(_end, [yyyy, '-', mm, '-', dd]);
                        });
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
                        getUserRequests();
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
    cModel = MainModel.of(context);
    initFilter();
  }

  Future<Null> getUserRequests() async {
    var _prefs = await prefs;
    var userId = _prefs.getInt('userID');
    var resp = await HttpRequest.request(
      '/Request/GetRequests',
      method: HttpRequest.GET,
      params: {
        'userID': userId,
        'typeID': 0,
        'statusID': statusId,
        'department': departmentId,
        'startDate': startDate,
        'endDate': endDate
      }
    );
    if (resp['ResultCode'] == '00') {
      setState(() {
        history = resp['Data'];
      });
    }
  }

  List<Widget> buildCard() {
    List<Widget> _list = [];
    if (history.length == 0) {
      _list.add(Center(child: Text('没有历史记录'),));
    }
    for (var item in history) {
      _list.add(
        Card(
          child: new Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ListTile(
                leading: Icon(
                  Icons.build,
                  color: Color(0xff14BD98),
                  size: 36.0,
                ),
                title: new Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "请求编号：",
                      style: new TextStyle(
                          fontSize: 18.0,
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w500
                      ),
                    ),
                    Text(
                      item['OID'],
                      style: new TextStyle(
                          fontSize: 18.0,
                          color: Colors.red,
                          //color: new Color(0xffD25565),
                          fontWeight: FontWeight.w400
                      ),
                    )
                  ],
                ),
                subtitle: Text(
                  "请求时间：${AppConstants.TimeForm(item['RequestDate'], 'yyyy-mm-dd hh:MM:ss')}",
                  style: new TextStyle(
                      color: Theme.of(context).accentColor
                  ),
                ),
              ),
              new Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    item['Equipments'].length>0?BuildWidget.buildCardRow('设备编号', item['Equipments'][0]['OID']):new Container(),
                    item['Equipments'].length>0?BuildWidget.buildCardRow('设备名称', item['Equipments'][0]['Name']):new Container(),
                    item['Equipments'].length>0?BuildWidget.buildCardRow('使用科室', item['Equipments'][0]['Department']['Name']):new Container(),
                    BuildWidget.buildCardRow('请求人', item['RequestUser']['Name']),
                    BuildWidget.buildCardRow('类型', item['RequestType']['Name']),
                    BuildWidget.buildCardRow('状态', item['Status']['Name']),
                    BuildWidget.buildCardRow('请求详情', item['FaultDesc'].length>10?'${item['FaultDesc'].substring(0,10)}...':item['FaultDesc']),
                  ],
                ),
              )
            ],
          ),
        )
      );
    }
    return _list;
  }

  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('报修历史'),
        elevation: 0.7,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                new Color(0xff2D577E),
                new Color(0xff4F8EAD)
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: () {
        showSheet(context);
      },
        child: Icon(Icons.search),
        backgroundColor: Colors.blueAccent,
      ),
      body: history==null?new Center(child: new SpinKitThreeBounce(color: Colors.blue,),):new ListView(
        children: buildCard()
      )
    );
  }
}