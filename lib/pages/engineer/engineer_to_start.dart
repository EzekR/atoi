import 'package:flutter/material.dart';
import 'package:atoi/utils/http_request.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:atoi/pages/engineer/engineer_start_page.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:atoi/models/models.dart';
import 'package:atoi/widgets/build_widget.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:atoi/pages/equipments/equipments_list.dart';

/// 工程师待开始工单页面类
class EngineerToStart extends StatefulWidget {
  _EngineerToStartState createState() => _EngineerToStartState();
}

class _EngineerToStartState extends State<EngineerToStart> {
  List<dynamic> _tasks = [];
  int offset = 5;
  bool _loading = false;
  bool _noMore = false;

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<Null> getTask() async {
    final SharedPreferences pref = await _prefs;
    var userId = await pref.getInt('userID');
    Map<String, dynamic> params = {'userID': userId, 'statusIDs': 1};
    var resp = await HttpRequest.request('/Dispatch/GetDispatchs',
        method: HttpRequest.GET, params: params);
    print(resp);
    setState(() {
      _tasks = resp['Data'];
    });
  }

  ScrollController _scrollController = ScrollController();

  void initState() {
    super.initState();
    EngineerModel model = MainModel.of(context);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        var _length = model.tasksToStart.length;
        model.getMoreTasksToStart().then((result) {
          if (model.tasksToStart.length == _length) {
            setState(() {
              _noMore = true;
            });
          } else {
            setState(() {
              _noMore = false;
            });
          }
        });
      }
    });
    refresh();
  }

  Future<Null> refresh() async {
    EngineerModel _model = MainModel.of(context);
    _model.getTasksToStart();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    Card buildCardItem(
        int dispatchId,
        String OID,
        String scheduleDate,
        List deviceName,
        String deviceNo,
        String location,
        String requestType,
        String urgency,
        String remark) {
      var _time = DateTime.tryParse(scheduleDate).toString().split(':');
      _time.removeLast();
      var departDate = _time.join(':');
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
                "派工单编号：$OID",
                style: new TextStyle(
                    fontSize: 16.0, color: Theme.of(context).primaryColor),
              ),
              subtitle: Text(
                "出发时间：$departDate",
                style: new TextStyle(color: Theme.of(context).accentColor),
              ),
            ),
            new Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  deviceName == null
                      ? new Container()
                      : BuildWidget.buildCardRow(
                          '设备名称',
                          deviceName.length > 1
                              ? '多设备'
                              : deviceName[0]['Name'], onTap: deviceName.length>1?null:() => Navigator.of(context).push(new MaterialPageRoute(builder: (_) => new EquipmentsList(equipmentId: deviceName[0]['OID'],)))),
                  location == ''
                      ? new Container()
                      : BuildWidget.buildCardRow('使用科室', location),
                  BuildWidget.buildCardRow('派工类型', requestType),
                  BuildWidget.buildCardRow('紧急程度', urgency),
                  BuildWidget.buildCardRow(
                      '主管备注',
                      remark.length > 10
                          ? '${remark.substring(0, 10)}...'
                          : remark),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      new RaisedButton(
                        onPressed: () {
                          //Navigator.of(context).pushNamed(EngineerStartPage.tag);
                          //todo: navigate to start page
                          Navigator.of(context)
                              .push(new MaterialPageRoute(builder: (_) {
                            return new EngineerStartPage(
                                dispatchId: dispatchId);
                          })).then((result) =>
                              refresh()
                              //null
                          );
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
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
                              style: new TextStyle(color: Colors.white),
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
            child: model.tasksToStart.length == 0
                ? ListView(
                    padding: const EdgeInsets.symmetric(vertical: 150.0),
                    children: <Widget>[
                      new Center(
                        child: new Text('没有待开始工单'),
                      )
                    ],
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(2.0),
                    itemCount: model.tasksToStart.length > 9
                        ? model.tasksToStart.length + 1
                        : model.tasksToStart.length,
                    controller: _scrollController,
                    itemBuilder: (context, i) {
                      if (i != model.tasksToStart.length) {
                        return buildCardItem(
                            model.tasksToStart[i]['ID'],
                            model.tasksToStart[i]['OID'],
                            model.tasksToStart[i]['ScheduleDate'],
                            model.tasksToStart[i]['Request']['Equipments']
                                        .length >
                                    0
                                ? model.tasksToStart[i]['Request']['Equipments']
                                : null,
                            model.tasksToStart[i]['Request']['Equipments']
                                        .length >
                                    0
                                ? model.tasksToStart[i]['Request']['Equipments']
                                    [0]['EquipmentCode']
                                : null,
                            model.tasksToStart[i]['Request']['DepartmentName'],
                            model.tasksToStart[i]['RequestType']['Name'],
                            model.tasksToStart[i]['Urgency']['Name'],
                            model.tasksToStart[i]['LeaderComments']);
                      } else {
                        return new Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            _noMore
                                ? new Center(
                                    child: new Text('没有更多待开始工单'),
                                  )
                                : new SpinKitChasingDots(
                                    color: Colors.blue,
                                  )
                          ],
                        );
                      }
                    }),
            onRefresh: model.getTasksToStart);
      },
    );
  }
}
