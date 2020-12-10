import 'dart:convert';
import 'dart:developer';

import 'package:atoi/pages/inventory/component_detail.dart';
import 'package:atoi/pages/inventory/consumable_detail.dart';
import 'package:atoi/pages/inventory/service_detail.dart';
import 'package:atoi/pages/inventory/spare_detail.dart';
import 'package:atoi/utils/http_request.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:atoi/models/models.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:date_format/date_format.dart';
import 'package:atoi/utils/common.dart';
import 'package:atoi/utils/constants.dart';
import 'package:atoi/widgets/build_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';

class StocktakingDetail extends StatefulWidget {
  final int stockID;
  final bool editable;
  StocktakingDetail({Key key, this.stockID, this.editable}):super(key: key);
  _StocktakingDetailState createState() => new _StocktakingDetailState();
}

class _StocktakingDetailState extends State<StocktakingDetail> {

  int currentObj = 1;
  List dropObj = [];
  ConstantsModel cModel;
  String scheduledDate;
  TextEditingController remarks = new TextEditingController();
  List<bool> expandList = new List(3).map((item) => true).toList();
  List stockItems = [];
  int stockType = 0;
  String stockName = '';
  int role;
  int stockStatus;
  TextEditingController approveComment = new TextEditingController();
  String barcode;
  FocusNode focusComment = new FocusNode();
  List<FocusNode> focusCards;

  void changeObj(value) {
    setState(() {
      currentObj = value;
    });
  }

