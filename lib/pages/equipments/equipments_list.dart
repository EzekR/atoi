import 'package:flutter/material.dart';
import 'package:atoi/utils/http_request.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:atoi/pages/equipments/print_qrcode.dart';

class EquipmentsList extends StatefulWidget{
  _EquipmentsListState createState() => _EquipmentsListState();
}

class _EquipmentsListState extends State<EquipmentsList> {

  List<dynamic> _equipments = [];

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
            return new ListTile(
              title: new Text(
                '${_equipments[i]['Name']} ${_equipments[i]['EquipmentCode']} ${_equipments[i]['Department']['Name']}'
              ),
              subtitle: new Text(
                  _equipments[i]['Manufacturer']['Name']
              ),
              onTap: () {
                Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
                  return new PrintQrcode(equipmentId: _equipments[i]['SerialCode'],);
                }));
              },
            );
          },
        )
    );
  }
}