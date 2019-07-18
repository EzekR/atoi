import 'package:flutter/material.dart';
import 'package:atoi/pages/engineer/engineer_start_page.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'package:atoi/utils/http_request.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EngineerToStart extends StatefulWidget{

  _EngineerToStartState createState() => _EngineerToStartState();
}

class _EngineerToStartState extends State<EngineerToStart> {


  List<Map<String, dynamic>> _tasks = [
    {"time": "2019-03-21 14:33", "deviceModel": "医用磁共振设备	Philips 781-296", "deviceNo": "ZC00000001", "deviceLocation": "磁共振1室", "subject": "系统报错", "detail": "系统报错，设备无法启动", "level": "紧急", "method": "上门维修"},
    {"time": "2019-04-22 9:21", "deviceModel": "医用CT	GE 8080-9527", "deviceNo": "ZC00000022", "deviceLocation": "放射科", "subject": "系统报错", "detail": "无法开机", "level": "紧急", "method": "上门维修"},
    {"time": "2019-05-24 19:56", "deviceModel": "医用X光设备 SIEMENZ 781-296", "deviceNo": "ZC00000221", "deviceLocation": "介入科", "subject": "系统报错", "detail": "显示器蓝屏", "level": "紧急", "method": "上门维修"},
    {"time": "2019-03-2 14:33", "deviceModel": "医用磁共振设备	Philips 781-296", "deviceNo": "ZC00000001", "deviceLocation": "磁共振1室", "subject": "系统报错", "detail": "系统报错，设备无法启动", "level": "紧急", "method": "上门维修"},
    {"time": "2019-03-22 14:33", "deviceModel": "医用磁共振设备	Philips 781-296", "deviceNo": "ZC00000001", "deviceLocation": "磁共振1室", "subject": "系统报错", "detail": "系统报错，设备无法启动", "level": "紧急", "method": "上门维修"},
  ];

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<Null> getTask() async {
    final SharedPreferences pref = await _prefs;
    var userId = await pref.getString('UserId');
    Map<String, dynamic> params = {
      'UserId': userId
    };
    var resp = await HttpRequest.request(
      '/Dispatch/GetDispatches',
      method: HttpRequest.GET,
      data: params
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

  Future getData() async {
  }

  Future<Null> _onRefresh() async {
    Dio dio = new Dio();
    var response = await dio.get<String>('http://api.stramogroup.com/e_get_request');
    Map _data = jsonDecode(response.data);
    Map _record = jsonDecode(_data['data']);
    if (response.statusCode == 200 && _data['error'] == 0) {
      Map<String, dynamic> _newRecord = {
        "time": _record['time'],
        "deviceModel": "医用磁共振设备	Philips 781-296",
        "deviceNo": "ZC00000001",
        "deviceLocation": "磁共振1室",
        "subject": _record['subject'],
        "detail": _record['detail'],
        "level": _record['level'],
        "method": _record['method']
      };
      setState(() {
        _tasks.insert(0, _newRecord);
      });
    } else {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: new Text('没有新派工'),
          )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    Card buildCardItem(String taskNo, String time, String deviceModel, String deviceLocation, String category, String detail, String level, String method) {
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
                "派工单号：$taskNo",
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
                        '设备位置：',
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
                    children: <Widget>[
                      new Text(
                        '故障分类：',
                        style: new TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600
                        ),
                      ),
                      new Text(
                        category,
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
                        '故障描述：',
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
                    children: <Widget>[
                      new Text(
                        '紧急程度：',
                        style: new TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600
                        ),
                      ),
                      new Text(
                        level,
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
                        '处理方式：',
                        style: new TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600
                        ),
                      ),
                      new Text(
                        method,
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
                          //Navigator.of(context).pushNamed(EngineerStartPage.tag);
                          //todo: navigate to start page
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        color: new Color(0xff2E94B9),
                        child: new Row(
                          children: <Widget>[
                            new Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                            ),
                            new Text(
                              '开始作业',
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
        child: new ListView.builder(
          padding: const EdgeInsets.all(2.0),
          itemCount: _tasks.length,
          itemBuilder: (context, i) => buildCardItem('PGD0000000$i', _tasks[i]['time'], _tasks[i]['deviceModel'], _tasks[i]['deviceLocation'], _tasks[i]['subject'], _tasks[i]['detail'], _tasks[i]['level'], _tasks[i]["method"]),
        ),
        onRefresh: getTask
    );
  }
}
