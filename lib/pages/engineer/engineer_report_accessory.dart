import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:atoi/widgets/build_widget.dart';
import 'package:atoi/utils/constants.dart';
import 'dart:convert';
import 'package:atoi/utils/http_request.dart';

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
  List _sources = [
    '外部供应商',
    '备件库'
  ];

  List _vendorList = [];
  var _vendors;

  List<DropdownMenuItem<String>> _dropDownMenuSources;
  List<DropdownMenuItem<String>> _dropDownMenuVendors;

  List<DropdownMenuItem<String>> getDropDownMenuItems(List list) {
    List<DropdownMenuItem<String>> items = new List();
    for (String method in list) {
      items.add(new DropdownMenuItem(
          value: method,
          child: new Text(method,
            style: new TextStyle(
                fontSize: 20.0
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
        _vendorList.add(vendor['Name'].length>8?vendor['Name'].substring(0,8):vendor['Name']);
      }
      setState(() {
        _vendors = vendors;
        _dropDownMenuVendors = getDropDownMenuItems(_vendorList);
        _currentVendor = _dropDownMenuVendors[0].value;
      });
    }
  }

  void changedDropDownSource(String selectedMethod) {
    setState(() {
      _currentSource = selectedMethod;
    });
  }

  void changedDropDownVendor(String selectedMethod) {
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
                  fontSize: 20.0,
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
          ),
        )
      ],
    );
  }
  
  void initState() {
    getVendors();
    _dropDownMenuSources = getDropDownMenuItems(_sources);
    _currentSource = _dropDownMenuSources[0].value;
    super.initState();
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
                      fontSize: 20.0,
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
                fontSize: 20.0,
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

  void saveAccessory() async {
    if (_name.text.isEmpty || _newCode.text.isEmpty || _oldCode.text.isEmpty || _qty.text.isEmpty || _amount.text.isEmpty) {
      showDialog(context: context,
        builder: (context) => AlertDialog(
          title: new Text('所有字段均不可为空'),
        )
      );
      return;
    }
    var _supplier = _vendors.singleWhere((_vendor) => _vendor['Name'].toString().startsWith(_currentVendor), orElse: () => null);
    print(_supplier);
    var _newByte = await _imageNew.readAsBytes();
    var imageNew = base64Encode(_newByte);
    var _oldByte = await _imageOld.readAsBytes();
    var imageOld = base64Encode(_oldByte);
    var data = {
      'Name': _name.text,
      'Source': {
        'Name': _currentSource,
        'ID': AppConstants.AccessorySourceType[_currentSource]
      },
      'Supplier': _supplier,
      'NewSerialCode': _newCode.text,
      'OldSerialCode': _oldCode.text,
      'Qty': _qty.text,
      'Amount': _amount.text,
      'FileInfos': [
        {
          'FileName': _imageNew.path,
          'ID': 0,
          'FileType': 1,
          'FileContent': imageNew
        },
        {
          'FileName': _imageOld.path,
          'ID': 0,
          'FileType': 1,
          'FileContent': imageOld
        },
      ]
    };
    Navigator.of(context).pop(data);
  }

  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('新增零件'),
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
      body: new Center(
        child: new ListView(
          children: <Widget>[
            new Card(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  buildInput('名称', _name),
                  BuildWidget.buildDropdown('来源', _currentSource, _dropDownMenuSources, changedDropDownSource),
                  _currentSource=='外部供应商'?BuildWidget.buildDropdown('外部供应商', _currentVendor, _dropDownMenuVendors, changedDropDownVendor):new Container(),
                  buildInput('新装编号', _newCode),
                  new Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: new Text('附件',
                      style: new TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w600
                      ),
                    ),
                  ),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      new IconButton(icon: Icon(Icons.add_a_photo), onPressed: () async {
                        _imageNew = await ImagePicker.pickImage(
                            source: ImageSource.camera,
                            maxWidth: 800.0
                        );
                      }),
                      _imageNew==null?new Container():new Container(width: 100.0, child: new Image.file(_imageNew),)
                    ],
                  ),
                  buildInput('新装部件金额（元/件）', _amount),
                  buildInput('数量', _qty),
                  buildInput('拆下编号', _oldCode),
                  new Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: new Text('附件',
                      style: new TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w600
                      ),
                    ),
                  ),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      new IconButton(icon: Icon(Icons.add_a_photo), onPressed: () async {
                        _imageOld = await ImagePicker.pickImage(
                            source: ImageSource.camera,
                            maxWidth: 800.0
                        );
                      }),
                      _imageOld==null?new Container():new Container(width: 100.0, child: new Image.file(_imageOld),)
                    ],
                  ),
                  ButtonTheme.bar( // make buttons use the appropriate styles for cards
                    child: ButtonBar(
                      children: <Widget>[
                        RaisedButton(
                          child: const Text('保存', style: TextStyle(color: Colors.white),),
                          color: AppConstants.AppColors['btn_main'],
                          onPressed: () {
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