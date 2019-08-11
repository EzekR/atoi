import 'package:flutter/material.dart';
import 'package:atoi/pages/manager/manager_assign_page.dart';
import 'dart:async';
import 'package:atoi/utils/http_request.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:atoi/models/models.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ManagerToAssign extends StatefulWidget {
  @override
  _ManagerToAssignState createState() => _ManagerToAssignState();

}

class _ManagerToAssignState extends State<ManagerToAssign> {

  List<dynamic> _tasks = [];
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  bool _loading = false;

  void initState() {
    //getData();
    super.initState();
  }

  Future<Null> getData() async {
    var prefs = await _prefs;
    var userID = await prefs.getInt('userID');
    Map<String, dynamic> params = {
      'userID': userID,
      'statusID': 1,
      'typeID': 0
    };
    setState(() {
      _loading = true;
    });
    var _data = await HttpRequest.request(
      '/Request/GetRequests',
      method: HttpRequest.GET,
      params: params
    );
    print(_data['Data']);
    prefs.setString('badgeA', _data['Data'].length.toString());
    setState(() {
      _tasks = _data['Data'];
      _loading = false;
    });
  }

  Future _cancelRequest(int requestId) async {
    var prefs = await _prefs;
    var userId = prefs.getInt('userID');
    Map<String, dynamic> _data = {
      'userID': userId,
      'requestID': requestId
    };
    var resp = await HttpRequest.request(
      '/Request/EndRequest',
      method: HttpRequest.POST,
      data: _data
    );
    print(resp);
    if (resp['ResultCode'] == '00') {
      showDialog(context: context,
        builder: (context) => AlertDialog(
          title: new Text('取消成功'),
        )
      );
      getData();
    }
  }

  Row buildRow(String leading, String content) {
    return new Row(
      children: <Widget>[
        new Expanded(
          flex: 3,
          child: new Text(
            leading,
            style: new TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w600
            ),
          ),
        ),
        new Expanded(
          flex: 7,
          child: new Text(
            content,
            style: new TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w400,
                color: Colors.grey
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    Card buildCardItem(Map task, int requestId, String taskNo, String time, String equipmentNo, String equipmentName, String departmentName, String requestPerson, String requestType, String status, String detail, List _equipments) {
      var _dataVal = DateTime.parse(time);
      var _format = '${_dataVal.year}-${_dataVal.month}-${_dataVal.day} ${_dataVal.hour}:${_dataVal.minute}:${_dataVal.second}';
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
                "请求时间：$_format",
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
                  buildRow('系统编号：', equipmentNo),
                  buildRow('设备名称：', equipmentName),
                  buildRow('使用科室：', departmentName),
                  buildRow('请求人：', requestPerson),
                  buildRow('类型：', requestType),
                  buildRow('状态：', status),
                  buildRow('请求详情：', detail),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      new RaisedButton(
                        onPressed: (){
                          //Navigator.of(context).pushNamed(ManagerAssignPage.tag);
                          Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
                            return new ManagerAssignPage(request: task);
                          }));
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
                          _cancelRequest(requestId);
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

    return ScopedModelDescendant<MainModel>(
      builder: (context, child, model) {
        return new RefreshIndicator(
            child: model.requests.length == 0?ListView(padding: const EdgeInsets.symmetric(vertical: 150.0), children: <Widget>[new Center(child: _loading?SpinKitRotatingPlain(color: Colors.blue):new Text('没有待派工请求'),)],):ListView.builder(
                padding: const EdgeInsets.all(2.0),
                itemCount: model.requests.length,
                itemBuilder: (context, i) => buildCardItem(model.requests[i], model.requests[i]['ID'], model.requests[i]['OID'], model.requests[i]['RequestDate'], model.requests[i]['EquipmentOID'], model.requests[i]['EquipmentName'], model.requests[i]['DepartmentName'], model.requests[i]['RequestUser']['Name'], model.requests[i]['RequestType']['Name'], model.requests[i]['Status']['Name'], model.requests[i]['FaultDesc'], model.requests[i]['Equipments'])
            ),
            onRefresh: model.getRequests
        );
      }
    );
  }
}
