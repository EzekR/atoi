import 'package:flutter/material.dart';
import 'package:atoi/utils/http_request.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:atoi/widgets/build_widget.dart';
import 'package:atoi/pages/equipments/vendor_detail.dart';
import 'package:atoi/pages/equipments/equipment_contract.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:atoi/models/models.dart';

/// 合同列表页面类
class ContractList extends StatefulWidget{
  _ContractListState createState() => _ContractListState();
}

class _ContractListState extends State<ContractList> {

  List<dynamic> _contracts = [];

  bool isSearchState = false;
  bool _loading = false;
  bool _editable = true;
  bool _noMore = false;
  List contractStatusList = [];
  int contractStatusId = 0;
  ConstantsModel cModel;
  int offset = 0;

  TextEditingController _keywords = new TextEditingController();
  String field = 'c.ID';

  Future<SharedPreferences> prefs = SharedPreferences.getInstance();

  ScrollController _scrollController = new ScrollController();

  Future<Null> getRole() async {
    var _prefs = await prefs;
    var _role = _prefs.getInt('role');
    _editable = _role==1?true:false;
  }

  void setFilter() async {
    getContracts();
  }

  List initList(Map _map) {
    List _list = [];
    _list.add({
      'value': 0,
      'text': '全部'
    });
    _map.forEach((key, val) {
      _list.add({
        'value': val,
        'text': key
      });
    });
    return _list;
  }
  
  void initFilter() async {
    setState(() {
      _keywords.clear();
      field = 'c.ID';
      contractStatusList = [
        {
          'value': 0,
          'text': '全部'
        },
        {
          'value': 1,
          'text': '失效'
        },
        {
          'value': 2,
          'text': '生效'
        },
        {
          'value': 3,
          'text': '未生效'
        },
        {
          'value': 4,
          'text': '即将失效'
        },
      ];
    });
  }

  Future<Null> getContracts({String filterText}) async {
    filterText = filterText??'';
    var resp = await HttpRequest.request(
      '/Contract/GetContracts',
      method: HttpRequest.GET,
      params: {
        'filterText': _keywords.text,
        'filterField': field,
        'status': contractStatusId,
        'CurRowNum': offset,
        'PageSize': 10
      }
    );
    if (resp['ResultCode'] == '00') {
      setState(() {
        _contracts.addAll(resp['Data']);
      });
    }
  }

  void showSheet(BuildContext context) {
    showModalBottomSheet(context: context, builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return ListView(
            children: <Widget>[
              SizedBox(height: 18.0,),
              Row(
                children: <Widget>[
                  SizedBox(width: 16.0,),
                  Text('搜索', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),)
                ],
              ),
              SizedBox(height: 6.0,),
              Row(
                children: <Widget>[
                  SizedBox(width: 16.0,),
                  Container(
                      width: 230.0,
                      height: 40.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: Color(0xfff2f2f2),
                      ),
                      child: Row(
                        children: <Widget>[
                          SizedBox(width: 10.0,),
                          Icon(Icons.search, color: Color(0xffaaaaaa),),
                          SizedBox(width: 10.0,),
                          Container(
                              width: 150.0,
                              child: Align(
                                alignment: Alignment(0.0, -0.5),
                                child: TextField(
                                  decoration: InputDecoration.collapsed(hintText: ''),
                                  controller: _keywords,
                                ),
                              )
                          ),
                        ],
                      )
                  ),
                  SizedBox(width: 16.0,),
                  Container(
                    width: 130.0,
                    height: 40.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      color: Color(0xfff2f2f2),
                    ),
                    child: Row(
                      children: <Widget>[
                        SizedBox(width: 6.0,),
                        DropdownButton(
                          value: field,
                          underline: Container(),
                          items: <DropdownMenuItem>[
                            DropdownMenuItem(
                              value: 'c.ID',
                              child: Text('系统编号'),
                            ),
                            DropdownMenuItem(
                              value: 'c.ContractNum',
                              child: Text('合同编号'),
                            ),
                            DropdownMenuItem(
                              value: 'e.SerialCode',
                              child: Text('设备序列号'),
                            ),
                            DropdownMenuItem(
                              value: 'e.ID',
                              child: Text('设备编号'),
                            ),
                          ],
                          onChanged: (val) {
                            setState(() {
                              field = val;
                            });
                          },
                        ),
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(height: 18.0,),
              Row(
                children: <Widget>[
                  SizedBox(width: 16.0,),
                  Text('状态', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),)
                ],
              ),
              SizedBox(height: 6.0,),
              Row(
                children: <Widget>[
                  SizedBox(width: 16.0,),
                  Container(
                      width: 230.0,
                      height: 40.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.0),
                        color: Color(0xfff2f2f2),
                      ),
                      child: Row(
                        children: <Widget>[
                          SizedBox(width: 6.0,),
                          DropdownButton(
                            value: contractStatusId,
                            underline: Container(),
                            items: contractStatusList.map<DropdownMenuItem>((item) {
                              return DropdownMenuItem(
                                value: item['value'],
                                child: Text(item['text']),
                              );
                            }).toList(),
                            onChanged: (val) {
                              print(val);
                              FocusScope.of(context).requestFocus(new FocusNode());
                              setState(() {
                                contractStatusId = val;
                              });
                            },
                          )
                        ],
                      )
                  ),
                ],
              ),
              SizedBox(height: 30.0,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    width: 100.0,
                    height: 40.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      border: Border.all(
                          color: Color(0xff3394B9),
                          width: 1.0
                      ),
                      color: Color(0xffEBF9FF),
                    ),
                    child: Center(
                      child: FlatButton(onPressed: () {
                        setState((){
                          _keywords.clear();
                          field = 'c.ID';
                          contractStatusId = contractStatusList[0]['value'];
                        });
                        initFilter();
                      }, child: Text('重置')),
                    ),
                  ),
                  Container(
                    width: 100.0,
                    height: 40.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      color: Color(0xff3394B9),
                    ),
                    child: Center(
                      child: FlatButton(onPressed: () {
                        setFilter();
                        Navigator.of(context).pop();
                      }, child: Text('确认', style: TextStyle(color: Colors.white),)),
                    ),
                  ),
                ],
              )
            ],
          );
        },
      );
    });
  }

  void initState() {
    super.initState();
    cModel = MainModel.of(context);
    initFilter();
    setState(() {
      _loading = true;
    });
    getContracts().then((result) => setState(() {
      _loading = false;
    }));
    getRole();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        var _length = _contracts.length;
        offset += 10;
        getContracts().then((result) {
          if (_contracts.length == _length) {
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
                  setState(() {
                    isSearchState = false;
                    _keywords.clear();
                  });
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
              //setState(() {
              //  isSearchState = false;
              //});
              showSheet(context);
            },
          ):IconButton(icon: Icon(Icons.search), onPressed: () {
            //setState(() {
            //  isSearchState = true;
            //});
            showSheet(context);
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
      body: _loading?new Center(child: new SpinKitThreeBounce(color: Colors.blue,),):(_contracts.length==0?Center(child: Text('无合同'),):new ListView.builder(
        itemCount: _contracts.length+1,
        controller: _scrollController,
        itemBuilder: (context, i) {
          if (i != _contracts.length) {
            return buildEquipmentCard(_contracts[i]);
          } else {
            return new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _noMore?new Center(child: new Text('没有更多合同'),):new SpinKitChasingDots(color: Colors.blue,)
              ],
            );
          }
        },
      )),
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
