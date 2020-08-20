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

/// 零件详情页
class ComponentDetail extends StatefulWidget {
  ComponentDetail({Key key, this.component, this.editable}) : super(key: key);
  final Map component;
  final bool editable;
  _ComponentDetailState createState() => new _ComponentDetailState();
}

class _ComponentDetailState extends State<ComponentDetail> {
  var _isExpandedDetail = true;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  String oid = '系统自动生成';
  EventBus bus = new EventBus();
  Map manufacturer;
  Map supplier;
  String purchaseDate = 'YYYY-MM-DD';
  List statusList = [
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
  String currentComponent;
  List equipmentComponents;
  String currentStatus;
  List statusItems;

  TextEditingController serialCode, spec, model, price, comment = new TextEditingController();

  void initState() {
    super.initState();
    if (widget.component != null) {
      getComponent();
    }
    statusItems = statusList.map<DropdownMenuItem<String>>((item) => DropdownMenuItem(value: item['text'], child: Text(item['text']))).toList();
    currentStatus = statusList[0]['text'];
  }

  void changeStatus(value) {
    FocusScope.of(context).requestFocus(new FocusNode());
    setState(() {
      currentStatus = value;
    });
  }

  void changeComponent(value) {
    FocusScope.of(context).requestFocus(new FocusNode());
    setState(() {
      currentComponent = value;
    });
  }

  Future<Null> getComponent() async {
    var resp = await HttpRequest.request('/Supplier/GetSupplierById',
        method: HttpRequest.GET, params: {'id': widget.component['ID']});
    if (resp['ResultCode'] == '00') {
      var _data = resp['Data'];
      setState(() {
        oid = _data['OID'];
      });
    }
  }

  List<FocusNode> _focusComponent = new List(10).map((item) {
    return new FocusNode();
  }).toList();

  //Future<Null> saveComponent() async {
  //  setState(() {
  //    _isExpandedDetail = true;
  //  });
  //  if (name.text.isEmpty) {
  //    showDialog(context: context, builder: (context) => CupertinoAlertDialog(
  //      title: new Text('供应商名称不可为空'),
  //    )).then((result) => FocusScope.of(context).requestFocus(_focusComponent[0]));
  //    return;
  //  }
  //  if (province == "") {
  //    showDialog(context: context, builder: (context) => CupertinoAlertDialog(
  //      title: new Text('供应商省份不可为空'),
  //    )).then((result) => FocusScope.of(context).requestFocus(_focusComponent[1]));
  //    return;
  //  }
  //  if (contact.text.isEmpty) {
  //    showDialog(context: context, builder: (context) => CupertinoAlertDialog(
  //      title: new Text('供应商联系人不可为空'),
  //    )).then((result) => FocusScope.of(context).requestFocus(_focusComponent[2]));
  //    return;
  //  }
  //  var prefs = await _prefs;
  //  var _info = {
  //    "SupplierType": {
  //      "ID": model.SupplierType[currentType],
  //    },
  //    "Name": name.text,
  //    "Province": currentProvince,
  //    "Mobile": mobile.text,
  //    "Address": address.text,
  //    "Contact": contact.text,
  //    "ContactMobile": contactMobile.text,
  //    "IsActive": currentStatus=='启用'?true:false,
  //  };
  //  if (widget.component != null) {
  //    _info['ID'] = widget.component['ID'];
  //  }
  //  var _data = {
  //    "userID": prefs.getInt('userID'),
  //    "info": _info
  //  };
  //  var resp = await HttpRequest.request(
  //      '/Supplier/SaveSupplier',
  //      method: HttpRequest.POST,
  //      data: _data
  //  );
  //  if (resp['ResultCode'] == '00') {
  //    showDialog(context: context, builder: (context) {
  //      return CupertinoAlertDialog(
  //        title: new Text('保存成功'),
  //      );
  //    }).then((result) => Navigator.of(context).pop());
  //  } else {
  //    showDialog(context: context, builder: (context) {
  //      return CupertinoAlertDialog(
  //        title: new Text(resp['ResultMessage']),
  //      );
  //    });
  //  }
  //}

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
              title: widget.editable?Text(widget.component==null?'新增零件':'更新零件'):Text('查看零件'),
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
                                '供应商基本信息',
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
                                      manufacturer == null ? '' : manufacturer['Name'],
                                      style: new TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black54),
                                    ),
                                  ),
                                  new Expanded(
                                      flex: 2,
                                      child: new IconButton(
                                          focusNode: _focusComponent[0],
                                          icon: Icon(Icons.search),
                                          onPressed: () async {
                                            FocusScope.of(context).requestFocus(new FocusNode());
                                            final _searchResult = await Navigator.of(context).push(new MaterialPageRoute(builder: (_) => SearchLazy(searchType: SearchType.DEVICE,)));
                                            print(_searchResult);
                                            if (_searchResult != null &&
                                                _searchResult != 'null') {
                                              setState(() {
                                                manufacturer = jsonDecode(_searchResult);
                                              });
                                            }
                                          })),
                                    ],
                                  ),
                                ):BuildWidget.buildRow('关联设备', manufacturer==null?'':manufacturer['Name']),
                                widget.editable?BuildWidget.buildDropdown('选择零件', currentComponent, equipmentComponents, changeComponent, required: true):BuildWidget.buildRow('选择零件', currentComponent),
                                widget.editable?BuildWidget.buildInput('序列号', serialCode, maxLength: 20, focusNode: _focusComponent[3]):BuildWidget.buildRow('电话', serialCode.text),
                                widget.editable?BuildWidget.buildInput('规格', spec, maxLength: 20, focusNode: _focusComponent[4]):BuildWidget.buildRow('地址', spec.text),
                                widget.editable?BuildWidget.buildInput('型号', model, focusNode: _focusComponent[2], required: true):BuildWidget.buildRow('联系人', model.text),
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
                                widget.editable?BuildWidget.buildInput('单价', price, maxLength: 20, focusNode: _focusComponent[5]):BuildWidget.buildRow('联系人电话', price.text),
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
                                widget.editable?BuildWidget.buildInput('备注', comment, maxLength: 20, focusNode: _focusComponent[5]):BuildWidget.buildRow('备注', comment.text),
                                widget.editable?BuildWidget.buildDropdown('状态', currentStatus, statusItems, changeComponent, required: true):BuildWidget.buildRow('状态', currentStatus),
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
                            //saveComponent();
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
