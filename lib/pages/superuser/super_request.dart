import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:atoi/widgets/build_widget.dart';
import 'package:atoi/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:date_format/date_format.dart';
import 'package:atoi/utils/http_request.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:atoi/models/constants_model.dart';
import 'package:atoi/widgets/search_lazy.dart';
import 'dart:convert';
import 'package:atoi/pages/manager/manager_complete_page.dart';

class SuperRequest extends StatefulWidget {
  final PageType pageType;
  final String filter;
  final String field;
  final int type;
  SuperRequest({Key key, this.pageType, this.field, this.filter, this.type}):super(key: key);
  _SuperRequestState createState() => new _SuperRequestState();
}

class _SuperRequestState extends State<SuperRequest> {

  List _requests = [];
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  bool _loading = false;
  bool _noMore = false;
  int offset = 0;
  ScrollController _scrollController = new ScrollController();
  ConstantsModel cModel = new ConstantsModel();

  // request params
  int _status;
  int _type;
  bool _recall;
  bool _overDue;
  String _field;
  TextEditingController _filter;
  String _startDate;
  String _endDate;
  int _depart;
  int _urgency;
  List _typeList = [];
  List _statusList = [];
  List _departmentList = [];
  List _urgencyList = [];
  List _dispatchList = [];

  Future<Null> refresh() async {
    offset = 0;
    _requests.clear();
    getRequests();
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

  Future<Null> getRequests() async {
    var _pref = await _prefs;
    int _userId = _pref.getInt('userID')??41;
    setState(() {
      _loading = true;
    });
    String _url;
    Map<String, dynamic> _param;
    switch (widget.pageType) {
      case PageType.REQUEST:
        _url = '/Request/GetRequests';
        _param = {
          'statusID': _status,
          'userID': _userId,
          'PageSize': 10,
          'CurRowNum': offset,
          'typeID': _type,
          'isRecall': _recall,
          'department': _depart,
          'urgency': _urgency,
          'overDue': _overDue,
          'startDate': _startDate,
          'endDate': _endDate,
          'filterField': _field,
          'filterText': _filter.text,
          'sortField': 'r.RequestDate'
        };
        break;
      case PageType.DISPATCH:
        _url = '/Dispatch/GetDispatchs?statusIDs=2&statusIDs=3&statusIDs=1&statusIDs=4';
        _param = {
          'userID': _userId,
          'urgency': _urgency,
          'type': _type,
          'pageSize': 10,
          'curRowNum': offset,
          'filterField': _field,
          'filterText': _filter.text
        };
    }
    var resp = await HttpRequest.request(
      _url,
      method: HttpRequest.GET,
      params: _param
    );
    if (resp['ResultCode'] == '00') {
      offset += 10;
      _requests.addAll(resp['Data']);
      setState(() {
        _loading = false;
      });
    }
  }

  Future<Null> initFilter() async {
    var _start = new DateTime.now().add(new Duration(days: widget.type==null?-4:-365));
    var _end = new DateTime.now();
    await cModel.getConstants();
    setState(() {
      _status = 0;
      _type = widget.type!=null?widget.type:0;
      _depart = -1;
      _recall = false;
      _overDue = false;
      _field = widget.field!=null?widget.field:(widget.pageType==PageType.REQUEST?'r.ID':'d.ID');
      _filter = new TextEditingController();
      _filter.text = widget.filter??'';
      _urgency = 0;
      _startDate = '';
      _endDate = formatDate(_end, [yyyy, '-', mm, '-', dd]);
      _typeList = initList(cModel.RequestType);
      _statusList = initList(cModel.RequestStatus, valueForAll: 0);
      _statusList.removeWhere((item) => item['value'] == -1);
      _departmentList = initList(cModel.Departments, valueForAll: -1);
      _urgencyList = initList(cModel.UrgencyID);
      _dispatchList = initList(cModel.DispatchStatus);
      _dispatchList.removeWhere((item) => item['value'] == -1 || item['value'] == 1 || item['value'] == 4);
    });
  }

  Future<List> getDispatchesByRequestId(int requestId) async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    int userId = await _prefs.getInt('userID');
    var resp = await HttpRequest.request(
        '/Dispatch/GetDispatchesByRequestID',
        method: HttpRequest.GET,
        params: {
          'id': requestId,
          'userId': userId
        }
    );
    if (resp['ResultCode'] == '00') {
      List _list = resp['Data'];
      //_list.removeWhere((item) => (item['Status']['ID']==-1 || item['Status']['ID']==4));
      return _list;
    } else {
      return [];
    }
  }

