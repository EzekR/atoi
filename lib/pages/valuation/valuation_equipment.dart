import 'package:atoi/utils/common.dart';
import 'package:atoi/utils/http_request.dart';
import 'package:atoi/widgets/build_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ValuationEquipment extends StatefulWidget {
  final int historyID;
  ValuationEquipment({this.historyID});
  _ValuationEquipmentState createState() => new _ValuationEquipmentState();
}

class _ValuationEquipmentState extends State<ValuationEquipment> {

  List _equipments = [];
  bool _loading = false;
  ScrollController _scrollController = new ScrollController();
  bool _noMore = false;
  int offset = 0;
  TextEditingController _keywords = new TextEditingController();
  String field = 've.EquipmentID';
  int equipmentType = -1;
  List equipmentTypes = [
    {
      'value': -1,
      'text': '全部'
    },
    {
      'value': 1,
      'text': '重点'
    },
    {
      'value': 2,
      'text': '次重点'
    },
    {
      'value': 3,
      'text': '一般'
    },
  ];

  Future<Null> getEquipments() async {
    Map resp = await HttpRequest.request(
      '/Valuation/QueryValHisEqpts',
      params: {
        'valHisID': widget.historyID,
        'equipmentType': equipmentType,
        'filterField': field,
        "filterText": _keywords.text,
        'curRowNum': offset,
        'pageSize': 10,
      }
    );
    if (resp['ResultCode'] == '00') {
      setState(() {
        _equipments.addAll(resp['Data']);
      });
    }
  }

  void initState() {
    super.initState();
    getEquipments();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        var _length = _equipments.length;
        offset += 10;
        getEquipments().then((result) {
          if (_equipments.length == _length) {
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
                                    value: 've.EquipmentID',
                                    child: Text('系统编号'),
                                  ),
                                  DropdownMenuItem(
                                    value: 've.AssetCode',
                                    child: Text('资产编号'),
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
                        Text('设备类型', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),)
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
                                  value: equipmentType,
                                  underline: Container(),
                                  items: equipmentTypes.map<DropdownMenuItem>((item) {
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
                                      equipmentType = val;
                                    });
                                  },
                                )
                              ],
                            )
                        ),
                      ],
                    ),
                    SizedBox(height: 6.0,),
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
                          field = 've.EquipmentID';
                          equipmentType = -1;
                          _keywords.clear();
                        });
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
                        _equipments.clear();
                        offset = 0;
                        getEquipments();
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

  Card buildEquipmentCard(Map item) {
    return Card(
      child: Column(
        children: <Widget>[
          ListTile(
            onTap: () {
            },
            leading: Icon(
              Icons.devices,
              color: Color(0xff14BD98),
              size: 36.0,
            ),
            title: Text(
              "系统编号： ${item['Equipment']['OID']}",
              style: new TextStyle(
                  fontSize: 16.0,
                  color: Theme.of(context).primaryColor
              ),
            ),
            subtitle: Text(
              "是否在库：${item['InSystem']?'是':'否'}",
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.blueAccent
              ),
            ),
          ),
          BuildWidget.buildCardRow('资产编号', item['Equipment']['AssetCode']),
          BuildWidget.buildCardRow('名称', item['Equipment']['Name']),
          BuildWidget.buildCardRow('设备序列号', item['Equipment']['SerialCode']),
          BuildWidget.buildCardRow('厂商', item['Equipment']['Manufacturer']['Name']),
          BuildWidget.buildCardRow('科室', item['Equipment']['Department']['Name']),
          BuildWidget.buildCardRow('金额', CommonUtil.CurrencyForm(item['Equipment']['PurchaseAmount'], times: 1, digits: 0)),
          BuildWidget.buildCardRow('设备类型', item['Equipment']['FujiClass2']['EquipmentType']['Name']),
          BuildWidget.buildCardRow('富士I类', item['Equipment']['FujiClass2']['FujiClass1']['Name']),
          BuildWidget.buildCardRow('富士II类', item['Equipment']['FujiClass2']['Name']),
          SizedBox(height: 8.0,)
        ],
      ),
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: Text('估价执行条件：设备清单'),
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
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSheet(context);
            },
          ),
        ],
      ),
      body: _loading?new Center(child: new SpinKitThreeBounce(color: Colors.blue,),):(_equipments.length==0?Center(child: Text('无设备'),):new ListView.builder(
        itemCount: _equipments.length>10?_equipments.length+1:_equipments.length,
        controller: _scrollController,
        itemBuilder: (context, i) {
          if (i != _equipments.length) {
            return buildEquipmentCard(_equipments[i]);
          } else {
            return new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _noMore?new Center(child: new Text('没有更多设备'),):new SpinKitChasingDots(color: Colors.blue,)
              ],
            );
          }
        },
      )),
    );
  }
}