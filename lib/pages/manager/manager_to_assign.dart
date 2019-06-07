import 'package:flutter/material.dart';

class ManagerToAssign extends StatelessWidget {
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
                          Icons.assignment_ind,
                          color: Colors.deepOrangeAccent,
                          size: 16.0,
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
                    child: new Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        new RaisedButton(
                          onPressed: () {},
                          textColor: Colors.white,
                          color: Theme.of(context).accentColor,
                          shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                          child: Text(
                            '安排派工'
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
      itemBuilder: (context, i) => buildCardItem('Philips 781-296 放射科', 'LSRM002020900002 上呼吸道内窥镜EW34-49','无法开机，屏幕闪烁，有异响', '待派工', 'C000000001', '2019-03-22 14：33'),
    );
  }
}
