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

  int _component;
  List _componentsList = [];

  int _componentStatus;
  List _componentStatusList = [];

  int _consumable = 0;
  List _consumableList = [];

  ConstantsModel cModel;

  TextEditingController lotNum, spec, model, price, quantity, comments = new TextEditingController();
  TextEditingController componentName = new TextEditingController();
  TextEditingController componentDesc = new TextEditingController();
  TextEditingController componentPrice = new TextEditingController();

  void initState() {
    super.initState();
    if (widget.po != null) {
      getComponent();
    }
    cModel = MainModel.of(context);
    initPageType();
  }

  void initPageType() {
    switch (widget.attachType) {
      case AttachmentType.COMPONENT:
        title = '零件';
        break;
      case AttachmentType.CONSUMABLE:
        title = '耗材';
        break;
      case AttachmentType.SERVICE:
        title = '服务';
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
      _componentStatus = _list[0]['value'];
    });
  }

  void changeComponentStatus(value) {
    print(value);
    FocusScope.of(context).requestFocus(new FocusNode());
    setState(() {
      _componentStatus = value;
    });
  }

  void changeComponent(value) {
    FocusScope.of(context).requestFocus(new FocusNode());
    setState(() {
      _component = value;
    });
  }

  Future<Null> getComponent() async {
    var resp = await HttpRequest.request('/Supplier/GetSupplierById',
        method: HttpRequest.GET, params: {'id': widget.po['ID']});
    if (resp['ResultCode'] == '00') {
      var _data = resp['Data'];
      setState(() {
        oid = _data['OID'];
      });
    }
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
      setState(() {
        _componentsList = _componentsList;
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
                addComponent();
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
      )).then((result) => FocusScope.of(context).requestFocus(_focusComponent[0]));
      return 'fail';
    }
    if (componentDesc.text.isEmpty) {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('零件描述不可为空'),
      )).then((result) => FocusScope.of(context).requestFocus(_focusComponent[0]));
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
            'ID': _componentStatus
          },
          'StdPrice': componentPrice.text
        }
      }
    );
    if (resp['ResultCode'] == '00') {
      return 'ok';
    }
  }

  void addComponent() {
    initComponentStatus();
    showDialog(context: context, builder: (context) => StatefulBuilder(
      builder: (context, setState) => SimpleDialog(
        title: Text('新增零件'),
        children: <Widget>[
          BuildWidget.buildCardRow('富士二类', _fujiClass2Name??''),
          BuildWidget.buildCardInput('简称', componentName, required: true),
          BuildWidget.buildCardInput('描述', componentDesc, required: true),
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
                  value: _componentStatus,
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
                      _componentStatus = value;
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
                color: Colors.redAccent,
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
                color: Colors.blueAccent,
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
    ));
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
                                widget.editable?buildDropdown('选择零件', _component, _componentsList, changeComponent, required: true):BuildWidget.buildRow('零件', _fujiClass2Name),
                                widget.editable?BuildWidget.buildInput('规格', spec, maxLength: 20, focusNode: _focusComponent[4]):BuildWidget.buildRow('地址', spec.text),
                                widget.editable?BuildWidget.buildInput('型号', model, focusNode: _focusComponent[2], required: true):BuildWidget.buildRow('联系人', model.text),
                                widget.editable?BuildWidget.buildInput('单价', price, maxLength: 20, focusNode: _focusComponent[5]):BuildWidget.buildRow('联系人电话', price.text),
                                widget.editable?BuildWidget.buildInput('数量', quantity, focusNode: _focusComponent[2], required: true):BuildWidget.buildRow('入库数量', quantity.text),
                                //widget.editable?new Padding(
                                //  padding: EdgeInsets.symmetric(vertical: 5.0),
                                //  child: new Row(
                                //    children: <Widget>[
                                //      new Expanded(
                                //        flex: 4,
                                //        child: new Wrap(
                                //          alignment: WrapAlignment.end,
                                //          crossAxisAlignment: WrapCrossAlignment.center,
                                //          children: <Widget>[
                                //            new Text(
                                //              '购入日期',
                                //              style: new TextStyle(
                                //                  fontSize: 16.0, fontWeight: FontWeight.w600),
                                //            )
                                //          ],
                                //        ),
                                //      ),
                                //      new Expanded(
                                //        flex: 1,
                                //        child: new Text(
                                //          '：',
                                //          style: new TextStyle(
                                //            fontSize: 16.0,
                                //            fontWeight: FontWeight.w600,
                                //          ),
                                //        ),
                                //      ),
                                //      new Expanded(
                                //        flex: 4,
                                //        child: new Text(
                                //          purchaseDate,
                                //          style: new TextStyle(
                                //              fontSize: 16.0,
                                //              fontWeight: FontWeight.w400,
                                //              color: Colors.black54
                                //          ),
                                //        ),
                                //      ),
                                //      new Expanded(
                                //        flex: 2,
                                //        child: new IconButton(
                                //            icon: Icon(Icons.calendar_today, color: AppConstants.AppColors['btn_main'],),
                                //            onPressed: () async {
                                //              FocusScope.of(context).requestFocus(new FocusNode());
                                //              var _time = DateTime.tryParse(purchaseDate)??DateTime.now();
                                //              DatePicker.showDatePicker(
                                //                context,
                                //                pickerTheme: DateTimePickerTheme(
                                //                  showTitle: true,
                                //                  confirm: Text('确认', style: TextStyle(color: Colors.blueAccent)),
                                //                  cancel: Text('取消', style: TextStyle(color: Colors.redAccent)),
                                //                ),
                                //                minDateTime: DateTime.now().add(Duration(days: -7300)),
                                //                maxDateTime: DateTime.parse('2030-01-01'),
                                //                initialDateTime: _time,
                                //                dateFormat: 'yyyy-MM-dd',
                                //                locale: DateTimePickerLocale.en_us,
                                //                onClose: () => print(""),
                                //                onCancel: () => print('onCancel'),
                                //                onChange: (dateTime, List<int> index) {
                                //                },
                                //                onConfirm: (dateTime, List<int> index) {
                                //                  var _date = formatDate(dateTime, [yyyy, '-', mm, '-', dd]);
                                //                  setState(() {
                                //                    purchaseDate = _date;
                                //                  });
                                //                },
                                //              );
                                //            }),
                                //      ),
                                //    ],
                                //  ),
                                //):BuildWidget.buildRow('购入日期', purchaseDate),
                                //widget.editable?BuildWidget.buildInput('备注', comments, maxLength: 100, focusNode: _focusComponent[5]):BuildWidget.buildRow('备注', comments.text),
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

enum AttachmentType {
  COMPONENT,
  CONSUMABLE,
  SERVICE
}
