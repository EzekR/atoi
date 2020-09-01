import 'package:flutter/material.dart';
import 'package:atoi/utils/http_request.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:atoi/widgets/build_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:atoi/models/models.dart';
import 'package:atoi/pages/inventory/consumable_detail.dart';

/// 耗材列表类
class ConsumableList extends StatefulWidget{
  _ConsumableListState createState() => _ConsumableListState();
}

class _ConsumableListState extends State<ConsumableList> {

  List<dynamic> _consumable = [
    {
      "Consumable": {
        "FujiClass2": {
          "ID": 0,
          "Name": "frank_有源超声"
        },
        "Name": "其他耗材23",
        "Description": "123",
        "Type": {
          "ID": 0
        },
        "ReplaceTimes": 0,
        "CostPer": 0,
        "StdPrice": 0,
        "IsIncluded": false,
        "IncludeContract": false,
        "IsActive": false,
        "AddDate": null,
        "UpdateDate": null,
        "OID": "HC00000015",
        "ID": 15
      },
      "LotNum": "12314-7689",
      "Specification": "75555554",
      "Model": "54754444444",
      "Supplier": {
        "SupplierType": {
          "ID": 0
        },
        "Name": "卡尔史托斯1",
        "AddDate": null,
        "IsActive": false,
        "OID": "GYS00000007",
        "ID": 7
      },
      "Price": 6886,
      "ReceiveQty": 100000,
      "PurchaseDate": "2020-07-15T00:00:00",
      "Purchase": {
        "ID": 0
      },
      "Comments": "yumnutrbbbbbbbbbbbyut",
      "AddDate": "2020-07-16T11:27:32",
      "AvaibleQty": 20000,
      "UpdateDate": "2020-07-16T11:38:07",
      "OID": "HCK00000015",
      "Qty": 0,
      "InboundQty": 0,
      "ID": 15
    },
    {
      "Consumable": {
        "FujiClass2": {
          "ID": 0,
          "Name": "骨科2"
        },
        "Name": "其他耗材23",
        "Description": "123",
        "Type": {
          "ID": 0
        },
        "ReplaceTimes": 0,
        "CostPer": 0,
        "StdPrice": 0,
        "IsIncluded": false,
        "IncludeContract": false,
        "IsActive": false,
        "AddDate": null,
        "UpdateDate": null,
        "OID": "HC00000006",
        "ID": 6
      },
      "LotNum": "9862-58-0716",
      "Specification": "9862-58-07162",
      "Model": "9862-58-0716321",
      "Supplier": {
        "SupplierType": {
          "ID": 0
        },
        "Name": "日立",
        "AddDate": null,
        "IsActive": false,
        "OID": "GYS00000005",
        "ID": 5
      },
      "Price": 33333,
      "ReceiveQty": 8895889.2,
      "PurchaseDate": "2019-10-17T00:00:00",
      "Purchase": {
        "ID": 0
      },
      "Comments": "xaafewf",
      "AddDate": "2020-07-16T11:23:56",
      "AvaibleQty": 100000,
      "UpdateDate": "2020-07-16T11:25:11",
      "OID": "HCK00000014",
      "Qty": 0,
      "InboundQty": 0,
      "ID": 14
    },
    {
      "Consumable": {
        "FujiClass2": {
          "ID": 0,
          "Name": "骨科2"
        },
        "Name": "其他耗材23",
        "Description": "123",
        "Type": {
          "ID": 0
        },
        "ReplaceTimes": 0,
        "CostPer": 0,
        "StdPrice": 0,
        "IsIncluded": false,
        "IncludeContract": false,
        "IsActive": false,
        "AddDate": null,
        "UpdateDate": null,
        "OID": "HC00000006",
        "ID": 6
      },
      "LotNum": "0709-1",
      "Specification": "0709-2",
      "Model": "0709-3",
      "Supplier": {
        "SupplierType": {
          "ID": 0
        },
        "Name": "史托斯",
        "AddDate": null,
        "IsActive": false,
        "OID": "GYS00000010",
        "ID": 10
      },
      "Price": 70.9,
      "ReceiveQty": 100,
      "PurchaseDate": "2020-07-31T00:00:00",
      "Purchase": {
        "ID": 0
      },
      "Comments": "2569840ssssssssssssssssssssssssssssssssssssssssssssss\nssssssssssssssssss",
      "AddDate": "2020-07-09T14:56:57",
      "AvaibleQty": 1000,
      "UpdateDate": "2020-07-09T16:31:09",
      "OID": "HCK00000002",
      "Qty": 0,
      "InboundQty": 0,
      "ID": 2
    }
  ];

  bool isSearchState = false;
  bool _loading = false;
  bool _editable = true;

  TextEditingController _keywords = new TextEditingController();
  String field = 'c.Name';
  int _fujiClass2 = 0;
  List _fujiList = [];
  Future<SharedPreferences> prefs = SharedPreferences.getInstance();
  ConstantsModel cModel;
  ScrollController _scrollController = new ScrollController();
  int offset = 0;
  bool _noMore = false;
  int role;

  Future<Null> getRole() async {
    var _prefs = await prefs;
    role = _prefs.getInt('role');
    _editable = role==1?true:false;
  }

  void setFilter() {
    setState(() {
      offset = 0;
      _consumable.clear();
    });
    getConsumable();
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
    await cModel.getConstants();
    List _list = cModel.FujiClass2.map((item) {
      return {
        'value': item['ID'],
        'text': item['Name']
      };
    }).toList();
    _list.add({
      'value': 0,
      'text': '全部'
    });
    setState(() {
      _fujiClass2 = 0;
      _fujiList = _list;
      field = 's.ID';
      _keywords.clear();
    });
  }

