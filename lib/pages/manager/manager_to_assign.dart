import 'package:flutter/material.dart';
import 'package:atoi/pages/manager/manager_assign_page.dart';

class ManagerToAssign extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    Card buildCardItem(String title, String subtitle, String describe, String status, String requestNo, String requestTime) {
      return new Card(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ListTile(
              leading: Icon(
                  Icons.build,
                  color: Color(0xff14BD98)
              ),
              title: Text(
                  "请求编号：$title",
                  style: new TextStyle(
                    fontSize: 16.0,
                    color: Theme.of(context).primaryColor
                  ),
              ),
              subtitle: Text(
                "请求时间：$subtitle",
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
                        '医用磁共振设备	Philips 781-296',
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
                        'ZC00000001',
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
                        '磁共振1室',
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
                        '系统报错',
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
                        '系统报错，设备无法启动',
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
                        color: Colors.lightBlue,
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
                          return null;
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        color: Colors.redAccent,
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
      itemCount: 20,
      itemBuilder: (context, i) => buildCardItem('C000000001', '2019-03-22 14:33','无法开机，屏幕闪烁，有异响', '待派工', 'C000000001', '2019-03-22 14:33'),
    );
  }
}
