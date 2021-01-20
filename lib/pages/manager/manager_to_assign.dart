import 'package:flutter/material.dart';
import 'package:atoi/pages/manager/manager_assign_page.dart';
import 'dart:async';
import 'package:atoi/utils/http_request.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:atoi/models/models.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:atoi/widgets/build_widget.dart';
import 'package:atoi/utils/constants.dart';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:date_format/date_format.dart';
import 'package:atoi/pages/equipments/equipments_list.dart';
import 'package:atoi/permissions.dart';

/// 超管待派工列表页面类
class ManagerToAssign extends StatefulWidget {
  @override
  _ManagerToAssignState createState() => _ManagerToAssignState();

}

class _ManagerToAssignState extends State<ManagerToAssign> {

  List<dynamic> _tasks = [];
  Future<SharedPreferences> prefs = SharedPreferences.getInstance();

  bool _loading = false;
  bool _noMore = false;
  int _role = 1;
  Map techPermission;
  Map specialPermission;

  ScrollController _scrollController = ScrollController();

  Future<Null> getRole() async {
    var _prefs = await prefs;
    var _roleId = _prefs.getInt('role');
    setState(() {
      _role = _roleId;
    });
  }

  Future<Null> getPermission() async {
    SharedPreferences _prefs = await prefs;
    Permission permissionInstance = new Permission();
    permissionInstance.prefs = _prefs;
    permissionInstance.initPermissions();
    techPermission = permissionInstance.getTechPermissions('Operations', 'Request');
    specialPermission = permissionInstance.getSpecialPermissions('Operations', 'Request');
  }

