import 'package:flutter/material.dart';
import 'package:atoi/widgets/search_bar.dart';
import 'package:atoi/models/models.dart';
import 'package:scoped_model/scoped_model.dart';
import 'dart:async';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:atoi/utils/http_request.dart';
import 'package:atoi/widgets/build_widget.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class VendorDetail extends StatefulWidget {
  _VendorDetailState createState() => new _VendorDetailState();
}

class _VendorDetailState extends State<VendorDetail> {
  String barcode = "";

  var _isExpandedDetail = true;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  var _fault = new TextEditingController();
  List serviceType = ['厂商', '代理商', '经销商', '其他供应商'];
  List province = [
    "北京市",
    "天津市",
    "上海市",
    "重庆市",
    "河北省",
    "山西省",
    "辽宁省",
    "吉林省",
    "黑龙江省",
    "江苏省",
    "浙江省",
    "安徽省",
    "福建省",
    "江西省",
    "山东省",
    "河南省",
    "湖北省",
    "湖南省",
    "广东省",
    "海南省",
    "四川省",
    "贵州省",
    "云南省",
    "陕西省",
    "甘肃省",
    "青海省",
    "台湾省",
    "内蒙古自治区",
    "广西壮族自治区",
    "西藏自治区",
    "宁夏回族自治区",
    "新疆维吾尔自治区",
    "香港特别行政区",
    "澳门特别行政区"
  ];
  List serviceScope = ['全保', '技术保', '其他保'];
  List<DropdownMenuItem<String>> dropdownType;
  List<DropdownMenuItem<String>> dropdownScope;
  List<DropdownMenuItem<String>> dropdownProvince;
  String currentType;
  String currentScope;
  String currentProvince;

  List vendorStatus = ['启用', '停用'];
  String currentStatus = '启用';
  Map<String, dynamic> supplier;
  String startDate = '起始日期';
  String endDate = '结束日期';

  MainModel mainModel = MainModel();

  List<Map> _equipments = [];

  List<dynamic> _imageList = [];

  void initState() {
    super.initState();
    dropdownType = getDropDownMenuItems(serviceType);
    dropdownProvince = getDropDownMenuItems(province);
    currentType = dropdownType[0].value;
    currentProvince = dropdownProvince[0].value;
  }

  void changeType(String selected) {
    setState(() {
      currentType = selected;
    });
  }

  void changeProvince(String selected) {
    setState(() {
      currentProvince = selected;
    });
  }

  void changeStatus(value) {
    setState(() {
      currentStatus = value;
    });
  }

  Future<String> pickDate() async {
    var val = await showDatePicker(
        context: context,
        initialDate: new DateTime.now(),
        firstDate:
            new DateTime.now().subtract(new Duration(days: 30)), // 减 30 天
        lastDate: new DateTime.now().add(new Duration(days: 30)), // 加 30 天
        locale: Locale('zh'));
    return '${val.year}-${val.month}-${val.day}';
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
        _equipments.add(resp['Data']);
      });
    } else {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: new Text(resp['ResultMessage']),
              ));
    }
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
    if (_equipments == null) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: new Text('请选择设备'),
              ));
      return;
    }
    if (_fault.text.isEmpty || _fault.text == null) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: new Text('盘点备注不可为空'),
              ));
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
          'RequestType': {'ID': 12},
          'Equipments': _equipments,
          'FaultDesc': _fault.text,
          'Files': fileList
        }
      };
      var resp = await HttpRequest.request('/Request/AddRequest',
          method: HttpRequest.POST, data: _data);
      print(resp);
      if (resp['ResultCode'] == '00') {
        showDialog(
            context: context,
            builder: (buider) => AlertDialog(
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
        _list.add(new Stack(
          alignment: FractionalOffset(1.0, 0),
          children: <Widget>[
            new Container(
              width: 100.0,
              child: Image.file(image),
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
            style: new TextStyle(fontSize: 20.0),
          )));
    }
    return items;
  }

  Future toSearch() async {
    final _searchResult =
        await showSearch(context: context, delegate: SearchBarDelegate());
    if (_searchResult != null && _searchResult != 'null') {
      print(_searchResult);
      Map _data = jsonDecode(_searchResult);
      var _result = _equipments.firstWhere(
          (_equipment) => _equipment['OID'] == _data['OID'],
          orElse: () => null);
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
              style: new TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600),
            ),
          ),
          new Expanded(
            flex: 6,
            child: new Text(
              defaultText,
              style: new TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w400,
                  color: Colors.black54),
            ),
          )
        ],
      ),
    );
  }

  Widget buildEquip() {
    List<Widget> tiles = [];
    Widget content;
    for (var _equipment in _equipments) {
      tiles.add(
        new Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.0),
          child: new Column(
            children: <Widget>[
              BuildWidget.buildRow('系统编号', _equipment['OID'] ?? ''),
              BuildWidget.buildRow('名称', _equipment['Name'] ?? ''),
              BuildWidget.buildRow('型号', _equipment['EquipmentCode'] ?? ''),
              BuildWidget.buildRow('序列号', _equipment['SerialCode'] ?? ''),
              BuildWidget.buildRow(
                  '使用科室', _equipment['Department']['Name'] ?? ''),
              BuildWidget.buildRow('安装地点', _equipment['InstalSite'] ?? ''),
              BuildWidget.buildRow(
                  '设备厂商', _equipment['Manufacturer']['Name'] ?? ''),
              BuildWidget.buildRow(
                  '资产等级', _equipment['AssetLevel']['Name'] ?? ''),
              BuildWidget.buildRow('维保状态', _equipment['WarrantyStatus'] ?? ''),
              BuildWidget.buildRow(
                  '服务范围', _equipment['ContractScope']['Name'] ?? ''),
              new Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    new Text('删除此设备'),
                    new IconButton(
                        icon: new Icon(Icons.delete_forever),
                        onPressed: () {
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
              title: new Text('新增供应商'),
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
                        new ExpansionPanel(
                          headerBuilder: (context, isExpanded) {
                            return ListTile(
                              leading: new Icon(
                                Icons.description,
                                size: 24.0,
                                color: Colors.blue,
                              ),
                              title: Text(
                                '供应商基本信息',
                                style: new TextStyle(
                                    fontSize: 22.0,
                                    fontWeight: FontWeight.w400),
                              ),
                            );
                          },
                          body: new Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.0),
                            child: new Column(
                              children: <Widget>[
                                BuildWidget.buildDropdown('类型', currentType,
                                    dropdownType, changeType),
                                BuildWidget.buildDropdown('省份', currentProvince,
                                    dropdownProvince, changeProvince),
                                BuildWidget.buildInput(
                                    '电话', new TextEditingController()),
                                BuildWidget.buildInput(
                                    '地址', new TextEditingController()),
                                BuildWidget.buildInput(
                                    '联系人', new TextEditingController()),
                                BuildWidget.buildInput(
                                    '联系人电话', new TextEditingController()),
                                BuildWidget.buildRadio('供应商经营状态', vendorStatus,
                                    currentStatus, changeStatus),
                                new Divider(),
                                new Padding(
                                  padding: EdgeInsets.symmetric(vertical: 5.0),
                                  child: new Row(
                                    children: <Widget>[
                                      new Text(
                                        '添加附件：',
                                        style: new TextStyle(
                                            fontSize: 20.0,
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
                          child:
                              Text('提交', style: TextStyle(color: Colors.white)),
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
