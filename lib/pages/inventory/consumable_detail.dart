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
  ConsumableDetail({Key key, this.consumable, this.editable}) : super(key: key);
  final Map consumable;
  final bool editable;
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

  int _consumable = 0;
  String _consumableName;
  List _consumableList = [];

  ConstantsModel cModel;

  TextEditingController lotNum = new TextEditingController(), spec = new TextEditingController(), model = new TextEditingController(), price = new TextEditingController(), quantity = new TextEditingController(), comments = new TextEditingController();

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
    List _list = cModel.FujiClass2.map((item) {
      return {
        'value': item['ID'],
        'text': item['Name']
      };
    }).toList();
    _list.add({
      'value': 0,
      'text': ''
    });
    setState(() {
      _fujiList = _list;
    });
  }

  void changeFuji(value) {
    FocusScope.of(context).requestFocus(new FocusNode());
    setState(() {
      _fujiClass2 = value;
    });
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
        price.text = _data['Price'].toString();
        quantity.text = _data['Qty'].toString();
        comments.text = _data['Comments'];
        purchaseDate = _data['PurchaseDate'].toString().split('T')[0];
        supplier = _data['Supplier'];
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
    if (lotNum.text.isEmpty) {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('批次号不可为空'),
      )).then((result) => FocusScope.of(context).requestFocus(_focusComponent[0]));
      return;
    }
    if (spec.text.isEmpty) {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('规格不可为空'),
      )).then((result) => FocusScope.of(context).requestFocus(_focusComponent[1]));
      return;
    }
    if (model.text.isEmpty) {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('型号不可为空'),
      )).then((result) => FocusScope.of(context).requestFocus(_focusComponent[2]));
      return;
    }
    if (price.text.isEmpty) {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('单价不可为空'),
      )).then((result) => FocusScope.of(context).requestFocus(_focusComponent[2]));
      return;
    }
    if (quantity.text.isEmpty) {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('可用数量不可为空'),
      )).then((result) => FocusScope.of(context).requestFocus(_focusComponent[2]));
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
    }
    var _data = {
      "userID": prefs.getInt('userID'),
      "info": _info
    };
    var resp = await HttpRequest.request(
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
                                widget.consumable!=null?'修改耗材':'新增耗材',
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
                                widget.editable&&widget.consumable==null?buildDropdown('富士二类', _fujiClass2, _fujiList, changeFuji, required: true):BuildWidget.buildRow('富士二类', _fujiClass2Name??''),
                                widget.editable&&widget.consumable==null?buildDropdown('选择耗材', _consumable, _consumableList, changeFuji, required: true):BuildWidget.buildRow('选择耗材', _consumableName??''),
                                widget.editable?BuildWidget.buildInput('批次号', lotNum, maxLength: 20, focusNode: _focusComponent[1], required: true):BuildWidget.buildRow('批次号', lotNum.text),
                                widget.editable?BuildWidget.buildInput('规格', spec, maxLength: 20, focusNode: _focusComponent[2], required: true):BuildWidget.buildRow('地址', spec.text),
                                widget.editable?BuildWidget.buildInput('型号', model, focusNode: _focusComponent[3], required: true):BuildWidget.buildRow('联系人', model.text),
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
                                widget.editable?BuildWidget.buildInput('单价', price, maxLength: 20, focusNode: _focusComponent[4], required: true):BuildWidget.buildRow('联系人电话', price.text),
                                widget.editable?BuildWidget.buildInput('入库数量', quantity, focusNode: _focusComponent[5], required: true):BuildWidget.buildRow('入库数量', quantity.text),
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
                                                    purchaseDate = _date;
                                                  });
                                                },
                                              );
                                            }),
                                      ),
                                    ],
                                  ),
                                ):BuildWidget.buildRow('购入日期', purchaseDate),
                                widget.editable?BuildWidget.buildInput('备注', comments, maxLength: 100, focusNode: _focusComponent[6]):BuildWidget.buildRow('备注', comments.text),
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