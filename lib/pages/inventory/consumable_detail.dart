import 'package:atoi/pages/inventory/consumable_list.dart';
import 'package:atoi/utils/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:atoi/models/models.dart';
import 'package:scoped_model/scoped_model.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:atoi/utils/http_request.dart';
import 'package:atoi/widgets/build_widget.dart';
import 'package:atoi/widgets/search_lazy.dart';
import 'package:atoi/utils/event_bus.dart';
import 'dart:convert';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:atoi/utils/constants.dart';
import 'package:date_format/date_format.dart';

/// 耗材详情页
class ConsumableDetail extends StatefulWidget {
  ConsumableDetail({Key key, this.consumable, this.editable, this.isStock}) : super(key: key);
  final Map consumable;
  final bool editable;
  final bool isStock;
  _ConsumableDetailState createState() => new _ConsumableDetailState();
}

class _ConsumableDetailState extends State<ConsumableDetail> {
  var _isExpandedDetail = true;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  String oid = '系统自动生成';
  EventBus bus = new EventBus();
  Map manufacturer;
  Map supplier;
  String purchaseDate = 'YYYY-MM-DD';
  int _fujiClass2 = 0;
  String _fujiClass2Name;
  List _fujiList = [];
  String purchaseNumber = '';

  int _consumable;
  String _consumableName;
  List _consumableList = [];
  ScrollController scrollController = new ScrollController();

  ConstantsModel cModel;

  TextEditingController lotNum = new TextEditingController(), spec = new TextEditingController(), model = new TextEditingController(), price = new TextEditingController(), quantity = new TextEditingController(), comments = new TextEditingController(),
  availableQty = new TextEditingController(), unit = new TextEditingController();

  void initState() {
    super.initState();
    if (widget.consumable != null) {
      getConsumable();
    }
    cModel = MainModel.of(context);
    initFuji();
  }

  void initFuji() {
    cModel.getConstants();
    List _list = [];
    _list.add({
      'value': 0,
      'text': ''
    });
    _list.addAll(cModel.FujiClass2.map((item) {
      return {
        'value': item['ID'],
        'text': item['Name']
      };
    }).toList());
    setState(() {
      _fujiList = _list;
    });
  }

  void changeFuji(value) {
    FocusScope.of(context).requestFocus(new FocusNode());
    setState(() {
      _fujiClass2 = value;
    });
    getConsumableByFuji(value);
  }

  void changeConsumable(value) {
    FocusScope.of(context).requestFocus(new FocusNode());
    setState(() {
      _consumable = value;
    });
  }

  void getConsumableByFuji(int fujiClass) async {
    Map resp = await HttpRequest.request(
      '/InvConsumable/QueryConsumablesByFujiClass2ID',
      method: HttpRequest.GET,
      params: {
        'fujiClass2Id': fujiClass
      }
    );
    if (resp['ResultCode'] == '00') {
      List _data = resp['Data'];
      _consumableList = _data.map((item) {
        return {
          'value': item['ID'],
          'text': item['Name']
        };
      }).toList();
      setState(() {
        _consumableList = _consumableList;
      });
    }
  }

  Future<Null> getConsumable() async {
    var resp = await HttpRequest.request('/InvConsumable/GetConsumableByID',
        method: HttpRequest.GET, params: {'consumableID': widget.consumable['ID']});
    if (resp['ResultCode'] == '00') {
      var _data = resp['Data'];
      setState(() {
        oid = _data['OID'];
        _fujiClass2 = _data['Consumable']['FujiClass2']['ID'];
        _fujiClass2Name = _data['Consumable']['FujiClass2']['Name'];
        _consumable = _data['Consumable']['ID'];
        _consumableName = _data['Consumable']['Name'];
        lotNum.text = _data['LotNum'];
        spec.text = _data['Specification'];
        model.text = _data['Model'];
        unit.text = _data['Unit'];
        price.text = _data['Price'].toString();
        quantity.text = _data['ReceiveQty'].toStringAsFixed(0);
        comments.text = _data['Comments'];
        availableQty.text = _data['AvaibleQty'].toStringAsFixed(0);
        purchaseDate = _data['PurchaseDate'].toString().split('T')[0];
        supplier = _data['Supplier'];
        purchaseNumber = _data['Purchase']['ID']==0?'':_data['Purchase']['Name'];
      });
    }
  }

  List<FocusNode> _focusComponent = new List(10).map((item) {
    return new FocusNode();
  }).toList();

