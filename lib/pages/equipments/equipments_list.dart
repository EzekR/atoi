import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:atoi/utils/http_request.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:atoi/pages/equipments/print_qrcode.dart';
import 'package:atoi/widgets/build_widget.dart';
import 'package:atoi/pages/equipments/equipment_detail.dart';
import 'package:timeline_list/timeline.dart';
import 'package:timeline_list/timeline_model.dart';

class EquipmentsList extends StatefulWidget{
  _EquipmentsListState createState() => _EquipmentsListState();
}

class _EquipmentsListState extends State<EquipmentsList> {

  List<dynamic> _equipments = [];

  List<Step> timeline = [];

  bool isSearchState = false;
  bool _loading = false;

  TextEditingController _keywords = new TextEditingController();

  Future<Null> getEquipments({String filterText}) async {
    filterText = filterText??'';
    setState(() {
      _loading = true;
    });
    var resp = await HttpRequest.request(
      '/Equipment/Getdevices',
      method: HttpRequest.GET,
      params: {
        'filterText': filterText
      }
    );
    setState(() {
      _loading = false;
    });
    if (resp['ResultCode'] == '00') {
      setState(() {
        _equipments = resp['Data'];
      });
    }
  }

  void initState() {
    super.initState();
    getEquipments();
  }

  Future<List<TimelineModel>> getTimeline(int deviceId) async {
    var resp = await HttpRequest.request(
      '/Equipment/GetTimeLine4App',
      method: HttpRequest.POST,
      data: {
        'id': deviceId
      }
    );
    if (resp['ResultCode'] == '00') {
      print(resp['Data']['Dispatches']);
      if (resp['Data']['Dispatches'] != null) {
        var _dispatches = resp['Data']['Dispatches'];
        List<TimelineModel> _timeline = [];
        for(var _item in _dispatches) {
          switch (_item['RequestType']['ID']) {
            case 1:
              _timeline.add(
                TimelineModel(
                  ListTile(
                    title: new Text(_item['TimelineDesc']),
                    subtitle: new Text(_item['EndDate'].split('T')[0]),
                  ),
                  icon: Icon(Icons.build, color: Colors.white,),
                  iconBackground: Colors.redAccent,
                  position: TimelineItemPosition.right
                )
              );
              break;
            case 3:
              _timeline.add(
                  TimelineModel(
                      ListTile(
                        title: new Text(_item['TimelineDesc']),
                        subtitle: new Text(_item['EndDate'].split('T')[0]),
                      ),
                      icon: Icon(Icons.store, color: Colors.white,),
                      iconBackground: Colors.redAccent,
                      position: TimelineItemPosition.right
                  )
              );
              break;
            case 4:
              _timeline.add(
                  TimelineModel(
                      ListTile(
                        title: new Text(_item['TimelineDesc']),
                        subtitle: new Text(_item['EndDate'].split('T')[0]),
                      ),
                      icon: Icon(Icons.people, color: Colors.white,),
                      iconBackground: Colors.green,
                      position: TimelineItemPosition.right
                  )
              );
              break;
            case 5:
              _timeline.add(
                  TimelineModel(
                      ListTile(
                        title: new Text(_item['TimelineDesc']),
                        subtitle: new Text(_item['EndDate'].split('T')[0]),
                      ),
                      icon: Icon(Icons.remove_red_eye, color: Colors.white,),
                      iconBackground: Colors.green,
                      position: TimelineItemPosition.right
                  )
              );
              break;
            case 2:
              _timeline.add(
                  TimelineModel(
                      ListTile(
                        title: new Text(_item['TimelineDesc']),
                        subtitle: new Text(_item['EndDate'].split('T')[0]),
                      ),
                      icon: Icon(Icons.assignment_turned_in, color: Colors.white,),
                      iconBackground: Colors.green,
                      position: TimelineItemPosition.right
                  )
              );
              break;
            default:
              _timeline.add(
                  TimelineModel(
                      ListTile(
                        title: new Text(_item['TimelineDesc']),
                        subtitle: new Text(_item['EndDate'].split('T')[0]),
                      ),
                      icon: Icon(Icons.check, color: Colors.white,),
                      iconBackground: Colors.grey,
                      position: TimelineItemPosition.right
                  )
              );
          }
        }
        return _timeline;
      } else {
        return [];
      }
    } else {
      return [];
    }
  }

