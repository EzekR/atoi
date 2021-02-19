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
import 'package:atoi/pages/equipments/equipments_list.dart';
import 'package:atoi/permissions.dart';

/// 超管待审核列表页面类
class ManagerToAuditPage extends StatefulWidget {
  static String tag = 'manager-to-audit-page';
  _ManagerToAuditPageState createState() => _ManagerToAuditPageState();
}

class _ManagerToAuditPageState extends State<ManagerToAuditPage> {

  List<dynamic> _reports = [];
  Future<SharedPreferences> prefs = SharedPreferences.getInstance();
  bool _loading = false;
  bool _noMore = false;
  Map techPermission;
  Map specialPermission;
  Map reportPermission;
  Map journalPermission;

  ScrollController _scrollController = new ScrollController();

  Future<Null> getData() async {
    var _prefs = await prefs;
    var userID = _prefs.getInt('userID');
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

  void getPermission() async {
    SharedPreferences _prefs = await prefs;
    Permission permissionInstance = new Permission();
    permissionInstance.prefs = _prefs;
    permissionInstance.initPermissions();
    techPermission = permissionInstance.getTechPermissions('Operations', 'Request');
    specialPermission = permissionInstance.getSpecialPermissions('Operations', 'Request');
    reportPermission = permissionInstance.getTechPermissions('Operations', 'DispatchReport');
    journalPermission = permissionInstance.getTechPermissions('Operations', 'DispatchJournal');
  }

  void initState() {
    //getData();
    getPermission();
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

    Card buildCardItem(Map dispatch) {
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
                  dispatch['Request']['Equipments'].length>0?BuildWidget.buildCardRow('设备名称', dispatch['Request']['EquipmentName'], onTap: dispatch['Request']['EquipmentName']=='多设备'?null:() => Navigator.of(context).push(new MaterialPageRoute(builder: (_) => new EquipmentsList(equipmentId: dispatch['Request']['EquipmentOID'], assetType: dispatch['Request']['AssetType']['ID'],)))):new Container(),
                  BuildWidget.buildCardRow('派工类型', dispatch['RequestType']['Name']),
                  BuildWidget.buildCardRow('紧急程度', dispatch['Urgency']['Name']),
                  BuildWidget.buildCardRow('请求编号', dispatch['Request']['OID']),
                  BuildWidget.buildCardRow('请求状态', dispatch['Status']['Name']),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      journalPermission!=null&&journalPermission['View']?new RaisedButton(
                        onPressed: (){
                          dispatch['DispatchJournal']['Status']['ID']==0||dispatch['DispatchJournal']['Status']['ID']==1?null:
                          Navigator.of(context).push(
                              new MaterialPageRoute(builder: (_) {
                                return new ManagerAuditVoucherPage(
                                  journalId: dispatch['DispatchJournal']['ID'], request: dispatch, status: dispatch['DispatchJournal']['Status']['ID'],);
                              })).then((result) => refresh());
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        color: iconColor(dispatch['DispatchJournal']['Status']['ID']),
                        child: new Row(
                          children: <Widget>[
                            new Icon(
                              dispatch['DispatchJournal']['Status']['ID'] == 3?Icons.check:Icons.fingerprint,
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
                      ):Container(),
                      new Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5.0),
                      ),
                      reportPermission!=null&&reportPermission['View']?new RaisedButton(
                        onPressed: (){
                          dispatch['DispatchReport']['Status']['ID']==0||dispatch['DispatchReport']['Status']['ID']==1?null:Navigator.of(context).push(new MaterialPageRoute(builder: (_){
                            return new ManagerAuditReportPage(reportId: dispatch['DispatchReport']['ID'], request: dispatch, status: dispatch['DispatchReport']['Status']['ID'],);
                          })).then((result) => refresh());
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        color: iconColor(dispatch['DispatchReport']['Status']['ID']),
                        child: new Row(
                          children: <Widget>[
                            new Icon(
                              dispatch['DispatchReport']['Status']['ID'] == 3?Icons.check:Icons.work,
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
                      ):Container()
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
            child: model.dispatches.length == 0?ListView(padding: const EdgeInsets.symmetric(vertical: 150.0), children: <Widget>[_loading?SpinKitThreeBounce(color: Colors.blue):new Center(child: new Text('没有待审核工单'),)],):ListView.builder(
              padding: const EdgeInsets.all(2.0),
              itemCount: model.dispatches.length>9?model.dispatches.length+1:model.dispatches.length,
              controller: _scrollController,
              itemBuilder: (context, i) {
                if (i != model.dispatches.length) {
                  return buildCardItem(model.dispatches[i]);
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
