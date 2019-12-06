import 'package:flutter/material.dart';
import 'package:atoi/utils/http_request.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:atoi/widgets/build_widget.dart';
import 'package:atoi/pages/equipments/vendor_detail.dart';
import 'package:atoi/pages/equipments/equipment_contract.dart';

class ContractList extends StatefulWidget{
  _ContractListState createState() => _ContractListState();
}

class _ContractListState extends State<ContractList> {

  List<dynamic> _contracts = [];

  Future<Null> getContracts() async {
    var resp = await HttpRequest.request(
      '/Contract/GetContracts',
      method: HttpRequest.GET,
    );
    if (resp['ResultCode'] == '00') {
      setState(() {
        _contracts = resp['Data'];
      });
    }
  }

  void initState() {
    super.initState();
    getContracts();
  }

  Card buildEquipmentCard(Map item) {
    return new Card(
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          ListTile(
            leading: Icon(
              Icons.insert_drive_file,
              color: Color(0xff14BD98),
              size: 36.0,
            ),
            title: Text(
              "合同名称：${item['Name']}",
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
                BuildWidget.buildCardRow('合同编号', item['ContractNum']),
                BuildWidget.buildCardRow('设备编号', item['EquipmentOID']),
                BuildWidget.buildCardRow('设备序列号', item['EquipmentSerialCode']),
                BuildWidget.buildCardRow('合同类型', item['Type']['Name']),
                BuildWidget.buildCardRow('供应商', item['Supplier']['Name']),
                BuildWidget.buildCardRow('开始时间', item['StartDate'].split('T')[0]),
                BuildWidget.buildCardRow('结束时间', item['EndDate'].split('T')[0]),
                BuildWidget.buildCardRow('状态', item['Status']),
              ],
            ),
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              new RaisedButton(
                onPressed: (){
                  Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
                    return new EquipmentContract(contract: item,);
                  }));
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                color: new Color(0xff2E94B9),
                child: new Row(
                  children: <Widget>[
                    new Icon(
                      Icons.mode_edit,
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
                padding: EdgeInsets.symmetric(horizontal: 15.0),
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
        title: new Text('合同列表'),
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
      body: _contracts.length==0?new Center(child: new SpinKitRotatingPlain(color: Colors.blue,),):new ListView.builder(
        itemCount: _contracts.length,
        itemBuilder: (context, i) {
          return buildEquipmentCard(_contracts[i]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
            return new EquipmentContract();
          }));
        },
        child: Icon(Icons.add_circle),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
