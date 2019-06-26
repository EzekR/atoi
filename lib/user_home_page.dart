import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class UserHomePage extends StatefulWidget{
  static String tag = 'user-home-page';
  @override
  _UserHomePageState createState() => new _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {

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

  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        leading: new Container(),
        title: new Align(
          alignment: Alignment(-3.0, 0),
          child: new Text('ATOI医疗设备管理系统'),
        ),
        elevation: 0.7,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).accentColor
              ],
            ),
          ),
        ),
        actions: <Widget>[
          new Align(
            alignment: Alignment(10.0, 0),
            child: new IconButton(
              icon: Icon(Icons.face),
              onPressed: () {
                _scaffoldKey.currentState.openEndDrawer();
              },
            ),
          ),
          new Padding(
            padding: const EdgeInsets.symmetric(vertical: 19.0),
            child: const Text(
                '真田幸村',
            ),
          ),
        ],
      ),
      body: new Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          CarouselSlider(
            viewportFraction: 1.0,
            items: <Widget>[
              new Container(
                width: MediaQuery.of(context).size.width,
                child: Image.asset('assets/mri.jpg'),
              )
            ],
          ),
          new Padding(
              padding: EdgeInsets.symmetric(vertical: 50.0),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  new Expanded(
                    flex: 4,
                    child: buildIconColumn(Icons.build, '维修'),
                  ),
                  new Expanded(
                    flex: 3,
                    child: buildIconColumn(Icons.remove_red_eye, '其他服务'),
                  ),
                  new Expanded(
                    flex: 4,
                    child: buildIconColumn(Icons.history, '服务记录'),
                  )
                ],
              ),
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              new Expanded(
                flex: 5,
                child: buildIconColumn(Icons.assignment_ind, '未响应服务'),
              )
            ],
          )
        ],
      ),
      endDrawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: CircleAvatar(
                backgroundColor: Colors.transparent,
                radius: 48.0,
                child: Image.asset('assets/alucard.jpg'),
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).accentColor,
              ),
            ),
            ListTile(
              title: Text('姓名'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('手机号'),
              onTap: () {
                _scaffoldKey.currentState.showBottomSheet((BuildContext context) {
                  return new Container(
                    decoration: BoxDecoration(
                        border: Border(top: BorderSide(color: Colors.grey))
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Text('This is a Material persistent bottom sheet. Drag downwards to dismiss it.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.indigo,
                          fontSize: 24.0,
                        ),
                      ),
                    ),
                  );
                });
              },
            ),
            ListTile(
              title: Text('修改信息'),
              onTap: () {

              },
            )
          ],
        ),
      ),
    );
  }
}