import 'package:atoi/pages/inventory/stocktaking_detail.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:atoi/models/models.dart';
import 'package:atoi/utils/http_request.dart';
import 'package:atoi/widgets/build_widget.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:flutter/cupertino.dart';

class StocktakingList extends StatefulWidget {

  _StocktakingListState createState() => new _StocktakingListState();
}

class _StocktakingListState extends State<StocktakingList> {

  List<dynamic> _stock = [];

  bool isSearchState = false;
  bool _loading = false;
  bool _editable = true;

  TextEditingController _keywords = new TextEditingController();
  String field = 'u.Name';
  int _status = 0;
  List _statusList = [];
  int _type = 0;
  List _typeList = [];
  Future<SharedPreferences> prefs = SharedPreferences.getInstance();
  ConstantsModel cModel;
  ScrollController _scrollController = new ScrollController();
  int offset = 0;
  bool _noMore = false;
  int role;
  int userID;
  DateTime today = new DateTime.now();
  String beginDate = '';
  String endDate = '';

  Future<Null> getRole() async {
    var _prefs = await prefs;
    role = _prefs.getInt('role');
    _editable = role==1;
    userID = _prefs.getInt('userID');
  }

  void setFilter() {
    setState(() {
      offset = 0;
      _stock.clear();
    });
    getStock();
  }

  List initList(List _map) {
    List _list = [];
    _list.add({
      'value': 0,
      'text': '全部'
    });
    _list.addAll(_map.map((item) {
      return {
        'value': item['ID'],
        'text': item['Name']
      };
    }).toList());
    return _list;
  }

  void initFilter() async {
    await cModel.getConstants();
    _typeList = initList(cModel.StockingType);
    _statusList = initList(cModel.StockingStatus);
    setState(() {
      field = 'u.Name';
      _keywords.clear();
      beginDate = '';
      endDate = '';
    });
  }

  Future<Null> getStock({String filterText}) async {
    filterText = filterText??'';
    var resp = await HttpRequest.request(
        '/Stocktaking/QueryStocktakingList',
        method: HttpRequest.GET,
        params: {
          'filterText': _keywords.text,
          'filterField': field,
          'status': _status,
          'type': _type,
          'beginDate': beginDate,
          'endDate': endDate,
          'curRowNum': offset,
          'PageSize': 10,
          'field': 'st.ID',
          'direction': true
        }
    );
    if (resp['ResultCode'] == '00') {
      setState(() {
        _stock.addAll(resp['Data']);
      });
    }
  }

