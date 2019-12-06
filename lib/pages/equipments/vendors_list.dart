import 'package:flutter/material.dart';
import 'package:atoi/utils/http_request.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:atoi/pages/equipments/print_qrcode.dart';
import 'package:atoi/widgets/build_widget.dart';
import 'package:atoi/pages/equipments/vendor_detail.dart';

class VendorsList extends StatefulWidget{
  _VendorsListState createState() => _VendorsListState();
}

class _VendorsListState extends State<VendorsList> {

  List<dynamic> _vendors = [];

  Future<Null> getVendors() async {
    var resp = await HttpRequest.request(
      '/DispatchReport/GetSuppliers?filterText=',
      method: HttpRequest.GET,
    );
    if (resp['ResultCode'] == '00') {
      setState(() {
        _vendors = resp['Data'];
      });
    }
  }

  void initState() {
    super.initState();
    getVendors();
  }

  Card buildEquipmentCard(Map item) {
    return new Card(
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          ListTile(
            leading: Icon(
              Icons.store,
              color: Color(0xff14BD98),
              size: 36.0,
            ),
            title: Text(
              "供应商名称：${item['Name']}",
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
                BuildWidget.buildCardRow('类型', item['SupplierType']['Name']),
                BuildWidget.buildCardRow('省份', item['Province']),
                BuildWidget.buildCardRow('地址', item['Address']),
                BuildWidget.buildCardRow('联系人', item['Contact']),
                BuildWidget.buildCardRow('联系电话', item['ContactMobile']),
                BuildWidget.buildCardRow('添加日期', item['AddDate'].split('T')[0]),
                BuildWidget.buildCardRow('状态', item['IsActive']?'启用':'停用'),
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
                    return new VendorDetail(vendor: item,);
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
        title: new Text('供应商列表'),
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
      body: _vendors.length==0?new Center(child: new SpinKitRotatingPlain(color: Colors.blue,),):new ListView.builder(
        itemCount: _vendors.length,
        itemBuilder: (context, i) {
          return buildEquipmentCard(_vendors[i]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
            return new VendorDetail();
          }));
        },
        child: Icon(Icons.add_circle),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
