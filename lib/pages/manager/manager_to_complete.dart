
import 'package:flutter/material.dart';
import 'package:atoi/pages/manager/manager_assign_page.dart';

class ManagerToComplete extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    List<Map<String, dynamic>> _tasks = [
      {"time": "2019-03-21 14:33", "deviceModel": "医用磁共振设备	Philips 781-296", "deviceNo": "ZC00000001", "deviceLocation": "磁共振1室", "subject": "系统报错", "detail": "系统报错，设备无法启动"},
      {"time": "2019-04-22 9:21", "deviceModel": "医用CT	GE 8080-9527", "deviceNo": "ZC00000022", "deviceLocation": "放射科", "subject": "系统报错", "detail": "无法开机"},
      {"time": "2019-05-24 19:56", "deviceModel": "医用X光设备 SIEMENZ 781-296", "deviceNo": "ZC00000221", "deviceLocation": "介入科", "subject": "系统报错", "detail": "显示器蓝屏"},
      {"time": "2019-03-2 14:33", "deviceModel": "医用磁共振设备	Philips 781-296", "deviceNo": "ZC00000001", "deviceLocation": "磁共振1室", "subject": "系统报错", "detail": "系统报错，设备无法启动"},
      {"time": "2019-03-22 14:33", "deviceModel": "医用磁共振设备	Philips 781-296", "deviceNo": "ZC00000001", "deviceLocation": "磁共振1室", "subject": "系统报错", "detail": "系统报错，设备无法启动"},
    ];

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
                          Navigator.of(context).pushNamed(ManagerAssignPage.tag);
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
                              '更新请求',
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
            //new Padding(
            //  padding: EdgeInsets.symmetric(vertical: 5.0),
            //  child: new Row(
            //    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //    children: <Widget>[
            //      Expanded(
            //        flex: 4,
            //        child: new Column(
            //          mainAxisAlignment: MainAxisAlignment.center,
            //          mainAxisSize: MainAxisSize.max,
            //          children: <Widget>[
            //            new Text(
            //              '故障描述',
            //              style: new TextStyle(
            //                color: Colors.black,
            //                fontSize: 16.0,
            //                fontWeight: FontWeight.w600
            //              ),
            //            ),
            //            new Padding(
            //              padding: EdgeInsets.symmetric(horizontal: 0.0),
            //              child: new Text(
            //                  describe,
            //                  style: new TextStyle(
            //                    color: Colors.grey,
            //                    fontSize: 12.0,
            //                    fontWeight: FontWeight.w400,
            //                  )
            //              )
            //            )
            //          ],
            //        ),
            //      ),
            //      Expanded(
            //        flex: 3,
            //        child: new Column(
            //          mainAxisAlignment: MainAxisAlignment.center,
            //          mainAxisSize: MainAxisSize.max,
            //          children: <Widget>[
            //            new Icon(
            //              Icons.assignment_ind,
            //              color: Colors.deepOrangeAccent,
            //              size: 20.0,
            //            ),
            //            Text(
            //              status,
            //              style: new TextStyle(
            //                fontSize: 14.0,
            //                color: Colors.black,
            //                fontWeight: FontWeight.w400
            //              ),
            //            )
            //          ],
            //        ),
            //      ),
            //      Expanded(
            //        flex: 4,
            //        child: new Column(
            //          mainAxisAlignment: MainAxisAlignment.center,
            //          mainAxisSize: MainAxisSize.max,
            //          children: <Widget>[
            //            new RaisedButton(
            //              onPressed: () {
            //                Navigator.of(context).pushNamed(ManagerAssignPage.tag);
            //              },
            //              textColor: Colors.white,
            //              color: Theme.of(context).accentColor,
            //              shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
            //              child: Text(
            //                '安排派工'
            //              ),
            //            )
            //          ],
            //        ),
            //      )
            //    ],
            //  ),
            //),
            //new Padding(
            //  padding: EdgeInsets.symmetric(vertical: 5.0),
            //  child: new Row(
            //    mainAxisAlignment: MainAxisAlignment.center,
            //    mainAxisSize: MainAxisSize.max,
            //    children: <Widget>[
            //      Expanded(
            //        flex: 5,
            //        child: new Row(
            //          mainAxisSize: MainAxisSize.min,
            //          mainAxisAlignment: MainAxisAlignment.start,
            //          children: <Widget>[
            //            new Padding(
            //              padding: EdgeInsets.symmetric(horizontal: 2.0),
            //            ),
            //            new Text(
            //              '请求编号: ',
            //              style: new TextStyle(
            //                color: Colors.black,
            //                fontSize: 14.0
            //              )
            //            ),
            //            new Text(
            //              requestNo,
            //              style: new TextStyle(
            //                color: Colors.blue,
            //                fontSize: 14.0
            //              ),
            //            )
            //          ],
            //        ),
            //      ),
            //      Expanded(
            //        flex: 5,
            //        child: new Row(
            //          mainAxisAlignment: MainAxisAlignment.start,
            //          mainAxisSize: MainAxisSize.min,
            //          children: <Widget>[
            //            new Text(
            //              '请求时间: ',
            //              style: new TextStyle(
            //                color: Colors.black,
            //                fontSize: 14.0
            //              ),
            //            ),
            //            new Text(
            //              requestTime,
            //              style: new TextStyle(
            //                color: Colors.blue,
            //                fontSize: 14.0
            //              ),
            //            )
            //          ],
            //        ),
            //      )
            //    ],
            //  ),
            //)
          ],
        ),
      );
    }

    return new ListView.builder(
      padding: const EdgeInsets.all(2.0),
      itemCount: 5,
      itemBuilder: (context, i) => buildCardItem('C00000000$i', _tasks[i]['time'], _tasks[i]['deviceModel'], _tasks[i]['deviceNo'], _tasks[i]['deviceLocation'], _tasks[i]['subject'], _tasks[i]['detail']),
    );
  }
}
