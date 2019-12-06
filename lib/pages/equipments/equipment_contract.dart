import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:atoi/widgets/search_page.dart';
import 'package:atoi/widgets/search_bar_vendor.dart';
import 'package:atoi/models/main_model.dart';
import 'package:atoi/utils/constants.dart';

class EquipmentContract extends StatefulWidget {
  EquipmentContract({Key key, this.contract}) : super(key: key);
  final Map contract;
  _EquipmentContractState createState() => new _EquipmentContractState();
}

class _EquipmentContractState extends State<EquipmentContract> {
  String barcode = "";

  var _isExpandedBasic = true;
  var _isExpandedDetail = false;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  List serviceType = ['原厂服务合同', '采购服务合同'];
  List serviceScope = ['全保', '技术保', '其他'];
  List<DropdownMenuItem<String>> dropdownType;
  List<DropdownMenuItem<String>> dropdownScope;
  String currentType;
  String currentScope;
  Map<String, dynamic> supplier;
  String startDate = 'YY-MM-DD';
  String endDate = 'YY-MM-DD';
  String OID = '系统自动生成';
  String _contractStatus = '生效';

  ConstantsModel model;

  MainModel mainModel = MainModel();

  List<dynamic> _equipments = [];

  List<dynamic> _imageList = [];

  TextEditingController projectNum = new TextEditingController(),
                        contractNum = new TextEditingController(),
                        amount = new TextEditingController(),
                        name = new TextEditingController(),
                        status = new TextEditingController(),
                        comments = new TextEditingController(),
                        scopeComments = new TextEditingController();

  Future<Null> getContract(int id) async {
    var resp = await HttpRequest.request(
      '/Contract/GetContractById',
      method: HttpRequest.GET,
      params: {
        'ID': id
      }
    );
    if (resp['ResultCode'] == '00') {
      var _data = resp['Data'];
      setState(() {
        _equipments = _data['Equipments'];
        OID = _data['OID'];
        projectNum.text = _data['ProjectNum'];
        contractNum.text = _data['ContractNum'];
        amount.text = _data['Amount'].toString();
        name.text = _data['Name'];
        status.text = _data['Status'];
        startDate = _data['StartDate'].split('T')[0];
        endDate = _data['EndDate'].split('T')[0];
        comments.text = _data['Comments'];
        scopeComments.text = _data['ScopeComments'];
        currentType = _data['Type']['Name'];
        currentScope = _data['Scope']['Name'];
        supplier = _data['Supplier'];
      });
      var today = new DateTime.now();
      var _start = DateTime.parse(_data['StartDate']);
      var _end = DateTime.parse(_data['EndDate']);
      if (today.isBefore(_start) || today.isAfter(_end)) {
        setState(() {
          _contractStatus = '未生效';
        });
      }
    }
  }

