import 'package:atoi/pages/equipments/equipments_list.dart';
import 'package:atoi/widgets/search_page.dart';
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

/// 服务详情页
class ServiceDetail extends StatefulWidget {
  ServiceDetail({Key key, this.service, this.editable, this.isStock, this.date}) : super(key: key);
  final Map service;
  final bool editable;
  final bool isStock;
  final String date;
  _ServiceDetailState createState() => new _ServiceDetailState();
}

class _ServiceDetailState extends State<ServiceDetail> {
  var _isExpandedDetail = true;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  String oid = '系统自动生成';
  EventBus bus = new EventBus();
  Map manufacturer;
  List equips = [];
  Map supplier;
  String startDate = 'YYYY-MM-DD';
  String endDate = 'YYYY-MM-DD';
  String purchaseDate = 'YYYY-MM-DD';
  int _fujiClass2 = 0;
  String purchaseNo = "";
  ScrollController scrollController = new ScrollController();

  ConstantsModel cModel;

  TextEditingController serviceName = new TextEditingController(), totalTimes = new TextEditingController(), availableTimes = new TextEditingController(), price = new TextEditingController(), comments = new TextEditingController();

  @override
  void initState() {
    super.initState();
    cModel = MainModel.of(context);
    getService();
  }

  //void initFuji() {
  //  cModel.getConstants();
  //  List _list = [];
  //  _list.add({
  //    'value': 0,
  //    'text': ''
  //  });
  //  _list.addAll(cModel.FujiClass2.map((item) {
  //    return {
  //      'value': item['ID'],
  //      'text': item['Name']
  //    };
  //  }).toList());
  //  setState(() {
  //    _fujiList = _list;
  //  });
  //}

  void changeFuji(value) {
    FocusScope.of(context).requestFocus(new FocusNode());
    setState(() {
      _fujiClass2 = value;
    });
  }

  Future<Null> getService() async {
    var resp = await HttpRequest.request('/InvService/GetServiceByID',
        method: HttpRequest.GET, params: {'serviceId': widget.service['ID']});
    if (resp['ResultCode'] == '00') {
      var _data = resp['Data'];
      setState(() {
        oid = _data['OID'];
        serviceName.text = _data['Name'];
        totalTimes.text = _data['TotalTimes'].toString();
        availableTimes.text = _data['AvaibleTimes'].toString();
        price.text = _data['Price'].toString();
        comments.text = _data['Comments'];
        supplier = _data['Supplier'];
        startDate = _data['StartDate'].toString().split('T')[0];
        endDate = _data['EndDate'].toString().split('T')[0];
        purchaseDate = _data['PurchaseDate'].toString().split('T')[0];
        _fujiClass2 = _data['FujiClass2']['ID'];
        //_fujiClass2Name = _data['FujiClass2']['Name'];
        purchaseNo = _data['Purchase']['ID']==0?"":_data['Purchase']['Name'];
        equips = _data['Equipments'];
      });
    }
  }

  List<FocusNode> _focusComponent = new List(10).map((item) {
    return new FocusNode();
  }).toList();

