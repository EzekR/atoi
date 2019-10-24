import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:atoi/utils/constants.dart';
import 'package:atoi/utils/http_request.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:atoi/widgets/build_widget.dart';
import 'package:atoi/models/models.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class UserRepairPage extends StatefulWidget {
  static String tag = 'user-repair-page';
  UserRepairPage({Key key, this.equipment}):super(key: key);
  final Map<dynamic, dynamic> equipment;

  @override
  _UserRepairPageState createState() => new _UserRepairPageState();

}

class _UserRepairPageState extends State<UserRepairPage> {

  var _isExpandedBasic = true;
  var _isExpandedDetail = false;
  ConstantsModel model;

  List<File> _imageList = [];

  TextEditingController _describe = new TextEditingController();
  TextEditingController _category = new TextEditingController();

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  List _serviceResults = [];

  String _userName = '';

  Future<Null> getRole() async {
    var prefs = await _prefs;
    var userName = prefs.getString('userName');
    setState(() {
      _userName = userName;
    });
  }
  List<DropdownMenuItem<String>> _dropDownMenuItems;
  String _currentResult;

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

  void changedDropDownMethod(String selectedMethod) {
    setState(() {
      _currentResult = selectedMethod;
    });
  }

  List iterateMap(Map item) {
    var _list = [];
    item.forEach((key, val) {
      _list.add(key);
    });
    return _list;
  }

  void initDropdown() {
    _serviceResults = iterateMap(model.FaultRepair);
    _dropDownMenuItems = getDropDownMenuItems(_serviceResults);
    //_currentResult = _dropDownMenuItems[0].value==null?'':_dropDownMenuItems[0];
  }

  void initState() {
    model = MainModel.of(context);
    initDropdown();
    super.initState();
  }

