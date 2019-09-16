import 'package:flutter/material.dart';
import 'package:atoi/widgets/search_bar.dart';
import 'package:atoi/models/models.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:atoi/utils/http_request.dart';
import 'package:atoi/widgets/build_widget.dart';

class EquipmentCheck extends StatefulWidget{
  static String tag = 'equipment-check';

  _EquipmentCheckState createState() => new _EquipmentCheckState();
}

class _EquipmentCheckState extends State<EquipmentCheck> {

  String barcode = "";

  var _isExpandedBasic = true;
  var _isExpandedDetail = false;
  var _isExpandedAssign = false;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  var _roleName;
  var _fault = new TextEditingController();

  MainModel mainModel = MainModel();

  List _serviceResults = [
    '未知',
    '已知'
  ];

  Map<String, dynamic> _result = {
    'equipNo': '',
    'equipLevel': '',
    'name': '',
    'model': '',
    'department': '',
    'location': '',
    'manufacturer': '',
    'guarantee': ''
  };

  List<Map> _equipments = [];

  List<DropdownMenuItem<String>> _dropDownMenuItems;
  String _currentResult;
  List<dynamic> _imageList = [];

  void initState(){
    _dropDownMenuItems = getDropDownMenuItems(_serviceResults);
    _currentResult = _dropDownMenuItems[0].value;
    getRole();
    super.initState();
  }

