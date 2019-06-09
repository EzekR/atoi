import 'package:flutter/material.dart';

class ManagerMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    Column buildIconColumn(IconData icon, String label) {
      Color color = Theme.of(context).primaryColor;

      return new Column(
        mainAxisSize: MainAxisSize.values[1],
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          new IconButton(
            icon: new Icon(icon),
            onPressed: () {},
            color: color,
            iconSize: 50.0,
          ),
          new Container(
            margin: const EdgeInsets.only(top: 8.0),
            child: new Text(
              label,
              style: new TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w400,
                color: new Color(0xff000000),
              ),
            ),
          ),
        ],
      );
    }

    return new Container(
      //child: new Padding(
      //  padding: const EdgeInsets.symmetric(vertical: 40.0),
      //  child: new Column(
      //    children: <Widget>[
      //      new Row(
      //        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //        children: <Widget>[
      //          buildIconColumn(Icons.build, '维修'),
      //          buildIconColumn(Icons.assignment_turned_in, '保养'),
      //          buildIconColumn(Icons.people, '巡检'),
      //        ],
      //      ),
      //    ],
      //  ),
      //),
      child: new Column(
        children: <Widget>[
          new Padding(
            padding: const EdgeInsets.symmetric(vertical: 40.0),
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Expanded(
                  flex: 4,
                  child: buildIconColumn(Icons.build, '维修'),
                ),
                Expanded(
                  flex: 3,
                  child: buildIconColumn(Icons.assignment_turned_in, '保养'),
                ),
                Expanded(
                  flex: 4,
                  child: buildIconColumn(Icons.people, '巡检'),
                )
              ],
            ),
          ),
          new Padding(
            padding: const EdgeInsets.symmetric(vertical: 40.0),
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Expanded(
                  flex: 4,
                  child: buildIconColumn(Icons.bookmark, '其他服务'),
                ),
                Expanded(
                  flex: 3,
                  child: buildIconColumn(Icons.store, '强检'),
                ),
                Expanded(
                  flex: 4,
                  child: buildIconColumn(Icons.remove_red_eye, '校正'),
                )
              ],
            ),
          ),
          new Padding(
            padding: const EdgeInsets.symmetric(vertical: 40.0),
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Expanded(
                  flex: 4,
                  child: buildIconColumn(Icons.queue, '新增'),
                ),
                Expanded(
                  flex: 3,
                  child: buildIconColumn(Icons.insert_chart, '生命周期管理'),
                ),
                Expanded(
                  flex: 4,
                  child: buildIconColumn(Icons.event_busy, '不良事件'),
                )
              ],
            )
          )
        ],
      ),
    );
  }
}