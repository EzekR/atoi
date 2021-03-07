import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:atoi/utils/http_request.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:atoi/widgets/build_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:atoi/models/models.dart';
import 'package:atoi/pages/inventory/consumable_detail.dart';
import 'package:atoi/utils/common.dart';
import 'package:atoi/pages/equipments/print_qrcode.dart';
import 'package:flutter/cupertino.dart';

/// 耗材列表类
class ConsumableList extends StatefulWidget{
  final bool optional;
  ConsumableList({Key key, this.optional}):super(key: key);
  _ConsumableListState createState() => _ConsumableListState();
}

class _ConsumableListState extends State<ConsumableList> {

  List<dynamic> _consumable = [];

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

  // modal
  TextEditingController _name = new TextEditingController();
  TextEditingController _desc = new TextEditingController();
  TextEditingController _price = new TextEditingController();
  List _typeList = [
    {
      'value': 1,
      'name': "定期"
    },
    {
      'value': 2,
      'name': "定量"
    },
    {
      'value': 3,
      'name': "小额成本"
    },
  ];
  int _consumableType = 1;

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
    List _list = [];
    _list.add({
      'value': 0,
      'text': '全部'
    });
    _list.addAll(cModel.FujiClass2.map((item) {
      return {
        'value': item['ID'],
        'text': item['Name']
      };
    }).toList());
    setState(() {
      _fujiClass2 = 0;
      _fujiList = _list;
      field = 'c.Name';
      _keywords.clear();
    });
  }

  FocusNode _focusName = new FocusNode();
  FocusNode _focusDesc = new FocusNode();
  FocusNode _focusPrice = new FocusNode();

  void addConsumable() {
    showDialog(context: context, builder: (context) => StatefulBuilder(
      builder: (context, setState) => SimpleDialog(
        title: Text('新增耗材'),
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
            child: Column(
              children: <Widget>[
                new Row(
                  children: <Widget>[
                    new Expanded(
                      flex: 3,
                      child: new Wrap(
                        alignment: WrapAlignment.end,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: <Widget>[
                          new Text(
                            '*',
                            style: new TextStyle(
                                color: Colors.red
                            ),
                          ),
                          new Text(
                            '富士II类',
                            style: new TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w600
                            ),
                          )
                        ],
                      ),
                    ),
                    new Expanded(
                      flex: 1,
                      child: new Text(
                        '：',
                        style: new TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    new Expanded(
                      flex: 7,
                      child: new DropdownButton(
                        value: _fujiClass2,
                        items: _fujiList.map<DropdownMenuItem>((item) {
                          return DropdownMenuItem(
                            value: item['value'],
                            child: Text(
                              item['text'],
                              style: TextStyle(
                                  fontSize: 12.0
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _fujiClass2 = value;
                          });
                        },
                        style: new TextStyle(
                          color: Colors.black54,
                          fontSize: 12.0,
                        ),
                      ),
                    ),
                  ],
                ),
                BuildWidget.buildCardInput('简称', _name, required: true, maxLength: 50, focus: _focusName),
                BuildWidget.buildCardInput('描述', _desc, required: true, maxLength: 200, focus: _focusDesc),
                new Row(
                  children: <Widget>[
                    new Expanded(
                      flex: 3,
                      child: new Wrap(
                        alignment: WrapAlignment.end,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: <Widget>[
                          new Text(
                            '*',
                            style: new TextStyle(
                                color: Colors.red
                            ),
                          ),
                          new Text(
                            '类型',
                            style: new TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w600
                            ),
                          )
                        ],
                      ),
                    ),
                    new Expanded(
                      flex: 1,
                      child: new Text(
                        '：',
                        style: new TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    new Expanded(
                      flex: 7,
                      child: new DropdownButton(
                        value: _consumableType,
                        items: _typeList.map<DropdownMenuItem>((item) {
                          return DropdownMenuItem(
                            value: item['value'],
                            child: Text(
                              item['name'],
                              style: TextStyle(
                                  fontSize: 12.0
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _consumableType = value;
                          });
                        },
                        style: new TextStyle(
                          color: Colors.black54,
                          fontSize: 12.0,
                        ),
                      ),
                    ),
                  ],
                ),
                BuildWidget.buildCardInput('标准单价', _price, maxLength: 13, focus: _focusPrice, inputType: TextInputType.numberWithOptions(decimal: true)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    RaisedButton(
                      color: Color(0xffD25565),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Center(
                        child: Text('取消',
                          style: TextStyle(
                              color: Colors.white
                          ),
                        ),
                      ),
                    ),
                    RaisedButton(
                      color: Color(0xff2E94B9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      onPressed: () async {
                        if (_name.text.isEmpty) {
                          showDialog(context: context, builder: (context) => CupertinoAlertDialog(
                            title: new Text('简称不可为空'),
                          )).then((result) => FocusScope.of(context).requestFocus(_focusName));
                          return;
                        }
                        if (_desc.text.isEmpty) {
                          showDialog(context: context, builder: (context) => CupertinoAlertDialog(
                            title: new Text('描述不可为空'),
                          )).then((result) => FocusScope.of(context).requestFocus(_focusDesc));
                          return;
                        }
                        if (double.parse(_price.text) > 9999999999.99) {
                          showDialog(context: context, builder: (context) => CupertinoAlertDialog(
                            title: new Text('价格不可超过1亿'),
                          )).then((result) => FocusScope.of(context).requestFocus(_focusPrice));
                          return;
                        }
                        Map _info = {
                          'FujiClass2': {
                            'ID': _fujiClass2,
                          },
                          'Name': _name.text,
                          'Description': _desc.text,
                          'Type': {
                            'ID': _consumableType
                          },
                          'StdPrice': _price.text
                        };
                        Map resp = await HttpRequest.request(
                          '/PurchaseOrder/SaveConsumable',
                          method: HttpRequest.POST,
                          data: {
                            'info': _info
                          }
                        );
                        if (resp['ResultCode'] == '00') {
                          Navigator.of(context).pop();
                          showDialog(context: context, builder: (context) => CupertinoAlertDialog(
                            title: new Text('保存成功'),
                          )).then((result) {
                            _name.clear();
                            _consumableType = _typeList[0]['value'];
                            _fujiClass2 = _fujiList[0]['value'];
                            _desc.clear();
                            _price.clear();
                            getConsumable(); });
                        } else {
                          showDialog(context: context, builder: (context) => CupertinoAlertDialog(
                            title: new Text(resp['ResultMessage']),
                          ));
                        }
                      },
                      child: Center(
                        child: Text('保存',
                          style: TextStyle(
                              color: Colors.white
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    ));
  }

  Future<Null> getConsumable({String filterText}) async {
    filterText = filterText??'';
    String url;
    if (widget.optional != null && widget.optional) {
      url = "/InvConsumable/QueryConsumableList4PO";
    } else {
      url = "/InvConsumable/QueryConsumableList";
    }
    var resp = await HttpRequest.request(
        url,
        method: HttpRequest.GET,
        params: {
          'filterText': _keywords.text,
          'filterField': field,
          'CurRowNum': offset,
          'FujiClass2ID': _fujiClass2,
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
                                items: widget.optional!=null&&widget.optional?<DropdownMenuItem>[
                                  DropdownMenuItem(
                                    value: 'c.Name',
                                    child: Text('简称'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'c.Description',
                                    child: Text('描述'),
                                  ),
                                ]:<DropdownMenuItem>[
                                  DropdownMenuItem(
                                    value: 'c.Name',
                                    child: Text('简称'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'c.Description',
                                    child: Text('描述'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'ic.ID',
                                    child: Text('系统编号'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'ic.PurchaseID',
                                    child: Text('采购单号'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'ic.LotNum',
                                    child: Text('批次号'),
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
                        Text('富士II类', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),)
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
    setState(() {
      _loading = true;
    });
    getConsumable().then((result) => setState(() {
      _loading = false;
    }));
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
    List<Widget> _list = [];
    if (widget.optional != null && widget.optional) {
      _list.addAll([
        BuildWidget.buildCardRow('富士二类', item['FujiClass2']['Name']),
        BuildWidget.buildCardRow('简称', item['Name']),
        BuildWidget.buildCardRow('描述', item['Description']),
        BuildWidget.buildCardRow('类型', item['Type']['Name']),
        BuildWidget.buildCardRow('更换频次(次/年)', item['ReplaceTimes'].toString()),
        BuildWidget.buildCardRow('单次保养耗材成本(元)', item['CostPer'].toString()),
        BuildWidget.buildCardRow('标准单价(元)', item['StdPrice'].toString()),
        BuildWidget.buildCardRow('是否参与估值', item['IsIncluded']?"是":"否"),
      ]);
    } else {
      _list.addAll([
        BuildWidget.buildCardRow('简称', item['Consumable']['Name']),
        BuildWidget.buildCardRow('描述', item['Consumable']['Description']),
        BuildWidget.buildCardRow('供应商', item['Supplier']['Name']),
        BuildWidget.buildCardRow('富士II类', item['Consumable']['FujiClass2']['Name']),
        BuildWidget.buildCardRow('单价（元）', CommonUtil.CurrencyForm(item['Price'], times: 1, digits: 0)),
        BuildWidget.buildCardRow('购入日期', item['PurchaseDate'].split('T')[0]),
        BuildWidget.buildCardRow('采购单号', item['Purchase']['ID']==0?'':'${item['Purchase']['Name']}'),
        BuildWidget.buildCardRow('可用数量', CommonUtil.CurrencyForm(item['AvaibleQty'], digits: 0, times: 1)),
        BuildWidget.buildCardRow('上次盘点日期', CommonUtil.TimeForm(item['LastestStocktakingDate']??'', 'yyyy-mm-dd')),
      ]);
    }
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
              Icons.battery_full,
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
              widget.optional!=null?"":"批次号：${item['LotNum']}",
              style: new TextStyle(
                  color: Theme.of(context).accentColor
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              children: _list,
            ),
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              //new RaisedButton(
              //  onPressed: (){
              //    Navigator.of(context).push(new MaterialPageRoute(builder: (_) => PrintQrcode(equipmentId: item['ID'], codeType: CodeType.CONSUMABLE,)));
              //  },
              //  shape: RoundedRectangleBorder(
              //    borderRadius: BorderRadius.circular(6),
              //  ),
              //  color: new Color(0xff2E94B9),
              //  child: new Row(
              //    children: <Widget>[
              //      new Icon(
              //        Icons.widgets,
              //        color: Colors.white,
              //      ),
              //      new Text(
              //        '二维码',
              //        style: new TextStyle(
              //            color: Colors.white
              //        ),
              //      )
              //    ],
              //  ),
              //),
              //SizedBox(
              //  width: 20,
              //),
              widget.optional!=null?Container(
                child: RaisedButton(
                  onPressed: () {
                    Navigator.of(context).pop(jsonEncode(item));
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  color: new Color(0xff2E94B9),
                  child: new Row(
                    children: <Widget>[
                      new Icon(
                        Icons.check,
                        color: Colors.white,
                      ),
                      new Text(
                        '选择',
                        style: new TextStyle(
                            color: Colors.white
                        ),
                      )
                    ],
                  ),
                ),
              ):new RaisedButton(
                onPressed: (){
                  Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
                    return new ConsumableDetail(consumable: item, editable: _editable, isStock: false,);
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
          if (widget.optional != null && widget.optional) {
            addConsumable();
          } else {
            Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
              return new ConsumableDetail(editable: true, isStock: false,);
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
          }
        },
        child: Icon(Icons.add_circle),
        backgroundColor: Colors.blue,
      ),
    );
  }
}

