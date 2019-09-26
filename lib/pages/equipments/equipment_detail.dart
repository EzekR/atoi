import 'package:flutter/material.dart';
import 'package:atoi/widgets/build_widget.dart';

class EquipmentDetail extends StatefulWidget {
  _EquipmentDetailState createState() => _EquipmentDetailState();
}

class _EquipmentDetailState extends State<EquipmentDetail> {

  void initState() {
    super.initState();
  }

  List<ExpansionPanel> buildExpansion() {
    var _list = [];
    //device info
    _list.add(ExpansionPanel(
      headerBuilder: (context, isExpanded) {
        return ListTile(
            leading: new Icon(Icons.info,
              size: 24.0,
              color: Colors.blue,
            ),
            title: Text('设备信息',
              style: new TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.w400
              ),
            )
        );
      },
      body: new Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.0),
        child: new Column(
          children: <Widget>[
            BuildWidget.buildInput('设备名称', new TextEditingController()),
            BuildWidget.buildInput('设备型号', new TextEditingController()),
            BuildWidget.buildInput('设备序列号', new TextEditingController()),
            BuildWidget.buildInput('设备厂商', new TextEditingController()),
            BuildWidget.buildInput('标准响应时间', new TextEditingController()),
          ],
        ),  
      )
    ));
    //asset info
    _list.add(ExpansionPanel(
        headerBuilder: (context, isExpanded) {
          return ListTile(
              leading: new Icon(Icons.web_asset,
                size: 24.0,
                color: Colors.blue,
              ),
              title: Text('资产信息',
                style: new TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.w400
                ),
              )
          );
        },
        body: new Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.0),
          child: new Column(
            children: <Widget>[
              BuildWidget.buildInput('固定资产', new TextEditingController()),
              BuildWidget.buildInput('资产编号', new TextEditingController()),
              BuildWidget.buildInput('资产等级', new TextEditingController()),
              BuildWidget.buildInput('折旧年限', new TextEditingController()),
              BuildWidget.buildInput('注册证有效期', new TextEditingController()),
            ],
          ),
        )
    ));
  }

  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('添加设备'),
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
          new IconButton(
            icon: Icon(Icons.search),
            color: Colors.white,
            iconSize: 30.0,
            onPressed: () {
            },
          ),
          new IconButton(
              icon: Icon(Icons.crop_free),
              color: Colors.white,
              iconSize: 30.0,
              onPressed: () {
              })
        ],
      ),

    );
  }
}