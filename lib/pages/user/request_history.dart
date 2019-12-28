import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:atoi/widgets/build_widget.dart';
import 'package:atoi/utils/http_request.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:atoi/utils/constants.dart';

class RequestHistory extends StatefulWidget {
  _RequestHistoryState createState() => _RequestHistoryState();
}

class _RequestHistoryState extends State<RequestHistory> {

  var history;
  Future<SharedPreferences> prefs = SharedPreferences.getInstance();

  void initState() {
    super.initState();
    getUserRequests();
  }

  Future<Null> getUserRequests() async {
    var _prefs = await prefs;
    var userId = _prefs.getInt('userID');
    var resp = await HttpRequest.request(
      '/Request/GetRequests',
      method: HttpRequest.GET,
      params: {
        'userID': userId,
        'typeID': 0
      }
    );
    if (resp['ResultCode'] == '00') {
      setState(() {
        history = resp['Data'];
      });
    }
  }

  List<Widget> buildCard() {
    List<Card> _list = [];
    for (var item in history) {
      _list.add(
        Card(
          child: new Column(
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
                      item['OID'],
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
                  "请求时间：${AppConstants.TimeForm(item['RequestDate'], 'yyyy-mm-dd hh:MM:ss')}",
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
                    item['Equipments'].length>0?BuildWidget.buildCardRow('设备编号', item['Equipments'][0]['OID']):new Container(),
                    item['Equipments'].length>0?BuildWidget.buildCardRow('设备名称', item['Equipments'][0]['Name']):new Container(),
                    item['Equipments'].length>0?BuildWidget.buildCardRow('使用科室', item['Equipments'][0]['Department']['Name']):new Container(),
                    BuildWidget.buildCardRow('请求人', item['RequestUser']['Name']),
                    BuildWidget.buildCardRow('类型', item['RequestType']['Name']),
                    BuildWidget.buildCardRow('状态', item['Status']['Name']),
                    BuildWidget.buildCardRow('请求详情', item['FaultDesc'].length>10?'${item['FaultDesc'].substring(0,10)}...':item['FaultDesc']),
                    //new Row(
                    //  mainAxisAlignment: MainAxisAlignment.end,
                    //  mainAxisSize: MainAxisSize.max,
                    //  children: <Widget>[
                    //    new RaisedButton(
                    //      onPressed: (){
                    //      },
                    //      shape: RoundedRectangleBorder(
                    //        borderRadius: BorderRadius.circular(6),
                    //      ),
                    //      color: new Color(0xff2E94B9),
                    //      child: new Row(
                    //        children: <Widget>[
                    //          new Icon(
                    //            Icons.library_books,
                    //            color: Colors.white,
                    //          ),
                    //          new Text(
                    //            '详情',
                    //            style: new TextStyle(
                    //                color: Colors.white
                    //            ),
                    //          )
                    //        ],
                    //      ),
                    //    ),
                    //  ],
                    //)
                  ],
                ),
              )
            ],
          ),
        )
      );
    }
    return _list;
  }

  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('报修历史'),
        elevation: 0.7,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                new Color(0xff2D577E),
                new Color(0xff4F8EAD)
              ],
            ),
          ),
        ),
      ),
      body: history==null?new Center(child: new SpinKitRotatingPlain(color: Colors.blue,),):new ListView(
        children: buildCard()
      )
    );
  }
}