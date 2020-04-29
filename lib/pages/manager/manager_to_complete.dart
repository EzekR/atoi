import 'package:flutter/material.dart';
import 'package:atoi/pages/manager/manager_complete_page.dart';
import 'dart:async';
import 'package:atoi/utils/http_request.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:atoi/models/models.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:atoi/widgets/build_widget.dart';
import 'package:atoi/utils/constants.dart';
import 'package:flutter/cupertino.dart';

/// 超管待完成列表页面类
class ManagerToComplete extends StatefulWidget {
  @override
  _ManagerToCompleteState createState() => _ManagerToCompleteState();

}

class _ManagerToCompleteState extends State<ManagerToComplete> {

  List<dynamic> _tasks = [];
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  bool _loading = false;
  bool _noMore = false;
  ScrollController _scrollController = new ScrollController();

  void initState() {
    refresh();
    super.initState();
    ManagerModel model = MainModel.of(context);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        var _length = model.todos.length;
        model.getMoreTodos().then((result) {
          if (model.todos.length == _length) {
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
    var prefs = await _prefs;
    var userID = await prefs.getInt('userID');
    Map<String, dynamic> params = {
      'userID': userID,
      'statusID': 98,
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
    setState(() {
      _tasks = _data['Data'];
      _loading = false;
    });
  }

  Future _cancelRequest(int requestId) async {
    var prefs = await _prefs;
    var userId = prefs.getInt('userID');
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
            title: new Text('终止成功'),
          )
      );
    }
    refresh();
  }



  Future<Null> _cancelDispatch(int requestID, int dispatchID) async {
    var prefs = await _prefs;
    var userId = prefs.getInt('userID');
    var resp = await HttpRequest.request(
      '/Dispatch/EndDispatch',
      method: HttpRequest.POST,
      data: {
        'userID': userId,
        'dispatchID': dispatchID,
        'requestID': requestID
      }
    );
    if (resp['ResultCode'] == '00') {
      showDialog(context: context,
          builder: (context) => CupertinoAlertDialog(
            title: new Text('取消成功'),
          )
      );
    }
    refresh();
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

  Future<List> getDispatchesByRequestId(int requestId) async {
    var resp = await HttpRequest.request(
      '/Dispatch/GetDispatchesByRequestID',
      method: HttpRequest.GET,
      params: {
        'id': requestId
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

  Future<Null> refresh() async {
    ManagerModel _model = MainModel.of(context);
    _model.getTodos();
  }

  List<Step> buildStep(List<dynamic> steps) {
    List<Step> _steps = [];
    for(var step in steps) {
      _steps.add(Step(
        title: new Text('派工单号：${step['OID']}'),
        subtitle: new Wrap(
          alignment: WrapAlignment.start,
          children: <Widget>[
            new Text('派工单状态：${step['Status']['Name']}   工程师：${step['Engineer']['Name']}')
          ],
        ),
        content: new Text(''),
        isActive: false
      ));
    }
    return _steps;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    Card buildCardItem(Map task, int requestId, String taskNo, String time, String equipmentName, String equipmentNo, String departmentName, String requestPerson, String requestType, String status, String detail) {
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
                  equipmentName==''?new Container():BuildWidget.buildCardRow('设备编号', equipmentName),
                  equipmentNo==''?new Container():BuildWidget.buildCardRow('设备名称', equipmentNo),
                  departmentName==''?new Container():BuildWidget.buildCardRow('使用科室', departmentName),
                  BuildWidget.buildCardRow('请求人', requestPerson),
                  BuildWidget.buildCardRow('请求类型', requestType),
                  BuildWidget.buildCardRow('请求状态', status),
                  BuildWidget.buildCardRow('请求详情', detail.length>10?'${detail.substring(0,10)}...':detail),
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
                                      width: 300.0,
                                      height: 600.0,
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
                          //Navigator.of(context).pushNamed(ManagerAssignPage.tag);
                          Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
                            return new ManagerCompletePage(requestId: requestId);
                          })).then((result) => refresh());
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
                        onPressed: () async {
                          if (!task['HasOpenDispatch']) {
                            showDialog(context: context,
                                builder: (context) => CupertinoAlertDialog(
                                  title: new Text('是否终止请求？'),
                                  actions: <Widget>[
                                    new Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        new Container(
                                          width: 100.0,
                                          child: RaisedButton(
                                            //padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                                            child: Text('确认', style: TextStyle(color: Colors.white),),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            color: AppConstants.AppColors['btn_cancel'],
                                            onPressed: () {
                                              _cancelRequest(requestId);
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ),
                                        new SizedBox(
                                          width: 10.0,
                                        ),
                                        new Container(
                                          width: 100.0,
                                          child: RaisedButton(
                                            child: Text('取消', style: TextStyle(color: Colors.white),),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            color: AppConstants.AppColors['btn_main'],
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                )
                            );
                          } else {
                            var _dispatches = await getDispatchesByRequestId(requestId);
                            _dispatches.removeWhere((item) => (item['Status']['ID'] == -1 || item['Status']['ID'] ==4));
                            if (_dispatches.length == 1) {
                              showDialog(context: context,
                                  builder: (context) => CupertinoAlertDialog(
                                    title: new Text('是否取消派工？'),
                                    content: new Text('${_dispatches[0]['OID']} ${_dispatches[0]['Engineer']['Name']}'),
                                    actions: <Widget>[
                                      new Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          new Container(
                                            width: 100.0,
                                            child: RaisedButton(
                                              //padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                                              child: Text('确认', style: TextStyle(color: Colors.white),),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              color: AppConstants.AppColors['btn_cancel'],
                                              onPressed: () {
                                                _cancelDispatch(requestId, _dispatches[0]['ID']);
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ),
                                          new SizedBox(
                                            width: 10.0,
                                          ),
                                          new Container(
                                            width: 100.0,
                                            child: RaisedButton(
                                              child: Text('取消', style: TextStyle(color: Colors.white),),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              color: AppConstants.AppColors['btn_main'],
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  )
                              );
                            } else {
                              showModalBottomSheet(
                                  context: context,
                                  builder: (context) => new ListView.builder(
                                    itemCount: _dispatches.length,
                                    shrinkWrap: true,
                                    itemBuilder: (context, i) {
                                      return new ListTile(
                                        leading: new Icon(Icons.assignment_late, color: Colors.blue,),
                                        title: new Text(_dispatches[i]['OID']),
                                        trailing: new Text(_dispatches[i]['Engineer']['Name']),
                                        onTap: () {
                                          Navigator.of(context).pop();
                                          showDialog(context: context,
                                              builder: (context) => CupertinoAlertDialog(
                                                title: new Text('是否取消派工？'),
                                                content: new Text('${_dispatches[i]['OID']} ${_dispatches[i]['Engineer']['Name']}'),
                                                actions: <Widget>[
                                                  new Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: <Widget>[
                                                      new Container(
                                                        width: 100.0,
                                                        child: RaisedButton(
                                                          //padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                                                          child: Text('确认', style: TextStyle(color: Colors.white),),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(6),
                                                          ),
                                                          color: AppConstants.AppColors['btn_cancel'],
                                                          onPressed: () {
                                                            _cancelDispatch(requestId, _dispatches[i]['ID']);
                                                            Navigator.of(context).pop();
                                                          },
                                                        ),
                                                      ),
                                                      new SizedBox(
                                                        width: 10.0,
                                                      ),
                                                      new Container(
                                                        width: 100.0,
                                                        child: RaisedButton(
                                                          child: Text('取消', style: TextStyle(color: Colors.white),),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(6),
                                                          ),
                                                          color: AppConstants.AppColors['btn_main'],
                                                          onPressed: () {
                                                            Navigator.of(context).pop();
                                                          },
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ],
                                              )
                                          );
                                        },
                                      );
                                    },
                                  )
                              );
                            }
                          }
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        color: AppConstants.AppColors['btn_cancel'],
                        child: new Row(
                          children: <Widget>[
                            new Icon(
                              Icons.cancel,
                              color: Colors.white,
                            ),
                            new Text(
                              task['HasOpenDispatch']?'取消派工':'终止请求',
                              style: new TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.0
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
              child: model.todos.length == 0?ListView(padding: const EdgeInsets.symmetric(vertical: 150.0), children: <Widget>[_loading?SpinKitThreeBounce(color: Colors.blue):new Center(child: new Text('没有更多未完成请求'),)],):ListView.builder(
                  padding: const EdgeInsets.all(2.0),
                  itemCount: model.todos.length>9?model.todos.length+1:model.todos.length,
                  controller: _scrollController,
                  itemBuilder: (context, i) {
                    if (i !=  model.todos.length) {
                      return buildCardItem(model.todos[i], model.todos[i]['ID'], model.todos[i]['OID'], model.todos[i]['RequestDate'], model.todos[i]['EquipmentOID'], model.todos[i]['EquipmentName'], model.todos[i]['DepartmentName'], model.todos[i]['RequestUser']['Name'], model.todos[i]['RequestType']['Name'], model.todos[i]['Status']['Name'], model.todos[i]['FaultDesc']);
                    } else {
                      return new Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          _noMore?new Center(child: new Text('没有更多未完成请求'),):new SpinKitChasingDots(color: Colors.blue,)
                        ],
                      );
                    }
                  }
              ),
              onRefresh: model.getTodos
          );
        }
    );
  }
}