  Future<Null> getConsumable({String filterText}) async {
    filterText = filterText??'';
    var resp = await HttpRequest.request(
        '/InvConsumable/QueryConsumableList',
        method: HttpRequest.GET,
        params: {
          'filterText': _keywords.text,
          'filterField': field,
          'CurRowNum': offset,
          'PageSize': 10
        }
    );
    if (resp['ResultCode'] == '00') {
      setState(() {
        _consumable.addAll(resp['Data']);
        _loading = false;
      });
    }
  }

  Future<Null> getConsumableByFuji({String filterText}) async {
    filterText = filterText??'';
    var resp = await HttpRequest.request(
        '/InvComponent/QueryConsumableList',
        method: HttpRequest.GET,
        params: {
          'ID': _fujiClass2
        }
    );
    if (resp['ResultCode'] == '00') {
      _consumable.clear();
      setState(() {
        _consumable.addAll(resp['Data']);
      });
    }
  }
  void showSheet(BuildContext context) {
    showModalBottomSheet(context: context, builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Column(
            children: <Widget>[
              Container(
                height: 300.0,
                child: ListView(
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
                                    value: 'c.Name',
                                    child: Text('简称'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'c.Description',
                                    child: Text('描述'),
                                  ),
                                ],
                                onChanged: (val) {
                                  FocusScope.of(context).requestFocus(new FocusNode());
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
                        Text('富士二类', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),)
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
                                  value: _fujiClass2,
                                  underline: Container(),
                                  items: _fujiList.map<DropdownMenuItem>((item) {
                                    return DropdownMenuItem(
                                      value: item['value'],
                                      child: Container(
                                        width: 200,
                                        child: Text(item['text']),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    FocusScope.of(context).requestFocus(new FocusNode());
                                    setState(() {
                                      _fujiClass2 = val;
                                    });
                                    getConsumableByFuji();
                                  },
                                )
                              ],
                            )
                        ),
                      ],
                    ),
                    SizedBox(height: 30.0,),
                  ],
                ),
              ),
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
                          _fujiClass2 = 0;
                          field = 'c.Name';
                          _keywords.clear();
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
    //setState(() {
    //  _loading = true;
    //});
    //getConsumable().then((result) => setState(() {
    //  _loading = false;
    //}));
    getRole();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        var _length = _consumable.length;
        offset += 10;
        getConsumable().then((result) {
          if (_consumable.length == _length) {
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
            onTap: () {
              Navigator.of(context).push(new MaterialPageRoute(builder: (context) => new ConsumableDetail(consumable: item, editable: false,)));
            },
            leading: Icon(
              Icons.battery_alert,
              color: Color(0xff14BD98),
              size: 36.0,
            ),
            title: Text(
              "系统编号： ${item['OID']}",
              style: new TextStyle(
                  fontSize: 16.0,
                  color: Theme.of(context).primaryColor
              ),
            ),
            subtitle: Text(
              "序列号：${item['LotNum']}",
              style: new TextStyle(
                  color: Theme.of(context).accentColor
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              children: <Widget>[
                BuildWidget.buildCardRow('简称', item['Consumable']['Name']),
                BuildWidget.buildCardRow('描述', item['Consumable']['Description']),
                BuildWidget.buildCardRow('供应商', item['Supplier']['Name']),
                BuildWidget.buildCardRow('富士2类', item['Consumable']['FujiClass2']['Name']),
                BuildWidget.buildCardRow('单价（元）', item['Price'].toString()),
                BuildWidget.buildCardRow('购入日期', item['PurchaseDate'].split('T')[0]),
                BuildWidget.buildCardRow('采购单号', item['Purchase']['ID'].toString()),
                BuildWidget.buildCardRow('可用数量', item['AvaibleQty'].toString()),
                //BuildWidget.buildCardRow('状态', item['IsActive']?'启用':'停用'),
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
                    return new ConsumableDetail(consumable: item, editable: _editable,);
                  })).then((result) {
                    setState(() {
                      _loading = true;
                      _consumable.clear();
                      offset = 0;
                    });
                    getConsumable();
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
              hintText: '请输入供应商名称/系统编号',
              hintStyle: new TextStyle(color: Colors.white)
          ),
          onChanged: (val) {
            getConsumable(filterText: val);
          },
        ):Text('耗材列表'),
        elevation: 0.7,
        actions: <Widget>[
          isSearchState?IconButton(
            icon: Icon(Icons.cancel),
            onPressed: () {
              //setState(() {
              //  isSearchState = false;
              //);
              showSheet(context);
            },
          ):IconButton(icon: Icon(Icons.search), onPressed: () {
            //setState(() {
            //  isSearchState = true;
            //});
            showSheet(context);
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
      body: _loading?new Center(child: new SpinKitThreeBounce(color: Colors.blue,),):(_consumable.length==0?Center(child: Text('无耗材'),):new ListView.builder(
        itemCount: _consumable.length>10?_consumable.length+1:_consumable.length,
        controller: _scrollController,
        itemBuilder: (context, i) {
          if (i !=_consumable.length) {
            return buildEquipmentCard(_consumable[i]);
          } else {
            return new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _noMore?new Center(child: new Text('没有更多耗材'),):new SpinKitChasingDots(color: Colors.blue,)
              ],
            );
          }
        },
      )),
      floatingActionButton: role==3?Container():FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
            return new ConsumableDetail(editable: true,);
          })).then((result) {
            setState(() {
              offset = 0;
              _consumable.clear();
              _loading = true;
            });
            getConsumable().then((result) =>
                setState(() {
                  _loading = false;
                }));});
        },
        child: Icon(Icons.add_circle),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
