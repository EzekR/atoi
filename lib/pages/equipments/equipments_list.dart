import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:atoi/utils/http_request.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:atoi/pages/equipments/print_qrcode.dart';
import 'package:atoi/widgets/build_widget.dart';
import 'package:atoi/pages/equipments/equipment_detail.dart';

class EquipmentsList extends StatefulWidget{
  _EquipmentsListState createState() => _EquipmentsListState();
}

class _EquipmentsListState extends State<EquipmentsList> {

  List<dynamic> _equipments = [];

  List<Step> timeline = [];

  Future<Null> getEquipments() async {
    var resp = await HttpRequest.request(
      '/Equipment/Getdevices',
      method: HttpRequest.GET,
    );
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

  Future<List<Step>> getTimeline(int deviceId) async {
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
        List<Step> _list = _dispatches.map<Step>((item) => Step(
            title: new Text('派工单号：${item['OID']}'),
            subtitle: new Text('派工时间：${item['EndDate'].split('T')[0]}'),
            content: new Text(item['TimelineDesc']),
            isActive: false
        )).toList();
        return _list;
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
              "序列号：${item['SerialCode']}",
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
                  }));
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
                  List<Step> _steps = await getTimeline(item['ID']);
                  if (_steps.length > 0) {
                    showDialog(context: context,
                        builder: (context) => SimpleDialog(
                          title: new Text('派工历史'),
                          children: <Widget>[
                            new Container(
                              width: 300.0,
                              height: 600.0,
                              child: new Stepper(
                                currentStep: 0,
                                controlsBuilder: (BuildContext context, {VoidCallback onStepContinue, VoidCallback onStepCancel}) {
                                  return Row(
                                    children: <Widget>[
                                      new Container()
                                    ],
                                  );
                                },
                                steps: _steps,
                              ),
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
          title: new Text('设备列表'),
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
        ),
        body: _equipments.length==0?new Center(child: new SpinKitRotatingPlain(color: Colors.blue,),):new ListView.builder(
          itemCount: _equipments.length,
          itemBuilder: (context, i) {
            return buildEquipmentCard(_equipments[i]);
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
              return new EquipmentDetail();
            }));
          },
          child: Icon(Icons.add_circle),
          backgroundColor: Colors.blue,
        ),
    );
  }
}