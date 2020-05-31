import 'package:flutter/material.dart';
import 'package:atoi/widgets/search_bar.dart';
import 'package:atoi/models/models.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:atoi/utils/http_request.dart';
import 'package:atoi/widgets/build_widget.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter/cupertino.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'dart:typed_data';
import 'package:uuid/uuid.dart';
import 'package:atoi/widgets/search_lazy.dart';

/// 不良事件页面类
class BadRequest extends StatefulWidget {
  static String tag = 'bad-request';

  _BadRequestState createState() => new _BadRequestState();
}

class _BadRequestState extends State<BadRequest> {
  String barcode = "";
  bool hold = false;

  var _isExpandedBasic = true;
  var _isExpandedDetail = false;
  var _isExpandedAssign = false;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  var _roleName = '';
  var _fault = new TextEditingController();
  ConstantsModel model;
  FocusNode _focus = new FocusNode();

  List _serviceResults = [];

  var _equipment;

  List<DropdownMenuItem<String>> _dropDownMenuItems;
  String _currentResult;
  List<dynamic> _imageList = [];

  List iterateMap(Map item) {
    var _list = [];
    item.forEach((key, val) {
      _list.add(key);
    });
    return _list;
  }

  void initDropdown() {
    _serviceResults = iterateMap(model.FaultBad);
    _dropDownMenuItems = getDropDownMenuItems(_serviceResults);
    _currentResult = _dropDownMenuItems[0].value;
  }

  void initState() {
    model = MainModel.of(context);
    initDropdown();
    getRole();
    super.initState();
  }

