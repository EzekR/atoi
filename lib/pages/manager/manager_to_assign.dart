import 'package:flutter/material.dart';
import 'package:atoi/pages/manager/manager_assign_page.dart';
import 'dart:async';

class ManagerToAssign extends StatefulWidget {
  @override
  _ManagerToAssignState createState() => _ManagerToAssignState();

}

class _ManagerToAssignState extends State<ManagerToAssign> {

  List<Map<String, dynamic>> _tasks = [];

  void initState() {
    super.initState();
    getData();
  }

  Future getData() async {
    await Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _tasks = [
          {"time": "2019-03-21 14:33", "deviceModel": "医用磁共振设备	Philips 781-296", "deviceNo": "ZC00000001", "deviceLocation": "磁共振1室", "subject": "系统报错", "detail": "系统报错，设备无法启动"},
          {"time": "2019-04-22 9:21", "deviceModel": "医用CT	GE 8080-9527", "deviceNo": "ZC00000022", "deviceLocation": "放射科", "subject": "系统报错", "detail": "无法开机"},
          {"time": "2019-05-24 19:56", "deviceModel": "医用X光设备 SIEMENZ 781-296", "deviceNo": "ZC00000221", "deviceLocation": "介入科", "subject": "系统报错", "detail": "显示器蓝屏"},
          {"time": "2019-03-2 14:33", "deviceModel": "医用磁共振设备	Philips 781-296", "deviceNo": "ZC00000001", "deviceLocation": "磁共振1室", "subject": "系统报错", "detail": "系统报错，设备无法启动"},
          {"time": "2019-03-22 14:33", "deviceModel": "医用磁共振设备	Philips 781-296", "deviceNo": "ZC00000001", "deviceLocation": "磁共振1室", "subject": "系统报错", "detail": "系统报错，设备无法启动"},
        ];
      });
    });
  }

  Future<Null> _onRefresh() async {
    await Future.delayed(Duration(seconds: 3), () {
      print('refresh');
      setState(() {
        _tasks = [
          {"time": "2019-03-20 14:33", "deviceModel": "医用磁共振设备	Philips 781-296", "deviceNo": "ZC00000001", "deviceLocation": "磁共振1室", "subject": "系统报错", "detail": "系统报错，设备无法启动"},
          {"time": "2019-03-01 14:33", "deviceModel": "医用磁共振设备	Philips 781-296", "deviceNo": "ZC00000001", "deviceLocation": "磁共振1室", "subject": "系统报错", "detail": "系统报错，设备无法启动"},
          {"time": "2019-03-02 14:33", "deviceModel": "医用磁共振设备	Philips 781-296", "deviceNo": "ZC00000001", "deviceLocation": "磁共振1室", "subject": "系统报错", "detail": "系统报错，设备无法启动"},
          {"time": "2019-03-21 14:33", "deviceModel": "医用磁共振设备	Philips 781-296", "deviceNo": "ZC00000001", "deviceLocation": "磁共振1室", "subject": "系统报错", "detail": "系统报错，设备无法启动"},
          {"time": "2019-04-22 9:21", "deviceModel": "医用CT	GE 8080-9527", "deviceNo": "ZC00000022", "deviceLocation": "放射科", "subject": "系统报错", "detail": "无法开机"},
          {"time": "2019-05-24 19:56", "deviceModel": "医用X光设备 SIEMENZ 781-296", "deviceNo": "ZC00000221", "deviceLocation": "介入科", "subject": "系统报错", "detail": "显示器蓝屏"},
          {"time": "2019-03-2 14:33", "deviceModel": "医用磁共振设备	Philips 781-296", "deviceNo": "ZC00000001", "deviceLocation": "磁共振1室", "subject": "系统报错", "detail": "系统报错，设备无法启动"},
          {"time": "2019-03-22 14:33", "deviceModel": "医用磁共振设备	Philips 781-296", "deviceNo": "ZC00000001", "deviceLocation": "磁共振1室", "subject": "系统报错", "detail": "系统报错，设备无法启动"},
        ];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

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
              title: new Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "请求编号：",
                    style: new TextStyle(
                        fontSize: 18.0,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500
                    ),
                  ),
                  Text(
                    taskNo,
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
                          Navigator.of(context).pushNamed(ManagerAssignPage.tag);
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        color: new Color(0xff2E94B9),
                        child: new Row(
                          children: <Widget>[
                            new Icon(
                              Icons.event_note,
                              color: Colors.white,
                            ),
                            new Text(
                              '派工',
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
                          return null;
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        color: new Color(0xffD25565),
                        child: new Row(
                          children: <Widget>[
                            new Icon(
                              Icons.cancel,
                              color: Colors.white,
                            ),
                            new Text(
                              '取消',
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
        child: ListView.builder(
          padding: const EdgeInsets.all(2.0),
          itemCount: _tasks.length,
          itemBuilder: (context, i) => buildCardItem('C00000000$i', _tasks[i]['time'], _tasks[i]['deviceModel'], _tasks[i]['deviceNo'], _tasks[i]['deviceLocation'], _tasks[i]['subject'], _tasks[i]['detail']),
        ),
        onRefresh: _onRefresh
    );
  }
}