  Card buildEquipmentCard(Map item) {
    return new Card(
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          ListTile(
            leading: Icon(
              Icons.desktop_mac,
              color: Color(0xff14BD98),
              size: 36.0,
            ),
            title: Text(
              "设备名称：${item['Name']}",
              style: new TextStyle(
                  fontSize: 16.0,
                  color: Theme.of(context).primaryColor
              ),
            ),
            subtitle: Text(
              "系统编号：${item['OID']}",
              style: new TextStyle(
                  color: Theme.of(context).accentColor
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              children: <Widget>[
                BuildWidget.buildCardRow('资产编号', item['AssetCode']),
                BuildWidget.buildCardRow('设备型号', item['EquipmentCode']),
                BuildWidget.buildCardRow('序列号', item['SerialCode']),
                BuildWidget.buildCardRow('厂商', item['Manufacturer']['Name']),
                BuildWidget.buildCardRow('资产等级', item['AssetLevel']['Name']),
                BuildWidget.buildCardRow('使用科室', item['Department']['Name']),
                BuildWidget.buildCardRow('维保状态', item['WarrantyStatus']),
              ],
            ),
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              new RaisedButton(
                onPressed: (){
                  Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
                    return new PrintQrcode(equipmentId: item['SerialCode'],);
                  }));
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                color: new Color(0xff2E94B9),
                child: new Row(
                  children: <Widget>[
                    new Icon(
                      Icons.widgets,
                      color: Colors.white,
                    ),
                    new Text(
                      '二维码',
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
                  Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
                    return new EquipmentDetail(equipment: item,);
                  })).then((result) => getEquipments());
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                color: new Color(0xff2E94B9),
                child: new Row(
                  children: <Widget>[
                    new Icon(
                      Icons.edit,
                      color: Colors.white,
                    ),
                    new Text(
                      '编辑',
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
                onPressed: () async {
                  List<TimelineModel> _steps = await getTimeline(item['ID']);
                  if (_steps.length > 0) {
                    showDialog(context: context,
                        builder: (context) => SimpleDialog(
                          title: new Text('生命周期'),
                          children: <Widget>[
                            new Container(
                              width: 300.0,
                              height: _steps.length*80.0,
                              child: Timeline(
                                children: _steps,
                                position: TimelinePosition.Left,
                              )
                            ),
                          ],
                        )
                    );
                  } else {
                    showDialog(context: context, builder: (context) => CupertinoAlertDialog(title: new Text('暂无事件'),));
                  }
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                color: new Color(0xff2E94B9),
                child: new Row(
                  children: <Widget>[
                    new Icon(
                      Icons.replay,
                      color: Colors.white,
                    ),
                    new Text(
                      '生命周期',
                      style: new TextStyle(
                          color: Colors.white
                      ),
                    )
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: isSearchState?TextField(
            controller: _keywords,
            style: new TextStyle(
              color: Colors.white
            ),
            decoration: new InputDecoration(
              prefixIcon: Icon(Icons.search, color: Colors.white,),
              hintText: '请输入设备名称/型号/序列号',
              hintStyle: new TextStyle(color: Colors.white)
            ),
            onChanged: (val) {
              getEquipments(filterText: val);
            },
          ):Text('设备列表'),
          elevation: 0.7,
          actions: <Widget>[
            isSearchState?IconButton(
              icon: Icon(Icons.cancel),
              onPressed: () {
                setState(() {
                  isSearchState = false;
                });
              },
            ):IconButton(icon: Icon(Icons.search), onPressed: () {
              setState(() {
                isSearchState = true;
              });
            })
          ],
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
        ),
        body: _loading?new Center(child: new SpinKitRotatingPlain(color: Colors.blue,),):new ListView.builder(
          itemCount: _equipments.length,
          itemBuilder: (context, i) {
            return buildEquipmentCard(_equipments[i]);
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
              return new EquipmentDetail();
            })).then((result) => getEquipments());
          },
          child: Icon(Icons.add_circle),
          backgroundColor: Colors.blue,
        ),
    );
  }
}