  void initState() {
    //getData();
    getPermission();
    refresh();
    super.initState();
    getRole();

    ManagerModel model = MainModel.of(context);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        var _length = model.requests.length;
        model.getMoreRequests().then((result) {
          if (model.requests.length == _length) {
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

  Future<Null> getData() async {
    var _prefs = await prefs;
    var userID = await _prefs.getInt('userID');
    Map<String, dynamic> params = {
      'userID': userID,
      'statusID': 1,
      'statusID': 2,
      'statusID': 3,
      'statusID': 4,
      'statusID': 5,
      'statusID': 6,
      'statusID': 7,
      'typeID': 0
    };
    setState(() {
      _loading = true;
    });
    var _data = await HttpRequest.request(
      '/Request/GetRequests',
      method: HttpRequest.GET,
      params: params
    );
    print(_data['Data']);
    _prefs.setString('badgeA', _data['Data'].length.toString());
    setState(() {
      _tasks = _data['Data'];
      _loading = false;
    });
  }

  Future _cancelRequest(int requestId) async {
    var _prefs = await prefs;
    var userId = _prefs.getInt('userID');
    Map<String, dynamic> _data = {
      'userID': userId,
      'requestID': requestId
    };
    var resp = await HttpRequest.request(
      '/Request/EndRequest',
      method: HttpRequest.POST,
      data: _data
    );
    print(resp);
    if (resp['ResultCode'] == '00') {
      showDialog(context: context,
        builder: (context) => CupertinoAlertDialog(
          title: new Text('取消成功'),
        )
      );
      getData();
    }
  }

  Row buildRow(String leading, String content) {
    return new Row(
      children: <Widget>[
        new Expanded(
          flex: 3,
          child: new Text(
            leading,
            style: new TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w600
            ),
          ),
        ),
        new Expanded(
          flex: 7,
          child: new Text(
            content,
            style: new TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w400,
                color: Colors.grey
            ),
          ),
        )
      ],
    );
  }

  Future<Null> refresh() async {
    ManagerModel _model = MainModel.of(context);
    _model.getRequests();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

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
                    taskNo,
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
                  equipmentName.isNotEmpty?BuildWidget.buildCardRow('设备名称', equipmentName, onTap: equipmentName=='多设备'?null:() => Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
                    return EquipmentsList(equipmentId: equipmentNo, assetType: _equipments[0]['AssetType']['ID'],);
                  }))):new Container(),
                  departmentName.isNotEmpty?BuildWidget.buildCardRow('使用科室', departmentName):new Container(),
                  BuildWidget.buildCardRow('请求人', requestPerson),
                  BuildWidget.buildCardRow('请求来源', task['Source']['Name']),
                  BuildWidget.buildCardRow('类型', requestType),
                  BuildWidget.buildCardRow('状态', status),
                  BuildWidget.buildCardRow('请求详情', detail.length>10?'${detail.substring(0,10)}...':detail),
                  task['SelectiveDate']==null?new Container():BuildWidget.buildCardRow('择期日期', AppConstants.TimeForm(task['SelectiveDate'], 'yyyy-mm-dd')),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      specialPermission==null||!specialPermission['RequestDispatch']?Container():new RaisedButton(
                        onPressed: (){
                          //Navigator.of(context).pushNamed(ManagerAssignPage.tag);
                          Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
                            return new ManagerAssignPage(request: task);
                          })).then((result) => refresh());
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        color: new Color(0xff2E94B9),
                        child: new Row(
                          children: <Widget>[
                            new Icon(
                              Icons.assignment_ind,
                              color: Colors.white,
                            ),
                            new Text(
                              '派工',
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
                      specialPermission==null||!specialPermission['RequestSelective']?Container():new RaisedButton(
                        onPressed: (){
                          var _date = DateTime.tryParse(task['SelectiveDate'].toString())??new DateTime.now();
                          DatePicker.showDatePicker(
                            context,
                            pickerTheme: DateTimePickerTheme(
                              showTitle: true,
                              confirm: Text('确认', style: TextStyle(color: Colors.blueAccent)),
                              cancel: Text('取消', style: TextStyle(color: Colors.redAccent)),
                            ),
                            minDateTime: DateTime.now(),
                            maxDateTime: DateTime.now().add(Duration(days: 365*10)),
                            initialDateTime: _date,
                            dateFormat: 'yyyy-MM-dd',
                            locale: DateTimePickerLocale.en_us,
                            onClose: () => print(""),
                            onCancel: () => print('onCancel'),
                            onChange: (dateTime, List<int> index) {
                            },
                            onConfirm: (dateTime, List<int> index) {
                              var date = formatDate(dateTime, [yyyy, '-', mm, '-', dd]);
                              HttpRequest.request(
                                  '/Request/UpdateSelectiveDate',
                                  method: HttpRequest.POST,
                                  data: {
                                    'requestId': requestId,
                                    'selectiveDate': date
                                  }
                              ).then((resp) {
                                if (resp['ResultCode'] == '00') {
                                  showDialog(context: context,
                                      builder: (context) =>CupertinoAlertDialog(
                                        title: new Text('择期成功'),
                                      )
                                  ).then((result) {
                                    refresh();
                                  });
                                } else {
                                  showDialog(context: context,
                                      builder: (context) =>CupertinoAlertDialog(
                                        title: new Text(resp['ResultMessage']),
                                      )
                                  );
                                }
                              });
                            },
                          );
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        color: new Color(0xff2E94B9),
                        child: new Row(
                          children: <Widget>[
                            new Icon(
                              Icons.calendar_today,
                              color: Colors.white,
                            ),
                            new Text(
                              '择期',
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

    return ScopedModelDescendant<MainModel>(
      builder: (context, child, model) {
        return new RefreshIndicator(
            child:
            (model.requests.length == 0?ListView(padding: const EdgeInsets.symmetric(vertical: 150.0), children: <Widget>[new Center(child: _loading?SpinKitThreeBounce(color: Colors.blue):new Text('没有待派工请求'),)],):
            ListView.builder(
                padding: const EdgeInsets.all(2.0),
                itemCount: model.requests.length>9?model.requests.length+1:model.requests.length,
                controller: _scrollController,
                itemBuilder: (context, i) {
                  if (i != model.requests.length) {
                     return buildCardItem(model.requests[i], model.requests[i]['ID'], model.requests[i]['OID'], model.requests[i]['RequestDate'], model.requests[i]['EquipmentOID'], model.requests[i]['EquipmentName'], model.requests[i]['DepartmentName'], model.requests[i]['RequestUser']['Name'], model.requests[i]['RequestType']['Name'], model.requests[i]['Status']['Name'], model.requests[i]['FaultDesc'], model.requests[i]['Equipments']);
                  } else {
                    return new Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        _noMore?new Center(child: new Text('没有更多任务需要派工'),):new SpinKitChasingDots(color: Colors.blue,)
                      ],
                    );
                  }
                }
            )),
            onRefresh: model.getRequests
        );
      }
    );
  }
}
