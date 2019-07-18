import 'package:flutter/material.dart';
import 'package:atoi/pages/manager/manager_complete_page.dart';
import 'package:atoi/utils/http_request.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ManagerToComplete extends StatefulWidget {
  _ManagerToCompleteState createState() => _ManagerToCompleteState();
}

class _ManagerToCompleteState extends State<ManagerToComplete> {
  List<dynamic> _tasks = [];

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
        '/app/Request/GetRequests',
        method: HttpRequest.GET,
        params: params
    );
    setState(() {
      _tasks = _data['Data'];
    });
  }

  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

//    List<Map<String, dynamic>> _tasks = [
//      {"time": "2019-03-21 14:33", "deviceModel": "医用磁共振设备	Philips 781-296", "deviceNo": "ZC00000001", "deviceLocation": "磁共振1室", "subject": "系统报错", "detail": "系统报错，设备无法启动"},
//      {"time": "2019-04-22 9:21", "deviceModel": "医用CT	GE 8080-9527", "deviceNo": "ZC00000022", "deviceLocation": "放射科", "subject": "系统报错", "detail": "无法开机"},
//      {"time": "2019-05-24 19:56", "deviceModel": "医用X光设备 SIEMENZ 781-296", "deviceNo": "ZC00000221", "deviceLocation": "介入科", "subject": "系统报错", "detail": "显示器蓝屏"},
//      {"time": "2019-03-2 14:33", "deviceModel": "医用磁共振设备	Philips 781-296", "deviceNo": "ZC00000001", "deviceLocation": "磁共振1室", "subject": "系统报错", "detail": "系统报错，设备无法启动"},
//      {"time": "2019-03-22 14:33", "deviceModel": "医用磁共振设备	Philips 781-296", "deviceNo": "ZC00000001", "deviceLocation": "磁共振1室", "subject": "系统报错", "detail": "系统报错，设备无法启动"},
//    ];

    Card buildCardItem(String taskNo, String time, String deviceModel, String deviceNo, String deviceLocation, String subject, String detail) {
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
              title: Text(
                "请求编号：$taskNo",
                style: new TextStyle(
                    fontSize: 16.0,
                    color: Theme.of(context).primaryColor
                ),
              ),
              subtitle: Text(
                "请求时间：$time",
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
                        '安装位置：',
                        style: new TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600
                        ),
                      ),
                      new Text(
                        deviceLocation,
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
                        '请求主题：',
                        style: new TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600
                        ),
                      ),
                      new Text(
                        subject,
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
                        '故障详情：',
                        style: new TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600
                        ),
                      ),
                      new Text(
                        detail,
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
                          Navigator.of(context).pushNamed(ManagerCompletePage.tag);
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        color: new Color(0xff005792),
                        child: new Row(
                          children: <Widget>[
                            new Icon(
                              Icons.event_note,
                              color: Colors.white,
                            ),
                            new Text(
                              '查看详情',
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

    return new RefreshIndicator(
        child: _tasks.length == 0?ListView(padding: const EdgeInsets.symmetric(vertical: 150.0), children: <Widget>[new Center(child: new Text('没有待完成工单'),)],):ListView.builder(
          padding: const EdgeInsets.all(2.0),
          itemCount: _tasks.length,
          itemBuilder: (context, i) => buildCardItem('C00000000$i', _tasks[i]['Date'], _tasks[i]['EquipmentName'], _tasks[i]['EquipmentNo'], _tasks[i]['Department'], '待完成', _tasks[i]['Detail']),
        ),
        onRefresh: getData
    );
  }
}
