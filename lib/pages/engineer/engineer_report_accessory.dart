import 'dart:developer';

import 'package:atoi/widgets/search_lazy.dart';
import 'package:atoi/widgets/search_page.dart';
import 'package:flutter/material.dart';
import 'package:atoi/widgets/build_widget.dart';
import 'package:atoi/utils/constants.dart';
import 'dart:convert';
import 'package:atoi/utils/http_request.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:atoi/widgets/search_bar_vendor.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:atoi/models/models.dart';
import 'package:flutter/cupertino.dart';
import 'package:atoi/utils/event_bus.dart';
import 'dart:typed_data';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:uuid/uuid.dart';

/// 报告零配件页面类
class EngineerReportAccessory extends StatefulWidget {
  final AccType accType;
  final int equipmentID;
  final int fujiClass2;
  EngineerReportAccessory({Key key, this.accType, this.equipmentID, this.fujiClass2}):super(key: key);
  _EngineerReportAccessoryState createState() => _EngineerReportAccessoryState();
}

class _EngineerReportAccessoryState extends State<EngineerReportAccessory> {

  var _name = new TextEditingController();
  var _newCode = new TextEditingController();
  var _amount = new TextEditingController();
  var _qty = new TextEditingController();
  var _oldCode = new TextEditingController();
  var _imageNew;
  var _imageOld;
  String _currentSource;
  String _currentVendor;
  List _sources = [];
  ConstantsModel model;
  bool hold = false;

  List _vendorList = [];
  var _vendors;
  var _vendor;
  List<DropdownMenuItem<String>> _dropDownMenuSources;
  List<DropdownMenuItem<String>> _dropDownMenuVendors;
  Map newComponent;
  Map oldComponent;
  List consumables = [];
  int consumable;
  List batches = [];
  List batchesRaw = [];
  int batch;
  TextEditingController consumableQuantity = new TextEditingController();
  List services = [];
  int service;

  List<DropdownMenuItem<String>> getDropDownMenuItems(List list) {
    List<DropdownMenuItem<String>> items = new List();
    for (String method in list) {
      items.add(new DropdownMenuItem(
          value: method,
          child: new Text(method,
            style: new TextStyle(
                fontSize: 16.0
            ),
          )
      ));
    }
    return items;
  }

  Future<Null> getVendors() async {
    var resp = await HttpRequest.request(
      '/DispatchReport/GetSuppliers?filterText=',
      method: HttpRequest.GET
    );
    print(resp);
    if (resp['ResultCode'] == '00') {
      var vendors = resp['Data'];
      for (var vendor in vendors) {
        //_vendorList.add(vendor['Name'].length>8?vendor['Name'].substring(0,8):vendor['Name']);
        _vendorList.add(vendor['Name']);
      }
      setState(() {
        _vendors = vendors;
        _dropDownMenuVendors = getDropDownMenuItems(_vendorList);
        _currentVendor = _dropDownMenuVendors[0].value;
      });
    }
  }

  void getConsumable() async {
    Map resp = await HttpRequest.request(
      '/InvConsumable/QueryConsumablesByFujiClass2ID',
      method: HttpRequest.GET,
      params: {
        'fujiClass2ID': widget.fujiClass2
      }
    );
    if (resp['ResultCode'] == '00') {
      setState(() {
        consumables = resp['Data'];
      });
    }
  }

  void getBatch() async {
    Map resp = await HttpRequest.request(
      '/InvConsumable/QueryConsumableList',
      method: HttpRequest.GET,
      params: {
        'filterField': 'ic.ConsumableID',
        'filterText': consumable,
        'sortField': 'ic.ID',
        'sortDirection': true,
        'fujiClass2ID': 0
      }
    );
    if (resp['ResultCode'] == '00') {
      setState(() {
        batchesRaw = resp['Data'];
        batches = resp['Data'].map((item) => {
          'ID': item['ID'],
          'Name': item['LotNum']
        }).toList();
      });
    }
  }

  void getServices() async {
    Map resp = await HttpRequest.request(
      '/InvService/QueryServiceList',
      method: HttpRequest.GET,
      params: {
        'statusID': 2,
        'filterField': 'e.ID',
        'filterText': widget.equipmentID,
        'sortField': 'se.ID',
        'sortDirection': true
      }
    );
    if (resp['ResultCode'] == '00') {
      setState(() {
        services = resp['Data'];
      });
    }
  }

  void changedDropDownSource(String selectedMethod) {
    FocusScope.of(context).requestFocus(new FocusNode());
    setState(() {
      _currentSource = selectedMethod;
    });
  }

  void changedDropDownVendor(String selectedMethod) {
    FocusScope.of(context).requestFocus(new FocusNode());
    setState(() {
      _currentVendor = selectedMethod;
    });
  }

