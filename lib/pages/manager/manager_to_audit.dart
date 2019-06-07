import 'package:flutter/material.dart';

class ManagerToAudit extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    Card buildCardItem(String title, String subtitle, String describe, String status, String requestNo, String requestTime) {
      return new Card(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            ListTile(
              leading:Icon(
                  Icons.build,
                  color: Color(0xff14BD98)
              ),
              title: Text(
                  title,
                  style: new TextStyle(
                    fontSize: 16.0
                  ),
              ),
              subtitle: Text(subtitle),
            ),
            new Padding(
              padding: EdgeInsets.symmetric(vertical: 5.0),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    flex: 4,
                    child: new Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        new Text(
                          '故障描述',
                          style: new TextStyle(
                            color: Colors.black,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600
                          ),
                        ),
                        new Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: new Text(
                              describe,
                              style: new TextStyle(
                                color: Colors.grey,
                                fontSize: 12.0,
                                fontWeight: FontWeight.w400,
                              )
                          )
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: new Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        new Icon(
                          Icons.thumb_up,
                          color: Colors.deepOrangeAccent,
                          size: 20.0,
                        ),
                        Text(
                          status,
                          style: new TextStyle(
                            fontSize: 14.0,
                            color: Colors.black,
                            fontWeight: FontWeight.w400
                          ),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        IconButton(
                            icon: Icon(Icons.fingerprint),
                            onPressed: () {},
                            color: Theme.of(context).accentColor,
                            tooltip: '审核凭证'
                        ),
                        IconButton(
                            icon: Icon(Icons.work),
                            onPressed: () {},
                            color: Theme.of(context).accentColor,
                            tooltip: '审核报告'
                        ),
                       ],
                    ),
                  )
                ],
              ),
            ),
            new Padding(
              padding: EdgeInsets.symmetric(vertical: 5.0),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    flex: 5,
                    child: new Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        new Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5.0)
                        ),
                        new Text(
                          '请求编号: ',
                          style: new TextStyle(
                            color: Colors.black,
                            fontSize: 14.0
                          )
                        ),
                        new Text(
                          requestNo,
                          style: new TextStyle(
                            color: Colors.blue,
                            fontSize: 14.0
                          ),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        new Text(
                          '请求时间: ',
                          style: new TextStyle(
                            color: Colors.black,
                            fontSize: 14.0
                          ),
                        ),
                        new Text(
                          requestTime,
                          style: new TextStyle(
                            color: Colors.blue,
                            fontSize: 14.0
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      );
    }

    return new ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: 20,
      itemBuilder: (context, i) => buildCardItem('Philips 781-296 放射科', 'LSRM002020900002 上呼吸道内窥镜EW34-49','无法开机，屏幕闪烁，有异响', '已解决', 'C000000001', '2019-03-22 14:33'),
    );
  }
}
