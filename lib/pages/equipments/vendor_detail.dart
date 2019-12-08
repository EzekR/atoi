import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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
import 'package:atoi/models/constants_model.dart';

class VendorDetail extends StatefulWidget {
  VendorDetail({Key key, this.vendor}) : super(key: key);
  final Map vendor;
  _VendorDetailState createState() => new _VendorDetailState();
}

class _VendorDetailState extends State<VendorDetail> {
  String barcode = "";
  var _isExpandedDetail = true;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  var _fault = new TextEditingController();
  List serviceType = ['厂商', '代理商', '经销商', '其他供应商'];
  List province = [
    "北京",
    "天津",
    "上海",
    "重庆",
    "河北",
    "山西",
    "辽宁",
    "吉林",
    "黑龙江",
    "江苏",
    "浙江",
    "安徽",
    "福建",
    "江西",
    "山东",
    "河南",
    "湖北",
    "湖南",
    "广东",
    "海南",
    "四川",
    "贵州",
    "云南",
    "陕西",
    "甘肃",
    "青海",
    "台湾",
    "内蒙古",
    "广西",
    "西藏",
    "宁夏",
    "新疆",
    "香港",
    "澳门"
  ];
  List serviceScope = ['全保', '技术保', '其他保'];
  List<DropdownMenuItem<String>> dropdownType;
  List<DropdownMenuItem<String>> dropdownScope;
  List<DropdownMenuItem<String>> dropdownProvince;
  String currentType;
  String currentScope;
  String currentProvince;
  List _imageList = [];
  String oid = '系统自动生成';

  var name = new TextEditingController(),
      mobile = new TextEditingController(),
      address = new TextEditingController(),
      contact = new TextEditingController(),
      contactMobile = new TextEditingController();

  List vendorStatus = ['启用', '停用'];
  String currentStatus = '启用';
  Map<String, dynamic> supplier;
  String startDate = '起始日期';
  String endDate = '结束日期';
  ConstantsModel model;

  void initState() {
    super.initState();
    dropdownType = getDropDownMenuItems(serviceType);
    dropdownProvince = getDropDownMenuItems(province);
    currentType = dropdownType[0].value;
    currentProvince = dropdownProvince[0].value;
    if (widget.vendor != null) {
      getVendor();
    }
    model = MainModel.of(context);
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

  Future<Null> getVendor() async {
    var resp = await HttpRequest.request('/Supplier/GetSupplierById',
        method: HttpRequest.GET, params: {'id': widget.vendor['ID']});
    if (resp['ResultCode'] == '00') {
      var _data = resp['Data'];
      setState(() {
        currentType = _data['SupplierType']['Name'];
        name.text = _data['Name'];
        currentProvince = _data['Province'];
        mobile.text = _data['Mobile'];
        address.text = _data['Address'];
        contact.text = _data['Contact'];
        contactMobile.text = _data['ContactMobile'];
        currentStatus = _data['IsActive'] ? '启用' : '停用';
        oid = _data['OID'];
      });
    }
  }

  Future<String> pickDate({String initialTime}) async {
    DateTime _time = DateTime.tryParse(initialTime)??DateTime.now();
    var val = await showDatePicker(
        context: context,
        initialDate: _time,
        firstDate:
            new DateTime.now().subtract(new Duration(days: 30)), // 减 30 天
        lastDate: new DateTime.now().add(new Duration(days: 30)), // 加 30 天
        locale: Locale('zh'));
    return '${val.year}-${val.month}-${val.day}';
  }

  void showSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return new ListView(
            shrinkWrap: true,
            children: <Widget>[
              ListTile(
                trailing: new Icon(Icons.collections),
                title: new Text('从相册添加'),
                onTap: () {
                  getImage(ImageSource.gallery);
                },
              ),
              ListTile(
                trailing: new Icon(Icons.add_a_photo),
                title: new Text('拍照添加'),
                onTap: () {
                  getImage(ImageSource.camera);
                },
              ),
            ],
          );
        });
  }

  Future<Null> saveVendor() async {
    if (name.text.isEmpty) {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('供应商名称不可为空'),
      ));
      return;
    }
    if (province == "") {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('供应商省份不可为空'),
      ));
      return;
    }
    if (contact.text.isEmpty) {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('供应商联系人不可为空'),
      ));
      return;
    }
    var prefs = await _prefs;
    var _info = {
      "SupplierType": {
        "ID": model.SupplierType[currentType],
      },
      "Name": name.text,
      "Province": currentProvince,
      "Mobile": mobile.text,
      "Address": address.text,
      "Contact": contact.text,
      "ContactMobile": contactMobile.text,
      "IsActive": currentStatus=='启用'?true:false,
    };
    if (widget.vendor != null) {
      _info['ID'] = widget.vendor['ID'];
    }
    var _data = {
      "userID": prefs.getInt('userID'),
      "info": _info
    };
    var resp = await HttpRequest.request(
      '/Supplier/SaveSupplier',
      method: HttpRequest.POST,
      data: _data
    );
    if (resp['ResultCode'] == '00') {
      showDialog(context: context, builder: (context) {
        return CupertinoAlertDialog(
          title: new Text('保存成功'),
        );
      }).then((result) => Navigator.of(context).pop());
    }
  }

  Future getImage(ImageSource sourceType) async {
    var image = await ImagePicker.pickImage(
      source: sourceType,
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

  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (context, child, mainModel) {
        return new Scaffold(
            appBar: new AppBar(
              title: new Text(widget.vendor==null?'新增供应商':'更新供应商'),
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
                                BuildWidget.buildRow('系统编号', oid),
                                BuildWidget.buildInput('名称', name, maxLength: 50),
                                BuildWidget.buildDropdown('类型', currentType,
                                    dropdownType, changeType),
                                BuildWidget.buildDropdown('省份', currentProvince,
                                    dropdownProvince, changeProvince),
                                BuildWidget.buildInput('电话', mobile, maxLength: 20),
                                BuildWidget.buildInput('地址', address, maxLength: 255),
                                BuildWidget.buildInput('联系人', contact),
                                BuildWidget.buildInput('联系人电话', contactMobile, maxLength: 20),
                                BuildWidget.buildRadio('供应商经营状态', vendorStatus,
                                    currentStatus, changeStatus),
                                new Divider(),
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
                            saveVendor();
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
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
                            borderRadius: BorderRadius.circular(6),
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

