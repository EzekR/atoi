import 'package:flutter/material.dart';
import 'package:atoi/pages/manager/manager_audit_voucher_page.dart';
import 'package:atoi/pages/manager/manager_audit_report_page.dart';
import 'package:atoi/utils/http_request.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:atoi/models/models.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:atoi/widgets/build_widget.dart';
import 'package:atoi/utils/constants.dart';

class ManagerToAuditPage extends StatefulWidget {
  static String tag = 'manager-to-audit-page';
  _ManagerToAuditPageState createState() => _ManagerToAuditPageState();
}

class _ManagerToAuditPageState extends State<ManagerToAuditPage> {

  List<dynamic> _reports = [];
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  bool _loading = false;
  bool _noMore = false;

  ScrollController _scrollController = new ScrollController();

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
    //getData();
    refresh();
    super.initState();
    ManagerModel model = MainModel.of(context);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        var _length = model.dispatches.length;
        model.getMoreDispatches().then((result) {
          if (model.dispatches.length == _length) {
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

  Future<Null> refresh() async {
    ManagerModel _model = MainModel.of(context);
    _model.getDispatches();
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    Card buildCardItem(Map dispatch, int dispatchId, int reportId,  String dispatchOID, String date, String deviceNo, String deviceName, String dispatchType, String urgency, String requestOID, Map journalStatus, Map reportStatus) {
      var _dataVal = DateTime.parse(date);
      var _format = '${_dataVal.year}-${_dataVal.month}-${_dataVal.day}';
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
              title: new Row(
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
                    dispatchOID,
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
                "派工时间：$_format",
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
                  deviceName==''?new Container():BuildWidget.buildCardRow('设备编号', deviceName),
                  deviceNo==''?new Container():BuildWidget.buildCardRow('设备名称', deviceNo),
                  BuildWidget.buildCardRow('派工类型', dispatchType),
                  BuildWidget.buildCardRow('紧急程度', urgency),
                  BuildWidget.buildCardRow('请求编号', requestOID),
                  BuildWidget.buildCardRow('请求状态', dispatch['Status']['Name']),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      new RaisedButton(
                        onPressed: (){
                          journalStatus['ID']==0||journalStatus['ID']==1?null:
                          Navigator.of(context).push(
                              new MaterialPageRoute(builder: (_) {
                                return new ManagerAuditVoucherPage(
                                  journalId: dispatchId, request: dispatch, status: dispatch['DispatchJournal']['Status']['ID'],);
                              })).then((result) => refresh());
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
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
                          reportStatus['ID']==0||reportStatus['ID']==1?null:Navigator.of(context).push(new MaterialPageRoute(builder: (_){
                            return new ManagerAuditReportPage(reportId: reportId, request: dispatch, status: dispatch['DispatchReport']['Status']['ID'],);
                          })).then((result) => refresh());
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
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
        return new RefreshIndicator(
            child: model.dispatches.length == 0?ListView(padding: const EdgeInsets.symmetric(vertical: 150.0), children: <Widget>[_loading?SpinKitRotatingPlain(color: Colors.blue):new Center(child: new Text('没有待审核工单'),)],):ListView.builder(
              padding: const EdgeInsets.all(2.0),
              itemCount: model.dispatches.length>9?model.dispatches.length+1:model.dispatches.length,
              controller: _scrollController,
              itemBuilder: (context, i) {
                if (i != model.dispatches.length) {
                  return buildCardItem(model.dispatches[i], model.dispatches[i]['DispatchJournal']['ID'], model.dispatches[i]['DispatchReport']['ID'], model.dispatches[i]['OID'], model.dispatches[i]['ScheduleDate'], model.dispatches[i]['Request']['Equipments'].length>0?model.dispatches[i]['Request']['Equipments'][0]['Name']:'', model.dispatches[i]['Request']['Equipments'].length>0?model.dispatches[i]['Request']['Equipments'][0]['OID']:'', model.dispatches[i]['RequestType']['Name'], model.dispatches[i]['Urgency']['Name'], model.dispatches[i]['Request']['OID'], model.dispatches[i]['DispatchJournal']['Status'], model.dispatches[i]['DispatchReport']['Status']);
                } else {
                  return new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _noMore?new Center(child: new Text('没有更多派工单需要审核'),):new SpinKitChasingDots(color: Colors.blue,)
                    ],
                  );
                }
              }
            ),
            onRefresh: model.getDispatches
        );
      },
    );
  }
}