  Future<Null> saveComponent() async {
    setState(() {
      _isExpandedDetail = true;
    });
    //if (_fujiClass2 == 0) {
    //  showDialog(context: context, builder: (context) => CupertinoAlertDialog(
    //    title: new Text('富士II类不可为空'),
    //  )).then((result) => scrollController.jumpTo(0.0));
    //  return;
    //}
    if (equips.isEmpty) {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('关联设备不可为空'),
      )).then((result) => scrollController.jumpTo(0.0));
      return;
    }
    if (serviceName.text.isEmpty) {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('服务名称不可为空'),
      )).then((result) => FocusScope.of(context).requestFocus(_focusComponent[1]));
      return;
    }
    if (price.text.isEmpty) {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('金额不可为空'),
      )).then((result) => FocusScope.of(context).requestFocus(_focusComponent[2]));
      return;
    }
    if (double.parse(price.text) > 9999999999.99) {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('金额需小于100亿'),
      )).then((result) => FocusScope.of(context).requestFocus(_focusComponent[2]));
      return;
    }
    if (totalTimes.text.isEmpty) {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('服务次数不可为空'),
      )).then((result) => FocusScope.of(context).requestFocus(_focusComponent[3]));
      return;
    }
    if (availableTimes.text.isEmpty) {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('剩余服务次数不可为空'),
      )).then((result) => FocusScope.of(context).requestFocus(_focusComponent[4]));
      return;
    }
    if (double.parse(availableTimes.text) > double.parse(totalTimes.text)) {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('剩余服务次数不可大于服务次数'),
      )).then((result) => FocusScope.of(context).requestFocus(_focusComponent[4]));
      return;
    }
    if (startDate == 'YYYY-MM-DD') {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('开始日期不可为空'),
      )).then((result) => FocusScope.of(context).requestFocus(_focusComponent[9]));
      return;
    }
    if (endDate == 'YYYY-MM-DD') {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('结束日期不可为空'),
      )).then((result) => FocusScope.of(context).requestFocus(_focusComponent[9]));
      return;
    }
    if (purchaseDate == 'YYYY-MM-DD') {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('购入日期不可为空'),
      )).then((result) => FocusScope.of(context).requestFocus(_focusComponent[9]));
      return;
    }
    DateTime _start = DateTime.tryParse(startDate);
    DateTime _end = DateTime.tryParse(endDate);
    if (_end.isBefore(_start)) {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('结束日期不可早于开始日期'),
      )).then((result) => FocusScope.of(context).requestFocus(_focusComponent[9]));
      return;
    }
    if (widget.date != null) {
      if (_end.isBefore(DateTime.tryParse(widget.date))) {
        showDialog(context: context, builder: (context) => CupertinoAlertDialog(
          title: new Text('结束日期不可早于盘点计划日期'),
        )).then((result) => FocusScope.of(context).requestFocus(_focusComponent[9]));
        return;
      }
    }
    if (supplier == null) {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('供应商不可为空'),
      )).then((result) => FocusScope.of(context).requestFocus(_focusComponent[9]));
      return;
    }
    var prefs = await _prefs;
    var _info = {
      'FujiClass2': {
        'ID': _fujiClass2
      },
      'Equipments': equips,
      'Name': serviceName.text,
      'TotalTimes': totalTimes.text,
      'Price': price.text,
      'AvaibleTimes': availableTimes.text,
      'StartDate': startDate,
      'EndDate': endDate,
      'PurchaseDate': purchaseDate,
      'Comments': comments.text,
      'Supplier': {
        'ID': supplier['ID']
      }
    };
    if (widget.isStock!=null&&widget.isStock) {
      //if (DateTime.tryParse(startDate).isBefore(DateTime.tryParse(widget.date))) {
      //  showDialog(context: context, builder: (context) => CupertinoAlertDialog(
      //    title: new Text('开始日期不可早于盘点日期'),
      //  ));
      //  return;
      //} else {
      //}
      Navigator.of(context).pop(jsonEncode(_info));
      return;
    }
    if (widget.service != null) {
      _info['ID'] = widget.service['ID'];
    }
    var _data = {
      "userID": prefs.getInt('userID'),
      "info": _info
    };
    var resp = await HttpRequest.request(
        '/InvService/SaveService',
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
              title: widget.editable?Text(widget.service==null?'新增服务':'修改服务'):Text('查看服务'),
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
                                '服务基本信息',
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
                                BuildWidget.buildRow('系统编号', oid),
                                //widget.editable?buildDropdown('富士II类', _fujiClass2, _fujiList, changeFuji, required: true):BuildWidget.buildRow('富士II类', _fujiClass2Name??''),
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
                                              '关联设备',
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
                                          equips.map((item) => item['Name']).toList().join(", "),
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
                                                final _searchResult = await Navigator.of(context).push(new MaterialPageRoute(builder: (_) => SearchPage(equipments: equips, onlyType: EquipmentType.MEDICAL, multiType: MultiSearchType.EQUIPMENT,)));
                                                print(_searchResult);
                                                if (_searchResult != null &&
                                                    _searchResult != 'null') {
                                                  setState(() {
                                                    equips = _searchResult;
                                                  });
                                                }
                                              })),
                                    ],
                                  ),
                                ):BuildWidget.buildRow('关联设备', equips==null?'':equips.map((item) => item['Name']).toList().join(",")),
                                widget.editable?BuildWidget.buildInput('服务名称', serviceName, maxLength: 50, focusNode: _focusComponent[1], required: true):BuildWidget.buildRow('服务名称', serviceName.text),
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
                                widget.editable?BuildWidget.buildInput('金额', price, maxLength: 13, inputType: TextInputType.numberWithOptions(decimal: true), focusNode: _focusComponent[2], required: true):BuildWidget.buildRow('金额', price.text),
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
                                widget.editable?BuildWidget.buildInput('服务次数', totalTimes, maxLength: 9, inputType: TextInputType.number, focusNode: _focusComponent[3], required: true):BuildWidget.buildRow('服务次数', totalTimes.text),
                                widget.editable?BuildWidget.buildInput('剩余服务次数', availableTimes, maxLength: 9, inputType: TextInputType.number, focusNode: _focusComponent[4], required: true):BuildWidget.buildRow('剩余服务次数', availableTimes.text),
                                widget.editable&&widget.service==null?new Padding(
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
                                widget.service!=null?BuildWidget.buildRow('采购单号', purchaseNo):Container(),
                                widget.editable?BuildWidget.buildInput('备注', comments, maxLength: 500, focusNode: _focusComponent[5]):BuildWidget.buildRow('备注', comments.text),
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
                            saveComponent();
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
