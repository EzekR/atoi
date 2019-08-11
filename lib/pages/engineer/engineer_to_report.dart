import 'package:flutter/material.dart';
import 'package:atoi/pages/engineer/engineer_voucher_page.dart';
import 'package:atoi/pages/engineer/engineer_report_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:atoi/utils/http_request.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:atoi/models/models.dart';

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

  void initState() {
    //getTask();
    super.initState();
  }

  Color buttonColor(status) {
    switch (status) {
      case 0:
        return new Color(0xff2E94B9);
        break;
      case 2:
        return new Color(0xff14BD98);
        break;
      case 3:
        return new Color(0xffF0B775);
        break;
      default:
        return new Color(0xff2E94B9);
        break;
    }
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
                "派工单号：$OID",
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
                  new Row(
                    children: <Widget>[
                      new Text(
                        '设备名称：',
                        style: new TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600
                        ),
                      ),
                      new Text(
                        deviceName,
                        style: new TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey
                        ),
                      )
                    ],
                  ),
                  new Row(
                    children: <Widget>[
                      new Text(
                        '设备序列号：',
                        style: new TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600
                        ),
                      ),
                      new Text(
                        deviceNo,
                        style: new TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey
                        ),
                      )
                    ],
                  ),
                  new Row(
                    children: <Widget>[
                      new Text(
                        '使用科室：',
                        style: new TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600
                        ),
                      ),
                      new Text(
                        location,
                        style: new TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey
                        ),
                      )
                    ],
                  ),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      new Text(
                        '请求类型：',
                        style: new TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600
                        ),
                      ),
                      new Text(
                        requestType,
                        style: new TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey
                        ),
                      ),
                    ],
                  ),
                  new Row(
                    children: <Widget>[
                      new Text(
                        '紧急程度：',
                        style: new TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600
                        ),
                      ),
                      new Text(
                        urgency,
                        style: new TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey
                        ),
                      ),
                    ],
                  ),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      new RaisedButton(
                        onPressed: (){
                          if (journalId == 0 || journalId ==1 || journalId == 2) {
                            Navigator.of(context).push(
                                new MaterialPageRoute(builder: (_) {
                                  return new EngineerVoucherPage(
                                      dispatchId: dispatchId, journalId: task['DispatchJournal']['ID'],);
                                }));
                          } else {
                            return null;
                          }
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        color: buttonColor(journalId),
                        child: new Row(
                          children: <Widget>[
                            new Icon(
                              journalId==0||journalId==1||journalId==2?Icons.fingerprint:Icons.check,
                              color: Colors.white,
                            ),
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
                          if (reportId == 0 || reportId == 1 || reportId == 2) {
                            Navigator.of(context).push(
                                new MaterialPageRoute(builder: (_) {
                                  return new EngineerReportPage(
                                      dispatchId: dispatchId, reportId: task['DispatchReport']['ID']);
                                }));
                          } else {
                            return null;
                          }
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        color: buttonColor(reportId),
                        child: new Row(
                          children: <Widget>[
                            new Icon(
                              reportId==0||reportId==1||reportId==2?Icons.work:Icons.check,
                              color: Colors.white,
                            ),
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
            child: model.tasksToReport.length == 0?ListView(padding: const EdgeInsets.symmetric(vertical: 150.0), children: <Widget>[new Center(child: new Text('没有待报告工单'),)],):ListView.builder(
                padding: const EdgeInsets.all(2.0),
                itemCount: model.tasksToReport.length,
                itemBuilder: (context, i) => buildCardItem(model.tasksToReport[i], model.tasksToReport[i]['ID'], model.tasksToReport[i]['DispatchJournal']['Status']['ID'], model.tasksToReport[i]['DispatchReport']['Status']['ID'], model.tasksToReport[i]['OID'], model.tasksToReport[i]['StartDate'], model.tasksToReport[i]['CreateDate'], model.tasksToReport[i]['Request']['Equipments'][0]['ResponseTimeLength'], model.tasksToReport[i]['Request']['Equipments'][0]['Name'], model.tasksToReport[i]['Request']['Equipments'][0]['SerialCode'], model.tasksToReport[i]['Request']['DepartmentName'], model.tasksToReport[i]['RequestType']['Name'], model.tasksToReport[i]['Urgency']['Name'], model.tasksToReport[i]['LeaderComments'])
            ),
            onRefresh: model.getTasksToReport
        );
      },
    );
  }
}
