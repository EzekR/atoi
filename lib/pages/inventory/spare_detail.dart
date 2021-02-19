import 'dart:convert';

import 'package:atoi/utils/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:atoi/models/models.dart';
import 'package:scoped_model/scoped_model.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:atoi/utils/http_request.dart';
import 'package:atoi/widgets/build_widget.dart';
import 'package:atoi/utils/event_bus.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:atoi/utils/constants.dart';
import 'package:date_format/date_format.dart';

/// 备件详情页
class SpareDetail extends StatefulWidget {
  SpareDetail({Key key, this.spare, this.editable, this.isStock}) : super(key: key);
  final Map spare;
  final bool editable;
  final bool isStock;
  _SpareDetailState createState() => new _SpareDetailState();
}

class _SpareDetailState extends State<SpareDetail> {
  var _isExpandedDetail = true;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  String oid = '系统自动生成';
  EventBus bus = new EventBus();
  TextEditingController manufacturer = new TextEditingController();
  TextEditingController name = new TextEditingController();
  TextEditingController model = new TextEditingController();
  Map supplier;
  String startDate = 'YYYY-MM-DD';
  String endDate = 'YYYY-MM-DD';
  int _fujiClass2 = 0;
  String _fujiClass2Name;
  List _fujiList = [];
  String useStatus = "";
  int statusID = 1;
  String status = '';
  ScrollController scrollController = new ScrollController();
  List statusList = [
    {
      "value": 1,
      "text": "在用"
    },
    {
      "value": 2,
      "text": "备用"
    }
  ];

  void changeStatus(val) {
    setState(() {
      statusID = val;
    });
  }

  ConstantsModel cModel;

  TextEditingController serialCode = new TextEditingController(), price = new TextEditingController(), comment = new TextEditingController();

  void initState() {
    super.initState();
    cModel = MainModel.of(context);
    initFuji();
    getSpare();
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
  }

  Future<Null> getSpare() async {
    var resp = await HttpRequest.request('/InvSpare/GetSpareByID',
        method: HttpRequest.GET, params: {'spareId': widget.spare['ID']});
    if (resp['ResultCode'] == '00') {
      var _data = resp['Data'];
      setState(() {
        oid = _data['OID'];
        name.text = _data['Name'];
        model.text = _data['Model'];
        manufacturer.text = _data['Manufacturer'];
        _fujiClass2 = _data['FujiClass2']['ID'];
        _fujiClass2Name = _data['FujiClass2']['Name'];
        serialCode.text = _data['SerialCode'];
        price.text = _data['Price'].toString();
        startDate = _data['StartDate'].toString().split('T')[0];
        endDate = _data['EndDate'].toString().split('T')[0];
        comment.text = _data['Comments'];
        useStatus = _data['UsageStatus'];
        status = _data['Status']['Name'];
        statusID = _data['Status']['ID'];
      });
    }
  }

  List<FocusNode> _focusComponent = new List(10).map((item) {
    return new FocusNode();
  }).toList();

  Future<bool> spareExist(String serialCode) async {
    Map resp = await HttpRequest.request(
        '/InvSpare/CheckSpareSerialCode',
        method: HttpRequest.POST,
        data: {
          "info": {
            'FujiClass2': {
              'ID': _fujiClass2
            },
            'serialCode': serialCode,
            'StartDate': startDate,
            'EndDate': endDate,
            'Price': price.text
          }
        }
    );
    if (resp['ResultCode'] == '00') {
      return resp['Data'];
    } else {
      return false;
    }
  }

