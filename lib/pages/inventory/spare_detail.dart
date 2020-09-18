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
  SpareDetail({Key key, this.spare, this.editable}) : super(key: key);
  final Map spare;
  final bool editable;
  _SpareDetailState createState() => new _SpareDetailState();
}

class _SpareDetailState extends State<SpareDetail> {
  var _isExpandedDetail = true;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  String oid = '系统自动生成';
  EventBus bus = new EventBus();
  Map manufacturer;
  Map supplier;
  String startDate = 'YYYY-MM-DD';
  String endDate = 'YYYY-MM-DD';
  int _fujiClass2 = 0;
  String _fujiClass2Name;
  List _fujiList = [];

  ConstantsModel cModel;

  TextEditingController serialCode = new TextEditingController(), price = new TextEditingController();

  void initState() {
    super.initState();
    cModel = MainModel.of(context);
    initFuji();
    getSpare();
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

  Future<Null> getSpare() async {
    var resp = await HttpRequest.request('/InvSpare/GetSpareByID',
        method: HttpRequest.GET, params: {'spareId': widget.spare['ID']});
    if (resp['ResultCode'] == '00') {
      var _data = resp['Data'];
      setState(() {
        oid = _data['OID'];
        _fujiClass2 = _data['FujiClass2']['ID'];
        _fujiClass2Name = _data['FujiClass2']['Name'];
        serialCode.text = _data['SerialCode'];
        price.text = _data['Price'].toString();
        startDate = _data['StartDate'].toString().split('T')[0];
        endDate = _data['EndDate'].toString().split('T')[0];
      });
    }
  }

  List<FocusNode> _focusComponent = new List(10).map((item) {
    return new FocusNode();
  }).toList();

  Future<Null> saveSpare() async {
    setState(() {
      _isExpandedDetail = true;
    });
    if (_fujiClass2 == null) {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('富士II类不可为空'),
      )).then((result) => FocusScope.of(context).requestFocus(_focusComponent[0]));
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
        title: new Text('月租过大'),
      )).then((result) => FocusScope.of(context).requestFocus(_focusComponent[3]));
      return;
    }
    if (startDate == 'YYYY-MM-DD') {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('开始日期不可为空'),
      )).then((result) => FocusScope.of(context).requestFocus(_focusComponent[0]));
      return;
    }
    if (endDate == 'YYYY-MM-DD') {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('结束日期不可为空'),
      )).then((result) => FocusScope.of(context).requestFocus(_focusComponent[0]));
      return;
    }
    if (DateTime.parse(startDate).isAfter(DateTime.parse(endDate))) {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('开始日期不可在结束日期之后'),
      )).then((result) => FocusScope.of(context).requestFocus(_focusComponent[0]));
      return;
    }
    var prefs = await _prefs;
    var _info = {
      'FujiClass2': {
        'ID': _fujiClass2,
      },
      'SerialCode': serialCode.text,
      'Price': price.text,
      'StartDate': startDate,
      'EndDate': endDate
    };
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
                                widget.editable?buildDropdown('富士二类', _fujiClass2, _fujiList, changeFuji, required: true):BuildWidget.buildRow('富士二类', _fujiClass2Name??''),
                                widget.editable?BuildWidget.buildInput('序列号', serialCode, maxLength: 30, focusNode: _focusComponent[2], required: true):BuildWidget.buildRow('序列号', serialCode.text),
                                widget.editable?BuildWidget.buildInput('月租(元)', price, maxLength: 13, inputType: TextInputType.numberWithOptions(decimal: true), focusNode: _focusComponent[3], required: true):BuildWidget.buildRow('月租', price.text),
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
                                                    endDate = _date;
                                                  });
                                                },
                                              );
                                            }),
                                      ),
                                    ],
                                  ),
                                ):BuildWidget.buildRow('结束日期', endDate),
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
