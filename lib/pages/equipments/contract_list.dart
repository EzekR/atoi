import 'package:flutter/material.dart';
import 'package:atoi/utils/http_request.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:atoi/widgets/build_widget.dart';
import 'package:atoi/pages/equipments/vendor_detail.dart';
import 'package:atoi/pages/equipments/equipment_contract.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ContractList extends StatefulWidget{
  _ContractListState createState() => _ContractListState();
}

class _ContractListState extends State<ContractList> {

  List<dynamic> _contracts = [];

  bool isSearchState = false;
  bool _loading = false;
  bool _editable = true;

  TextEditingController _keywords = new TextEditingController();

  Future<SharedPreferences> prefs = SharedPreferences.getInstance();

  Future<Null> getRole() async {
    var _prefs = await prefs;
    var _role = _prefs.getInt('role');
    _editable = _role==1?true:false;
  }

  Future<Null> getContracts({String filterText}) async {
    filterText = filterText??'';
    setState(() {
      _loading = true;
    });
    var resp = await HttpRequest.request(
      '/Contract/GetContracts',
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
        _contracts = resp['Data'];
      });
    }
  }

  void initState() {
    super.initState();
    getContracts();
    getRole();
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
                    return new EquipmentContract(contract: item, editable: _editable,);
                  })).then((result) => getContracts());
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                color: new Color(0xff2E94B9),
                child: new Row(
                  children: <Widget>[
                    new Icon(
                      _editable?Icons.mode_edit:Icons.remove_red_eye,
                      color: Colors.white,
                    ),
                    new Text(
                      _editable?'编辑':'查看',
                      style: new TextStyle(
                          color: Colors.white
                      ),
                    )
                  ],
                ),
              ),
              new SizedBox(
                width: 60,
              )
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
              hintText: '请输入系统编号/合同编号/名称',
              hintStyle: new TextStyle(color: Colors.white)
          ),
          onChanged: (val) {
            getContracts(filterText: val);
          },
        ):Text('合同列表'),
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
      body: _loading?new Center(child: new SpinKitRotatingPlain(color: Colors.blue,),):new ListView.builder(
        itemCount: _contracts.length,
        itemBuilder: (context, i) {
          return buildEquipmentCard(_contracts[i]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
            return new EquipmentContract(editable: true,);
          })).then((result) => getContracts());
        },
        child: Icon(Icons.add_circle),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