  Future<Null> getDevice() async {
    Map<String, dynamic> params = {
      'codeContent': barcode,
    };
    var resp = await HttpRequest.request(
        '/Equipment/GetDeviceByQRCode',
        method: HttpRequest.GET,
        params: params
    );
    print(resp);
    if (resp['ResultCode'] == '00') {
      setState(() {
        _equipments.add(resp['Data']);
      });
    }
  }
  Future getImage() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 1
    );
    if (image != null) {
      setState(() {
        _imageList.add(image);
      });
    }
  }

  Future getRole() async {
    final SharedPreferences prefs = await _prefs;
    setState(() {
      _roleName = prefs.getString('userName');
    });
  }

  Future<Null> submit() async {
    if (_equipments == null) {
      showDialog(context: context,
          builder: (context) => AlertDialog(
            title: new Text('请选择设备'),
          )
      );
      return;
    }
    if (_fault.text.isEmpty || _fault.text == null) {
      showDialog(context: context,
          builder: (context) => AlertDialog(
            title: new Text('盘点备注不可为空'),
          )
      );
    } else {
      var prefs = await _prefs;
      var userID = prefs.getInt('userID');
      var fileList = [];
      for (var image in _imageList) {
        List<int> imageBytes = await image.readAsBytes();
        var fileContent = base64Encode(imageBytes);
        var file = {
          'FileContent': fileContent,
          'FileName': image.path,
          'FiltType': 1,
          'ID': 0
        };
        fileList.add(file);
      }
      var _data = {
        'userID': userID,
        'requestInfo': {
          'RequestType': {
            'ID': 12
          },
          'Equipments': _equipments,
          'FaultDesc': _fault.text,
          'Files': fileList
        }
      };
      var resp = await HttpRequest.request(
          '/Request/AddRequest',
          method: HttpRequest.POST,
          data: _data
      );
      print(resp);
      if (resp['ResultCode'] == '00') {
        showDialog(context: context, builder: (buider) =>
            AlertDialog(
              title: new Text('提交请求成功'),
            )).then((result) =>
            Navigator.of(context, rootNavigator: true).pop(result)
        );
      }
    }
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

  Future toSearch() async {
    final _searchResult = await showSearch(context: context, delegate: SearchBarDelegate());
    if (_searchResult != null && _searchResult != 'null') {
      print(_searchResult);
      Map _data = jsonDecode(_searchResult);
      var _result = _equipments.firstWhere((_equipment) => _equipment['OID'] == _data['OID'], orElse: ()=> null);
      if (_result == null) {
        setState(() {
          _equipments.add(_data);
        });
      }
    }
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

  Widget buildEquip() {
    List<Widget> tiles = [];
    Widget content;
    for(var _equipment in _equipments) {
      tiles.add(
        new Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.0),
          child: new Column(
            children: <Widget>[
              BuildWidget.buildRow('系统编号', _equipment['OID']??''),
              BuildWidget.buildRow('名称', _equipment['Name']??''),
              BuildWidget.buildRow('型号', _equipment['EquipmentCode']??''),
              BuildWidget.buildRow('序列号', _equipment['SerialCode']??''),
              BuildWidget.buildRow('使用科室', _equipment['Department']['Name']??''),
              BuildWidget.buildRow('安装地点', _equipment['InstalSite']??''),
              BuildWidget.buildRow('设备厂商', _equipment['Manufacturer']['Name']??''),
              BuildWidget.buildRow('资产等级', _equipment['AssetLevel']['Name']??''),
              BuildWidget.buildRow('维保状态', _equipment['WarrantyStatus']??''),
              BuildWidget.buildRow('服务范围', _equipment['ContractScope']['Name']??''),
              new Padding(padding: EdgeInsets.symmetric(vertical: 8.0),
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    new Text('删除此设备'),
                    new IconButton(icon: new Icon(Icons.delete_forever), onPressed: (){
                      _equipments.remove(_equipment);
                      setState(() {
                        _equipments = _equipments;
                      });
                    })
                  ],
                ),
              )
            ],
          ),
        ),
      );
    }
    content = new Column(
      children: tiles,
    );
    return content;
  }
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (context, child, mainModel) {
        return new Scaffold(
            appBar: new AppBar(
              title: new Text('新建请求--盘点'),
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
                new IconButton(
                  icon: Icon(Icons.search),
                  color: Colors.white,
                  iconSize: 30.0,
                  onPressed: () {
                    toSearch();
                  }
                  ,
                ),
                new IconButton(
                    icon: Icon(Icons.crop_free),
                    color: Colors.white,
                    iconSize: 30.0,
                    onPressed: () {
                      scan();
                    })
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
                              _isExpandedAssign =!isExpanded;
                            }
                          }
                        });
                      },
                      children: [
                        new ExpansionPanel(
                          headerBuilder: (context, isExpanded) {
                            return ListTile(
                                leading: new Icon(Icons.info,
                                  size: 24.0,
                                  color: Colors.blue,
                                ),
                                title: Text('设备基本信息',
                                  style: new TextStyle(
                                      fontSize: 22.0,
                                      fontWeight: FontWeight.w400
                                  ),
                                ),
                            );
                          },
                          body: _equipments.length==0?new Center(child: new Text('请选择设备')):buildEquip(),
                          isExpanded: _isExpandedBasic,
                        ),
                        new ExpansionPanel(
                          headerBuilder: (context, isExpanded) {
                            return ListTile(
                                leading: new Icon(Icons.description,
                                  size: 24.0,
                                  color: Colors.blue,
                                ),
                                title: Text('请求详细信息',
                                  style: new TextStyle(
                                      fontSize: 22.0,
                                      fontWeight: FontWeight.w400
                                  ),
                                ),
                            );
                          },
                          body: new Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.0),
                            child: new Column(
                              children: <Widget>[
                                BuildWidget.buildRow('类型', '盘点'),
                                BuildWidget.buildRow('请求人', _roleName),
                                BuildWidget.buildRow('主题', _equipments==null?'--盘点':'多设备--盘点'),
                                new Divider(),
                                new Padding(
                                  padding: EdgeInsets.symmetric(vertical: 5.0),
                                  child: new Row(
                                    children: <Widget>[
                                      new Expanded(
                                        flex: 4,
                                        child: new Text(
                                          '盘点备注：',
                                          style: new TextStyle(
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.w600
                                          ),
                                        ),
                                      ),
                                      new Expanded(
                                        flex: 6,
                                        child: new TextField(
                                          controller: _fault,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                new Padding(
                                  padding: EdgeInsets.symmetric(vertical: 5.0),
                                  child: new Row(
                                    children: <Widget>[
                                      new Text(
                                        '添加附件：',
                                        style: new TextStyle(
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.w600
                                        ),
                                      ),
                                      new IconButton(
                                          icon: Icon(Icons.add_a_photo),
                                          onPressed: () {
                                            getImage();
                                          })
                                    ],
                                  ),
                                ),
                                buildImageRow(_imageList),
                                new Padding(padding: EdgeInsets.symmetric(vertical: 8.0))
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
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: EdgeInsets.all(12.0),
                          color: new Color(0xff2E94B9),
                          child: Text('提交请求', style: TextStyle(color: Colors.white)),
                        ),
                        new RaisedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: EdgeInsets.all(12.0),
                          color: new Color(0xffD25565),
                          child: Text('返回首页', style: TextStyle(color: Colors.white)),
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

  Future scan() async {
    try {
      String barcode = await BarcodeScanner.scan();
      setState(() {
        return this.barcode = barcode;
      });
      await getDevice();
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          return this.barcode = 'The user did not grant the camera permission!';
        });
      } else {
        setState(() {
          return this.barcode = 'Unknown error: $e';
        });
      }
    } on FormatException{
      setState(() => this.barcode = 'null (User returned using the "back"-button before scanning anything. Result)');
    } catch (e) {
      setState(() => this.barcode = 'Unknown error: $e');
    }
  }
}