  Future<Null> saveSpare() async {
    setState(() {
      _isExpandedDetail = true;
    });
    if (_fujiClass2 == 0) {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('富士II类不可为空'),
      )).then((result) => scrollController.jumpTo(0.0));
      return;
    }
    if (manufacturer.text.isEmpty) {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('厂家不可为空'),
      )).then((result) => FocusScope.of(context).requestFocus(_focusComponent[7]));
      return;
    }
    if (model.text.isEmpty) {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('型号不可为空'),
      )).then((result) => FocusScope.of(context).requestFocus(_focusComponent[8]));
      return;
    }
    if (name.text.isEmpty) {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('名称不可为空'),
      )).then((result) => FocusScope.of(context).requestFocus(_focusComponent[9]));
      return;
    }
    if (serialCode.text.isEmpty) {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('序列号不可为空'),
      )).then((result) => FocusScope.of(context).requestFocus(_focusComponent[2]));
      return;
    }
    if (price.text.isEmpty) {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('月租不可为空'),
      )).then((result) => FocusScope.of(context).requestFocus(_focusComponent[3]));
      return;
    }
    if (double.parse(price.text) > 9999999999.99) {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('月租需小于100亿'),
      )).then((result) => FocusScope.of(context).requestFocus(_focusComponent[3]));
      return;
    }
    if (startDate == 'YYYY-MM-DD') {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('开始日期不可为空'),
      )).then((result) => scrollController.jumpTo(400.0));
      return;
    }
    if (endDate == 'YYYY-MM-DD') {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('结束日期不可为空'),
      )).then((result) => scrollController.jumpTo(400.0));
      return;
    }
    if (DateTime.parse(startDate).isAfter(DateTime.parse(endDate))) {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('开始日期不可在结束日期之后'),
      )).then((result) => scrollController.jumpTo(400.0));
      return;
    }
    var prefs = await _prefs;
    var _info = {
      'FujiClass2': {
        'ID': _fujiClass2,
      },
      'Name': name.text,
      'Model': model.text,
      'Manufacturer': manufacturer.text,
      'SerialCode': serialCode.text,
      'Price': price.text,
      'StartDate': startDate,
      'EndDate': endDate,
      'Status': {
        'ID': statusID
      },
      'Comments': comment.text
    };
    if (widget.isStock!=null&&widget.isStock) {
      bool exist = await spareExist(serialCode.text);
      if (!exist) {
        Navigator.of(context).pop(jsonEncode(_info));
      } else {
        showDialog(context: context, builder: (context) => CupertinoAlertDialog(
          title: new Text('备用机已存在'),
        ));
      }
      return;
    }
    if (widget.spare != null) {
      _info['ID'] = widget.spare['ID'];
    }
    var _data = {
      "userID": prefs.getInt('userID'),
      "info": _info
    };
    var resp = await HttpRequest.request(
        '/InvSpare/SaveSpare',
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
              title: widget.editable?Text(widget.spare==null?'新增备用机':'修改备用机'):Text('查看备用机'),
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
                                '备用机基本信息',
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
                                widget.spare == null?Container():BuildWidget.buildRow('系统编号', oid),
                                widget.editable?buildDropdown('富士II类', _fujiClass2, _fujiList, changeFuji, required: true):BuildWidget.buildRow('富士II类', _fujiClass2Name??''),
                                widget.editable?BuildWidget.buildInput('名称', name, maxLength: 30, focusNode: _focusComponent[9], required: true):BuildWidget.buildRow('序列号', name.text),
                                widget.editable?BuildWidget.buildInput('型号', model, maxLength: 30, focusNode: _focusComponent[8], required: true):BuildWidget.buildRow('型号', model.text),
                                widget.editable?BuildWidget.buildInput('厂家', manufacturer, maxLength: 30, focusNode: _focusComponent[7], required: true):BuildWidget.buildRow('厂家', manufacturer.text),
                                widget.editable?BuildWidget.buildInput('序列号', serialCode, maxLength: 30, focusNode: _focusComponent[2], required: true):BuildWidget.buildRow('序列号', serialCode.text),
                                widget.editable?BuildWidget.buildInput('月租(元)', price, maxLength: 13, inputType: TextInputType.numberWithOptions(decimal: true), focusNode: _focusComponent[3], required: true):BuildWidget.buildRow('月租(元)', CommonUtil.CurrencyForm(double.tryParse(price.text), times: 1, digits: 0)),
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
                                              '开始日期',
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
                                          startDate,
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
                                              var _time = DateTime.tryParse(startDate)??DateTime.now();
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
                                                    startDate = _date;
                                                  });
                                                },
                                              );
                                            }),
                                      ),
                                    ],
                                  ),
                                ):BuildWidget.buildRow('开始日期', startDate),
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
                                              '结束日期',
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
                                          endDate,
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
                                              var _time = DateTime.tryParse(endDate)??DateTime.now();
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
                                                    endDate = _date;
                                                  });
                                                },
                                              );
                                            }),
                                      ),
                                    ],
                                  ),
                                ):BuildWidget.buildRow('结束日期', endDate),
                                widget.editable?buildDropdown('使用状态', statusID, statusList, changeStatus, required: true):BuildWidget.buildRow('使用状态', status??''),
                                !widget.editable?BuildWidget.buildRow('状态', useStatus):Container(),
                                widget.editable?BuildWidget.buildInput('备注', comment, maxLength: 30):BuildWidget.buildRow('备注', comment.text),
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
                            saveSpare();
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
            )
        );
      },
    );
  }
}
