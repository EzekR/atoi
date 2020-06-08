import 'package:flutter/material.dart';
import 'package:atoi/widgets/search_bar_checkbox.dart';
import 'package:atoi/widgets/search_bar.dart';
import 'package:atoi/models/models.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:atoi/utils/http_request.dart';
import 'package:atoi/utils/constants.dart';
import 'package:atoi/widgets/build_widget.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:atoi/widgets/search_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:uuid/uuid.dart';

/// 巡检页面类
class PatrolRequest extends StatefulWidget{
  static String tag = 'patrol-request';

  _PatrolRequestState createState() => new _PatrolRequestState();
}

class _PatrolRequestState extends State<PatrolRequest> {

  String barcode = "";
  bool hold = false;

  var _isExpandedBasic = true;
  var _isExpandedDetail = false;
  var _isExpandedAssign = false;
  var _fault = new TextEditingController();
  FocusNode _focus = new FocusNode();

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  MainModel mainModel = MainModel();

  List _equipments = [];

  List<dynamic> _imageList = [];

  var _role;
  var _roleName;

  Future getRole() async {
    final SharedPreferences prefs = await _prefs;
    _role = await prefs.getInt('role');
    _roleName = prefs.getString('userName');
  }
  void initState(){
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
      var _obj = _equipments.firstWhere((item) => (item['ID'] == resp['Data']['ID']), orElse: () => null);
      if (_obj == null) {
        setState(() {
          _equipments.add(resp['Data']);
        });
      }
    } else {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(title: new Text(resp['ResultMessage']),));
    }
  }

List<String> _imageIdentifiers = [];

Future getImage() async {
  List<Asset> image = await MultiImagePicker.pickImages(
      maxImages: 3,
      enableCamera: true,
  );
  if (image != null) {
    image.forEach((_image) async {
      if (!_imageList.any((item) => item['identity'] == _image.identifier)) {
        var _data = await _image.getByteData();
        var compressed = await FlutterImageCompress.compressWithList(
          _data.buffer.asUint8List(),
          minHeight: 800,
          minWidth: 600,
        );
        setState(() {
          _imageList.add(
            {
              'identity': _image.identifier,
              'content': Uint8List.fromList(compressed)
            }
          );
        });
      }
    });
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
                  child: BuildWidget.buildPhotoPageList(context, image['content']),
                ),
                new Padding(
                  padding: EdgeInsets.symmetric(horizontal: 0.0),
                  child: new IconButton(icon: Icon(Icons.cancel), color: Colors.blue,  onPressed: (){

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

  Future<Null> submit() async {
    if (_equipments.isEmpty) {
      showDialog(context: context,
          builder: (context) => CupertinoAlertDialog(
            title: new Text('请选择设备'),
          )
      );
      return;
    }
    if (_fault.text == null || _fault.text.isEmpty) {
      showDialog(context: context,
        builder: (context) => CupertinoAlertDialog(
          title: new Text('巡检要求不能为空'),
        )
      ).then((result) => FocusScope.of(context).requestFocus(_focus));
    } else {
      var prefs = await _prefs;
      var userID = prefs.getInt('userID');
      var fileList = [];
      for (var image in _imageList) {
        var fileContent = base64Encode(image['content']);
        var file = {
          'FileContent': fileContent,
          'FileName': 'patrol_${Uuid().v1()}.jpg',
          'FileType': 1,
          'ID': 0
        };
        fileList.add(file);
      }
      var _list = [];
      for (var item in _equipments) {
        _list.add({
          'ID': item['ID']
        });
      }
      var _data = {
        'userID': userID,
        'requestInfo': {
          'RequestType': {
            'ID': 4
          },
          'Equipments': _list,
          'FaultDesc': _fault.text,
          'Files': fileList
        }
      };
      setState(() {
        hold = true;
      });
      var resp = await HttpRequest.request(
          '/Request/AddRequest',
          method: HttpRequest.POST,
          data: _data
      );
      setState(() {
        hold = false;
      });
      print(resp);
      if (resp['ResultCode'] == '00') {
        showDialog(context: context, builder: (buider) =>
            CupertinoAlertDialog(
              title: new Text('提交请求成功'),
            )).then((result) =>
            Navigator.of(context, rootNavigator: true).pop(result)
        );
      }
    }
  }
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
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600
              ),
            ),
          ),
          new Expanded(
            flex: 6,
            child: new Text(
              defaultText,
              style: new TextStyle(
                  fontSize: 16.0,
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
              BuildWidget.buildRow('资产编号', _equipment['AssetCode']??''),
              BuildWidget.buildRow('名称', _equipment['Name']??''),
              BuildWidget.buildRow('型号', _equipment['EquipmentCode']??''),
              BuildWidget.buildRow('序列号', _equipment['SerialCode']??''),
              BuildWidget.buildRow('设备厂商', _equipment['Manufacturer']['Name']??''),
              BuildWidget.buildRow('使用科室', _equipment['Department']['Name']??''),
              BuildWidget.buildRow('安装地点', _equipment['InstalSite']??''),
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
              title: new Text('新建请求--巡检'),
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
                  onPressed: () async {
                    Navigator.of(context).push(new MaterialPageRoute(builder: (context) {
                      return SearchPage(equipments: _equipments,);
                    })).then((selected) {
                      if (selected != null) {
                        setState(() {
                          _equipments = selected;
                        });
                      }
                    });
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
                                  size: 20.0,
                                  color: Colors.blue,
                                ),
                                title: Text('设备基本信息',
                                  style: new TextStyle(
                                      fontSize: 20.0,
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
                                  size: 20.0,
                                  color: Colors.blue,
                                ),
                                title:Text('请求详细信息',
                                  style: new TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.w400
                                  ),
                                ),
                            );
                          },
                          body: new Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.0),
                            child: new Column(
                              children: <Widget>[
                                BuildWidget.buildRow('类型', '巡检'),
                                BuildWidget.buildRow('主题', '${_equipments.length==1?_equipments[0]['Name']:'多设备'}--巡检'),
                                BuildWidget.buildRow('请求人', _roleName==null?'':_roleName),
                                new Divider(),
                                BuildWidget.buildInput('巡检要求', _fault, focusNode: _focus, maxLength: 200, lines: 3, required: true),
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
                                                  getImage();
                                                })
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                new SizedBox(
                                  width: 250,
                                  child: buildImageRow(_imageList),
                                ),
                                new Padding(padding: EdgeInsets.symmetric(vertical: 8.0))
                              ],
                            ),
                          ),
                          isExpanded: _isExpandedDetail,
                        ),
                      ],
                    ),
                    SizedBox(height: 20.0),
                    new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        new RaisedButton(
                          onPressed: () {
                            return hold?null:submit();
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
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
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: EdgeInsets.all(12.0),
                          color: new Color(0xffD25565),
                          child: Text('返回首页', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.0),
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
