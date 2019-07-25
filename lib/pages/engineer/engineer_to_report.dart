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
      'statusID': 2
    };
    var resp = await HttpRequest.request(
        '/Dispatch/GetDispatchs',
        method: HttpRequest.GET,
        params: params
    );
    print(resp);
    setState(() {
      _tasks = resp['Data'];
    });
  }

  void initState() {
    getTask();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    Card buildCardItem(int dispatchId, int journalId, int reportId, String OID, String scheduleDate, String deviceName, String deviceNo, String location, String requestType, String urgency, String remark) {
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
                "出发时间：$scheduleDate",
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
                        '设备编号：',
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
                        '安装位置：',
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
                          if (journalId == 0) {
                            Navigator.of(context).push(
                                new MaterialPageRoute(builder: (_) {
                                  return new EngineerVoucherPage(
                                      dispatchId: dispatchId);
                                }));
                          } else {
                            return null;
                          }
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        color: journalId == 0?new Color(0xff2E94B9):new Color(0xffF0B775),
                        child: new Row(
                          children: <Widget>[
                            new Icon(
                              journalId==0?Icons.fingerprint:Icons.check,
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
                          if (reportId == 0) {
                            Navigator.of(context).push(
                                new MaterialPageRoute(builder: (_) {
                                  return new EngineerReportPage(
                                      dispatchId: dispatchId);
                                }));
                          } else {
                            return null;
                          }
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        color: reportId == 0?new Color(0xff2E94B9):new Color(0xffF0B775),
                        child: new Row(
                          children: <Widget>[
                            new Icon(
                              reportId==0?Icons.work:Icons.check,
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
        if (_tasks.length > 0){
          model.setBadge(_tasks.length.toString(), 'EB');
        }
        return new RefreshIndicator(
            child: _tasks.length == 0?ListView(padding: const EdgeInsets.symmetric(vertical: 150.0), children: <Widget>[new Center(child: new Text('没有待报告工单'),)],):ListView.builder(
                padding: const EdgeInsets.all(2.0),
                itemCount: _tasks.length,
                itemBuilder: (context, i) => buildCardItem(_tasks[i]['ID'], _tasks[i]['DispatchJournalID'], _tasks[i]['DispatchReport']['ID'], _tasks[i]['OID'], _tasks[i]['ScheduleDate'], _tasks[i]['Request']['Equipments'][0]['Name'], _tasks[i]['Request']['Equipments'][0]['SerialCode'], _tasks[i]['Request']['DepartmentName'], _tasks[i]['RequestType']['Name'], _tasks[i]['Urgency']['Name'], _tasks[i]['LeaderComments'])
            ),
            onRefresh: getTask
        );
      },
    );
  }
}
