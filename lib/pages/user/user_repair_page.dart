import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'dart:async';
import 'package:atoi/utils/constants.dart';
import 'package:atoi/utils/http_request.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:atoi/widgets/build_widget.dart';
import 'package:atoi/models/models.dart';
import 'package:atoi/utils/image_util.dart';
import 'dart:typed_data';
import 'package:uuid/uuid.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

/// 用户报修页面类
class UserRepairPage extends StatefulWidget {
  static String tag = 'user-repair-page';
  UserRepairPage({Key key, this.equipment}) : super(key: key);
  final Map<dynamic, dynamic> equipment;

  @override
  _UserRepairPageState createState() => new _UserRepairPageState();
}

class _UserRepairPageState extends State<UserRepairPage> {
  var _isExpandedBasic = true;
  var _isExpandedDetail = false;
  ConstantsModel model;
  //增加操作状态
  bool _stunned = false;
  FocusNode _focusNode = new FocusNode();

  List<dynamic> _imageList = [];

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
          child: new Text(
            method,
            style: new TextStyle(fontSize: 16.0),
          )));
    }
    return items;
  }

  void changedDropDownMethod(String selectedMethod) {
    FocusScope.of(context).requestFocus(new FocusNode());
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
    _serviceResults = iterateMap(model.MachineStatus);
    _dropDownMenuItems = getDropDownMenuItems(_serviceResults);
    _currentResult = _dropDownMenuItems[0].value;
  }

  void initState() {
    model = MainModel.of(context);
    initDropdown();
    super.initState();
  }

  //void showSheet(context) {
  //  showModalBottomSheet(
  //      context: context,
  //      builder: (context) {
  //        return new ListView(
  //          shrinkWrap: true,
  //          children: <Widget>[
  //            ListTile(
  //              trailing: new Icon(Icons.collections),
  //              title: new Text('从相册添加'),
  //              onTap: () {
  //                getImage(ImageSource.gallery);
  //              },
  //            ),
  //            ListTile(
  //              trailing: new Icon(Icons.add_a_photo),
  //              title: new Text('拍照添加'),
  //              onTap: () {
  //                getImage(ImageSource.camera);
  //              },
  //            ),
  //          ],
  //        );
  //      });
  //}

  //Future getImage(ImageSource sourceType) async {
  //  try {
  //    var image = await ImagePicker.pickImage(
  //      source: sourceType,
  //    );
  //    if (image != null) {
  //      var compressed = await FlutterImageCompress.compressAndGetFile(
  //        image.absolute.path,
  //        image.absolute.path,
  //        minHeight: 800,
  //        minWidth: 600,
  //      );
  //      setState(() {
  //        _imageList.add(compressed);
  //      });
  //    }
  //  } catch (e) {
  //    print(e);
  //  }
  //}

  Future<Null> submit() async {
    setState(() {
      _isExpandedDetail = true;
      _isExpandedBasic = true;
    });
    if (_describe.text.isEmpty) {
      showDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
                title: new Text('故障描述不可为空'),
              )).then((result) => _focusNode.requestFocus());
      return;
    }
    List<dynamic> Files = [];
    for (var image in _imageList) {
      var content = base64Encode(image['content']);
      Map _json = {
        'FileContent': content,
        'FileName': 'repair_${Uuid().v1()}.jpg',
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
          {'ID': widget.equipment['ID']}
        ],
        'RequestType': {'ID': 1},
        'FaultDesc': _describe.text,
        'MachineStatus': {
          //'ID': model.FaultRepair[_currentResult]
          'ID': model.MachineStatus[_currentResult]
        },
        'Files': Files
      }
    };
    //改变操作状态防止按钮多次点击
    setState(() {
      _stunned = true;
    });
    var resp = await HttpRequest.request(
      '/Request/AddRequest',
      method: HttpRequest.POST,
      data: _data,
    );
    //改变操作状态释放按钮
    setState(() {
      _stunned = false;
    });
    print(resp);
    if (resp['ResultCode'] == '00') {
      showDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: new Text('报修成功'),
        ),
      ).then(
          (result) => Navigator.of(context, rootNavigator: true).pop(result));
    }
  }

  TextField buildTextField(
      String labelText, String defaultText, bool isEnabled) {
    return new TextField(
      decoration: InputDecoration(
          labelText: labelText,
          labelStyle: new TextStyle(fontSize: 16.0),
          disabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 1))),
      controller: new TextEditingController(text: defaultText),
      enabled: isEnabled,
      style: new TextStyle(fontSize: 16.0),
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

  Padding buildInput(String labelText, TextEditingController controller) {
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
            child: new TextField(
              enabled: true,
              controller: controller,
              style: new TextStyle(fontSize: 18.0),
            ),
          )
        ],
      ),
    );
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

    if (imageList.length > 0) {
      for (var image in imageList) {
        _list.add(new Stack(
          alignment: FractionalOffset(1.0, 0),
          children: <Widget>[
            new Container(
              width: 100.0,
              child: BuildWidget.buildPhotoPageList(context, image['content']),
            ),
            new Padding(
              padding: EdgeInsets.symmetric(horizontal: 0.0),
              child: new IconButton(
                  icon: Icon(Icons.cancel, color: Colors.blue,),
                  color: Colors.white,
                  onPressed: () {

                    imageList.remove(image);
                    setState(() {
                      _imageList = imageList;
                    });
                  }),
            )
          ],
        ));
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
        children: _list);
  }

  @override
  Widget build(BuildContext context) {
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
            padding:
                const EdgeInsets.symmetric(horizontal: 5.0, vertical: 19.0),
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
                      } else {}
                    }
                  });
                },
                children: [
                  new ExpansionPanel(canTapOnHeader: true,
                    headerBuilder: (context, isExpanded) {
                      return ListTile(
                          leading: new Icon(
                            Icons.info,
                            size: 20.0,
                            color: Colors.blue,
                          ),
                          title: Text(
                            '设备基本信息',
                            style: new TextStyle(
                                fontSize: 20.0, fontWeight: FontWeight.w400),
                          ));
                    },
                    body: new Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: new Column(
                        children: <Widget>[
                          BuildWidget.buildRow(
                              '系统编号', widget.equipment['OID'] ?? ''),
                          BuildWidget.buildRow('资产编号', widget.equipment['AssetCode']??''),
                          BuildWidget.buildRow(
                              '名称', widget.equipment['Name'] ?? ''),
                          BuildWidget.buildRow(
                              '型号', widget.equipment['EquipmentCode'] ?? ''),
                          BuildWidget.buildRow(
                              '序列号', widget.equipment['SerialCode'] ?? ''),
                          BuildWidget.buildRow('设备厂商',
                              widget.equipment['Manufacturer']['Name'] ?? ''),
                          BuildWidget.buildRow('使用科室',
                              widget.equipment['Department']['Name'] ?? ''),
                          BuildWidget.buildRow(
                              '安装地点', widget.equipment['InstalSite'] ?? ''),
                          BuildWidget.buildRow(
                              '维保状态', widget.equipment['WarrantyStatus'] ?? ''),
                          BuildWidget.buildRow('服务范围',
                              widget.equipment['ContractScope']['Name'] ?? ''),
                        ],
                      ),
                    ),
                    isExpanded: _isExpandedBasic,
                  ),
                  new ExpansionPanel(canTapOnHeader: true,
                    headerBuilder: (context, isExpanded) {
                      return ListTile(
                          leading: new Icon(
                            Icons.description,
                            size: 20.0,
                            color: Colors.blue,
                          ),
                          title: new Text(
                            '报修内容',
                            style: new TextStyle(
                                fontWeight: FontWeight.w400, fontSize: 20.0),
                          ));
                    },
                    body: new Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: new Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          BuildWidget.buildDropdown('机器状态', _currentResult,
                              _dropDownMenuItems, changedDropDownMethod, context: context, required: true),
                          BuildWidget.buildInput('故障描述', _describe, maxLength: 200, required: true, focusNode: _focusNode),
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
                          buildImageRow(_imageList)
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
                      //根据stunned状态判断按钮是否可用
                      FocusScope.of(context).requestFocus(new FocusNode());
                      return _stunned?null:submit();
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: EdgeInsets.all(12.0),
                    color: AppConstants.AppColors['btn_main'],
                    child: Text('点击报修', style: TextStyle(color: Colors.white)),
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