  Row buildDropdown(String title, String currentItem, List dropdownItems, Function changeDropdown) {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        new Expanded(
          flex: 4,
          child: new Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
            child: new Text(
              title,
              style: new TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600
              ),
            ),
          ),
        ),
        new Expanded(
          flex: 6,
          child: new DropdownButton(
            value: currentItem,
            items: dropdownItems,
            onChanged: changeDropdown,
            isExpanded: true,
            isDense: true,
            style: new TextStyle(
              fontSize: 10.0,
              color: Colors.black54
            ),
          ),
        )
      ],
    );
  }

  List iterateMap(Map item) {
    var _list = [];
    item.forEach((key, val) {
      _list.add(key);
    });
    return _list;
  }
  
  void initDropdown() {
    _sources = iterateMap(model.AccessorySourceType);
    _dropDownMenuSources = getDropDownMenuItems(_sources);
    _currentSource = _dropDownMenuSources[0].value;
  }
  
  void initState() {
    getVendors();
    model = MainModel.of(context);
    initDropdown();
    super.initState();
    if (widget.accType == AccType.CONSUMABLE) {
      getConsumable();
    }
    if (widget.accType == AccType.SERVICE) {
      getServices();
    }
  }

  Future getImage(String imageType) async {
    List<Asset> image = await MultiImagePicker.pickImages(
        maxImages: 1,
        enableCamera: true
    );
    if (image != null) {
      image.forEach((_image) async {
        var _data = await _image.getByteData();
        var compressed = await FlutterImageCompress.compressWithList(
          _data.buffer.asUint8List(),
          minHeight: 800,
          minWidth: 600,
        );
        setState(() {
          imageType=='new'?_imageNew = Uint8List.fromList(compressed):_imageOld = Uint8List.fromList(compressed);
        });
      });
    }
  }

  Padding buildInput(String labelText, TextEditingController controller) {
    return new Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
      child: new Row(
        children: <Widget>[
          new Expanded(
            flex: 4,
            child: new Wrap(
              alignment: WrapAlignment.end,
              children: <Widget>[
                new Text(
                  labelText,
                  style: new TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600
                  ),
                ),
              ],
            )
          ),
          new Expanded(
            flex: 1,
            child: new Text(
              '：',
              style: new TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w600
              ),
            ),
          ),
          new Expanded(
            flex: 6,
            child: new TextField(
              enabled: true,
              controller: controller,
              style: new TextStyle(
                  fontSize: 18.0
              ),
            ),
          )
        ],
      ),
    );
  }

  List<FocusNode> _focusAcc = new List(10).map((item) {
    return new FocusNode();
  }).toList();

  void saveAccessory() async {
    //if (_name.text.isEmpty) {
    //  showDialog(context: context,
    //    builder: (context) => CupertinoAlertDialog(
    //      title: new Text('名称不可为空'),
    //    )
    //  ).then((result) => FocusScope.of(context).requestFocus(_focusAcc[0]));
    //  return;
    //}
    if (_newCode.text.isEmpty) {
      showDialog(context: context,
          builder: (context) => CupertinoAlertDialog(
            title: new Text('新装编号不可为空'),
          )
      ).then((result) => FocusScope.of(context).requestFocus(_focusAcc[1]));
      return;
    }
    if (_oldCode.text.isEmpty) {
      showDialog(context: context,
          builder: (context) => CupertinoAlertDialog(
            title: new Text('拆下不可为空'),
          )
      ).then((result) => FocusScope.of(context).requestFocus(_focusAcc[2]));
      return;
    }
    //if (_amount.text.isEmpty) {
    //  showDialog(context: context,
    //      builder: (context) => CupertinoAlertDialog(
    //        title: new Text('新装部件金额不可为空'),
    //      )
    //  ).then((result) => FocusScope.of(context).requestFocus(_focusAcc[3]));
    //  return;
    //}
    //if (double.tryParse(_amount.text) > 99999999.99) {
    //  showDialog(context: context,
    //      builder: (context) => CupertinoAlertDialog(
    //        title: new Text('新装部件金额过大'),
    //      )
    //  ).then((result) => FocusScope.of(context).requestFocus(_focusAcc[3]));
    //  return;
    //}
    //if (_qty.text.isEmpty) {
    //  showDialog(context: context,
    //      builder: (context) => CupertinoAlertDialog(
    //        title: new Text('数量不可为空'),
    //      )
    //  ).then((result) => FocusScope.of(context).requestFocus(_focusAcc[4]));
    //  return;
    //}
    //if (_qty.text.split('.').length>1) {
    //  showDialog(context: context,
    //      builder: (context) => CupertinoAlertDialog(
    //        title: new Text('零件数量必须为整数'),
    //      )
    //  ).then((result) => FocusScope.of(context).requestFocus(_focusAcc[4]));
    //  return;
    //}
    //if (int.tryParse(_qty.text) > 999999999) {
    //  showDialog(context: context,
    //      builder: (context) => CupertinoAlertDialog(
    //        title: new Text('数量过大'),
    //      )
    //  ).then((result) => FocusScope.of(context).requestFocus(_focusAcc[4]));
    //  return;
    //}
    //if (_currentSource == '外部供应商' && _vendor == null) {
    //  showDialog(context: context,
    //    builder: (context) => CupertinoAlertDialog(
    //      title: new Text('请选择供应商'),
    //    )
    //  ).then((result) => FocusScope.of(context).requestFocus(_focusAcc[5]));
    //  return;
    //}
    var _supplier = _vendor;
    print(_supplier);
    var imageNew;
    var imageOld;
    List<Map> _files = [];
    if (_imageNew != null) {
      imageNew = base64Encode(_imageNew);
      _files.add(
        {
          'FileName': 'acc_new_${Uuid().v1()}.jpg',
          'ID': 0,
          'FileType': 1,
          'FileContent': imageNew
        }
      );
    }
    if (_imageOld != null) {
      imageOld = base64Encode(_imageOld);
      _files.add(
        {
          'FileName': 'acc_old_${Uuid().v1()}.jpg',
          'ID': 0,
          'FileType': 2,
          'FileContent': imageOld
        }
      );
    }
    var data = {
      //'Name': _name.text,
      //'Source': {
      //  'Name': _currentSource,
      //  'ID': model.AccessorySourceType[_currentSource]
      //},
      //'Supplier': _currentSource=='备件库'?{'ID': 0}:_supplier,
      'DispatchReportID': 0,
      'OldSerialCode': _oldCode.text,
      'UsedDate': '',
      'Component': {
        'ID': newComponent['Component']['ID']
      },
      'NewInvComponent': newComponent,
      'OldInvComponent': oldComponent,
      'FileInfos': _files
    };
    Navigator.of(context).pop(data);
  }

  void saveConsumable() {
    if (consumable == null) {
      showDialog(context: context,
          builder: (context) => CupertinoAlertDialog(
            title: new Text('耗材不可为空'),
          )
      ).then((result) => FocusScope.of(context).requestFocus(_focusAcc[1]));
      return;
    }
    if (batch == null) {
      showDialog(context: context,
          builder: (context) => CupertinoAlertDialog(
            title: new Text('批次号不可为空'),
          )
      ).then((result) => FocusScope.of(context).requestFocus(_focusAcc[1]));
      return;
    }
    if (consumableQuantity.text.isEmpty) {
      showDialog(context: context,
          builder: (context) => CupertinoAlertDialog(
            title: new Text('数量不可为空'),
          )
      ).then((result) => FocusScope.of(context).requestFocus(_focusAcc[9]));
      return;
    }
    Map data = {
      'InvConsumable': batchesRaw.firstWhere((item) => item['ID'] == batch, orElse: null),
      'Qty': consumableQuantity.text
    };
    Navigator.of(context).pop(data);
  }

  void saveService() {
    if (service == null) {
      showDialog(context: context,
          builder: (context) => CupertinoAlertDialog(
            title: new Text('服务不可为空'),
          )
      ).then((result) => FocusScope.of(context).requestFocus(_focusAcc[1]));
      return;
    }
    Map data = {
      'Service': services.firstWhere((item) => item['ID'] == service, orElse: null),
    };
    Navigator.of(context).pop(data);
  }

  Padding buildRowVendor(String labelText, String vendor) {
    return new Padding(
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
                  style: TextStyle(color: Colors.red),
                ),
                new Text(
                  labelText,
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
            flex: 3,
              child: new Text(
                vendor,
                style: new TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w400,
                    color: Colors.black54
                ),
              )
          ),
          new Expanded(
              flex: 3,
              child: new IconButton(
                  icon: Icon(Icons.search),
                  focusNode: _focusAcc[5],
                  onPressed: () async {
                    final _searchResult = await showSearch(context: context, delegate: SearchBarVendor(), hintText: '请输入供应商名称');
                    print(_searchResult);
                    if (_searchResult != null && _searchResult != 'null') {
                      setState(() {
                        _vendor = jsonDecode(_searchResult);
                      });
                    }
                  }
              )
          ),
        ],
      ),
    );
  }

  void searchNew() async {
    Map data = await searchComponent();
    setState(() {
      newComponent = data;
      _newCode.text = newComponent['SerialCode'];
    });
  }

  void searchOld() async {
    Map data = await searchComponent();
    setState(() {
      oldComponent = data;
      _oldCode.text = oldComponent['SerialCode'];
    });
  }

  Future<Map> searchComponent() async {
    String result = await Navigator.of(context).push(new MaterialPageRoute(builder: (_) => SearchLazy(searchType: SearchType.COMPONENT, equipmentID: widget.equipmentID,)));
    Map data = jsonDecode(result);
    return data;
  }

  List<Widget> _buildStuff() {
    List<Widget> _list = [];
    switch (widget.accType) {
      case AccType.COMPONENT:
        _list.addAll([
          //BuildWidget.buildInput('名称', _name, focusNode: _focusAcc[0], lines: 1, required: true),
          //BuildWidget.buildDropdown('来源', _currentSource, _dropDownMenuSources, changedDropDownSource, context: context),
          //new SizedBox(
          //  height: 5.0,
          //),
          //_currentSource=='外部供应商'?buildRowVendor('外部供应商', _vendor==null?'':_vendor['Name']):new Container(),
          BuildWidget.buildInputWithSearch('新装编号', _newCode, focusNode: _focusAcc[1], lines: 1, required: true, pressed: searchNew, enabled: false),
          new Padding(
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
                        '附件',
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      new IconButton(
                          icon: Icon(Icons.add_a_photo),
                          onPressed: () {
                            FocusScope.of(context).requestFocus(new FocusNode());
                            getImage('new');
                          })
                    ],
                  ),
                )
              ],
            ),
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _imageNew==null?new Container():
              new Stack(
                alignment: FractionalOffset(1.0, 0),
                children: <Widget>[
                  new Container(
                    width: 150.0,
                    child: BuildWidget.buildPhotoPageList(context, _imageNew),
                  ),
                  new Padding(
                    padding: EdgeInsets.symmetric(horizontal: 0.0),
                    child: new IconButton(icon: Icon(Icons.cancel), color: Colors.blue,  onPressed: (){
                      setState(() {
                        _imageNew = null;
                      });
                    }),
                  )
                ],
              )
            ],
          ),
          BuildWidget.buildInputWithSearch('拆下编号', _oldCode, focusNode: _focusAcc[2], lines: 1, required: true, enabled: true, pressed: searchOld),
          new Padding(
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
                        '附件',
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      new IconButton(
                          icon: Icon(Icons.add_a_photo),
                          onPressed: () {
                            FocusScope.of(context).requestFocus(new FocusNode());
                            getImage('old');
                          })
                    ],
                  ),
                )
              ],
            ),
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _imageOld==null?new Container():
              new Stack(
                alignment: FractionalOffset(1.0, 0),
                children: <Widget>[
                  new Container(
                    width: 150.0,
                    child: BuildWidget.buildPhotoPageList(context, _imageOld),
                  ),
                  new Padding(
                    padding: EdgeInsets.symmetric(horizontal: 0.0),
                    child: new IconButton(icon: Icon(Icons.cancel), color: Colors.blue,  onPressed: (){
                      setState(() {
                        _imageOld = null;
                      });
                    }),
                  )
                ],
              )
            ],
          ),
        ]);
        break;
      case AccType.CONSUMABLE:
        _list.addAll([
          BuildWidget.buildDropdownNew('耗材简称', consumable, consumables, (val) => setState(() {consumable=val; getBatch();}), required: true),
          BuildWidget.buildDropdownNew('批次号', batch, batches, (val)=>setState((){batch = val;}), required: true),
          BuildWidget.buildInput('数量', consumableQuantity, lines: 1, maxLength: 13, required: true, focusNode: _focusAcc[9])
        ]);
        break;
      case AccType.SERVICE:
        _list.addAll([
          BuildWidget.buildDropdownNew('外购维修服务', service, services, (val)=>setState((){service=val;}), required: true)
        ]);
        break;
    }
    _list.add(
      Container( // make buttons use the appropriate styles for cards
        child: ButtonBar(
          children: <Widget>[
            RaisedButton(
              child: const Text('保存', style: TextStyle(color: Colors.white),),
              color: AppConstants.AppColors['btn_main'],
              onPressed: () {
                FocusScope.of(context).requestFocus(new FocusNode());
                switch (widget.accType) {
                  case AccType.COMPONENT:
                    saveAccessory();
                    break;
                  case AccType.CONSUMABLE:
                    saveConsumable();
                    break;
                  case AccType.SERVICE:
                    saveService();
                    break;
                }
              },
            ),
            RaisedButton(
              child: const Text('取消', style: TextStyle(color: Colors.white),),
              color: AppConstants.AppColors['btn_cancel'],
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
    return _list;
  }

  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('新增零配件'),
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
        ),
        body: _vendorList.isEmpty?new Center(child: SpinKitThreeBounce(color: Colors.blue,),):new Center(
            child: new ListView(
              children: <Widget>[
                new Card(
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _buildStuff(),
                  ),
                ),
              ],
            )
        )
    );
  }
}

enum AccType {
  COMPONENT,
  CONSUMABLE,
  SERVICE
}