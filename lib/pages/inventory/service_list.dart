import 'package:flutter/material.dart';
import 'package:atoi/utils/http_request.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:atoi/widgets/build_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:atoi/models/models.dart';
import 'package:atoi/pages/inventory/component_detail.dart';

/// 服务列表类
class ServiceList extends StatefulWidget{
  _ServiceListState createState() => _ServiceListState();
}

class _ServiceListState extends State<ServiceList> {

  List<dynamic> _components = [
    {
      "FujiClass2": {
        "Name": "20200805II类",
        "FujiClass1": {
          "ID": 0,
          "AddDate": null,
          "UpdateDate": null,
          "EquipmentType1": {
            "Level": 0
          },
          "EquipmentType2": {
            "Level": 0
          },
          "FujiClass2Count": 0
        },
        "IncludeLabour": false,
        "PatrolTimes": 0,
        "PatrolHours": 0,
        "MaintenanceTimes": 0,
        "MaintenanceHours": 0,
        "RepairHours": 0,
        "IncludeContract": false,
        "FullCoveragePtg": 0,
        "TechCoveragePtg": 0,
        "IncludeSpare": false,
        "SparePrice": 0,
        "SpareRentPtg": 0,
        "IncludeRepair": false,
        "Usage": 0,
        "EquipmentType": {
          "ID": 0
        },
        "RepairComponentCost": 0,
        "Repair3partyRatio": 0,
        "Repair3partyCost": 0,
        "RepairCostRatio": 0,
        "MethodID": 0,
        "AddDate": null,
        "UpdateDate": null,
        "Repairs": [],
        "Components": [],
        "Consumables": [],
        "hasEdited": false,
        "ID": 12
      },
      "Name": "服务名称",
      "TotalTimes": 100,
      "Price": 0,
      "StartDate": "2020-08-07T00:00:00",
      "EndDate": "2020-08-07T00:00:00",
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
      "Purchase": {
        "ID": 0
      },
      "PurchaseDate": "2020-08-07T00:00:00",
      "Comments": "",
      "AddDate": "2020-08-07T14:36:59",
      "AvaibleTimes": 100,
      "UpdateDate": "2020-08-17T09:42:19",
      "OID": "WGFW00000001",
      "Inbounded": false,
      "Status": "失效",
      "ID": 1
    }
  ];

  bool isSearchState = false;
  bool _loading = false;
  bool _editable = true;

  TextEditingController _keywords = new TextEditingController();
  String field = 'c.Name';
  int useStatus = 1;
  List useList = [];
  int supplierId = 0;
  List supplierList = [];
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
      _components.clear();
    });
    getComponents();
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
    setState(() {
      useStatus = 1;
      field = 's.ID';
      _keywords.clear();
      useList = [
        {
          'value': 0,
          'text': '全部'
        },
        {
          'value': 1,
          'text': '在库'
        },
        {
          'value': 2,
          'text': '已用'
        },
        {
          'value': 3,
          'text': '报废'
        },

      ];
      supplierList = initList(cModel.SupplierType);
      supplierId = supplierList[0]['value'];
    });
  }

  Future<Null> getComponents({String filterText}) async {
    filterText = filterText??'';
    var resp = await HttpRequest.request(
        '/InvComponent/QueryServiceList',
        method: HttpRequest.GET,
        params: {
          'filterText': _keywords.text,
          'filterField': field,
          'statusID': useStatus,
          'CurRowNum': offset,
          'PageSize': 10
        }
    );
    if (resp['ResultCode'] == '00') {
      setState(() {
        _components.addAll(resp['Data']);
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
                                  value: useStatus,
                                  underline: Container(),
                                  items: useList.map<DropdownMenuItem>((item) {
                                    return DropdownMenuItem(
                                      value: item['value'],
                                      child: Container(
                                        width: 200,
                                        child: Text(item['text']),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    print(val);
                                    FocusScope.of(context).requestFocus(new FocusNode());
                                    setState(() {
                                      useStatus = val;
                                    });
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
                          useStatus = -1;
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
    //getComponents().then((result) => setState(() {
    //  _loading = false;
    //}));
    getRole();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        var _length = _components.length;
        offset += 10;
        getComponents().then((result) {
          if (_components.length == _length) {
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
              Icons.assignment_turned_in,
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
              "服务名称：${item['Name']}",
              style: new TextStyle(
                  color: Theme.of(context).accentColor
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              children: <Widget>[
                BuildWidget.buildCardRow('关联富士II类', item['FujiClass2']['Name']),
                BuildWidget.buildCardRow('供应商', item['Supplier']['Name']),
                BuildWidget.buildCardRow('服务次数', item['TotalTimes'].toString()),
                BuildWidget.buildCardRow('购入日期', item['StartDate'].split('T')[0]),
                BuildWidget.buildCardRow('购入日期', item['EndDate'].split('T')[0]),
                BuildWidget.buildCardRow('金额', item['Price'].toString()),
                BuildWidget.buildCardRow('剩余服务次数', item['AvaibleTimes'].toString()),
                BuildWidget.buildCardRow('采购单号', item['Purchase']['ID'].toString()),
                BuildWidget.buildCardRow('状态', item['Status']),
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
                    return new ComponentDetail(component: item, editable: _editable,);
                  })).then((result) {
                    setState(() {
                      _loading = true;
                      _components.clear();
                      offset = 0;
                    });
                    getComponents().then((result) {
                      setState(() {
                        _loading = false;
                      });
                    });
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
            getComponents(filterText: val);
          },
        ):Text('服务列表'),
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
      body: _loading?new Center(child: new SpinKitThreeBounce(color: Colors.blue,),):(_components.length==0?Center(child: Text('无供应商'),):new ListView.builder(
        itemCount: _components.length>10?_components.length+1:_components.length,
        controller: _scrollController,
        itemBuilder: (context, i) {
          if (i !=_components.length) {
            return buildEquipmentCard(_components[i]);
          } else {
            return new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _noMore?new Center(child: new Text('没有更多供应商'),):new SpinKitChasingDots(color: Colors.blue,)
              ],
            );
          }
        },
      )),
      floatingActionButton: role==3?Container():FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
            return new ComponentDetail(editable: true,);
          })).then((result) {
            setState(() {
              offset = 0;
              _components.clear();
              _loading = true;
            });
            getComponents().then((result) =>
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

enum ListType {
  COMPONENT,
  CONSUMABLE,
}