  Future getImage() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.camera,
    );
    if (image != null) {
      var compressed = await FlutterImageCompress.compressAndGetFile(
        image.absolute.path,
        image.absolute.path,
        minHeight: 800,
        minWidth: 600,
      );
      setState(() {
        _imageList.add(compressed);
      });
    }
  }

  Future<Null> submit() async {
    if (_describe.text.isEmpty) {
      showDialog(context: context,
        builder: (context) => AlertDialog(
          title: new Text('故障描述不可为空'),
        )
      );
      return;
    }
    List<dynamic> Files = [];
    for(var image in _imageList) {
      List<int> imageBytes = await image.readAsBytes();
      var content = base64Encode(imageBytes);
      Map _json = {
        'FileContent': content,
        'FileName': image.path,
        'ID': 0,
        'FileType': 1
      };
      Files.add(_json);
    }
    var prefs = await _prefs;
    var userID = prefs.getInt('userID');
    Map<String, dynamic> _data = {
      'userID': userID,
      'requestInfo': {
        'Equipments': [
          {
            'ID': widget.equipment['ID']
          }
        ],
        'RequestType': {
          'ID': 1
        },
        'FaultDesc': _describe.text,
        'FaultType': {
          //'ID': model.FaultRepair[_currentResult]
          'ID': 1
        },
        'Files': Files
      }
    };
    var resp = await HttpRequest.request(
      '/Request/AddRequest',
      method: HttpRequest.POST,
      data: _data,
    );
    print(resp);
    if (resp['ResultCode'] == '00') {
      showDialog(context: context, builder: (context) => AlertDialog(
        title: new Text('报修成功'),
      ),).then((result) =>
        Navigator.of(context, rootNavigator: true).pop(result)
      );
    }
  }

  TextField buildTextField(String labelText, String defaultText, bool isEnabled) {
    return new TextField(
      decoration: InputDecoration(
          labelText: labelText,
          labelStyle: new TextStyle(
              fontSize: 20.0
          ),
          disabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                  color: Colors.grey,
                  width: 1
              )
          )
      ),
      controller: new TextEditingController(text: defaultText),
      enabled: isEnabled,
      style: new TextStyle(
          fontSize: 16.0
      ),
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
              style: new TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w600
              ),
            ),
          ),
          new Expanded(
            flex: 6,
            child: new Text(
              defaultText,
              style: new TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w400,
                  color: Colors.black54
              ),
            ),
          )
        ],
      ),
    );
  }

  Padding buildInput(String labelText, TextEditingController controller) {
    return new Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: new Row(
        children: <Widget>[
          new Expanded(
            flex: 4,
            child: new Text(
              labelText,
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

  GridView buildImageRow(List imageList) {
    List<Widget> _list = [];

    if (imageList.length >0 ){
      for(var image in imageList) {
        _list.add(
            new Stack(
              alignment: FractionalOffset(1.0, 0),
              children: <Widget>[
                new Container(
                  width: 100.0,
                  child: Image.file(image),
                ),
                new Padding(
                  padding: EdgeInsets.symmetric(horizontal: 0.0),
                  child: new IconButton(icon: Icon(Icons.cancel), color: Colors.white, onPressed: (){
                    imageList.remove(image);
                    setState(() {
                      _imageList = imageList;
                    });
                  }),
                )
              ],
            )
        );
      }
    } else {
      _list.add(new Container());
    }

    return new GridView.count(
        shrinkWrap: true,
        primary: false,
        mainAxisSpacing: 5,
        crossAxisSpacing: 5,
        crossAxisCount: 2,
        children: _list
    );
  }

  @override
  Widget build(BuildContext context){
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('设备报修'),
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
        actions: <Widget>[
          new Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 19.0),
            child: Text(_userName),
          ),
        ],
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
                      _isExpandedBasic = !isExpanded;
                    } else {
                      if (index == 1) {
                        _isExpandedDetail = !isExpanded;
                      } else {
                      }
                    }
                  });
                },
                children: [
                  new ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return ListTile(
                          leading: new Icon(
                            Icons.info,
                            size: 24.0,
                            color: Colors.blue,
                          ),
                          title: Text(
                            '设备基本信息',
                            style: new TextStyle(
                                fontSize: 22.0,
                                fontWeight: FontWeight.w400
                            ),
                          )
                      );
                    },
                    body: new Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: new Column(
                        children: <Widget>[
                          BuildWidget.buildRow('系统编号', widget.equipment['OID']??''),
                          BuildWidget.buildRow('名称', widget.equipment['Name']??''),
                          BuildWidget.buildRow('型号', widget.equipment['EquipmentCode']??''),
                          BuildWidget.buildRow('序列号', widget.equipment['SerialCode']??''),
                          BuildWidget.buildRow('使用科室', widget.equipment['Department']['Name']??''),
                          BuildWidget.buildRow('安装地点', widget.equipment['InstalSite']??''),
                          BuildWidget.buildRow('设备厂商', widget.equipment['Manufacturer']['Name']??''),
                          BuildWidget.buildRow('资产等级', widget.equipment['AssetLevel']['Name']??''),
                          BuildWidget.buildRow('维保状态', widget.equipment['WarrantyStatus']??''),
                          BuildWidget.buildRow('服务范围', widget.equipment['ContractScope']['Name']??''),
                        ],
                      ),
                    ),
                    isExpanded: _isExpandedBasic,
                  ),
                  new ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return ListTile(
                          leading: new Icon(
                            Icons.description,
                            size: 24.0,
                            color: Colors.blue,
                          ),
                          title: new Text(
                            '报修内容',
                            style: new TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 22.0
                            ),
                          )
                      );
                    },
                    body: new Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: new Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          BuildWidget.buildInput('故障描述', _describe),
                          BuildWidget.buildDropdown('故障分类', _currentResult, _dropDownMenuItems, changedDropDownMethod),
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
                                        '添加附件：',
                                        style: new TextStyle(
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.w600
                                        ),
                                      ),
                                    ],
                                  )
                                ),
                                new Expanded(
                                  flex: 7,
                                  child: new IconButton(
                                      icon: Icon(Icons.add_a_photo),
                                      onPressed: () {
                                        getImage();
                                      }),
                                )
                              ],
                            ),
                          ),
                          buildImageRow(_imageList)
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
                  new RaisedButton(
                    onPressed: () {
                      submit();
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: EdgeInsets.all(12.0),
                    color: AppConstants.AppColors['btn_main'],
                    child: Text(
                        '点击报修',
                        style: TextStyle(
                            color: Colors.white
                        )
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
