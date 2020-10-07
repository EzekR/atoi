import 'package:atoi/pages/inventory/consumable_list.dart';
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

/// 采购单附件类
class POAttachment extends StatefulWidget {
  POAttachment({Key key, this.po, this.editable, this.attachType}) : super(key: key);
  final Map po;
  final bool editable;
  final AttachmentType attachType;
  _POAttachmentState createState() => new _POAttachmentState();
}

class _POAttachmentState extends State<POAttachment> {
  var _isExpandedDetail = true;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  String oid = '系统自动生成';
  EventBus bus = new EventBus();
  Map manufacturer;
  Map supplier;
  Map _equipment;
  String purchaseDate = 'YYYY-MM-DD';
  int _fujiClass2 = 0;
  String _fujiClass2Name;
  List _fujiList = [];
  String title;

  String _fujiComponentName;
  int _fujiComponent;
  List _fujiComponentsList = [];
  Map _selectedComponent;

  int _component;
  List _componentsList = [];

  int _componentType;
  List _componentStatusList = [];

  Map _consumableDetail;

  ConstantsModel cModel;

  // general
  TextEditingController lotNum = new TextEditingController(), spec = new TextEditingController(), model = new TextEditingController(), price = new TextEditingController(), quantity = new TextEditingController(), comments = new TextEditingController();
  // component
  TextEditingController componentName = new TextEditingController(),
                        componentDesc = new TextEditingController(),
                        componentPrice = new TextEditingController();
  //service
  TextEditingController serviceName = new TextEditingController(),
                        serviceTimes = new TextEditingController();
  String startDate = 'YYYY-MM-DD';
  String endDate = 'YYYY-MM-DD';
  ScrollController scrollController = new ScrollController();

  void initState() {
    super.initState();
    cModel = MainModel.of(context);
    initPageType();
  }