  void getRole() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    role = _prefs.getInt('role');
  }

  Future<bool> checkUnique() async {
    Map resp = await HttpRequest.request(
      '/Stocktaking/VerifyUniqueStocktaking',
      method: HttpRequest.POST,
      data: {
        'id': 0,
        'objId': currentObj
      }
    );
    if (resp['ResultCode'] == '00') {
      if (!resp['Data']) {
        showDialog(context: context, builder: (context) => CupertinoAlertDialog(
          title: new Text('当前存在该类型未结束的盘点'),
        ));
        return false;
      } else {
        return true;
      }
    } else {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text(resp['ResultMessage']),
      ));
      return false;
    }
  }

  Future<int> saveStocktaking(int status) async {
    bool result = true;
    if (widget.stockID == null) {
      result = await checkUnique();
    }
    //bool result = true;
    if (result) {
      Map resp = await HttpRequest.request(
        '/Stocktaking/SaveStocktaking',
        method: HttpRequest.POST,
        data: {
          'ID': widget.stockID??0,
          'ObjectType': {
            'ID': currentObj
          },
          'ScheduledDate': scheduledDate,
          'Status': {
            'ID': status
          },
          'Comment': remarks.text
        }
      );
      if (resp['ResultCode'] == '00') {
        showDialog(context: context, builder: (context) => CupertinoAlertDialog(
          title: new Text('保存成功'),
        )).then((result) {
          Navigator.of(context).pop();
          //Navigator.of(context).push(new MaterialPageRoute(builder: (_) => StocktakingDetail(stockID: resp['Data'], editable: true,)));
        });
        return resp['Data'];
      } else {
        showDialog(context: context, builder: (context) => CupertinoAlertDialog(
          title: new Text(resp['ResultMessage']),
        ));
        return 0;
      }
    } else {
      return 0;
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

  void getStockDetailByID() async {
    Map resp = await HttpRequest.request(
      '/Stocktaking/GetStocktakingByID',
      method: HttpRequest.GET,
      params: {
        'id': widget.stockID
      }
    );
    if (resp['ResultCode'] == '00') {
      switch(resp['Data']['ObjectType']['ID']) {
        case 1:
          stockItems = resp['Data']['StComponents'];
          break;
        case 2:
          stockItems = resp['Data']['StConsumables'];
          break;
        case 3:
          stockItems = resp['Data']['StServices'];
          break;
        case 4:
          stockItems = resp['Data']['StSpares'];
          break;
      }
      focusCards = new List(stockItems.length).map((item) {
        return new FocusNode();
      }).toList();
      setState(() {
        stockType = resp['Data']['ObjectType']['ID'];
        stockName = resp['Data']['ObjectType']['Name'];
        stockStatus = resp['Data']['Status']['ID'];
        scheduledDate = CommonUtil.TimeForm(resp['Data']['ScheduledDate'], 'yyyy-mm-dd');
        remarks.text = resp['Data']['Comment'];
      });
    }
  }

  bool checkItemChange() {
    bool hasChanged = false;
    for(int i=0; i<stockItems.length; i++) {
      if (!stockItems[i]['IsInventory'] || (stockType == 1 && stockItems[i]['Status']['ID'] != stockItems[i]['OriginStatus']['ID']) || (stockType == 2 && stockItems[i]['OriginAvaibleQty'] != stockItems[i]['AvaibleQty']) || (stockType ==3 && stockItems[i]['AvaibleTimes'] != stockItems[i]['OriginAvaibleTimes'])) {
        FocusScope.of(context).requestFocus(focusCards[i]);
        if (stockItems[i]['Comments'] == "") {
          hasChanged = true;
        }
      }
    }
    if (hasChanged) {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('备注不可为空'),
      ));
    }
    return hasChanged;
  }

  Future<bool> checkStocktaking(int action) async {
    bool res = checkItemChange();
    if (res) {
      return false;
    }
    Map _data = {
      'action': action,
      'info': {
        'ID': widget.stockID,
        'ObjectType': {
          'ID': stockType
        }
      },
    };
    switch (stockType) {
      case 1:
        _data['info']['StComponents'] = stockItems;
        break;
      case 2:
        _data['info']['StConsumables'] = stockItems;
        break;
      case 3:
        _data['info']['StServices'] = stockItems;
        break;
      case 4:
        _data['info']['StSpares'] = stockItems;
        break;
    }
    Map resp = await HttpRequest.request(
      '/Stocktaking/CheckStocktaking',
      method: HttpRequest.POST,
      data: _data
    );
    if (resp['ResultCode'] == '00') {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> saveStuffToStocktaking(Map info) async {
    info['StocktakingID'] = widget.stockID;
    info['IsInventory'] = true;
    String _url;
    switch (stockType) {
      case 1:
        info['InvComponent'] = {
          'ID': 0
        };
        _url = '/Stocktaking/SaveStComponent';
        break;
      case 2:
        info['InvConsumable'] = {
          'ID': 0
        };
        _url = '/Stocktaking/SaveStConsumable';
        break;
      case 3:
        info['InvService'] = {
          'ID': 0
        };
        _url = '/Stocktaking/SaveStService';
        break;
      case 4:
        info['InvSpare'] = {
          'ID': 0
        };
        _url = '/Stocktaking/SaveStSpare';
    }
    Map resp = await HttpRequest.request(
      _url,
      method: HttpRequest.POST,
      data: {
        'info': info
      }
    );
    if (resp['ResultCode'] == '00') {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> approveStock(int action) async {
    Map resp = await HttpRequest.request(
      '/Stocktaking/ApproveStocktaking',
      method: HttpRequest.POST,
      data: {
        'id': widget.stockID,
        'action': action,
        'comment': approveComment.text
      }
    );
    if (resp['ResultCode'] == '00') {
      return true;
    } else {
      return false;
    }
  }

  void deleteObj(Map item) async {
    Map resp = await HttpRequest.request(
      '/Stocktaking/DeleteStocktakingElement',
      method: HttpRequest.POST,
      data: {
        'id': item['ID'],
        'type': stockType
      }
    );
    if (resp['ResultCode'] == '00') {
      setState(() {
        stockItems.remove(item);
      });
    } else {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('删除失败'),
      ));
      return;
    }
  }

  void setScanStuff() {
    Map decoded = jsonDecode(barcode);
    log('$decoded');
    String stockObject;
    switch (stockType) {
      case 1:
        stockObject = 'InvComponent';
        break;
      case 2:
        stockObject = 'InvConsumable';
        break;
      case 3:
        stockObject = 'InvService';
        break;
      case 4:
        stockObject = 'InvSpare';
        break;
    }
    int index = stockItems.indexWhere((item) => item[stockObject]['ID'] == decoded['id']);
    if (index < 0) {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('盘点清单不存在该物件'),
      ));
      return;
    }
    String scanned = jsonEncode(stockItems[index]);
    stockItems.removeAt(index);
    List reversed = stockItems.reversed.toList();
    reversed.add(jsonDecode(scanned));
    setState(() {
      stockItems = reversed.reversed.toList();
    });
  }

  Future scan() async {
    try {
      String barcode = await BarcodeScanner.scan();
      setState(() {
        return this.barcode = barcode;
      });
      log("$barcode");
      setScanStuff();
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          return this.barcode = 'The user did not grant the camera permission!';
        });
      } else {
        setState(() {
          return this.barcode = 'Unknown error: $e';
        });
      }
    } on FormatException{
      setState(() => this.barcode = 'null (User returned using the "back"-button before scanning anything. Result)');
    } catch (e) {
      setState(() => this.barcode = 'Unknown error: $e');
    }
  }

  void initState() {
    cModel = MainModel.of(context);
    dropObj = cModel.StockingType;
    scheduledDate = formatDate(DateTime.now(), [yyyy,'-',mm,'-',dd]);
    if (widget.stockID != null) {
      getStockDetailByID();
    }
    getRole();
    super.initState();
  }

  Row buildDropdown(String title, int currentItem, List dropdownItems, Function changeDropdown, {bool required}) {
    required = required??false;
    return new Row(
      children: <Widget>[
        new Expanded(
          flex: 4,
          child: new Wrap(
            alignment: WrapAlignment.end,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              required?new Text(
                '*',
                style: new TextStyle(
                    color: Colors.red
                ),
              ):Container(),
              new Text(
                title,
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
          flex: 6,
          child: new DropdownButton(
            value: currentItem,
            items: dropdownItems.map<DropdownMenuItem>((item) {
              return DropdownMenuItem(
                value: item['ID'],
                child: Text(
                  item['Name'],
                  style: TextStyle(
                      fontSize: 12.0
                  ),
                ),
              );
            }).toList(),
            onChanged: changeDropdown,
            style: new TextStyle(
              color: Colors.black54,
              fontSize: 12.0,
            ),
          ),
        )
      ],
    );
  }

  List<Widget> buildStockList() {
    List<Widget> _list = [];
    if (stockItems.length == 0) {
      _list.add(Center(
        child: Text('暂无数据'),
      ));
    } else {
      switch(stockType) {
        case 1:
          List _drops = [
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
          for(int i=0; i<stockItems.length; i++) {
            void _change(value) {
              setState(() {
                stockItems[i]['Status']['ID'] = value;
              });
            }
            void _changeSwitch(value) {
              stockItems[i]['IsInventory'] = value;
              print(stockItems[i]);
            }
            void _editorCallback(value) {
              stockItems[i]['Comments'] = value;
            }
            String _input = stockItems[i]['Comments'];
            _list.add(
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Column(
                      children: <Widget>[
                        BuildWidget.buildCardRow('系统编号', stockItems[i]['InvComponent']['ID']==0?'':stockItems[i]['OID']),
                        BuildWidget.buildCardRow('关联设备', stockItems[i]['Equipment']['Name']),
                        BuildWidget.buildCardRow('零件简称', stockItems[i]['Component']['Name']),
                        BuildWidget.buildCardRow('序列号', stockItems[i]['SerialCode']),
                        BuildWidget.buildCardRow('规格', stockItems[i]['Specification']),
                        BuildWidget.buildCardRow('型号', stockItems[i]['Model']),
                        BuildWidget.buildCardRow('供应商', stockItems[i]['Supplier']['Name']),
                        BuildWidget.buildCardRow('采购单号', stockItems[i]['Purchase']['ID']==0?'':stockItems[i]['Purchase']['Name']),
                        BuildWidget.buildCardRow('购入日期', formatDate(DateTime.tryParse(stockItems[i]['PurchaseDate']), [yyyy, '-', mm, '-', dd])),
                        widget.editable?BuildWidget.buildCardDropdown('状态', stockItems[i]['Status']['ID'], _drops, _change):BuildWidget.buildCardRow('状态', stockItems[i]['Status']['Name']),
                        widget.editable?BuildWidget.buildCardSwitch('是否在库', _changeSwitch, initValue: stockItems[i]['IsInventory']):BuildWidget.buildCardRow('是否在库', stockItems[i]['IsInventory']?'是':'否'),
                        widget.editable?BuildWidget.buildCardInputStock('备注', _input, callback: _editorCallback, maxLength: 500, focus: focusCards[i]):BuildWidget.buildCardRow('备注', _input),
                        widget.editable?Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            IconButton(
                              icon: Icon(Icons.delete_forever, color: Colors.red,),
                              onPressed: () {
                                showDialog(context: context, builder: (context) => CupertinoAlertDialog(
                                  title: Text('是否删除此盘点对象？'),
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
                                        deleteObj(stockItems[i]);
                                      },
                                      child: Text(
                                          '确认'
                                      ),
                                    ),
                                  ],
                                ));
                              },
                            )
                          ],
                        ):Container()
                      ],
                    ),
                  ),
                )
            );
            _list.add(SizedBox(height: 5.0,));
          }
          break;
        case 2:
          for (int i=0; i<stockItems.length; i++) {
            void _changeSwitch(value) {
              stockItems[i]['IsInventory'] = value;
            }
            void _editorQty(value) {
              stockItems[i]['AvaibleQty'] = value;
            }
            void _editorComment(value) {
              stockItems[i]['Comments'] = value;
            }
            _list.add(
              Card(
                child: Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Column(
                    children: <Widget>[
                      BuildWidget.buildCardRow('系统编号', stockItems[i]['InvConsumable']['ID']==0?'':stockItems[i]['OID']),
                      BuildWidget.buildCardRow('富士II类', stockItems[i]['FujiClass2']['Name']),
                      BuildWidget.buildCardRow('耗材简称', stockItems[i]['Consumable']['Name']),
                      BuildWidget.buildCardRow('批次号', stockItems[i]['LotNum']),
                      BuildWidget.buildCardRow('规格', stockItems[i]['Specification']),
                      BuildWidget.buildCardRow('型号', stockItems[i]['Model']),
                      BuildWidget.buildCardRow('单位', stockItems[i]['Unit']),
                      BuildWidget.buildCardRow('供应商', stockItems[i]['Supplier']['Name']),
                      BuildWidget.buildCardRow('采购单号', stockItems[i]['Purchase']['ID']==0?'':stockItems[i]['Purchase']['Name']),
                      BuildWidget.buildCardRow('购入日期', stockItems[i]['OID']),
                      widget.editable?BuildWidget.buildCardInputStock('可用数量', stockItems[i]['AvaibleQty'].toString(), callback: _editorQty, maxLength: 13, inputType: TextInputType.numberWithOptions(decimal: false)):BuildWidget.buildCardRow('可用数量', stockItems[i]['AvaibleQty'].toString()),
                      widget.editable?BuildWidget.buildCardSwitch('是否在库', _changeSwitch, initValue: stockItems[i]['IsInventory']):BuildWidget.buildCardRow('是否在库', stockItems[i]['IsInventory']?'是':'否'),
                      widget.editable?BuildWidget.buildCardInputStock('备注', stockItems[i]['Comments'].toString(), callback: _editorComment, maxLength: 500, focus: focusCards[i]):BuildWidget.buildCardRow('备注', stockItems[i]['Comments'].toString()),
                      widget.editable?Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.delete_forever, color: Colors.red,),
                            onPressed: () {
                              showDialog(context: context, builder: (context) => CupertinoAlertDialog(
                                title: Text('是否删除此盘点对象？'),
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
                                      deleteObj(stockItems[i]);
                                    },
                                    child: Text(
                                        '确认'
                                    ),
                                  ),
                                ],
                              ));
                            },
                          )
                        ],
                      ):Container()
                    ],
                  ),
                ),
              ),
            );
            _list.add(SizedBox(height: 5.0,));
          }
          break;
        case 3:
          for (int i=0; i<stockItems.length; i++) {
            void _changeSwitch(value) {
              stockItems[i]['IsInventory'] = value;
            }
            void _editorTimes(value) {
              stockItems[i]['AvaibleTimes'] = value;
            }
            void _editorComment(value) {
              stockItems[i]['Comments'] = value;
            }
            _list.add(
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Column(
                      children: <Widget>[
                        BuildWidget.buildCardRow('系统编号', stockItems[i]['InvService']['ID']==0?'':stockItems[i]['OID']),
                        BuildWidget.buildCardRow('服务名称', stockItems[i]['Name']),
                        BuildWidget.buildCardRow('富士II类', stockItems[i]['FujiClass2']['Name']),
                        BuildWidget.buildCardRow('起止时间', '${CommonUtil.TimeForm(stockItems[i]['StartDate'], 'yyyy-mm-dd')} - ${CommonUtil.TimeForm(stockItems[i]['EndDate'], 'yyyy-mm-dd')}'),
                        BuildWidget.buildCardRow('供应商', stockItems[i]['Supplier']['Name']),
                        BuildWidget.buildCardRow('采购单号', stockItems[i]['Purchase']['ID']==0?'':stockItems[i]['Purchase']['Name']),
                        widget.editable?BuildWidget.buildCardInputStock('剩余服务次数', stockItems[i]['AvaibleTimes'].toString(), callback: _editorTimes, inputType: TextInputType.numberWithOptions(decimal: false), maxLength: 9):BuildWidget.buildCardRow('剩余服务次数', stockItems[i]['AvaibleTimes'].toString()),
                        widget.editable?BuildWidget.buildCardSwitch('是否在库', _changeSwitch, initValue: stockItems[i]['IsInventory']):BuildWidget.buildCardRow('是否在库', stockItems[i]['IsInventory']?'是':'否'),
                        widget.editable?BuildWidget.buildCardInputStock('备注', stockItems[i]['Comments'].toString(), callback: _editorComment, maxLength: 500, focus: focusCards[i]):BuildWidget.buildCardRow('备注', stockItems[i]['Comments'].toString()),
                        widget.editable?Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            IconButton(
                              icon: Icon(Icons.delete_forever, color: Colors.red,),
                              onPressed: () {
                                showDialog(context: context, builder: (context) => CupertinoAlertDialog(
                                  title: Text('是否删除此盘点对象？'),
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
                                        deleteObj(stockItems[i]);
                                      },
                                      child: Text(
                                          '确认'
                                      ),
                                    ),
                                  ],
                                ));
                              },
                            )
                          ],
                        ):Container()
                      ],
                    ),
                  ),
                )
            );
            _list.add(SizedBox(height: 5.0,));
          }
          break;
        case 4:
          for (int i=0; i<stockItems.length; i++) {
            void _changeSwitch(value) {
              setState(() {
                stockItems[i]['IsInventory'] = value;
              });
            }
            void _editorComment(value) {
              stockItems[i]['Comments'] = value;
            }
            _list.add(
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Column(
                      children: <Widget>[
                        BuildWidget.buildCardRow('系统编号', stockItems[i]['InvSpare']['ID']==0?'':stockItems[i]['OID']),
                        BuildWidget.buildCardRow('序列号', stockItems[i]['SerialCode']),
                        BuildWidget.buildCardRow('富士II类', stockItems[i]['FujiClass2']['Name']),
                        BuildWidget.buildCardRow('设备名称', stockItems[i]['Name']),
                        BuildWidget.buildCardRow('型号', stockItems[i]['Model']),
                        BuildWidget.buildCardRow('厂家', stockItems[i]['Manufacturer']),
                        BuildWidget.buildCardRow('起止时间', '${CommonUtil.TimeForm(stockItems[i]['StartDate'], 'yyyy-mm-dd')} - ${CommonUtil.TimeForm(stockItems[i]['EndDate'], 'yyyy-mm-dd')}'),
                        BuildWidget.buildCardRow('使用状态', stockItems[i]['IsInventory']?'备用':'在库'),
                        widget.editable?BuildWidget.buildCardSwitch('是否在库', _changeSwitch, initValue: stockItems[i]['IsInventory']):BuildWidget.buildCardRow('是否在库', stockItems[i]['IsInventory']?'是':'否'),
                        widget.editable?BuildWidget.buildCardInputStock('备注', stockItems[i]['Comments'].toString(), callback: _editorComment, maxLength: 500, focus: focusCards[i]):BuildWidget.buildCardRow('备注', stockItems[i]['Comments'].toString()),
                        widget.editable?Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            IconButton(
                              icon: Icon(Icons.delete_forever, color: Colors.red,),
                              onPressed: () {
                                showDialog(context: context, builder: (context) => CupertinoAlertDialog(
                                  title: Text('是否删除此盘点对象？'),
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
                                        deleteObj(stockItems[i]);
                                      },
                                      child: Text(
                                          '确认'
                                      ),
                                    ),
                                  ],
                                ));
                              },
                            )
                          ],
                        ):Container()
                      ],
                    ),
                  ),
                )
            );
            _list.add(SizedBox(height: 5.0,));
          }
          break;
      }
    }
    return _list;
  }

  List<ExpansionPanel> buildExpansion() {
    List<ExpansionPanel> _list = [];
    _list.add(
      new ExpansionPanel(canTapOnHeader: true,
        headerBuilder: (context, isExpanded) {
          return ListTile(
            leading: new Icon(
              Icons.description,
              size: 24.0,
              color: Colors.blue,
            ),
            title: Text(
              '基本信息',
              style: new TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w400),
            ),
          );
        },
        body: new Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.0),
          child: new Column(
            children: <Widget>[
              widget.stockID==null||stockStatus==1?buildDropdown('盘点对象', currentObj, dropObj, changeObj):BuildWidget.buildRow('盘点对象', stockName),
              new Padding(
                padding: EdgeInsets.symmetric(vertical: 5.0),
                child: widget.stockID==null||stockStatus==1?new Row(
                  children: <Widget>[
                    new Expanded(
                      flex: 4,
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
                            '计划日期',
                            style: new TextStyle(
                                fontSize: 16.0, fontWeight: FontWeight.w600),
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
                      flex: 4,
                      child: new Text(
                        scheduledDate,
                        style: new TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w400,
                            color: Colors.black54
                        ),
                      ),
                    ),
                    new Expanded(
                      flex: 2,
                      child: new IconButton(
                          icon: Icon(Icons.calendar_today, color: AppConstants.AppColors['btn_main'],),
                          onPressed: () async {
                            FocusScope.of(context).requestFocus(new FocusNode());
                            var _time = DateTime.tryParse(scheduledDate)??DateTime.now();
                            DatePicker.showDatePicker(
                              context,
                              pickerTheme: DateTimePickerTheme(
                                showTitle: true,
                                confirm: Text('确认', style: TextStyle(color: Colors.blueAccent)),
                                cancel: Text('取消', style: TextStyle(color: Colors.redAccent)),
                              ),
                              minDateTime: DateTime.now().add(Duration(days: -7300)),
                              maxDateTime: DateTime.parse('2030-01-01'),
                              initialDateTime: _time,
                              dateFormat: 'yyyy-MM-dd',
                              locale: DateTimePickerLocale.en_us,
                              onClose: () => print(""),
                              onCancel: () => print('onCancel'),
                              onChange: (dateTime, List<int> index) {
                              },
                              onConfirm: (dateTime, List<int> index) {
                                var _date = formatDate(dateTime, [yyyy, '-', mm, '-', dd]);
                                setState(() {
                                  scheduledDate = _date;
                                });
                              },
                            );
                          }),
                    ),
                  ],
                ):BuildWidget.buildRow('计划日期', scheduledDate),
              ),
              widget.stockID==null||stockStatus==1?BuildWidget.buildInput("备注", remarks, maxLength: 255, lines: 3):BuildWidget.buildRow('备注', remarks.text)
            ],
          ),
        ),
        isExpanded: expandList[0],
      ),
    );
    if (stockStatus!=null && stockStatus > 1) {
      _list.add(
        ExpansionPanel(
            canTapOnHeader: true,
            headerBuilder: (context, isExpanded) {
              return ListTile(
                  leading: new Icon(
                    Icons.description,
                    size: 24.0,
                    color: Colors.blue,
                  ),
                  title: Row(
                    children: <Widget>[
                      Text(
                        stockName,
                        style: new TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w400),
                      ),
                      widget.editable?IconButton(
                        icon: Icon(Icons.add_circle, color: Colors.blueAccent,),
                        onPressed: () {
                          switch (stockType) {
                            case 1:
                              Navigator.of(context).push(new MaterialPageRoute(builder: (_) => ComponentDetail(editable: true, isStock: true,))).then((result) async {
                                if (result != null) {
                                  Map _info = jsonDecode(result);
                                  int index = stockItems.indexWhere((item) => item['SerialCode'] == _info['SerialCode']);
                                  if (index > -1) {
                                    showDialog(context: context, builder: (context) => CupertinoAlertDialog(
                                      title: new Text('相同零件序列号已在盘点列表中'),
                                    ));
                                  }
                                  bool save = await saveStuffToStocktaking(_info);
                                  if (save) {
                                    getStockDetailByID();
                                    showDialog(context: context, builder: (context) => CupertinoAlertDialog(
                                      title: new Text('添加成功'),
                                    ));
                                  }
                                }
                              });
                              break;
                            case 2:
                              Navigator.of(context).push(new MaterialPageRoute(builder: (_) => ConsumableDetail(editable: true, isStock: true,))).then((result) async {
                                if (result != null){
                                  Map _info = jsonDecode(result);
                                  int ind = stockItems.indexWhere((item) => item['LotNum']==_info['LotNum'] || item['Consumable']['ID']==_info['Consumable']['ID']);
                                  if (ind > -1) {
                                    showDialog(context: context, builder: (context) => CupertinoAlertDialog(
                                      title: new Text('耗材已在库中'),
                                    ));
                                  }
                                  bool save = await saveStuffToStocktaking(_info);
                                  if (save) {
                                    getStockDetailByID();
                                    showDialog(context: context, builder: (context) => CupertinoAlertDialog(
                                      title: new Text('添加成功'),
                                    ));
                                  }
                                }
                              });
                              break;
                            case 3:
                              Navigator.of(context).push(new MaterialPageRoute(builder: (_) => ServiceDetail(editable: true, isStock: true, date: scheduledDate,))).then((result) async {
                                if (result != null) {
                                  Map _info = jsonDecode(result);
                                  bool save = await saveStuffToStocktaking(_info);
                                  if (save) {
                                    getStockDetailByID();
                                    showDialog(context: context, builder: (context) => CupertinoAlertDialog(
                                      title: new Text('添加成功'),
                                    ));
                                  }
                                }
                              });
                              break;
                            case 4:
                              Navigator.of(context).push(new MaterialPageRoute(builder: (_) => SpareDetail(editable: true, isStock: true,))).then((result) async {
                                if (result != null) {
                                  Map _info = jsonDecode(result);
                                  int ind = stockItems.indexWhere((item) => item['FujiClass2']['ID']==_info['FujiClass2']['ID']||item['StartDate']==_info['StartDate']);
                                  if (ind > -1) {
                                    showDialog(context: context, builder: (context) => CupertinoAlertDialog(
                                      title: new Text('备用机已在库中'),
                                    ));
                                  }
                                  bool save = await saveStuffToStocktaking(_info);
                                  if (save) {
                                    getStockDetailByID();
                                    showDialog(context: context, builder: (context) => CupertinoAlertDialog(
                                      title: new Text('添加成功'),
                                    ));
                                  }
                                }
                              });
                              break;
                          }
                        },
                      ):Container(),
                      widget.editable?IconButton(
                        onPressed: () {
                          scan();
                        },
                        icon: Icon(Icons.crop_free, color: Colors.blueAccent,),
                      ):Container(),
                    ],
                  )
              );
            },
            body: GestureDetector(
              onTap: () {
                print("list tap");
                FocusNode currentFocus = FocusScope.of(context);
                currentFocus.unfocus();
              },
              child: Column(
                children: focusCards==null?[]:buildStockList(),
              ),
            ),
            isExpanded: expandList[1]
        ),
      );
    }
    return _list;
  }

  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (context, child, mainModel) {
        return new Scaffold(
            appBar: new AppBar(
              title: Text('盘点'),
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
              actions: <Widget>[],
            ),
            body: new Padding(
              padding: EdgeInsets.symmetric(vertical: 5.0),
              child: new Card(
                child: new ListView(
                  children: <Widget>[
                    new ExpansionPanelList(
                      animationDuration: Duration(milliseconds: 200),
                      expansionCallback: (index, isExpanded) {
                        setState(() {
                          expandList[index] = !isExpanded;
                        });
                      },
                      children: buildExpansion(),
                    ),
                    SizedBox(height: 24.0),
                    widget.editable&&role==1?BuildWidget.buildInput('审批备注', approveComment, focusNode: focusComment):Container(),
                    widget.editable&&role==2?Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        RaisedButton(
                          onPressed: () async {
                            if (widget.stockID == null || stockStatus < 2) {
                              saveStocktaking(1);
                            } else {
                              bool res = await checkStocktaking(1);
                              if (res) {
                                showDialog(context: context, builder: (context) => CupertinoAlertDialog(
                                  title: new Text('保存成功'),
                                )).then((result) => Navigator.of(context).pop());
                              } else {
                                showDialog(context: context, builder: (context) => CupertinoAlertDialog(
                                  title: new Text('保存失败'),
                                ));
                              }
                            }
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          color: Color(0xff2E94B9),
                          child: Text('保存', style: TextStyle(color: Colors.white),),
                        ),
                        RaisedButton(
                          onPressed: () async {
                            if (widget.stockID == null) {
                              int stockID = await saveStocktaking(1);
                              if (stockID != 0) {
                                bool result = await startStocktaking(stockID);
                                if (result) {
                                  Navigator.of(context).push(new MaterialPageRoute(builder: (_) => new StocktakingDetail(stockID: stockID, editable: true,)));
                                }
                              }
                            } else {
                              bool res = await checkStocktaking(2);
                              if (res) {
                                showDialog(context: context, builder: (context) => CupertinoAlertDialog(
                                  title: new Text('提交成功'),
                                )).then((result) => Navigator.of(context).pop());
                              } else {
                                showDialog(context: context, builder: (context) => CupertinoAlertDialog(
                                  title: new Text('提交失败'),
                                ));
                              }
                            }
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          color: Color(0xff2E94B9),
                          child: Text((widget.stockID==null||stockStatus<2)?'开始盘点':'提交', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ):Container(),
                    widget.editable&&role==1?Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        RaisedButton(
                          onPressed: () async {
                            bool res = await checkStocktaking(1);
                            if (res) {
                              //if (approveComment.text.isEmpty) {
                              //  showDialog(context: context, builder: (context) => CupertinoAlertDialog(
                              //    title: new Text('备注不可为空'),
                              //  ));
                              //  return;
                              //}
                              bool resp = await approveStock(3);
                              if (resp) {
                                showDialog(context: context, builder: (context) => CupertinoAlertDialog(
                                  title: new Text('已同步'),
                                )).then((result) => Navigator.of(context).pop());
                              } else {
                                showDialog(context: context, builder: (context) => CupertinoAlertDialog(
                                  title: new Text('同步失败'),
                                ));
                              }
                            }
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          color: Color(0xff2E94B9),
                          child: Text('同步', style: TextStyle(color: Colors.white),),
                        ),
                        RaisedButton(
                          onPressed: () async {
                            bool res = await checkStocktaking(1);
                            if (res) {
                              if (approveComment.text.isEmpty) {
                                showDialog(context: context, builder: (context) => CupertinoAlertDialog(
                                  title: new Text('审批备注不可为空'),
                                )).then((result) => FocusScope.of(context).requestFocus(focusComment));
                                return;
                              }
                              bool resp = await approveStock(4);
                              if (resp) {
                                showDialog(context: context, builder: (context) => CupertinoAlertDialog(
                                  title: new Text('已退回'),
                                )).then((result) => Navigator.of(context).pop());
                              } else {
                                showDialog(context: context, builder: (context) => CupertinoAlertDialog(
                                  title: new Text('退回失败'),
                                ));
                              }
                            }
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          color: Color(0xff2E94B9),
                          child: Text('退回', style: TextStyle(color: Colors.white),),
                        ),
                      ],
                    ):Container()
                  ],
                ),
              ),
            )
        );
      },
    );
  }
}