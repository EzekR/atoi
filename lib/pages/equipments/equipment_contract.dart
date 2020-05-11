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
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:date_format/date_format.dart';
import 'package:atoi/utils/event_bus.dart';

/// 设备合同页面类
class EquipmentContract extends StatefulWidget {
  EquipmentContract({Key key, this.contract, this.editable}) : super(key: key);
  final Map contract;
  final bool editable;
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
  EventBus bus = new EventBus();

  ConstantsModel model;

  MainModel mainModel = MainModel();

  List _equipments;

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
        startDate = _data['StartDate'].split('T')[0]=='null'?'YY-MM-DD':_data['StartDate'].split('T')[0];
        endDate = _data['EndDate'].split('T')[0]=='null'?'YY-MM-DD':_data['EndDate'].split('T')[0];
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

  List<FocusNode> _focusContract = new List(10).map((item) {
    return new FocusNode();
  }).toList();

  Future<Null> saveContract() async {
    if (_equipments == null || _equipments.isEmpty) {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('请选择设备'),
      )).then((result) => FocusScope.of(context).requestFocus(_focusContract[5]));
      return;
    }

    if (contractNum.text.isEmpty) {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('合同编号不可为空'),
      )).then((result) => FocusScope.of(context).requestFocus(_focusContract[0]));
      return;
    }
    if (amount.text.isEmpty || double.parse(amount.text) > 99999999.99) {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('金额不可为空且金额不可大于1亿'),
      )).then((result) => FocusScope.of(context).requestFocus(_focusContract[1]));
      return;
    }
    if (name.text.isEmpty) {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('名称不可为空'),
      )).then((result) => FocusScope.of(context).requestFocus(_focusContract[2]));
      return;
    }
    if (startDate == 'YY-MM-DD' || endDate == 'YY-MM-DD') {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('起始日期不可为空'),
      )).then((result) => FocusScope.of(context).requestFocus(_focusContract[6]));
      return;
    }
    var _start = DateTime.parse(startDate);
    var _end = DateTime.parse(endDate);
    if (_end.isBefore(_start)) {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('起止日期格式有误'),
      )).then((result) => FocusScope.of(context).requestFocus(_focusContract[6]));
      return;
    }
    if (supplier == null) {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('供应商不可为空'),
      )).then((result) => FocusScope.of(context).requestFocus(_focusContract[7]));
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
        title: new Text(resp['ResultMessage']),
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
    bus.on('unfocus', (param) {
      _focusContract.forEach((item) {
        if (item.hasFocus) {
          item.unfocus();
        }
      });
    });
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

  Future<Null> pickDate(String dateType, {String initialTime}) async {
    DateTime _time = DateTime.tryParse(initialTime)??DateTime.now();
    DatePicker.showDatePicker(
      context,
      pickerTheme: DateTimePickerTheme(
        showTitle: true,
        confirm: Text('确认', style: TextStyle(color: Colors.blueAccent)),
        cancel: Text('取消', style: TextStyle(color: Colors.redAccent)),
      ),
      minDateTime: DateTime.parse('2000-01-01'),
      maxDateTime: DateTime.parse('2030-01-01'),
      initialDateTime: _time,
      dateFormat: 'yyyy-MM-dd',
      locale: DateTimePickerLocale.en_us,
      onClose: () => print(""),
      onCancel: () => print('onCancel'),
      onChange: (dateTime, List<int> index) {
      },
      onConfirm: (dateTime, List<int> index) {
        var _date = formatDate(dateTime, [yyyy, '-', mm, '-', dd]);
        setState(() {
          dateType=='start'?startDate=_date:endDate=_date;
        });
        var _today = new DateTime.now();
        switch (dateType) {
          case 'start':
            if (_today.isBefore(dateTime)) {
              setState(() {
                _contractStatus = '未生效';
              });
            } else {
              setState(() {
                _contractStatus = '生效';
              });
            }
            break;
          case 'end':
            if (_today.isAfter(DateTime.parse(startDate))) {
              _contractStatus = '未生效';
            } else {
              if (_today.isAfter(dateTime)) {
                setState(() {
                  _contractStatus = '失效';
                });
              } else {
                if (_today.add(new Duration(days: 30)).isAfter(dateTime) && _today.isBefore(dateTime)) {
                  setState(() {
                    _contractStatus = '即将失效';
                  });
                } else {
                  setState(() {
                    _contractStatus = '生效';
                  });
                }
              }
            }
        }
      },
    );
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
              child: BuildWidget.buildPhotoPageFile(context, image),
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

  Future toSearch() async {
    final _searchResult =
        await showSearch(context: context, delegate: SearchBarDelegate(), hintText: '请输入设备名称');
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
              BuildWidget.buildRow('设备厂商', _equipment['Manufacturer']['Name'] ?? ''),
              BuildWidget.buildRow('资产等级', _equipment['AssetLevel']['Name'] ?? ''),
              BuildWidget.buildRow(
                  '使用科室', _equipment['Department']['Name'] ?? ''),
              BuildWidget.buildRow('安装地点', _equipment['InstalSite'] ?? ''),
              widget.editable?new Padding(
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
              ):new Divider()
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
              title: widget.editable?Text(widget.contract==null?'新增合同':'更新合同'):Text('查看合同'),
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
              actions: widget.editable?<Widget>[
                new IconButton(
                  icon: Icon(Icons.search),
                  color: Colors.white,
                  iconSize: 30.0,
                  focusNode: _focusContract[5],
                  onPressed: () async {
                    //toSearch();
                    Navigator.of(context).push(new MaterialPageRoute(builder: (context) {
                      return SearchPage(equipments: _equipments,);
                    })).then((selected) {
                      print(selected.toString());
                      if (selected != null) {
                        setState(() {
                          _equipments = selected;
                        });
                      }
                    });
                  },
                ),
                //new IconButton(
                //    icon: Icon(Icons.crop_free),
                //    color: Colors.white,
                //    iconSize: 30.0,
                //    onPressed: () {
                //      scan();
                //    })
              ]:[],
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
                          body: _equipments ==null || _equipments.isEmpty
                              ? new Center(child: new Text('请选择设备'))
                              : buildEquip(),
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
                                '合同详细信息',
                                style: new TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w400),
                              ),
                            );
                          },
                          body: new Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.0),
                            child: new Column(
                              children: <Widget>[
                                BuildWidget.buildRow('系统编号', OID),
                                widget.editable?BuildWidget.buildInput('合同编号', contractNum, maxLength: 20, focusNode: _focusContract[0]):BuildWidget.buildRow('合同编号', contractNum.text),
                                widget.editable?BuildWidget.buildInput('项目编号', projectNum, maxLength: 20, focusNode: _focusContract[9]):BuildWidget.buildRow('项目编号', projectNum.text),
                                widget.editable?BuildWidget.buildInput('金额', amount, inputType: TextInputType.numberWithOptions(decimal: true), maxLength: 11, focusNode: _focusContract[1]):BuildWidget.buildRow('金额', amount.text),
                                widget.editable?BuildWidget.buildInput('名称', name, maxLength: 50, focusNode: _focusContract[2]):BuildWidget.buildRow('名称', name.text),
                                widget.editable?BuildWidget.buildDropdown('类型', currentType, dropdownType, changeType):BuildWidget.buildRow('类型', currentType),
                                widget.editable?new Padding(
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
                                                  fontSize: 16.0,
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
                                            fontSize: 16.0,
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
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.w400,
                                                color: Colors.black54),
                                          )),
                                      new Expanded(
                                          flex: 3,
                                          child: new IconButton(
                                              focusNode: _focusContract[7],
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
                                ):BuildWidget.buildRow('供应商', supplier==null?'':supplier['Name']),
                                widget.editable?new Padding(
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
                                                  fontSize: 16.0, fontWeight: FontWeight.w600),
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
                                        child: new Column(
                                          children: <Widget>[
                                            new Row(
                                              children: <Widget>[
                                                new Expanded(
                                                  flex: 4,
                                                  child: new Text(
                                                    startDate,
                                                    style: new TextStyle(
                                                        fontSize: 16.0,
                                                        fontWeight: FontWeight.w400,
                                                        color: Colors.black54
                                                    ),
                                                  ),
                                                ),
                                                new Expanded(
                                                  flex: 2,
                                                  child: new IconButton(
                                                      focusNode: _focusContract[6],
                                                      icon: Icon(Icons.calendar_today, color: AppConstants.AppColors['btn_main'],),
                                                      onPressed: () async {
                                                        await pickDate('start', initialTime: startDate);
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
                                                        fontSize: 16.0,
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
                                                        await pickDate('end', initialTime: endDate);
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
                                ):BuildWidget.buildRow('起止日期', '$startDate\n$endDate'),
                                //BuildWidget.buildRow('状态', _contractStatus),
                                widget.editable?BuildWidget.buildDropdown('服务范围', currentScope, dropdownScope, changeScope):BuildWidget.buildRow('服务范围', currentScope),
                                widget.editable&&currentScope=='其他'?BuildWidget.buildInput('其他范围', scopeComments, maxLength: 50):new Container(),
                                !widget.editable&&currentScope=='其他'?BuildWidget.buildRow('其他范围', scopeComments.text):new Container(),
                                widget.editable?BuildWidget.buildInput('备注', comments, maxLength: 500):BuildWidget.buildRow('备注', comments.text),
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
                    SizedBox(height: 20.0),
                    new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        widget.editable?new RaisedButton(
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
                        ):new Container(),
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
