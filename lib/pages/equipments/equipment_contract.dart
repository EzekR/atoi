import 'dart:developer';

import 'package:atoi/pages/equipments/equipments_list.dart';
import 'package:atoi/utils/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:atoi/widgets/search_page.dart';
import 'package:atoi/widgets/search_bar_vendor.dart';
import 'package:atoi/models/main_model.dart';
import 'package:atoi/utils/constants.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:date_format/date_format.dart';
import 'package:atoi/utils/event_bus.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'dart:typed_data';
import 'package:uuid/uuid.dart';
import 'package:atoi/widgets/search_lazy.dart';

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
  List serviceScope = ['全保', '技术保', '其它'];
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
  ScrollController _scrollController = new ScrollController();
  List<bool> expansionList = new List(5).map((_) => true).toList();
  List relatedComponents = [];
  List relatedConsumables = [];
  int currentEquip;

  ConstantsModel model;

  MainModel mainModel = MainModel();

  List _equipments = [];

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
        currentEquip = _equipments.length>0?_equipments[0]['ID']:0;
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
        relatedComponents = _data['Components'].map((item) {
          Map _comp = item['Component'];
          _comp['Equipment'] = item['Equipment'];
          return _comp;
        }).toList();
        relatedConsumables = _data['Consumables'].map((item) {
          Map _con = item['Consumable'];
          _con['Equipment'] = item['Equipment'];
          return _con;
        }).toList();
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

  List<FocusNode> _focusContract = new List(20).map((item) {
    return new FocusNode();
  }).toList();

  Future<Null> saveContract() async {
    setState(() {
      _isExpandedBasic = true;
      _isExpandedDetail = true;
    });
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
    if (startDate == 'YY-MM-DD') {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('开始日期不可为空'),
      )).then((result) => _scrollController.jumpTo(1300.0));
      return;
    }
    if (endDate == 'YY-MM-DD') {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('结束日期不可为空'),
      )).then((result) => _scrollController.jumpTo(1300.0));
      return;
    }
    var _start = DateTime.parse(startDate);
    var _end = DateTime.parse(endDate);
    if (_end.isBefore(_start)) {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('起止日期格式有误'),
      )).then((result) => _scrollController.jumpTo(1300.0));
      return;
    }
    if (supplier == null) {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('供应商不可为空'),
      )).then((result) => _scrollController.jumpTo(1200.0));
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
      "Components": relatedComponents.map((comp) => {
        "ContractID": widget.contract['ID'],
        "Equipment": {
          'ID': comp['Equipment']['ID']
        },
        'Component': {
          'ID': comp['ID']
        }
      }).toList(),
      "Consumables": relatedConsumables.map((con) => {
        "ContractID": widget.contract['ID'],
        "Equipment": {
          'ID': con['Equipment']['ID']
        },
        'Consumable': {
          'ID': con['ID']
        }
      }).toList(),
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
    print('change type');
    FocusScope.of(context).requestFocus(new FocusNode());
    setState(() {
      currentType = selected;
    });
  }

  void changeScope(String selected) {
    FocusScope.of(context).requestFocus(new FocusNode());
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
      maxDateTime: DateTime.now().add(Duration(days: 365*10)),
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


  GridView buildImageRow(List imageList) {
    List<Widget> _list = [];

    if (imageList.length > 0) {
      for (var image in imageList) {
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
              BuildWidget.buildRow('型号', _equipment['ModelCode'] ?? ''),
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
  
  List<Widget> buildRelatedStaff(List targetStaff, int listType) {
    List<Widget> _list = [];
    _list.addAll(
      targetStaff.map<Widget>((item) => Card(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              BuildWidget.buildCardRow('简称', item['Name']),
              BuildWidget.buildCardRow('描述', item['Description']),
              BuildWidget.buildCardRow('设备系统编号', item['Equipment']['OID']),
              BuildWidget.buildCardRow('设备资产编号', item['Equipment']['AssetCode']),
              BuildWidget.buildCardRow('关联设备名称', item['Equipment']['Name']),
              widget.editable?Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.delete_forever),
                    color: Colors.red,
                    onPressed: () {
                      setState(() {
                        targetStaff.remove(item);
                      });
                    },
                  )
                ],
              ):Container(),
            ],
          ),
        )
      )).toList()
    );
    _list.add(
        widget.editable?Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) => StatefulBuilder(
                      builder: (context, setState) => SimpleDialog(
                        title: Text(listType==1?"添加零件":"添加耗材"),
                        children: <Widget>[
                          BuildWidget.buildCardDropdown('关联设备', currentEquip, _equipments.map((item) => {
                            'value': item['ID'],
                            'text': item['Name']
                          }).toList(), (val) => setState(() {currentEquip=val;}), required: true),
                          BuildWidget.buildCardRow('设备系统编号', _equipments.isNotEmpty?_equipments.firstWhere((item) => item['ID']==currentEquip, orElse: null)['OID']:""),
                          BuildWidget.buildCardRow('设备资产编号', _equipments.isNotEmpty?_equipments?.firstWhere((item) => item['ID']==currentEquip, orElse: null)['AssetCode']:""),
                          BuildWidget.buildCardRowWithSearch(listType==1?'零件':"耗材", targetStaff.map((item) => item['Name']).join("; "), required: true, toSearch: () async {
                            if (_equipments.isEmpty) {
                              return;
                            }
                            final comps = await Navigator.of(context).push(new MaterialPageRoute(builder: (_) => SearchPage(multiType: listType==1?MultiSearchType.COMPONENT:MultiSearchType.CONSUMABLE, equipments: targetStaff, onlyType: EquipmentType.MEDICAL,
                              fujiClass2: _equipments?.firstWhere((item) => item['ID']==currentEquip)['FujiClass2']['ID'],)));
                            if (comps != null) {
                              comps.forEach((comp) {
                                comp['Equipment'] = _equipments.firstWhere((item) => item['ID'] == currentEquip);
                              });
                              log("$comps");
                              setState(() {
                                addAllUnique(comps, targetStaff);
                              });
                            }
                          })
                        ],
                      ),
                    )
                );
              },
            )
          ],
        ):Container()
    );

    return _list;
  }

  void addAllUnique(List source, List target) {
    source.forEach((item) => target.indexOf(item)>-1?null:target.add(item));
  }

  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (context, child, mainModel) {
        return new Scaffold(
            appBar: new AppBar(
              title: widget.editable?Text(widget.contract==null?'新增服务合同':'更新服务合同'):Text('查看服务合同'),
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
                      return SearchPage(equipments: _equipments, onlyType: EquipmentType.MEDICAL, multiType: MultiSearchType.EQUIPMENT,);
                    })).then((selected) {
                      print(selected.toString());
                      if (selected != null) {
                        setState(() {
                          _equipments = selected;
                          currentEquip = _equipments[0]['ID'];
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
                  controller: _scrollController,
                  children: <Widget>[
                    new ExpansionPanelList(
                      animationDuration: Duration(milliseconds: 200),
                      expansionCallback: (index, isExpanded) {
                        FocusScope.of(context).unfocus();
                        setState(() {
                          expansionList[index] = !expansionList[index];
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
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w400),
                              ),
                            );
                          },
                          body: _equipments ==null || _equipments.isEmpty
                              ? new Center(child: new Text('请选择设备'))
                              : buildEquip(),
                          isExpanded: expansionList[0],
                        ),
                        new ExpansionPanel(canTapOnHeader: true,
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
                                widget.editable?BuildWidget.buildInput('合同编号', contractNum, maxLength: 20, focusNode: _focusContract[0], required: true):BuildWidget.buildRow('合同编号', contractNum.text),
                                widget.editable?BuildWidget.buildInput('项目编号', projectNum, maxLength: 20, focusNode: _focusContract[9]):BuildWidget.buildRow('项目编号', projectNum.text),
                                widget.editable?BuildWidget.buildInput('金额', amount, inputType: TextInputType.numberWithOptions(decimal: true), maxLength: 11, focusNode: _focusContract[1], required: true):BuildWidget.buildRow('金额', CommonUtil.CurrencyForm(double.tryParse(amount.text), times: 1, digits: 0)),
                                widget.editable?BuildWidget.buildInput('名称', name, maxLength: 50, focusNode: _focusContract[2], required: true):BuildWidget.buildRow('名称', name.text),
                                widget.editable?BuildWidget.buildDropdown('类型', currentType, dropdownType, changeType, required: true):BuildWidget.buildRow('类型', currentType),
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
                                              '*',
                                              style: new TextStyle(
                                                  color: Colors.red
                                              ),
                                            ),
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
                                              icon: Icon(Icons.search),
                                              onPressed: () async {
                                                FocusScope.of(context).requestFocus(new FocusNode());
                                                final _searchResult = await Navigator.of(context).push(new MaterialPageRoute(builder: (_) => SearchLazy(searchType: SearchType.MANUFACTURER,)));
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
                                              '*',
                                              style: new TextStyle(
                                                  color: Colors.red
                                              ),
                                            ),
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
                                                      icon: Icon(Icons.calendar_today, color: AppConstants.AppColors['btn_main'],),
                                                      onPressed: () async {
                                                        FocusScope.of(context).requestFocus(new FocusNode());
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
                                                        FocusScope.of(context).requestFocus(new FocusNode());
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
                                widget.editable&&currentScope=='其它'?BuildWidget.buildInput('其它范围', scopeComments, maxLength: 50, focusNode: _focusContract[18]):new Container(),
                                !widget.editable&&currentScope=='其它'?BuildWidget.buildRow('其它范围', scopeComments.text):new Container(),
                                widget.editable?BuildWidget.buildInput('备注', comments, maxLength: 500, focusNode: _focusContract[19]):BuildWidget.buildRow('备注', comments.text),
                                new Divider(),
                                new Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 8.0))
                              ],
                            ),
                          ),
                          isExpanded: expansionList[1],
                        ),
                        ExpansionPanel(
                          canTapOnHeader: true,
                          headerBuilder: (context, isExpanded) {
                            return ListTile(
                              leading: new Icon(
                                Icons.description,
                                size: 20.0,
                                color: Colors.blue,
                              ),
                              title: Text(
                                '零件',
                                style: new TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w400),
                              ),
                            );
                          },
                          body: Column(
                            children: buildRelatedStaff(relatedComponents, 1),
                          ),
                          isExpanded: expansionList[2]
                        ),
                        ExpansionPanel(
                            canTapOnHeader: true,
                            headerBuilder: (context, isExpanded) {
                              return ListTile(
                                leading: new Icon(
                                  Icons.description,
                                  size: 20.0,
                                  color: Colors.blue,
                                ),
                                title: Text(
                                  '耗材',
                                  style: new TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.w400),
                                ),
                              );
                            },
                            body: Column(
                              children: buildRelatedStaff(relatedConsumables, 2),
                            ),
                            isExpanded: expansionList[3]
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
                            FocusScope.of(context).requestFocus(new FocusNode());
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
