import 'package:flutter/material.dart';
import 'package:atoi/pages/manager/manager_audit_voucher_page.dart';
import 'package:atoi/pages/manager/manager_audit_report_page.dart';
import 'package:atoi/utils/http_request.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:atoi/models/models.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ManagerToAuditPage extends StatefulWidget {
  static String tag = 'manager-to-audit-page';
  _ManagerToAuditPageState createState() => _ManagerToAuditPageState();
}

class _ManagerToAuditPageState extends State<ManagerToAuditPage> {

  List<dynamic> _reports = [];
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  bool _loading = false;

  Future<Null> getData() async {
    var prefs = await _prefs;
    var userID = prefs.getInt('userID');
    Map<String, dynamic> params = {
      'userID': userID,
      'statusIDs': 3,
    };
    setState(() {
      _loading = true;
    });
    var _data = await HttpRequest.request(
        '/Dispatch/GetDispatchs',
        method: HttpRequest.GET,
        params: params
    );
    setState(() {
      _reports = _data['Data'];
      _loading = false;
    });
  }

  void initState() {
    getData();
    super.initState();
  }

  Color iconColor(int statusId) {
    if (statusId == 0) {
      return Colors.grey;
    } else {
      if (statusId == 2) {
        return new Color(0xff2E94B9);
      } else {
        if (statusId == 3) {
          return new Color(0xffF0B775);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    Card buildCardItem(Map dispatch, int dispatchId, int reportId,  String dispatchOID, String date, String deviceNo, String deviceName, String dispatchType, String urgency, String requestOID, Map journalStatus, Map reportStatus) {
      var _dataVal = DateTime.parse(date);
      var _format = '${_dataVal.year}-${_dataVal.month}-${_dataVal.day} ${_dataVal.hour}:${_dataVal.minute}:${_dataVal.second}';
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
                "派工单号：$dispatchOID",
                style: new TextStyle(
                    fontSize: 16.0,
                    color: Theme.of(context).primaryColor
                ),
              ),
              subtitle: Text(
                "结束时间：$_format",
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
                        '派工类型：',
                        style: new TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600
                        ),
                      ),
                      new Text(
                        dispatchType,
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
                    children: <Widget>[
                      new Text(
                        '请求单号：',
                        style: new TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600
                        ),
                      ),
                      new Text(
                        requestOID,
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
                          if (journalStatus['ID'] == 2) {
                            Navigator.of(context).push(
                                new MaterialPageRoute(builder: (_) {
                                  return new ManagerAuditVoucherPage(
                                      journalId: dispatchId, request: dispatch);
                                }));
                          } else {
                            null;
                          }
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        color: iconColor(journalStatus['ID']),
                        child: new Row(
                          children: <Widget>[
                            new Icon(
                              journalStatus['ID'] == 3?Icons.check:Icons.fingerprint,
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
                          //Navigator.of(context).pushNamed(ManagerAuditReportPage.tag);
                          reportId == 0?null:Navigator.of(context).push(new MaterialPageRoute(builder: (_){
                            return new ManagerAuditReportPage(reportId: reportId, request: dispatch);
                          }));
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        color: iconColor(reportStatus['ID']),
                        child: new Row(
                          children: <Widget>[
                            new Icon(
                              reportStatus['ID'] == 3?Icons.check:Icons.work,
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
        if(_reports.length > 0) {
          model.setBadge(_reports.length.toString(), 'B');
        }
        return new RefreshIndicator(
            child: _reports.length == 0?ListView(padding: const EdgeInsets.symmetric(vertical: 150.0), children: <Widget>[_loading?SpinKitRotatingPlain(color: Colors.blue):new Center(child: new Text('没有待审核工单'),)],):ListView.builder(
              padding: const EdgeInsets.all(2.0),
              itemCount: _reports.length,
              itemBuilder: (context, i) => buildCardItem(_reports[i], _reports[i]['DispatchJournal']['ID'], _reports[i]['DispatchReport']['ID'], _reports[i]['OID'], _reports[i]['ScheduleDate'], _reports[i]['Request']['Equipments'][0]['Name'], _reports[i]['Request']['Equipments'][0]['OID'], _reports[i]['RequestType']['Name'], _reports[i]['Urgency']['Name'], _reports[i]['Request']['OID'], _reports[i]['DispatchJournal']['Status'], _reports[i]['DispatchReport']['Status']),
            ),
            onRefresh: getData
        );
      },
    );
  }
}
