import 'package:flutter/material.dart';
import 'package:atoi/pages/manager/manager_audit_voucher_page.dart';
import 'package:atoi/pages/manager/manager_audit_report_page.dart';
import 'package:atoi/utils/http_request.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ManagerToAuditPage extends StatefulWidget {
  static String tag = 'manager-to-audit-page';
  _ManagerToAuditPageState createState() => _ManagerToAuditPageState();
}

class _ManagerToAuditPageState extends State<ManagerToAuditPage> {

  List<dynamic> _reports = [];
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<Null> getData() async {
    var prefs = await _prefs;
    var userID = prefs.getInt('userID');
    Map<String, dynamic> params = {
      'userID': userID,
      'statusID': 1,
      'typeID': 1
    };
    var _data = await HttpRequest.request(
        '/Request/GetRequests',
        method: HttpRequest.GET,
        params: params
    );
    setState(() {
      _reports = _data['Data'];
    });
  }

  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

//    List<Map<String, String>> _reports = [
//      {"time": "2019-03-21 14:33", "deviceModel": "医用磁共振设备	Philips 781-296", "deviceNo": "ZC00000001", "engineer": "张学友", "client": "李老师", "content": "监督外部供应商更换球馆"},
//      {"time": "2019-04-22 14:33", "deviceModel": "医用CT	GE 8080-9527", "deviceNo": "ZC00000022", "engineer": "刘德华", "client": "王老师", "content": "更换显示器线"},
//      {"time": "2019-05-24 14:33", "deviceModel": "医用X光设备 SIEMENZ 781-296", "deviceNo": "ZC00000221", "engineer": "郭富城", "client": "罗老师", "content": "重启系统"},
//      {"time": "2019-03-2 14:33", "deviceModel": "医用磁共振设备	Philips 781-296", "deviceNo": "ZC00000001", "engineer": "金城武", "client": "赵老师", "content": "系统报错，设备无法启动"},
//      {"time": "2019-03-22 14:33", "deviceModel": "医用磁共振设备	Philips 781-296", "deviceNo": "ZC00000001", "engineer": "磁共振1室", "client": "系统报错", "content": "系统报错，设备无法启动"},
//    ];


    Card buildCardItem(Map request, String title, String subtitle, String deviceModel, String deviceNo, String engineer, String client, String content) {
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
                "派工单号：$title",
                style: new TextStyle(
                    fontSize: 16.0,
                    color: Theme.of(context).primaryColor
                ),
              ),
              subtitle: Text(
                "出发时间：$subtitle",
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
                        '设备型号：',
                        style: new TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600
                        ),
                      ),
                      new Text(
                        deviceModel,
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
                        '工程师姓名：',
                        style: new TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600
                        ),
                      ),
                      new Text(
                        engineer,
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
                        '客户姓名：',
                        style: new TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600
                        ),
                      ),
                      new Text(
                        client,
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
                        '工作内容：',
                        style: new TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600
                        ),
                      ),
                      new Text(
                        content,
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
                          //Navigator.of(context).pushNamed(ManagerAuditVoucherPage.tag);
                          Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
                            return new ManagerAuditVoucherPage(request: request);
                          }));
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        color: new Color(0xff2E94B9),
                        child: new Row(
                          children: <Widget>[
                            new Icon(
                              Icons.fingerprint,
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
                          Navigator.of(context).push(new MaterialPageRoute(builder: (_){
                            return new ManagerAuditReportPage(request: request);
                          }));
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        color: new Color(0xff2E94B9),
                        child: new Row(
                          children: <Widget>[
                            new Icon(
                              Icons.work,
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

    return new RefreshIndicator(
        child: _reports.length == 0?ListView(padding: const EdgeInsets.symmetric(vertical: 150.0), children: <Widget>[new Center(child: new Text('没有待审核工单'),)],):ListView.builder(
          padding: const EdgeInsets.all(2.0),
          itemCount: _reports.length,
          itemBuilder: (context, i) => buildCardItem(_reports[i], 'PGD0000000$i', _reports[i]['Date'], _reports[i]['EquipmentName'], _reports[i]['EquipmentNo'], 'John Wick', 'Winston', _reports[i]['Detail']),
        ),
        onRefresh: getData
    );
  }
}