  Future<Null> saveContract() async {
    if (_equipments.length == 0) {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('请选择设备'),
      ));
      return;
    }

    if (contractNum.text.isEmpty) {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('合同编号不可为空'),
      ));
      return;
    }
    if (amount.text.isEmpty || double.parse(amount.text) > 99999999.99) {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('金额不可为空且金额不可大于1亿'),
      ));
      return;
    }
    if (name.text.isEmpty) {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('名称不可为空'),
      ));
      return;
    }
    if (startDate == '起始日期' || endDate == '结束日期') {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('起始日期不可为空'),
      ));
      return;
    }
    if (supplier == null) {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('供应商不可为空'),
      ));
      return;
    }
    var _equipList = _equipments.map((item) => {'ID': item['ID']}).toList();
    var _info = {
      "Equipments": _equipList,
      "Supplier": {
        'ID': supplier==null?0:supplier['ID']
      },
      "ContractNum": contractNum.text,
      "Name": name.text,
      "Type": {
        "ID": model.ContractType[currentType],
      },
      "Scope": {
        "ID": model.ContractScope[currentScope],
      },
      "ScopeComments": scopeComments.text,
      "Amount": amount.text,
      "ProjectNum": projectNum.text,
      "StartDate": startDate,
      "EndDate": endDate,
      "Comments": comments.text,
      //"Status": status.text,
    };
    if (widget.contract != null) {
      _info['ID'] = widget.contract['ID'];
    } else {
      _info['ID'] = 0;
    }
    var prefs = await _prefs;
    var userID = prefs.getInt('userID');
    var _data = {
      'userID': userID,
      'info': _info
    };
    var resp = await HttpRequest.request(
      '/Contract/SaveContract',
      method: HttpRequest.POST,
      data: _data
    );
    if (resp['ResultCode'] == '00') {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('保存成功'),
      )).then((result) => Navigator.of(context).pop());
    } else {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text(resp['Data']),
      ));
    }
  }

  void initState() {
    super.initState();
    model = MainModel.of(context);
    dropdownType = getDropDownMenuItems(model.ContractTypeList);
    dropdownScope = getDropDownMenuItems(model.ContractScopeList);
    currentScope = dropdownScope[0].value;
    currentType = dropdownType[0].value;
    if (widget.contract != null) {
      getContract(widget.contract['ID']);
    }
  }

  void changeType(String selected) {
    setState(() {
      currentType = selected;
    });
  }

  void changeScope(String selected) {
    setState(() {
      currentScope = selected;
    });
  }

  Future<String> pickDate(String dateType) async {
    var val = await showDatePicker(
        context: context,
        initialDate: new DateTime.now(),
        firstDate: new DateTime.now().subtract(new Duration(days: 3650)), // 减 30 天
        lastDate: new DateTime.now().add(new Duration(days: 3650)), // 加 30 天
        locale: Locale('zh'));
    var _today = new DateTime.now();
    switch (dateType) {
      case 'start':
        if (_today.isBefore(val)) {
          setState(() {
            _contractStatus = '未生效';
          });
        }
        break;
      case 'end':
        if (_today.isAfter(val)) {
          setState(() {
            _contractStatus = '失效';
          });
        }
        if (_today.add(new Duration(days: 30)).isAfter(val) && _today.isBefore(val)) {
          setState(() {
            _contractStatus = '即将失效';
          });
        }
    }
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
              title: new Text(widget.contract==null?'添加合同':'更新合同'),
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
                    //toSearch();
                    final selected = await Navigator.of(context)
                        .push(new MaterialPageRoute(builder: (context) {
                      return SearchPage();
                    }));
                    print(selected);
                    _equipments.addAll(selected);
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
                                    fontWeight: FontWeight.w400),
                              ),
                            );
                          },
                          body: _equipments.length == 0
                              ? new Center(child: new Text('请选择设备'))
                              : buildEquip(),
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
                              title: Text(
                                '合同详细信息',
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
                                BuildWidget.buildRow('系统编号', OID),
                                BuildWidget.buildInput(
                                    '项目编号', projectNum, maxLength: 20),
                                BuildWidget.buildInput(
                                    '合同编号', contractNum, maxLength: 20),
                                BuildWidget.buildInput(
                                    '金额', amount, inputType: TextInputType.numberWithOptions(), maxLength: 11),
                                BuildWidget.buildInput(
                                    '名称', name, maxLength: 50),
                                BuildWidget.buildDropdown('类型', currentType,
                                    dropdownType, changeType),
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
                                              '起止日期',
                                              style: new TextStyle(
                                                  fontSize: 20.0, fontWeight: FontWeight.w600),
                                            )
                                          ],
                                        ),
                                      ),
                                      new Expanded(
                                        flex: 1,
                                        child: new Text(
                                          '：',
                                          style: new TextStyle(
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      new Expanded(
                                        flex: 6,
                                        child: new Column(
                                          children: <Widget>[
                                            new Row(
                                              children: <Widget>[
                                                new Expanded(
                                                  flex: 4,
                                                  child: new Text(
                                                    startDate,
                                                    style: new TextStyle(
                                                        fontSize: 20.0,
                                                        fontWeight: FontWeight.w400,
                                                        color: Colors.black54
                                                    ),
                                                  ),
                                                ),
                                                new Expanded(
                                                  flex: 2,
                                                  child: new IconButton(
                                                      icon: Icon(Icons.calendar_today, color: AppConstants.AppColors['btn_main'],),
                                                      onPressed: () async {
                                                        var _date = await pickDate('start');
                                                        setState(() {
                                                          startDate = _date;
                                                        });
                                                      }
                                                  ),
                                                )
                                              ],
                                            ),
                                            new Row(
                                              children: <Widget>[
                                                new Expanded(
                                                  flex: 4,
                                                  child: new Text(
                                                    endDate,
                                                    style: new TextStyle(
                                                        fontSize: 20.0,
                                                        fontWeight: FontWeight.w400,
                                                        color: Colors.black54
                                                    ),
                                                  ),
                                                ),
                                                new Expanded(
                                                  flex: 2,
                                                  child: new IconButton(
                                                      icon: Icon(Icons.calendar_today, color: AppConstants.AppColors['btn_main'],),
                                                      onPressed: () async {
                                                        var _date = await pickDate('end');
                                                        setState(() {
                                                          endDate = _date;
                                                        });
                                                      }
                                                  ),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                BuildWidget.buildRow('状态', _contractStatus),
                                new Padding(
                                  padding: EdgeInsets.symmetric(vertical: 5.0),
                                  child: new Row(
                                    children: <Widget>[
                                      new Expanded(
                                        flex: 4,
                                        child: new Wrap(
                                          alignment: WrapAlignment.end,
                                          crossAxisAlignment:
                                              WrapCrossAlignment.center,
                                          children: <Widget>[
                                            new Text(
                                              '供应商',
                                              style: new TextStyle(
                                                  fontSize: 20.0,
                                                  fontWeight: FontWeight.w600),
                                            )
                                          ],
                                        ),
                                      ),
                                      new Expanded(
                                        flex: 1,
                                        child: new Text(
                                          '：',
                                          style: new TextStyle(
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      new Expanded(
                                          flex: 3,
                                          child: new Text(
                                            supplier == null
                                                ? ''
                                                : supplier['Name'],
                                            style: new TextStyle(
                                                fontSize: 20.0,
                                                fontWeight: FontWeight.w400,
                                                color: Colors.black54),
                                          )),
                                      new Expanded(
                                          flex: 3,
                                          child: new IconButton(
                                              icon: Icon(Icons.search),
                                              onPressed: () async {
                                                final _searchResult =
                                                    await showSearch(
                                                        context: context,
                                                        delegate:
                                                            SearchBarVendor(),
                                                        hintText: '请输厂商名称');
                                                print(_searchResult);
                                                if (_searchResult != null &&
                                                    _searchResult != 'null') {
                                                  setState(() {
                                                    supplier = jsonDecode(
                                                        _searchResult);
                                                  });
                                                }
                                              })),
                                    ],
                                  ),
                                ),
                                BuildWidget.buildDropdown('服务范围', currentScope,
                                    dropdownScope, changeScope),
                                currentScope=='其他'?BuildWidget.buildInput('其他范围', scopeComments, maxLength: 50):new Container(),
                                BuildWidget.buildInput(
                                    '备注', comments, maxLength: 500),
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
                            saveContract();
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
