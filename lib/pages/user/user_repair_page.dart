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

  List<File> _imageList = [];

  TextEditingController _describe = new TextEditingController();
  TextEditingController _category = new TextEditingController();

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  void initState() {
    super.initState();
  }

  Map<String, String> _reqBody = {
    'name': '真田新村',
    'phone': ''
  };

  Future getImage() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800.0
    );
    setState(() {
      _imageList.add(image);
    });
  }

  Future uploadImage() async {
    FormData _formData = new FormData.from({
      "describe": _describe.text,
      "category": _category.text
    });
    if (_imageList.length > 0) {
      for(var i=0; i<_imageList.length; i++) {
        var path = _imageList[i].path;
        var name = path.substring(path.lastIndexOf("/") + 1, path.length);
        var suffix = name.substring(name.lastIndexOf(".") + 1, name.length);
        _formData.add("file$i", new UploadFileInfo(_imageList[i], _imageList[i].path, contentType: ContentType.parse("image/$suffix")));
      }
    }
    print(_formData);
    Dio dio = new Dio();
    var response = await dio.post<String>("http://api.stramogroup.com/request", data: _formData);
    if (response.statusCode == 200) {
      var result = await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('报修成功'),
              )
          );
      Navigator.of(context).pop();
    }
  }

  Future<Null> submit() async {
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
        'Subject': '用户报修',
        'FaultDesc': _describe.text,
        'StatudID': 1,
        'FaultType': {
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
      print('yes');
      showDialog(context: context, builder: (context) => AlertDialog(
        title: new Text('报修成功'),
      ),
      ).then((result) =>
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

  Row buildImageRow(List imageList) {
    List<Widget> _list = [];

    if (imageList.length >0 ){
      for(var image in imageList) {
        _list.add(
            new Container(
              width: 100.0,
              child: Image.file(image),
            )
        );
      }
    } else {
      _list.add(new Container());
    }

    _list.add(new IconButton(icon: Icon(Icons.add_a_photo), onPressed: () {
      getImage();
    }));

    return new Row(
      mainAxisAlignment: MainAxisAlignment.start,
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
          new Icon(Icons.face),
          new Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 19.0),
            child: const Text('真田信村'),
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
                          buildRow('设备系统编号：', widget.equipment['OID']),
                          buildRow('设备名称：', widget.equipment['Name']),
                          buildRow('使用科室：', widget.equipment['Department']['Name']),
                          buildRow('设备厂商：', widget.equipment['Manufacturer']['Name']),
                          buildRow('资产等级：', widget.equipment['AssetLevel']['Name']),
                          buildRow('设备型号：', widget.equipment['EquipmentCode']),
                          buildRow('安装地点：', widget.equipment['InstalSite']),
                          buildRow('保修状况：', widget.equipment['WarrantyStatus']),
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
                          buildInput('故障描述：', _describe),
                          buildRow('故障分类：', '未知'),
                          new Padding(
                            padding: EdgeInsets.symmetric(vertical: 5.0),
                            child: new Text('上传故障照片',
                              style: new TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.grey
                              ),
                            ),
                          ),
                          buildImageRow(_imageList)
                          //new Row(
                          //  mainAxisAlignment: MainAxisAlignment.start,
                          //  children: <Widget>[
                          //    new ListView.builder(
                          //        shrinkWrap: true,
                          //        scrollDirection: Axis.horizontal,
                          //        itemCount: _imageList.length,
                          //        itemBuilder: (context, i) => new Container(
                          //          width: 200.0,
                          //          child: new Image.file(_imageList[i], width: 200.0),
                          //        )
                          //    ),
                          //    new IconButton(
                          //        icon: Icon(Icons.add_a_photo),
                          //        onPressed: () {
                          //          getImage();
                          //        }
                          //    )
                          //  ],
                          //),
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
                    color: Colors.indigo,
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