  void terminateStock(int stockID) async {
    Map resp = await HttpRequest.request(
      '/Stocktaking/TerminateStocktaking',
      method: HttpRequest.POST,
      data: {
        'id': stockID
      }
    );
    if (resp['ResultCode'] == '00') {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('终止成功'),
      )).then((result) {
        initFilter();
        offset = 0;
        _stock.clear();
        getStock();
      });
    }
  }

  Future<bool> startStocktaking(int stockID) async {
    Map resp = await HttpRequest.request(
        '/Stocktaking/StartStocktaking',
        method: HttpRequest.POST,
        data: {
          'id': stockID
        }
    );
    if (resp['ResultCode'] == '00') {
      return true;
    } else {
      return false;
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
                                    value: 'u.Name',
                                    child: Text('请求人'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'st.ID',
                                    child: Text('系统编号'),
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
                                  value: _status,
                                  underline: Container(),
                                  items: _statusList.map<DropdownMenuItem>((item) {
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
                                      _status = val;
                                    });
                                  },
                                )
                              ],
                            )
                        ),
                      ],
                    ),
                    SizedBox(height: 18.0,),
                    Row(
                      children: <Widget>[
                        SizedBox(width: 16.0,),
                        Text('盘点对象', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),)
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
                                  value: _type,
                                  underline: Container(),
                                  items: _typeList.map<DropdownMenuItem>((item) {
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
                                      _type = val;
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
                      children: <Widget>[
                        SizedBox(width: 16.0,),
                        Text('请求日期', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),)
                      ],
                    ),
                    SizedBox(height: 6.0,),
                    Row(
                      children: <Widget>[
                        SizedBox(width: 16.0,),
                        Container(
                          width: 116.0,
                          height: 40.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0),
                            color: Color(0xfff2f2f2),
                          ),
                          child: Center(
                            child: FlatButton(
                                onPressed: () {
                                  FocusScope.of(context).requestFocus(new FocusNode());
                                  DatePicker.showDatePicker(
                                    context,
                                    pickerTheme: DateTimePickerTheme(
                                      showTitle: true,
                                      confirm: Text('确认', style: TextStyle(color: Colors.blueAccent)),
                                      cancel: Text('取消', style: TextStyle(color: Colors.redAccent)),
                                    ),
                                    minDateTime: DateTime.parse('2000-01-01'),
                                    maxDateTime: DateTime.parse('2030-01-01'),
                                    initialDateTime: DateTime.tryParse(beginDate)??DateTime.now(),
                                    dateFormat: 'yyyy-MM-dd',
                                    locale: DateTimePickerLocale.en_us,
                                    onClose: () => print(""),
                                    onCancel: () => print('onCancel'),
                                    onChange: (dateTime, List<int> index) {
                                    },
                                    onConfirm: (dateTime, List<int> index) {
                                      setState(() {
                                        beginDate = formatDate(dateTime, [yyyy,'-', mm, '-', dd]);
                                      });
                                    },
                                  );
                                },
                                child: Text(beginDate, style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12.0),)
                            ),
                          ),
                        ),
                        Text('   -   '),
                        Container(
                          width: 116.0,
                          height: 40.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0),
                            color: Color(0xfff2f2f2),
                          ),
                          child: Center(
                            child: FlatButton(
                                onPressed: () {
                                  FocusScope.of(context).requestFocus(new FocusNode());
                                  DatePicker.showDatePicker(
                                    context,
                                    pickerTheme: DateTimePickerTheme(
                                      showTitle: true,
                                      confirm: Text('确认', style: TextStyle(color: Colors.blueAccent)),
                                      cancel: Text('取消', style: TextStyle(color: Colors.redAccent)),
                                    ),
                                    minDateTime: DateTime.parse('2000-01-01'),
                                    maxDateTime: DateTime.parse('2030-01-01'),
                                    initialDateTime: DateTime.tryParse(endDate)??DateTime.now(),
                                    dateFormat: 'yyyy-MM-dd',
                                    locale: DateTimePickerLocale.en_us,
                                    onClose: () => print(""),
                                    onCancel: () => print('onCancel'),
                                    onChange: (dateTime, List<int> index) {
                                    },
                                    onConfirm: (dateTime, List<int> index) {
                                      setState(() {
                                        endDate = formatDate(dateTime, [yyyy,'-', mm, '-', dd]);
                                      });
                                    },
                                  );
                                },
                                child: Text(endDate, style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12.0),)
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.0,),
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
                          _status = 0;
                          field = 'u.Name';
                          _type = 0;
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
    getStock().then((result) => setState(() {
      _loading = false;
    }));
    getRole();
    beginDate = formatDate(DateTime.now(), [yyyy, '-', mm, '-', dd]);
    endDate = formatDate(DateTime.now(), [yyyy, '-', mm, '-', dd]);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        var _length = _stock.length;
        offset += 10;
        getStock().then((result) {
          if (_stock.length == _length) {
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
              Navigator.of(context).push(new MaterialPageRoute(builder: (context) => StocktakingDetail(stockID: item['ID'], editable: false,)));
            },
            leading: Icon(
              Icons.playlist_add_check,
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
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              children: <Widget>[
                BuildWidget.buildCardRow('请求人', item['User']['Name']),
                BuildWidget.buildCardRow('盘点对象', item['ObjectType']['Name']),
                BuildWidget.buildCardRow('请求日期', item['CreatedDate'].split('T')[0]),
                BuildWidget.buildCardRow('计划日期', item['ScheduledDate'].split('T')[0]),
                BuildWidget.buildCardRow('状态', item['Status']['Name']),
              ],
            ),
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              (item['Status']['ID']==2||item['Status']['ID']==1)&&userID==item['User']['ID']&&role==2?new RaisedButton(
                onPressed: () async {
                  if (item['Status']['ID'] == 1) {
                    bool res = await startStocktaking(item['ID']);
                    if (!res) {
                      return;
                    }
                  }
                  Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
                    return new StocktakingDetail(stockID: item['ID'], editable: true,);
                  })).then((result) {
                    setState(() {
                      offset = 0;
                      _stock.clear();
                      beginDate = '';
                      endDate = '';
                    });
                    getStock();
                  });
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                color: new Color(0xff2E94B9),
                child: new Row(
                  children: <Widget>[
                    new Icon(
                      Icons.playlist_add_check,
                      color: Colors.white,
                    ),
                    new Text(
                      '盘点',
                      style: new TextStyle(
                          color: Colors.white
                      ),
                    ),
                  ],
                ),
              ):Container(),
              (item['Status']['ID']==2||item['Status']['ID']==1)&&userID==item['User']['ID']&&role==2?SizedBox(width: 40,):Container(),
              item['Status']['ID']==1&&role==2?RaisedButton(
                onPressed: () {
                  Navigator.of(context).push(new MaterialPageRoute(builder: (_) => new StocktakingDetail(stockID: item['ID'], editable: true,))).then((result) {
                    beginDate = '';
                    endDate = '';
                    offset = 0;
                    _stock.clear();
                    getStock();
                  });
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                color: new Color(0xff2E94B9),
                child: new Row(
                  children: <Widget>[
                    new Icon(
                      Icons.edit,
                      color: Colors.white,
                    ),
                    new Text(
                      '编辑',
                      style: new TextStyle(
                          color: Colors.white
                      ),
                    ),
                  ],
                ),
              ):Container(),
              item['Status']['ID']==3&&role==1?RaisedButton(
                onPressed: () {
                  Navigator.of(context).push(new MaterialPageRoute(builder: (_) => new StocktakingDetail(stockID: item['ID'], editable: true,))).then((result) {
                    beginDate = '';
                    endDate = '';
                    offset = 0;
                    _stock.clear();
                    getStock();
                  });
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                color: new Color(0xff2E94B9),
                child: new Row(
                  children: <Widget>[
                    new Icon(
                      Icons.remove_red_eye,
                      color: Colors.white,
                    ),
                    new Text(
                      '审批',
                      style: new TextStyle(
                          color: Colors.white
                      ),
                    ),
                  ],
                ),
              ):Container(),
              item['Status']['ID']>=0&&item['Status']['ID']<=3&&role==1?RaisedButton(
                onPressed: () {
                  showDialog(context: context, builder: (context) => CupertinoAlertDialog(
                    title: Text('是否终止盘点？'),
                    actions: <Widget>[
                      CupertinoDialogAction(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                            '取消'
                        ),
                      ),
                      CupertinoDialogAction(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          terminateStock(item['ID']);
                        },
                        child: Text(
                            '确认'
                        ),
                      ),
                    ],
                  ));
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                color: new Color(0xff2E94B9),
                child: new Row(
                  children: <Widget>[
                    new Icon(
                      Icons.indeterminate_check_box,
                      color: Colors.white,
                    ),
                    new Text(
                      '终止',
                      style: new TextStyle(
                          color: Colors.white
                      ),
                    ),
                  ],
                ),
              ):Container(),
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
            getStock(filterText: val);
          },
        ):Text('库存盘点列表'),
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
      body: _loading?new Center(child: new SpinKitThreeBounce(color: Colors.blue,),):(_stock.length==0?Center(child: Text('无待盘点库存'),):new ListView.builder(
        itemCount: _stock.length>10?_stock.length+1:_stock.length,
        controller: _scrollController,
        itemBuilder: (context, i) {
          if (i !=_stock.length) {
            return buildEquipmentCard(_stock[i]);
          } else {
            return new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _noMore?new Center(child: new Text('没有更多待盘点库存'),):new SpinKitChasingDots(color: Colors.blue,)
              ],
            );
          }
        },
      )),
      floatingActionButton: role==2?FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
            return new StocktakingDetail(editable: true,);
          })).then((result) {
            setState(() {
              offset = 0;
              _stock.clear();
              beginDate = '';
              endDate = '';
            });
            getStock();
          });
        },
        child: Icon(Icons.add_circle),
        backgroundColor: Colors.blue,
      ):Container(),
    );
  }
}