  void initPageType() async {
    switch (widget.attachType) {
      case AttachmentType.COMPONENT:
        title = '零件';
        if (widget.po != null) {
          await getFujiComponents(widget.po['Equipment']['FujiClass2']['ID']);
          _equipment = widget.po['Equipment'];
          _selectedComponent = widget.po['Component'];
          _component = _selectedComponent['ID'];
          spec.text = widget.po['Specification'];
          model.text = widget.po['Model'];
          price.text = widget.po['Price'].toString();
          quantity.text = widget.po['Qty'].toString();
        }
        break;
      case AttachmentType.CONSUMABLE:
        title = '耗材';
        if (widget.po != null) {
          _consumableDetail = widget.po['Consumable'];
          spec.text = widget.po['Specification'];
          model.text = widget.po['Model'];
          price.text = widget.po['Price'].toString();
          quantity.text = widget.po['Qty'].toString();
        }
        break;
      case AttachmentType.SERVICE:
        title = '服务';
        initFuji();
        if (widget.po != null) {
          _fujiClass2 = widget.po['FujiClass2']['ID'];
          serviceTimes.text = widget.po['TotalTimes'].toString();
          price.text = widget.po['Price'].toString();
          serviceName.text = widget.po['Name'];
          startDate = widget.po['StartDate'].toString().split('T')[0];
          endDate = widget.po['EndDate'].toString().split('T')[0];
        }
        break;
    }
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

  void initComponentStatus() {
    List _list = cModel.ComponentStatus.map((item) {
      return {
        'value': item['ID'],
        'text': item['Name']
      };
    }).toList();
    setState(() {
      _componentStatusList = _list;
      _componentType = _list[0]['value'];
    });
  }

  void changeComponentStatus(value) {
    print(value);
    FocusScope.of(context).requestFocus(new FocusNode());
    setState(() {
      _componentType = value;
    });
  }

  void changeComponent(value) {
    FocusScope.of(context).requestFocus(new FocusNode());
    setState(() {
      _component = value;
      _selectedComponent = _fujiComponentsList.firstWhere((item) => item['ID'] == value, orElse: null);
    });
  }

  void getEquipment(int equipmentId) async {
    Map resp = await HttpRequest.request(
      '/Equipment/GetDeviceByID',
      method: HttpRequest.GET,
      params: {
        'id': equipmentId
      }
    );
    if (resp['ResultCode'] == '00') {
      _equipment = resp['Data'];
      _fujiClass2Name = resp['Data']['FujiClass2']['Name'];
    }
  }

  void getFujiComponents(int fujiId) async {
    Map resp = await HttpRequest.request(
      '/InvComponent/QueryComponentsByFujiClass2ID',
      params: {
        'fujiClass2ID': fujiId
      }
    );
    if (resp['ResultCode'] == '00') {
      _componentsList = resp['Data'].map((item) {
        return {
          'value': item['ID'],
          'text': item['Name']
        };
      }).toList();
      _fujiComponentsList = resp['Data'];
      setState(() {
        _componentsList = _componentsList;
      });
    }
  }

  List<FocusNode> _focusComponent = new List(10).map((item) {
    return new FocusNode();
  }).toList();

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
          flex: 4,
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
        ),
        new Expanded(
          flex: 2,
          child: Center(
            child: IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                if (_equipment == null) {
                  showDialog(context: context, builder: (context) => CupertinoAlertDialog(
                    title: new Text('请先选择关联设备'),
                  )).then((result) => FocusScope.of(context).requestFocus(_focusComponent[0]));
                  return;
                } else {
                  addComponent();
                }
              },
            ),
          ),
        )
      ],
    );
  }

  Future<String> saveComponent() async {
    if (componentName.text.isEmpty) {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('零件名称不可为空'),
      )).then((result) => FocusScope.of(context).requestFocus(_focusComponentName));
      return 'fail';
    }
    if (componentDesc.text.isEmpty) {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('零件描述不可为空'),
      )).then((result) => FocusScope.of(context).requestFocus(_focusComponentDesc));
      return 'fail';
    }
    Map resp = await HttpRequest.request(
      '/PurchaseOrder/SaveComponent',
      method: HttpRequest.POST,
      data: {
        'info': {
          'FujiClass2': {
            'ID': _equipment['FujiClass2']['ID']
          },
          'Name': componentName.text,
          'Description': componentDesc.text,
          'Type': {
            'ID': _componentType
          },
          'StdPrice': componentPrice.text
        }
      }
    );
    if (resp['ResultCode'] == '00') {
      return 'ok';
    } else {
      return 'fail';
    }
  }

  FocusNode _focusComponentName = new FocusNode();
  FocusNode _focusComponentDesc = new FocusNode();

  void addComponent() {
    initComponentStatus();
    showDialog(context: context, builder: (context) => StatefulBuilder(
      builder: (context, setState) => SimpleDialog(
        title: Text('新增零件'),
        children: <Widget>[
          Padding(
            padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
            child: Column(
              children: <Widget>[
                BuildWidget.buildCardRow('富士二类', _fujiClass2Name??''),
                BuildWidget.buildCardInput('简称', componentName, required: true, focus: _focusComponentName),
                BuildWidget.buildCardInput('描述', componentDesc, required: true, focus: _focusComponentDesc),
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
                        value: _componentType,
                        items: _componentStatusList.map<DropdownMenuItem>((item) {
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
                            _componentType = value;
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
                BuildWidget.buildCardInput('标准单价', componentPrice),
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
                      onPressed: () {
                        saveComponent().then((result) {
                          if (result == 'ok') {
                            getFujiComponents(_equipment['FujiClass2']['ID']);
                            Navigator.of(context).pop();
                          }
                        });
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

  void saveAttachmentToPO() async {
    if (widget.attachType == AttachmentType.COMPONENT && _equipment == null) {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('设备不可为空'),
      )).then((result) => scrollController.jumpTo(0.0));
      return;
    }
    if (widget.attachType == AttachmentType.COMPONENT && double.parse(price.text) > 9999999999.99 ) {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('零件单价不可高于1亿'),
      )).then((result) => FocusScope.of(context).requestFocus(_focusComponent[3]));
      return;
    }
    if (widget.attachType == AttachmentType.CONSUMABLE && _consumableDetail == null) {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('耗材不可为空'),
      )).then((result) => scrollController.jumpTo(0.0));
      return;
    }
    if (widget.attachType == AttachmentType.CONSUMABLE || widget.attachType == AttachmentType.COMPONENT) {

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

      if (quantity.text.isEmpty) {
        showDialog(context: context, builder: (context) => CupertinoAlertDialog(
          title: new Text('数量不可为空'),
        )).then((result) => FocusScope.of(context).requestFocus(_focusComponent[4]));
        return;
      }

      if (double.parse(quantity.text) > 9999999999.99) {
        showDialog(context: context, builder: (context) => CupertinoAlertDialog(
          title: new Text('数量不可大于1亿'),
        )).then((result) => FocusScope.of(context).requestFocus(_focusComponent[4]));
        return;
      }
    }

    if (widget.attachType == AttachmentType.SERVICE) {
      if (_fujiClass2 == null) {
        showDialog(context: context, builder: (context) => CupertinoAlertDialog(
          title: new Text('富士II类不可为空'),
        )).then((result) => scrollController.jumpTo(0.0));
        return;
      }
      if (serviceName.text.isEmpty) {
        showDialog(context: context, builder: (context) => CupertinoAlertDialog(
          title: new Text('服务名称不可为空'),
        )).then((result) => FocusScope.of(context).requestFocus(_focusComponent[1]));
        return;
      }
      if (startDate == 'YYYY-MM-DD' || endDate == 'YYYY-MM-DD') {
        showDialog(context: context, builder: (context) => CupertinoAlertDialog(
          title: new Text('开始结束日期不可为空'),
        )).then((result) => scrollController.jumpTo(100.0));
        return;
      }
      if (serviceTimes.text.isEmpty) {
        showDialog(context: context, builder: (context) => CupertinoAlertDialog(
          title: new Text('服务次数不可为空'),
        )).then((result) => scrollController.jumpTo(100.0));
        return;
      }
    }
    if (price.text.isEmpty) {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('单价不可为空'),
      )).then((result) => FocusScope.of(context).requestFocus(_focusComponent[3]));
      return;
    }
    Map _component;
    switch (widget.attachType) {
      case AttachmentType.COMPONENT:
        _component = {
          'Component': _selectedComponent,
          'Equipment': _equipment,
          'Specification': spec.text,
          'Model': model.text,
          'Price': price.text,
          'Qty': quantity.text
        };
        break;
      case AttachmentType.CONSUMABLE:
        _component = {
          'Consumable': _consumableDetail,
          'Specification': spec.text,
          'Model': model.text,
          'Price': price.text,
          'Qty': quantity.text
        };
        break;
      case AttachmentType.SERVICE:
        Map _selectedFuji = cModel.FujiClass2.firstWhere((item) => item['ID'] == _fujiClass2);
        _component = {
          'FujiClass2': _selectedFuji,
          'Name': serviceName.text,
          'TotalTimes': serviceTimes.text,
          'Price': price.text,
          'StartDate': startDate,
          'EndDate': endDate
        };
        break;
    }
    Navigator.of(context).pop(jsonEncode(_component));
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

  List buildPageList() {
    List<Widget> _list = [];
    switch (widget.attachType) {
      case AttachmentType.COMPONENT:
        _list.addAll([
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
                    _equipment == null ? '' : _equipment['Name'],
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
                          final _searchResult = await Navigator.of(context).push(new MaterialPageRoute(builder: (_) => SearchLazy(searchType: SearchType.DEVICE,)));
                          print(_searchResult);
                          if (_searchResult != null &&
                              _searchResult != 'null') {
                            setState(() {
                              _equipment = jsonDecode(_searchResult);
                            });
                            await getEquipment(_equipment['ID']);
                            await getFujiComponents(_equipment['FujiClass2']['ID']);
                          }
                        })),
              ],
            ),
          ):BuildWidget.buildRow('关联设备', _equipment==null?'':_equipment['Name']),
          widget.editable?buildDropdown('选择零件', _component, _componentsList, changeComponent, required: true):BuildWidget.buildRow('零件', _fujiComponentName),
          widget.editable?BuildWidget.buildInput('规格', spec, maxLength: 20, focusNode: _focusComponent[1], required: true):BuildWidget.buildRow('规格', spec.text),
          widget.editable?BuildWidget.buildInput('型号', model, focusNode: _focusComponent[2], required: true):BuildWidget.buildRow('型号', model.text),
          widget.editable?BuildWidget.buildInput('单价', price, maxLength: 13, focusNode: _focusComponent[3], inputType: TextInputType.number, required: true):BuildWidget.buildRow('单价', price.text),
          widget.editable?BuildWidget.buildInput('数量', quantity, maxLength: 13, inputType: TextInputType.numberWithOptions(), focusNode: _focusComponent[4], required: true):BuildWidget.buildRow('数量', quantity.text),
        ]);
        break;
      case AttachmentType.CONSUMABLE:
        _list.addAll([
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
                        '选择耗材',
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
                    _consumableDetail == null ? '' : _consumableDetail['Name'],
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
                          final _searchResult = await Navigator.of(context).push(new MaterialPageRoute(builder: (_) => ConsumableList(optional: true,)));
                          print(_searchResult);
                          if (_searchResult != null &&
                              _searchResult != 'null') {
                            setState(() {
                              _consumableDetail = jsonDecode(_searchResult);
                            });
                          }
                        })),
              ],
            ),
          ):BuildWidget.buildRow('关联设备', _equipment==null?'':_equipment['Name']),
          widget.editable?BuildWidget.buildInput('规格', spec, maxLength: 20, focusNode: _focusComponent[1], required: true):BuildWidget.buildRow('规格', spec.text),
          widget.editable?BuildWidget.buildInput('型号', model, focusNode: _focusComponent[2], required: true):BuildWidget.buildRow('型号', model.text),
          widget.editable?BuildWidget.buildInput('单价', price, maxLength: 20, focusNode: _focusComponent[3], required: true):BuildWidget.buildRow('单价', price.text),
          widget.editable?BuildWidget.buildInput('数量', quantity, inputType: TextInputType.number, focusNode: _focusComponent[4], required: true):BuildWidget.buildRow('数量', quantity.text),
        ]);
        break;
      case AttachmentType.SERVICE:
        _list.addAll([
          widget.editable?Row(
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
                flex: 6,
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
          ):Container(),
          widget.editable?BuildWidget.buildInput('服务名称', serviceName, maxLength: 20, focusNode: _focusComponent[1], required: true):BuildWidget.buildRow('服务名称', serviceName.text),
          widget.editable?BuildWidget.buildInput('金额', price, maxLength: 20, focusNode: _focusComponent[2], required: true):BuildWidget.buildRow('金额', price.text),
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
                        '开始时间',
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
          ):BuildWidget.buildRow('开始时间', startDate),
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
                        '结束时间',
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
          ):BuildWidget.buildRow('结束时间', endDate),
          widget.editable?BuildWidget.buildInput('服务次数', serviceTimes, maxLength: 20, focusNode: _focusComponent[5], required: true):BuildWidget.buildRow('服务次数', serviceTimes.text),
        ]);
        break;
    }
    return _list;
  }

  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (context, child, mainModel) {
        return new Scaffold(
            appBar: new AppBar(
              title: widget.editable?Text(widget.po==null?'新增$title':'修改$title'):Text('查看$title'),
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
                        new ExpansionPanel(
                          canTapOnHeader: true,
                          headerBuilder: (context, isExpanded) {
                            return ListTile(
                              leading: new Icon(
                                Icons.description,
                                size: 24.0,
                                color: Colors.blue,
                              ),
                              title: Text(
                                '$title基本信息',
                                style: new TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w400),
                              ),
                            );
                          },
                          body: new Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.0),
                            child: new Column(
                              children: buildPageList(),
                            ),
                          ),
                          isExpanded: true,
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
                            saveAttachmentToPO();
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

enum AttachmentType {
  COMPONENT,
  CONSUMABLE,
  SERVICE
}
