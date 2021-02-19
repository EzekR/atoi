import 'package:flutter/material.dart';
import 'package:atoi/pages/engineer/engineer_voucher_page.dart';
import 'package:atoi/pages/engineer/engineer_report_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:atoi/utils/http_request.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:atoi/models/models.dart';
import 'package:atoi/widgets/build_widget.dart';
import 'package:atoi/utils/constants.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:atoi/pages/equipments/equipments_list.dart';
import 'package:atoi/permissions.dart';

/// 工程师待上传报告列表页面类
class EngineerToReport extends StatefulWidget{
  _EngineerToReportState createState() => _EngineerToReportState();
}

class _EngineerToReportState extends State<EngineerToReport> {

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  List<dynamic> _tasks = [];
  bool _noMore = false;
  Map techPermission;
  Map specialPermission;

  void getPermission() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    Permission permissionInstance = new Permission();
    permissionInstance.prefs = _prefs;
    permissionInstance.initPermissions();
    techPermission = permissionInstance.getTechPermissions('Operations', 'Dispatch');
    specialPermission = permissionInstance.getSpecialPermissions('Operations', 'Dispatch');
  }

  Future<Null> getTask() async {
    final SharedPreferences pref = await _prefs;
    var userId = await pref.getInt('userID');
    Map<String, dynamic> params = {
      'userID': userId,
      'statusIDs': 2,
      'statusIDs': 3,
    };
    var resp = await HttpRequest.request(
        '/Dispatch/GetDispatchs?userID=${userId}&statusIDs=2&statusIDs=3',
        method: HttpRequest.GET,
    );
    print(resp);
    setState(() {
      _tasks = resp['Data'];
    });
  }

  ScrollController _scrollController = ScrollController();

  void initState() {
    //getTask();
    getPermission();
    super.initState();
    EngineerModel model = MainModel.of(context);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        var _length = model.tasksToReport.length;
        model.getMoreTasksToReport().then((result) {
          if (model.tasksToReport.length == _length) {
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
    refresh();
  }

  Icon buttonIconJournal(status) {
    switch (status) {
      case 0:
        return new Icon(Icons.fingerprint, color: Colors.white,);
        break;
      case 2:
        return new Icon(Icons.poll, color: Colors.white,);
        break;
      case 3:
        return new Icon(Icons.check, color: Colors.white,);
        break;
      default:
        return new Icon(Icons.fingerprint, color: Colors.white,);
        break;
    }
  }

  Icon buttonIconReport(status) {
    switch (status) {
      case 0:
        return new Icon(Icons.work, color: Colors.white,);
        break;
      case 2:
        return new Icon(Icons.poll, color: Colors.white,);
        break;
      case 3:
        return new Icon(Icons.check, color: Colors.white,);
        break;
      default:
        return new Icon(Icons.work, color: Colors.white,);
        break;
    }
  }

  Color buttonColor(status) {
    switch (status) {
      case 0:
        return AppConstants.AppColors['btn_main'];
        break;
      case 2:
        return AppConstants.AppColors['btn_success'];
        break;
      case 3:
        return AppConstants.AppColors['btn_success'];
        break;
      default:
        return AppConstants.AppColors['btn_main'];
        break;
    }
  }

  Future<Null> refresh() async {
    EngineerModel _model = MainModel.of(context);
    _model.getTasksToReport();
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    Card buildCardItem(Map task, int dispatchId, int journalId, int reportId, String OID, String scheduleDate, String createDate, int responseTime, String deviceName, String deviceNo, String location, String requestType, String urgency, String remark) {
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
              title: Text(
                "派工单编号：$OID",
                style: new TextStyle(
                    fontSize: 16.0,
                    color: Theme.of(context).primaryColor
                ),
              ),
              subtitle: Text(
                "开始时间：${AppConstants.TimeForm(scheduleDate, 'hh:mm')}",
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
                  deviceName==''?new Container():BuildWidget.buildCardRow('设备名称', task['Request']['Equipments'].length>1?'多设备':deviceName, onTap: task['Request']['Equipments'].length>1?null:() => Navigator.of(context).push(new MaterialPageRoute(builder: (_) => new EquipmentsList(equipmentId: task['Request']['Equipments'][0]['OID'], assetType: task['Request']['AssetType']['ID'],)))),
                  deviceNo==''?new Container():BuildWidget.buildCardRow('序列号', task['Request']['Equipments'].length>1?'多设备':deviceNo),
                  location==''?new Container():BuildWidget.buildCardRow('使用科室', location),
                  BuildWidget.buildCardRow('请求类型', requestType),
                  BuildWidget.buildCardRow('紧急程度', urgency),
                  BuildWidget.buildCardRow('审批状态', task['Status']['Name']),
                  techPermission==null||!techPermission['View']?Container():new Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      new RaisedButton(
                        onPressed: (){
                          Navigator.of(context).push(
                              new MaterialPageRoute(builder: (_) {
                                return new EngineerVoucherPage(
                                  dispatchId: dispatchId, journalId: task['DispatchJournal']['ID'], status: task['DispatchJournal']['Status']['ID'],);
                              })).then((result) => refresh());
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        color: buttonColor(journalId),
                        child: new Row(
                          children: <Widget>[
                            buttonIconJournal(task['DispatchJournal']['Status']['ID']),
                            new Text(
                              '凭证',
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
                      new RaisedButton(
                        onPressed: (){
                          Navigator.of(context).push(
                              new MaterialPageRoute(builder: (_) {
                                return new EngineerReportPage(
                                    dispatchId: dispatchId, reportId: task['DispatchReport']['ID'], status: task['DispatchReport']['Status']['ID'],);
                              })).then((result) =>
                              refresh()
                              //null
                          );
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        color: buttonColor(reportId),
                        child: new Row(
                          children: <Widget>[
                            buttonIconReport(task['DispatchReport']['Status']['ID']),
                            new Text(
                              '报告',
                              style: new TextStyle(
                                  color: Colors.white
                              ),
                            )
                          ],
                        ),
                      )
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
            child: model.tasksToReport.length == 0?ListView(padding: const EdgeInsets.symmetric(vertical: 150.0), children: <Widget>[new Center(child: new Text('没有作业中工单'),)],):ListView.builder(
                padding: const EdgeInsets.all(2.0),
                itemCount: model.tasksToReport.length>9?model.tasksToReport.length+1:model.tasksToReport.length,
                controller: _scrollController,
                itemBuilder: (context, i) {
                  if (i != model.tasksToReport.length) {
                    return buildCardItem(model.tasksToReport[i], model.tasksToReport[i]['ID'], model.tasksToReport[i]['DispatchJournal']['Status']['ID'], model.tasksToReport[i]['DispatchReport']['Status']['ID'], model.tasksToReport[i]['OID'], model.tasksToReport[i]['StartDate'].toString(), model.tasksToReport[i]['CreateDate'].toString(), model.tasksToReport[i]['Request']['Equipments'].length>0?model.tasksToReport[i]['Request']['Equipments'][0]['ResponseTimeLength']:0, model.tasksToReport[i]['Request']['Equipments'].length>0?model.tasksToReport[i]['Request']['Equipments'][0]['Name']:'', model.tasksToReport[i]['Request']['Equipments'].length>0?model.tasksToReport[i]['Request']['Equipments'][0]['SerialCode']:'', model.tasksToReport[i]['Request']['DepartmentName'], model.tasksToReport[i]['RequestType']['Name'], model.tasksToReport[i]['Urgency']['Name'], model.tasksToReport[i]['LeaderComments']);
                  } else {
                    return new Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        _noMore?new Center(child: new Text('没有更多作业中工单'),):new SpinKitChasingDots(color: Colors.blue,)
                      ],
                    );
                  }
                }
            ),
            onRefresh: model.getTasksToReport
        );
      },
    );
  }
}
