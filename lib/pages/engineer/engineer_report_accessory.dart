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
    if (_name.text.isEmpty) {
      showDialog(context: context,
        builder: (context) => CupertinoAlertDialog(
          title: new Text('名称不可为空'),
        )
      ).then((result) => FocusScope.of(context).requestFocus(_focusAcc[0]));
      return;
    }
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
    if (_amount.text.isEmpty) {
      showDialog(context: context,
          builder: (context) => CupertinoAlertDialog(
            title: new Text('新装部件金额不可为空'),
          )
      ).then((result) => FocusScope.of(context).requestFocus(_focusAcc[3]));
      return;
    }
    if (double.tryParse(_amount.text) > 99999999.99) {
      showDialog(context: context,
          builder: (context) => CupertinoAlertDialog(
            title: new Text('新装部件金额过大'),
          )
      ).then((result) => FocusScope.of(context).requestFocus(_focusAcc[3]));
      return;
    }
    if (_qty.text.isEmpty) {
      showDialog(context: context,
          builder: (context) => CupertinoAlertDialog(
            title: new Text('数量不可为空'),
          )
      ).then((result) => FocusScope.of(context).requestFocus(_focusAcc[4]));
      return;
    }
    if (_qty.text.split('.').length>1) {
      showDialog(context: context,
          builder: (context) => CupertinoAlertDialog(
            title: new Text('零件数量必须为整数'),
          )
      ).then((result) => FocusScope.of(context).requestFocus(_focusAcc[4]));
      return;
    }
    if (int.tryParse(_qty.text) > 999999999) {
      showDialog(context: context,
          builder: (context) => CupertinoAlertDialog(
            title: new Text('数量过大'),
          )
      ).then((result) => FocusScope.of(context).requestFocus(_focusAcc[4]));
      return;
    }
    if (_currentSource == '外部供应商' && _vendor == null) {
      showDialog(context: context,
        builder: (context) => CupertinoAlertDialog(
          title: new Text('请选择供应商'),
        )
      ).then((result) => FocusScope.of(context).requestFocus(_focusAcc[5]));
      return;
    }
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
      'Name': _name.text,
      'Source': {
        'Name': _currentSource,
        'ID': model.AccessorySourceType[_currentSource]
      },
      'Supplier': _currentSource=='备件库'?{'ID': 0}:_supplier,
      'NewSerialCode': _newCode.text,
      'OldSerialCode': _oldCode.text,
      'Qty': _qty.text,
      'Amount': _amount.text,
      'FileInfos': _files
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
                children: <Widget>[
                  BuildWidget.buildInput('名称', _name, focusNode: _focusAcc[0], lines: 1, required: true),
                  BuildWidget.buildDropdown('来源', _currentSource, _dropDownMenuSources, changedDropDownSource, context: context),
                  new SizedBox(
                    height: 5.0,
                  ),
                  _currentSource=='外部供应商'?buildRowVendor('外部供应商', _vendor==null?'':_vendor['Name']):new Container(),
                  BuildWidget.buildInput('新装编号', _newCode, focusNode: _focusAcc[1], lines: 1, required: true),
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
                              RichText(
                                softWrap: true,
                                textAlign: TextAlign.end,
                                text: TextSpan(
                                  text: '*',
                                  style: TextStyle(
                                    color: Colors.red
                                  ),
                                  children: [
                                    new TextSpan(
                                      text: '新装部件金额（元/件）',
                                      style: new TextStyle(
                                          fontSize: 16.0,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600
                                      ),
                                    )
                                  ]
                                )
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
                          child: new TextField(
                            controller: _amount,
                            maxLines: 1,
                            maxLength: 11,
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: true,
                              signed: false
                            ),
                            focusNode: _focusAcc[3],
                            //textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              fillColor: Color(0xfff0f0f0),
                              filled: true,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  BuildWidget.buildInput('数量', _qty, inputType: TextInputType.number, maxLength: 9, focusNode: _focusAcc[4], lines: 1, required: true),
                  BuildWidget.buildInput('拆下编号', _oldCode, focusNode: _focusAcc[2], lines: 1, required: true),
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
                  Container( // make buttons use the appropriate styles for cards
                    child: ButtonBar(
                      children: <Widget>[
                        RaisedButton(
                          child: const Text('保存', style: TextStyle(color: Colors.white),),
                          color: AppConstants.AppColors['btn_main'],
                          onPressed: () {
                            FocusScope.of(context).requestFocus(new FocusNode());
                            saveAccessory();
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
                ],
              ),
            ),
          ],
        )
      )
    );
  }
}