  Future<Null> getDevice() async {
    Map<String, dynamic> params = {
      'codeContent': barcode,
    };
    var resp = await HttpRequest.request('/Equipment/GetDeviceByQRCode',
        method: HttpRequest.GET, params: params);
    print(resp);
    if (resp['ResultCode'] == '00') {
      setState(() {
        _equipment = resp['Data'];
      });
    } else {
      showDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
                title: new Text(resp['ResultMessage']),
              ));
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
      print(_image.identifier);
      if (_imageIdentifiers.indexOf(_image.identifier) < 0) {
        _imageIdentifiers.add(_image.identifier);
        var _data = await _image.getByteData();
        var compressed = await FlutterImageCompress.compressWithList(
          _data.buffer.asUint8List(),
          minHeight: 800,
          minWidth: 600,
        );
        setState(() {
          _imageList.add(Uint8List.fromList(compressed));
        });
      }
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
    if (_equipment == null) {
      showDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
                title: new Text('请选择设备'),
              ));
      return;
    }
    if (_fault.text.isEmpty || _fault.text == null) {
      showDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
                title: new Text('不良事件描述不可为空'),
              )).then((result) => FocusScope.of(context).requestFocus(_focus));
    } else {
      var prefs = await _prefs;
      var userID = prefs.getInt('userID');
      var fileList = [];
      for (var image in _imageList) {
        var fileContent = base64Encode(image);
        var file = {
          'FileContent': fileContent,
          'FileName': 'bad_${Uuid().v1()}.jpg',
          'FileType': 1,
          'ID': 0
        };
        fileList.add(file);
      }
      var _data = {
        'userID': userID,
        'requestInfo': {
          'RequestType': {'ID': 7},
          'Equipments': [
            {'ID': _equipment['ID']}
          ],
          'FaultType': {
            'ID': model.FaultBad[_currentResult],
          },
          'FaultDesc': _fault.text,
          'Files': fileList
        }
      };
      //Fluttertoast.showToast(
      //    msg: "正在上传...",
      //    toastLength: Toast.LENGTH_SHORT,
      //    gravity: ToastGravity.CENTER,
      //    backgroundColor: Colors.black54,
      //    textColor: Colors.white,
      //    fontSize: 16.0);
      //setState(() {
      //  hold = true;
      //});
      var resp = await HttpRequest.request('/Request/AddRequest',
          method: HttpRequest.POST, data: _data);
      //Fluttertoast.cancel();
      //setState(() {
      //  hold = false;
      //});
      print(resp);
      if (resp['ResultCode'] == '00') {
        showDialog(
            context: context,
            builder: (buider) => CupertinoAlertDialog(
                  title: new Text('提交请求成功'),
                )).then(
            (result) => Navigator.of(context, rootNavigator: true).pop(result));
      }
    }
  }

  GridView buildImageRow(List imageList) {
    List<Widget> _list = [];

    if (imageList.length > 0) {
      for (var image in imageList) {
        print(image.runtimeType);
        _list.add(new Stack(
          alignment: FractionalOffset(1.0, 0),
          children: <Widget>[
            new Container(
              width: 100.0,
              child: BuildWidget.buildPhotoPageList(context, image),
            ),
            new Padding(
              padding: EdgeInsets.symmetric(horizontal: 0.0),
              child: new IconButton(
                  icon: Icon(Icons.cancel),
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
    setState(() {
      _currentResult = selectedMethod;
    });
  }

  Future toSearch() async {
    final _searchResult = await Navigator.of(context).push(new MaterialPageRoute(builder: (_) => SearchLazy(searchType: SearchType.DEVICE)));
    Map _data = jsonDecode(_searchResult);
    setState(() {
      //_result.addAll(_data);
      _equipment = _data;
    });
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
              title: new Text('新建请求--不良事件'),
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
                  },
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
                              _isExpandedAssign = !isExpanded;
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
                                size: 20.0,
                                color: Colors.blue,
                              ),
                              title: Text(
                                '设备基本信息',
                                style: new TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w400),
                              ),
                            );
                          },
                          body: new Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.0),
                            child: _equipment == null
                                ? new Center(child: new Text('请选择设备'))
                                : new Column(
                                    children: <Widget>[
                                      BuildWidget.buildRow(
                                          '系统编号', _equipment['OID'] ?? ''),
                                      BuildWidget.buildRow('资产编号', _equipment['AssetCode']??''),
                                      BuildWidget.buildRow(
                                          '名称', _equipment['Name'] ?? ''),
                                      BuildWidget.buildRow('型号',
                                          _equipment['EquipmentCode'] ?? ''),
                                      BuildWidget.buildRow('序列号',
                                          _equipment['SerialCode'] ?? ''),
                                      BuildWidget.buildRow(
                                          '设备厂商',
                                          _equipment['Manufacturer']['Name'] ??
                                              ''),
                                      BuildWidget.buildRow(
                                          '使用科室',
                                          _equipment['Department']['Name'] ??
                                              ''),
                                      BuildWidget.buildRow('安装地点',
                                          _equipment['InstalSite'] ?? ''),
                                      BuildWidget.buildRow('维保状态',
                                          _equipment['WarrantyStatus'] ?? ''),
                                      BuildWidget.buildRow(
                                          '服务范围',
                                          _equipment['ContractScope']['Name'] ??
                                              ''),
                                      new Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 8.0))
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
                                  size: 20.0,
                                  color: Colors.blue,
                                ),
                                title: Text(
                                  '请求详细信息',
                                  style: new TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.w400),
                                ));
                          },
                          body: new Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.0),
                            child: new Column(
                              children: <Widget>[
                                BuildWidget.buildRow('类型', '不良事件'),
                                BuildWidget.buildRow(
                                    '主题',
                                    _equipment == null
                                        ? '--不良事件'
                                        : '${_equipment['Name']}--不良事件'),
                                BuildWidget.buildRow('请求人', _roleName),
                                new Divider(),
                                BuildWidget.buildDropdownLeft('来源：', _currentResult, _dropDownMenuItems, changedDropDownMethod),
                                new Padding(
                                  padding: EdgeInsets.symmetric(vertical: 5.0),
                                  child: new Row(
                                    children: <Widget>[
                                      new Expanded(
                                          flex: 4,
                                          child: Row(
                                            children: <Widget>[
                                              new Text(
                                                '*',
                                                style: new TextStyle(
                                                    color: Colors.red
                                                ),
                                              ),
                                              new Text(
                                                '不良事件描述：',
                                                style: new TextStyle(
                                                    fontSize: 16.0,
                                                    fontWeight: FontWeight.w600
                                                ),
                                              ),
                                            ],
                                          )
                                      ),
                                      new Expanded(
                                        flex: 6,
                                        child: new TextField(
                                          controller: _fault, maxLength: 200, maxLines: 3,
                                          focusNode: _focus,
                                          decoration: InputDecoration(
                                            fillColor: Color(0xfff0f0f0),
                                            filled: true,
                                          ),
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
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.w600),
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
                    SizedBox(height: 20.0),
                    new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        new RaisedButton(
                          onPressed: () {
                            return submit();
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: EdgeInsets.all(12.0),
                          color: new Color(0xff2E94B9),
                          child: Text('提交请求',
                              style: TextStyle(color: Colors.white)),
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
                          child: Text('返回首页',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.0),
                  ],
                ),
              ),
            ));
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
    } on FormatException {
      setState(() => this.barcode =
          'null (User returned using the "back"-button before scanning anything. Result)');
    } catch (e) {
      setState(() => this.barcode = 'Unknown error: $e');
    }
  }
}