  Future<Null> saveConsumable() async {
    setState(() {
      _isExpandedDetail = true;
    });
    if (_fujiClass2 == 0) {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('富士II类不可为空'),
      )).then((result) => FocusScope.of(context).requestFocus(_focusComponent[0]));
      return;
    }
    if (_consumable == null) {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('耗材不可为空'),
      )).then((result) => scrollController.jumpTo(0));
      return;
    }
    if (lotNum.text.isEmpty) {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('批次号不可为空'),
      )).then((result) => FocusScope.of(context).requestFocus(_focusComponent[1]));
      return;
    }
    if (spec.text.isEmpty) {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('规格不可为空'),
      )).then((result) => FocusScope.of(context).requestFocus(_focusComponent[2]));
      return;
    }
    if (model.text.isEmpty) {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('型号不可为空'),
      )).then((result) => FocusScope.of(context).requestFocus(_focusComponent[3]));
      return;
    }
    if (unit.text.isEmpty) {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('单位不可为空'),
      )).then((result) => FocusScope.of(context).requestFocus(_focusComponent[7]));
      return;
    }
    if (price.text.isEmpty) {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('单价不可为空'),
      )).then((result) => FocusScope.of(context).requestFocus(_focusComponent[4]));
      return;
    }
    if (double.parse(price.text) > 9999999999.99) {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('单价需小于100亿'),
      )).then((result) => FocusScope.of(context).requestFocus(_focusComponent[4]));
      return;
    }
    if (quantity.text.isEmpty) {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('入库数量不可为空'),
      )).then((result) => FocusScope.of(context).requestFocus(_focusComponent[5]));
      return;
    }
    if (double.parse(quantity.text) > 9999999999.99) {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('入库数量需小于100亿'),
      )).then((result) => FocusScope.of(context).requestFocus(_focusComponent[5]));
      return;
    }
    if (widget.consumable != null && widget.editable) {
      if (availableQty.text.isEmpty) {
        showDialog(context: context, builder: (context) => CupertinoAlertDialog(
          title: new Text('可用数量不可为空'),
        )).then((result) => FocusScope.of(context).requestFocus(_focusComponent[5]));
        return;
      }
      if (double.parse(availableQty.text) > 9999999999.99) {
        showDialog(context: context, builder: (context) => CupertinoAlertDialog(
          title: new Text('可用数量需小于100亿'),
        )).then((result) => FocusScope.of(context).requestFocus(_focusComponent[5]));
        return;
      }
    }
    if (supplier == null) {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('供应商不可为空'),
      )).then((result) => scrollController.jumpTo(1000));
      return;
    }
    if (purchaseDate == 'YYYY-MM-DD') {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('购入日期不可为空'),
      )).then((result) => scrollController.jumpTo(800));
      return;
    }
    var prefs = await _prefs;
    var _info = {
      "Consumable": {
        "ID": _consumable,
      },
      "LotNum": lotNum.text,
      "Specification": spec.text,
      "Model": model.text,
      "Unit": unit.text,
      "Price": price.text,
      "ReceiveQty": quantity.text,
      "Supplier": {
        "ID": supplier['ID']
      },
      "PurchaseDate": purchaseDate,
      "Comments": comments.text
    };
    if (widget.consumable != null) {
      _info['ID'] = widget.consumable['ID'];
      _info['AvaibleQty'] = availableQty.text;
    }
    var _data = {
      "userID": prefs.getInt('userID'),
      "info": _info
    };
    if (widget.isStock != null && widget.isStock) {
      Navigator.of(context).pop(jsonEncode(_info));
      return;
    }
    Map resp;
    if (widget.consumable !=null && widget.editable) {
      if (double.parse(availableQty.text) > double.parse(quantity.text)) {
        showDialog(context: context, builder: (context) => CupertinoAlertDialog(
          title: new Text('请确认可用数量是否要大于入库数量'),
          actions: <Widget>[
            new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Container(
                  width: 100.0,
                  child: RaisedButton(
                    //padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                    child: Text('确认', style: TextStyle(color: Colors.white),),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    color: AppConstants.AppColors['btn_cancel'],
                    onPressed: () async {
                      resp = await HttpRequest.request(
                          '/InvConsumable/SaveConsumable',
                          method: HttpRequest.POST,
                          data: _data
                      );
                      if (resp['ResultCode'] == '00') {
                        showDialog(context: context, builder: (context) {
                          return CupertinoAlertDialog(
                            title: new Text('保存成功'),
                          );
                        }).then((result) {
                          int count = 0;
                          Navigator.popUntil(context, (route) {
                            return count++ == 2;
                          });
                        });
                      } else {
                        showDialog(context: context, builder: (context) {
                          return CupertinoAlertDialog(
                            title: new Text(resp['ResultMessage']),
                          );
                        });
                      }
                    },
                  ),
                ),
                new SizedBox(
                  width: 10.0,
                ),
                new Container(
                  width: 100.0,
                  child: RaisedButton(
                    child: Text('取消', style: TextStyle(color: Colors.white),),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    color: AppConstants.AppColors['btn_main'],
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                )
              ],
            ),
          ],
        ));
      } else {
        resp = await HttpRequest.request(
            '/InvConsumable/SaveConsumable',
            method: HttpRequest.POST,
            data: _data
        );
        if (resp['ResultCode'] == '00') {
          showDialog(context: context, builder: (context) {
            return CupertinoAlertDialog(
              title: new Text('保存成功'),
            );
          }).then((result) => Navigator.of(context).pop());
        } else {
          showDialog(context: context, builder: (context) {
            return CupertinoAlertDialog(
              title: new Text(resp['ResultMessage']),
            );
          });
        }
      }
    } else {
      resp = await HttpRequest.request(
          '/InvConsumable/SaveConsumable',
          method: HttpRequest.POST,
          data: _data
      );
      if (resp['ResultCode'] == '00') {
        showDialog(context: context, builder: (context) {
          return CupertinoAlertDialog(
            title: new Text('保存成功'),
          );
        }).then((result) => Navigator.of(context).pop());
      } else {
        showDialog(context: context, builder: (context) {
          return CupertinoAlertDialog(
            title: new Text(resp['ResultMessage']),
          );
        });
      }
    }
  }

  Row buildDropdown(String title, int currentItem, List dropdownItems, Function changeDropdown, {bool required}) {
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
                value: item['value'],
                child: Text(
                  item['text'],
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

  Padding buildRow(String labelText, String defaultText) {
    return new Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: new Row(
        children: <Widget>[
          new Expanded(
            flex: 4,
            child: new Text(
              labelText,
              style: new TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
            ),
          ),
          new Expanded(
            flex: 6,
            child: new Text(
              defaultText,
              style: new TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w400,
                  color: Colors.black54),
            ),
          )
        ],
      ),
    );
  }

  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (context, child, mainModel) {
        return new Scaffold(
            appBar: new AppBar(
              title: widget.editable?Text(widget.consumable==null?'新增耗材':'修改耗材'):Text('查看耗材'),
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
                  controller: scrollController,
                  children: <Widget>[
                    new ExpansionPanelList(
                      animationDuration: Duration(milliseconds: 200),
                      expansionCallback: (index, isExpanded) {
                        setState(() {
                          if (index == 0) {
                            _isExpandedDetail = !isExpanded;
                          } else {}
                        });
                      },
                      children: [
                        new ExpansionPanel(canTapOnHeader: true,
                          headerBuilder: (context, isExpanded) {
                            return ListTile(
                              leading: new Icon(
                                Icons.description,
                                size: 24.0,
                                color: Colors.blue,
                              ),
                              title: Text(
                                '耗材基本信息',
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
                                widget.consumable!=null?BuildWidget.buildRow('系统编号', oid):Container(),
                                widget.editable&&widget.consumable==null?buildDropdown('富士II类', _fujiClass2, _fujiList, changeFuji, required: true):BuildWidget.buildRow('富士II类', _fujiClass2Name??''),
                                widget.editable&&widget.consumable==null?buildDropdown('选择耗材', _consumable, _consumableList, changeConsumable, required: true):BuildWidget.buildRow('选择耗材', _consumableName??''),
                                widget.editable?BuildWidget.buildInput('批次号', lotNum, maxLength: 30, focusNode: _focusComponent[1], required: true):BuildWidget.buildRow('批次号', lotNum.text),
                                widget.editable?BuildWidget.buildInput('规格', spec, maxLength: 50, focusNode: _focusComponent[2], required: true):BuildWidget.buildRow('规格', spec.text),
                                widget.editable?BuildWidget.buildInput('型号', model, maxLength: 50, focusNode: _focusComponent[3], required: true):BuildWidget.buildRow('型号', model.text),
                                widget.editable?BuildWidget.buildInput('单位', unit, maxLength: 10, focusNode: _focusComponent[7], required: true):BuildWidget.buildRow('单位', unit.text),
                                widget.editable?new Padding(
                                  padding: EdgeInsets.symmetric(vertical: 5.0),
                                  child: new Row(
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
                                              '供应商',
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
                                          supplier == null ? '' : supplier['Name'],
                                          style: new TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.black54),
                                        ),
                                      ),
                                      new Expanded(
                                          flex: 2,
                                          child: new IconButton(
                                              focusNode: _focusComponent[3],
                                              icon: Icon(Icons.search),
                                              onPressed: () async {
                                                FocusScope.of(context).requestFocus(new FocusNode());
                                                final _searchResult = await Navigator.of(context).push(new MaterialPageRoute(builder: (_) => SearchLazy(searchType: SearchType.VENDOR,)));
                                                print(_searchResult);
                                                if (_searchResult != null &&
                                                    _searchResult != 'null') {
                                                  setState(() {
                                                    supplier = jsonDecode(_searchResult);
                                                  });
                                                }
                                              })),
                                    ],
                                  ),
                                ):BuildWidget.buildRow('供应商', supplier==null?'':supplier['Name']),
                                widget.editable?BuildWidget.buildInput('单价(元)', price, maxLength: 13, inputType: TextInputType.numberWithOptions(decimal: true), focusNode: _focusComponent[4], required: true):BuildWidget.buildRow('单价(元)', CommonUtil.CurrencyForm(double.tryParse(price.text), times: 1, digits: 0)),
                                widget.editable&&widget.consumable==null?BuildWidget.buildInput('入库数量', quantity, maxLength: 13, inputType: TextInputType.numberWithOptions(decimal: true), focusNode: _focusComponent[5], required: true):BuildWidget.buildRow('入库数量', CommonUtil.CurrencyForm(double.tryParse(quantity.text), times: 1, digits: 0)),
                                widget.editable&&widget.consumable!=null?BuildWidget.buildInput('可用数量', availableQty, maxLength: 13, inputType: TextInputType.number, focusNode: _focusComponent[6], required: true):Container(),
                                !widget.editable?BuildWidget.buildRow("可用数量", availableQty.text):Container(),
                                widget.editable&&widget.consumable==null?new Padding(
                                  padding: EdgeInsets.symmetric(vertical: 5.0),
                                  child: new Row(
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
                                              '购入日期',
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
                                          purchaseDate,
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
                                              var _time = DateTime.tryParse(purchaseDate)??DateTime.now();
                                              DatePicker.showDatePicker(
                                                context,
                                                pickerTheme: DateTimePickerTheme(
                                                  showTitle: true,
                                                  confirm: Text('确认', style: TextStyle(color: Colors.blueAccent)),
                                                  cancel: Text('取消', style: TextStyle(color: Colors.redAccent)),
                                                ),
                                                minDateTime: DateTime.now().add(Duration(days: -7300)),
                                                maxDateTime: DateTime.now().add(Duration(days: 365*10)),
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
                                                    purchaseDate = _date;
                                                  });
                                                },
                                              );
                                            }),
                                      ),
                                    ],
                                  ),
                                ):BuildWidget.buildRow('购入日期', purchaseDate),
                                widget.consumable!=null?BuildWidget.buildRow('采购单号', purchaseNumber):Container(),
                                widget.editable?BuildWidget.buildInput('备注', comments, maxLength: 500, focusNode: _focusComponent[8]):BuildWidget.buildRow('备注', comments.text),
                                new Divider(),
                                new Padding(
                                    padding:
                                    EdgeInsets.symmetric(vertical: 8.0))
                              ],
                            ),
                          ),
                          isExpanded: _isExpandedDetail,
                        ),
                      ],
                    ),
                    SizedBox(height: 24.0),
                    new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        widget.editable?new RaisedButton(
                          onPressed: () {
                            FocusScope.of(context).requestFocus(new FocusNode());
                            saveConsumable();
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: EdgeInsets.all(12.0),
                          color: new Color(0xff2E94B9),
                          child:
                          Text('提交', style: TextStyle(color: Colors.white)),
                        ):new Container(),
                        new RaisedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: EdgeInsets.all(12.0),
                          color: new Color(0xffD25565),
                          child:
                          Text('返回', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ));
      },
    );
  }
}
