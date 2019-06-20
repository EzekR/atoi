import 'package:flutter/material.dart';
import 'package:atoi/pages/engineer/engineer_start_page.dart';

class EngineerToStart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    List<Map<String, dynamic>> _tasks = [
      {"time": "2019-03-21 14:33", "deviceModel": "医用磁共振设备	Philips 781-296", "deviceLocation": "磁共振1室", "category": "系统原因", "detail": "系统报错，设备无法启动", "level": "紧急", "method": "上门服务"},
      {"time": "2019-03-21 14:33", "deviceModel": "医用磁共振设备	Philips 781-296", "deviceLocation": "磁共振1室", "category": "系统原因", "detail": "系统报错，设备无法启动", "level": "紧急", "method": "上门服务"},
      {"time": "2019-03-21 14:33", "deviceModel": "医用磁共振设备	Philips 781-296", "deviceLocation": "磁共振1室", "category": "系统原因", "detail": "系统报错，设备无法启动", "level": "紧急", "method": "上门服务"},
      {"time": "2019-03-21 14:33", "deviceModel": "医用磁共振设备	Philips 781-296", "deviceLocation": "磁共振1室", "category": "系统原因", "detail": "系统报错，设备无法启动", "level": "紧急", "method": "上门服务"},
      {"time": "2019-03-21 14:33", "deviceModel": "医用磁共振设备	Philips 781-296", "deviceLocation": "磁共振1室", "category": "系统原因", "detail": "系统报错，设备无法启动", "level": "紧急", "method": "上门服务"},
    ];

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
                          Navigator.of(context).pushNamed(EngineerStartPage.tag);
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
                              '详情',
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
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('开始作业！'),
                            )
                          );
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        color: new Color(0xfffd5f00),
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

    return new ListView.builder(
      padding: const EdgeInsets.all(2.0),
      itemCount: 5,
      itemBuilder: (context, i) => buildCardItem('PGD0000000$i', _tasks[i]['time'], _tasks[i]['deviceModel'], _tasks[i]['deviceLocation'], _tasks[i]['category'], _tasks[i]['detail'], _tasks[i]['level'], _tasks[i]["method"]),
    );
  }
}