  List<Step> buildStep(List<dynamic> steps) {
    List<Step> _steps = [];
    for(var step in steps) {
      _steps.add(Step(
          title: new Text('派工单号：${step['OID']}'),
          subtitle: new Wrap(
            alignment: WrapAlignment.start,
            children: <Widget>[
              new Text('派工单状态：${step['Status']['Name']}   工程师：${step['Engineer']['Name']}',
                style: TextStyle(
                    fontSize: 11.0
                ),
              )
            ],
          ),
          content: new Text(''),
          isActive: false
      ));
    }
    return _steps;
  }

  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        var _length = _requests.length;
        getRequests().then((result) {
          if (_requests.length == _length) {
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
    initFilter().then((result) => getRequests());
  }

  Card buildCardItem(Map task, int requestId, String taskNo, String time, String equipmentNo, String equipmentName, String departmentName, String requestPerson, String requestType, String status, String detail, List _equipments) {
    return new Card(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListTile(
            leading: Icon(
              Icons.build,
              color: Color(0xff14BD98),
              size: 36.0,
            ),
            title: new GestureDetector(
              onTap: () {
                Navigator.of(context).push(new MaterialPageRoute(builder: (_) => ManagerCompletePage(requestId: requestId,)));
              },
              child: new Row(
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
                    taskNo,
                    style: new TextStyle(
                        fontSize: 18.0,
                        color: Colors.red,
                        //color: new Color(0xffD25565),
                        fontWeight: FontWeight.w400
                    ),
                  ),
                ],
              ),
            ),
            subtitle: Text(
              "请求时间：${AppConstants.TimeForm(time, 'hh:mm')}",
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
                equipmentNo.isNotEmpty?BuildWidget.buildCardRow('设备编号', equipmentNo):new Container(),
                equipmentName.isNotEmpty?BuildWidget.buildCardRow('设备名称', equipmentName):new Container(),
                departmentName.isNotEmpty?BuildWidget.buildCardRow('使用科室', departmentName):new Container(),
                BuildWidget.buildCardRow('请求人', requestPerson),
                BuildWidget.buildCardRow('类型', requestType),
                BuildWidget.buildCardRow('状态', status),
                BuildWidget.buildCardRow('请求详情', detail.length>10?'${detail.substring(0,10)}...':detail),
                task['SelectiveDate']==null?new Container():BuildWidget.buildCardRow('择期日期', AppConstants.TimeForm(task['SelectiveDate'], 'yyyy-mm-dd')),
                new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    new RaisedButton(
                      onPressed: () async {
                        var _dispatches = await getDispatchesByRequestId(requestId);
                        if (_dispatches.length>0) {
                          showDialog(context: context,
                              builder: (context) => SimpleDialog(
                                title: new Text('派工历史'),
                                children: <Widget>[
                                  new Container(
                                    width: 350.0,
                                    height: 400.0,
                                    child: new Stepper(
                                      currentStep: _dispatches.length-1,
                                      controlsBuilder: (BuildContext context, {VoidCallback onStepContinue, VoidCallback onStepCancel}) {
                                        return new Container();
                                      },
                                      steps: buildStep(_dispatches),
                                    ),
                                  ),
                                ],
                              )
                          );
                        } else {
                          showDialog(context: context, builder: (context) => CupertinoAlertDialog(title: new Text('暂无派工历史'),));
                        }
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      color: AppConstants.AppColors['btn_success'],
                      child: new Row(
                        children: <Widget>[
                          new Icon(
                            Icons.history,
                            color: Colors.white,
                          ),
                          new Text(
                            '历史派工',
                            style: new TextStyle(
                                color: Colors.white,
                                fontSize: 12.0
                            ),
                          )
                        ],
                      ),
                    ),
                    new RaisedButton(
                      onPressed: (){
                        Navigator.of(context).push(new MaterialPageRoute(builder: (_) => ManagerCompletePage(requestId: requestId,)));
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      color: AppConstants.AppColors['btn_success'],
                      child: new Row(
                        children: <Widget>[
                          new Icon(
                            Icons.event_note,
                            color: Colors.white,
                          ),
                          new Text(
                            '查看详情',
                            style: new TextStyle(
                                color: Colors.white,
                                fontSize: 12.0
                            ),
                          )
                        ],
                      ),
                    ),
                    new RaisedButton(
                      onPressed: (){
                        task['Status']['ID']>1?Navigator.of(context).push(new MaterialPageRoute(builder: (_) => new SuperRequest(pageType: PageType.DISPATCH, filter: taskNo, field: 'd.RequestID'))):showDialog(context: (context), builder: (context) => CupertinoAlertDialog(title: Text('暂无派工单'),));
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      color: AppConstants.AppColors['btn_success'],
                      child: new Row(
                        children: <Widget>[
                          new Icon(
                            Icons.assignment_ind,
                            color: Colors.white,
                          ),
                          new Text(
                            '派工单',
                            style: new TextStyle(
                                color: Colors.white
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Color iconColor(int statusId) {
    switch (statusId) {
      case 0:
        return Colors.grey;
        break;
      case 1:
        return Colors.grey;
        break;
      case 2:
        return AppConstants.AppColors['btn_main'];
        break;
      case 3:
        return AppConstants.AppColors['btn_success'];
        break;
      default:
        return Colors.grey;
        break;
    }
  }
  
  Card buildCardDispatch(Map dispatch) {
    return new Card(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListTile(
            leading: Icon(
              Icons.visibility,
              color: Color(0xff14BD98),
              size: 40.0,
            ),
            title: new GestureDetector(
              onTap: () {
                Navigator.of(context).push(new MaterialPageRoute(builder: (_) => ManagerCompletePage(requestId: dispatch['Request']['ID'],)));
              },
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "派工单编号：",
                    style: new TextStyle(
                        fontSize: 18.0,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500
                    ),
                  ),
                  Text(
                    dispatch['OID'],
                    style: new TextStyle(
                        fontSize: 18.0,
                        color: Colors.red,
                        //color: new Color(0xffD25565),
                        fontWeight: FontWeight.w400
                    ),
                  )
                ],
              ),
            ),
            subtitle: Text(
              "派工时间：${AppConstants.TimeForm(dispatch['ScheduleDate'].toString(), 'hh:mm')}",
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
                dispatch['Request']['Equipments'].length>0?BuildWidget.buildCardRow('设备编号', dispatch['Request']['EquipmentOID']):new Container(),
                dispatch['Request']['Equipments'].length>0?BuildWidget.buildCardRow('设备名称', dispatch['Request']['EquipmentName']):new Container(),
                BuildWidget.buildCardRow('派工类型', dispatch['RequestType']['Name']),
                BuildWidget.buildCardRow('紧急程度', dispatch['Urgency']['Name']),
                BuildWidget.buildCardRow('请求编号', dispatch['Request']['OID']),
                BuildWidget.buildCardRow('请求状态', dispatch['Status']['Name']),
                new Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    SizedBox(height: 20,)
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
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
                                        controller: _filter,
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
                                value: _field,
                                underline: Container(),
                                items: widget.pageType==PageType.REQUEST?<DropdownMenuItem>[
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
                                  FocusScope.of(context).requestFocus(new FocusNode());
                                  setState(() {
                                    _field = val;
                                  });
                                },
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 18.0,),
                    widget.pageType==PageType.DISPATCH?Container():Row(
                      children: <Widget>[
                        SizedBox(width: 16.0,),
                        Text('请求日期', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),)
                      ],
                    ),
                    widget.pageType==PageType.DISPATCH?Container():SizedBox(height: 6.0,),
                    widget.pageType==PageType.DISPATCH?Container():Row(
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
                                    initialDateTime: DateTime.parse(_startDate),
                                    dateFormat: 'yyyy-MM-dd',
                                    locale: DateTimePickerLocale.en_us,
                                    onClose: () => print(""),
                                    onCancel: () => print('onCancel'),
                                    onChange: (dateTime, List<int> index) {
                                    },
                                    onConfirm: (dateTime, List<int> index) {
                                      setState(() {
                                        _startDate = formatDate(dateTime, [yyyy,'-', mm, '-', dd]);
                                      });
                                    },
                                  );
                                },
                                child: Text(_startDate, style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12.0),)
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
                                    initialDateTime: DateTime.parse(_endDate),
                                    dateFormat: 'yyyy-MM-dd',
                                    locale: DateTimePickerLocale.en_us,
                                    onClose: () => print(""),
                                    onCancel: () => print('onCancel'),
                                    onChange: (dateTime, List<int> index) {
                                    },
                                    onConfirm: (dateTime, List<int> index) {
                                      setState(() {
                                        _endDate = formatDate(dateTime, [yyyy,'-', mm, '-', dd]);
                                      });
                                    },
                                  );
                                },
                                child: Text(_endDate, style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12.0),)
                            ),
                          ),
                        ),
                      ],
                    ),
                    widget.pageType==PageType.DISPATCH?Container():SizedBox(height: 18.0,),
                    widget.pageType==PageType.DISPATCH?Container():Row(
                      children: <Widget>[
                        SizedBox(width: 16.0,),
                        Text('请求状态', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),)
                      ],
                    ),
                    widget.pageType==PageType.DISPATCH?Container():SizedBox(height: 6.0,),
                    widget.pageType==PageType.DISPATCH?Container():Row(
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
                                  value: _status,
                                  underline: Container(),
                                  items: _statusList.map<DropdownMenuItem>((item) {
                                    return DropdownMenuItem(
                                      value: item['value'],
                                      child: Container(
                                        width: 200.0,
                                        child: Text(item['text']),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    print(val);
                                    FocusScope.of(context).requestFocus(new FocusNode());
                                    setState(() {
                                      _status = val;
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
                        Text(widget.pageType==PageType.DISPATCH?'派工类型':'请求类型', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),)
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
                                  value: _type,
                                  underline: Container(),
                                  items: _typeList.map<DropdownMenuItem>((item) {
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
                                      _type = val;
                                    });
                                  },
                                )
                              ],
                            )
                        ),
                      ],
                    ),
                    widget.pageType==PageType.DISPATCH?Container():SizedBox(height: 18.0,),
                    widget.pageType==PageType.DISPATCH?Container():Row(
                      children: <Widget>[
                        SizedBox(width: 16.0,),
                        Text('是否召回', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),)
                      ],
                    ),
                    widget.pageType==PageType.DISPATCH?Container():SizedBox(height: 6.0,),
                    widget.pageType==PageType.DISPATCH?Container():Row(
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
                              value: _recall,
                              onChanged: (val) {
                                FocusScope.of(context).requestFocus(new FocusNode());
                                setState(() {
                                  _recall = val;
                                });
                              },
                            ),
                          ),
                        )
                      ],
                    ),
                    widget.pageType==PageType.DISPATCH?Container():SizedBox(height: 18.0,),
                    widget.pageType==PageType.DISPATCH?Container():Row(
                      children: <Widget>[
                        SizedBox(width: 16.0,),
                        Text('科室', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),)
                      ],
                    ),
                    widget.pageType==PageType.DISPATCH?Container():SizedBox(height: 6.0,),
                    widget.pageType==PageType.DISPATCH?Container():Row(
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
                                  value: _depart,
                                  underline: Container(),
                                  items: _departmentList.map<DropdownMenuItem>((item) {
                                    return DropdownMenuItem(
                                      value: item['value'],
                                      child: Container(
                                        width: 160.0,
                                        child: Text(item['text']),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    FocusScope.of(context).requestFocus(new FocusNode());
                                    setState(() {
                                      _depart = val;
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
                                  Navigator.of(context).push(new MaterialPageRoute(builder: (_) => SearchLazy(searchType: SearchType.DEPARTMENT,))).then((result) {
                                    if (result != null) {
                                      var _result = jsonDecode(result);
                                      setState(() {
                                        _depart = _result['ID'];
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
                                  value: _urgency,
                                  underline: Container(),
                                  items: _urgencyList.map<DropdownMenuItem>((item) {
                                    return DropdownMenuItem(
                                      value: item['value'],
                                      child: Container(
                                        width: 160.0,
                                        child: Text(item['text']),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    FocusScope.of(context).requestFocus(new FocusNode());
                                    setState(() {
                                      _urgency = val;
                                    });
                                  },
                                )
                              ],
                            )
                        ),
                      ],
                    ),
                    widget.pageType==PageType.DISPATCH?Container():SizedBox(height: 18.0,),
                    widget.pageType==PageType.DISPATCH?Container():Row(
                      children: <Widget>[
                        SizedBox(width: 16.0,),
                        Text('是否超期', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),)
                      ],
                    ),
                    widget.pageType==PageType.DISPATCH?Container():SizedBox(height: 6.0,),
                    widget.pageType==PageType.DISPATCH?Container():Row(
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
                              value: _overDue,
                              onChanged: (val) {
                                FocusScope.of(context).requestFocus(new FocusNode());
                                setState(() {
                                  _overDue = val;
                                });
                              },
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  SizedBox(width: 9.0,),
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
                          _filter.clear();
                          _field = widget.pageType==PageType.DISPATCH?'d.ID':'r.ID';
                          _recall = false;
                          _overDue = false;
                          _startDate = formatDate(DateTime.now().add(new Duration(days: -90)), [yyyy, '-', mm, '-', dd]);
                          _endDate = formatDate(DateTime.now(), [yyyy, '-', mm, '-', dd]);
                          _type = _typeList[0]['value'];
                          //_dispatchStatusId = 3;
                          _status = _statusList[0]['value'];
                          _depart = _departmentList[0]['value'];
                          _urgency = _urgencyList[0]['value'];
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
                      child: FlatButton(onPressed: () async {
                        //setFilter();
                        _requests.clear();
                        offset = 0;
                        await getRequests();
                        Navigator.of(context).pop();
                      }, child: Text('确认', style: TextStyle(color: Colors.white),)),
                    ),
                  ),
                  SizedBox(width: 8.0,)
                ],
              ),
            ],
          );
        },
      );
    });
  }

  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        backgroundColor: Color(0xFF385A95),
        title: Text(widget.pageType==PageType.REQUEST?'客户请求列表':'派工单列表'),
      ),
      body: new RefreshIndicator(
          child: _requests.length == 0?ListView(padding: const EdgeInsets.symmetric(vertical: 150.0), children: <Widget>[new Center(child: _loading?SpinKitThreeBounce(color: Colors.blue):new Text('没有待派工请求'),)],):
          ListView.builder(
              padding: const EdgeInsets.all(2.0),
              itemCount: _requests.length>9?_requests.length+1:_requests.length,
              controller: _scrollController,
              itemBuilder: (context, i) {
                if (i != _requests.length) {
                  return widget.pageType==PageType.REQUEST?buildCardItem(_requests[i], _requests[i]['ID'], _requests[i]['OID'], _requests[i]['RequestDate'], _requests[i]['EquipmentOID'], _requests[i]['EquipmentName'], _requests[i]['DepartmentName'], _requests[i]['RequestUser']['Name'], _requests[i]['RequestType']['Name'], _requests[i]['Status']['Name'], _requests[i]['FaultDesc'], _requests[i]['Equipments']):buildCardDispatch(_requests[i]);
                } else {
                  return new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _noMore?new Center(child: new Text('没有更多任务需要派工'),):new SpinKitChasingDots(color: Colors.blue,)
                    ],
                  );
                }
              }
          ),
          onRefresh: refresh
      ),
      floatingActionButton: new FloatingActionButton(
          onPressed: () {
            showSheet(context);
          },
          backgroundColor: Colors.blueAccent,
          child: Icon(Icons.search),
      ),
    );
  }
}

enum PageType {
  REQUEST,
  DISPATCH
}