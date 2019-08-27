import 'package:flutter/material.dart';
import 'package:atoi/pages/engineer/engineer_voucher_page.dart';
import 'package:atoi/pages/engineer/engineer_report_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:atoi/utils/http_request.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:atoi/models/models.dart';
import 'package:atoi/widgets/build_widget.dart';
import 'package:atoi/utils/constants.dart';

class EngineerToReport extends StatefulWidget{
  _EngineerToReportState createState() => _EngineerToReportState();
}

class _EngineerToReportState extends State<EngineerToReport> {

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  List<dynamic> _tasks = [];

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
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        print('滑动到了最底部');
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
      var _dateParse = DateTime.parse(scheduleDate);
      var _startTime = '${_dateParse.year}-${_dateParse.month}-${_dateParse.day} ${_dateParse.hour}:${_dateParse.minute}';
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
                "开始时间：$_startTime",
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
                  deviceName==''?new Container():BuildWidget.buildCardRow('设备名称', task['Request']['Equipments'].length>1?'多设备':deviceName),
                  deviceNo==''?new Container():BuildWidget.buildCardRow('序列号', task['Request']['Equipments'].length>1?'多设备':deviceNo),
                  location==''?new Container():BuildWidget.buildCardRow('使用科室', location),
                  BuildWidget.buildCardRow('请求类型', requestType),
                  BuildWidget.buildCardRow('紧急程度', urgency),
                  BuildWidget.buildCardRow('审批状态', task['Status']['Name']),
                  new Row(
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
                          borderRadius: BorderRadius.circular(24),
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
                              })).then((result) => refresh());
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
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
                itemCount: model.tasksToReport.length,
                controller: _scrollController,
                itemBuilder: (context, i) => buildCardItem(model.tasksToReport[i], model.tasksToReport[i]['ID'], model.tasksToReport[i]['DispatchJournal']['Status']['ID'], model.tasksToReport[i]['DispatchReport']['Status']['ID'], model.tasksToReport[i]['OID'], model.tasksToReport[i]['StartDate'], model.tasksToReport[i]['CreateDate'], model.tasksToReport[i]['Request']['Equipments'].length>0?model.tasksToReport[i]['Request']['Equipments'][0]['ResponseTimeLength']:0, model.tasksToReport[i]['Request']['Equipments'].length>0?model.tasksToReport[i]['Request']['Equipments'][0]['Name']:'', model.tasksToReport[i]['Request']['Equipments'].length>0?model.tasksToReport[i]['Request']['Equipments'][0]['SerialCode']:'', model.tasksToReport[i]['Request']['DepartmentName'], model.tasksToReport[i]['RequestType']['Name'], model.tasksToReport[i]['Urgency']['Name'], model.tasksToReport[i]['LeaderComments'])
            ),
            onRefresh: model.getTasksToReport
        );
      },
    );
  }
}
