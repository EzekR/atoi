import 'package:flutter/material.dart';
import 'package:atoi/utils/http_request.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:atoi/pages/engineer/engineer_start_page.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:atoi/models/models.dart';

class EngineerToStart extends StatefulWidget{

  _EngineerToStartState createState() => _EngineerToStartState();
}

class _EngineerToStartState extends State<EngineerToStart> {


  List<dynamic> _tasks = [];

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<Null> getTask() async {
    final SharedPreferences pref = await _prefs;
    var userId = await pref.getInt('userID');
    Map<String, dynamic> params = {
      'userID': userId,
      'statusIDs': 1
    };
    var resp = await HttpRequest.request(
      '/Dispatch/GetDispatchs',
      method: HttpRequest.GET,
      params: params
    );
    print(resp);
    setState(() {
      _tasks = resp['Data'];
    });
  }

  void initState() {
    //getTask();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    Card buildCardItem(int dispatchId, String OID, String scheduleDate, String deviceName, String deviceNo, String location, String requestType, String urgency, String remark) {
      var _datetime = DateTime.parse(scheduleDate);
      var departDate = '${_datetime.year}-${_datetime.month}-${_datetime.day}';
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
                "派工单号：$OID",
                style: new TextStyle(
                    fontSize: 16.0,
                    color: Theme.of(context).primaryColor
                ),
              ),
              subtitle: Text(
                "出发时间：$departDate",
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
                  deviceName == null?new Container():new Row(
                    children: <Widget>[
                      new Text(
                        '设备名称：',
                        style: new TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600
                        ),
                      ),
                      new Text(
                        deviceName,
                        style: new TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey
                        ),
                      )
                    ],
                  ),
                  deviceNo == null?new Container():new Row(
                    children: <Widget>[
                      new Text(
                        '设备型号：',
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
                        '使用科室：',
                        style: new TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600
                        ),
                      ),
                      new Text(
                        location,
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
                        '派工类型：',
                        style: new TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600
                        ),
                      ),
                      new Text(
                        requestType,
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
                        '紧急程度：',
                        style: new TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600
                        ),
                      ),
                      new Text(
                        urgency,
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
                        '主管备注：',
                        style: new TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600
                        ),
                      ),
                      new Text(
                        remark,
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
                          //Navigator.of(context).pushNamed(EngineerStartPage.tag);
                          //todo: navigate to start page
                          Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
                            return new EngineerStartPage(dispatchId: dispatchId);
                          }));
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        color: new Color(0xff2E94B9),
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

    return ScopedModelDescendant<MainModel>(
      builder: (context, child, model) {
        return new RefreshIndicator(
            child: model.tasksToStart.length == 0?ListView(padding: const EdgeInsets.symmetric(vertical: 150.0), children: <Widget>[new Center(child: new Text('没有待开始工单'),)],):ListView.builder(
                padding: const EdgeInsets.all(2.0),
                itemCount: model.tasksToStart.length,
                itemBuilder: (context, i) => buildCardItem(model.tasksToStart[i]['ID'], model.tasksToStart[i]['OID'], model.tasksToStart[i]['ScheduleDate'], model.tasksToStart[i]['Request']['Equipments'].length>0?model.tasksToStart[i]['Request']['Equipments'][0]['Name']:null, model.tasksToStart[i]['Request']['Equipments'].length>0?model.tasksToStart[i]['Request']['Equipments'][0]['EquipmentCode']:null, model.tasksToStart[i]['Request']['DepartmentName'], model.tasksToStart[i]['RequestType']['Name'], model.tasksToStart[i]['Urgency']['Name'], model.tasksToStart[i]['LeaderComments'])
            ),
            onRefresh: model.getTasksToStart
        );
      },
    );
  }
}
