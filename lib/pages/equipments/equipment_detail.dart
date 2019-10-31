import 'package:flutter/material.dart';
import 'package:atoi/widgets/build_widget.dart';
import 'package:atoi/widgets/search_bar_vendor.dart';
import 'dart:convert';
import 'package:scoped_model/scoped_model.dart';
import 'package:atoi/models/models.dart';
import 'package:atoi/utils/http_request.dart';

class EquipmentDetail extends StatefulWidget {
  EquipmentDetail({Key key, this.equipment}):super(key: key);
  final Map equipment;
  _EquipmentDetailState createState() => _EquipmentDetailState();
}

class _EquipmentDetailState extends State<EquipmentDetail> {
  List assetLevel = ['重要', '一般', '特殊'];
  List<DropdownMenuItem<String>> dropdownLevel;
  String currentLevel;
  String validationStartDate = '起始';
  String validationEndDate = '结束';
  String installStartDate = '起始';
  String installEndDate = '结束';
  String purchaseDate = '采购日期';
  String checkDate = '验收时间';
  String mandatoryDate = '强检时间';
  String recallDate = '召回时间';
  String equipmentClassCode = '';
  ConstantsModel model;

  var name = new TextEditingController(),
      equipmentCode = new TextEditingController(),
      serialCode = new TextEditingController(),
      responseTime = new TextEditingController(),
      assetCode = new TextEditingController(),
      depreciationYears = new TextEditingController(),
      contractName = new TextEditingController(),
      purchaseWay = new TextEditingController(),
      purchaseAmount = new TextEditingController(),
      installSite = new TextEditingController(),
      warrantyStatus = new TextEditingController(),
      maintainPeriod = new TextEditingController(),
      patrolPeriod = new TextEditingController(),
      correctionPeriod = new TextEditingController();

  List departments = [];
  List<DropdownMenuItem<String>> dropdownDepartments;
  String currentDepartment;

  List runningStatus = ['使用', '停用'];
  List<DropdownMenuItem<String>> dropdownStatus;
  String currentStatus;

  List machineStatus = ['正常', '故障', '已报废'];
  List<DropdownMenuItem<String>> dropdownMachine;
  String currentMachine;

  List mandatoryFlag = ['无', '待强检', '已强检'];
  List<DropdownMenuItem<String>> dropdownMandatory;
  String currentMandatory;

  List period = ['无', '天/次', '月/次', '年/次'];
  List<DropdownMenuItem<String>> dropdownPeriod;
  String currentPeriod;

  List equipmentClass = ['1类', '2类', '3类'];
  List<DropdownMenuItem<String>> dropdownClass;
  String currentClass;

  List class1 = [];
  List class1Item = [];
  List<DropdownMenuItem<String>> dropdownClass1;
  String currentClass1;

  List class2 = [];
  List class2Item = [];
  List<DropdownMenuItem<String>> dropdownClass2;
  String currentClass2;

  List class3 = [];
  List class3Item = [];
  List<DropdownMenuItem<String>> dropdownClass3;
  String currentClass3;

  List catI = [];

  List catII = [];

  List catIII = [];

  List isFixed = ['是', '否'];
  String currentFixed = '是';

  List origin = ['国产', '进口'];
  String currentOrigin = '国产';

  List checkStatus = ['已验收', '未验收'];
  String currentCheck = '已验收';

  List recall = ['是', '否'];
  String currentRecall = '否';

  Map<String, dynamic> manufacturer;

  void changeValue(value) {
    setState(() {
      currentFixed = value;
    });
  }

  void changeOrigin(value) {
    setState(() {
      currentOrigin = value;
    });
  }

  void changeCheck(value) {
    setState(() {
      currentCheck = value;
    });
  }

  void changeRecall(value) {
    setState(() {
      currentRecall = value;
    });
  }

  void initDepart() {
    print(model.DepartmentsList);
    departments = model.DepartmentsList;
    dropdownDepartments = getDropDownMenuItems(departments);
    currentDepartment = dropdownDepartments[0].value;
    print(currentDepartment);
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

  void changeLevel(String selectedMethod) {
    setState(() {
      currentLevel = selectedMethod;
    });
  }

  void changeDepartment(String selectedMethod) {
    setState(() {
      currentDepartment = selectedMethod;
    });
  }

  void changeStatus(String selectedMethod) {
    setState(() {
      currentStatus = selectedMethod;
    });
  }

  void changeMachine(String selectedMethod) {
    setState(() {
      currentMachine = selectedMethod;
    });
  }

  void changeMandatory(String selectedMethod) {
    setState(() {
      currentMandatory = selectedMethod;
    });
  }

  void changePeriod(String selectedMethod) {
    setState(() {
      currentPeriod = selectedMethod;
    });
  }

  void changeClass(String selectedMethod) {
    setState(() {
      currentClass = selectedMethod;
    });
  }

  Future<Null> initClass1() async {
    var resp = await HttpRequest.request(
      '/Equipment/GetEquipmentClass',
      method: HttpRequest.GET,
      params: {
        'level': 1
      }
    );
    if (resp['ResultCode'] == '00') {
      List _list = resp['Data'].map((item) {
        return item['Description'];
      }).toList();
      setState(() {
        class1 = _list;
        class1Item = resp['Data'];
      });
      dropdownClass1 = getDropDownMenuItems(class1);
      currentClass1 = dropdownClass1[0].value;
    }
  }

  Future<Null> initClass(String code, int level) async {
    var resp = await HttpRequest.request(
      '/Equipment/GetEquipmentClass',
      method: HttpRequest.GET,
      params: {
        'level': level,
        'parentCode': code
      }
    );
    if (resp['ResultCode'] == '00') {
      List _list = resp['Data'].map((item) {
        return item['Description'];
      }).toList();
      switch (level) {
        case 2:
          setState(() {
            class2 = _list;
            class2Item = resp['Data'];
          });
          dropdownClass2 = getDropDownMenuItems(class2);
          currentClass2 = dropdownClass2[0].value;
          break;
        case 3:
          setState(() {
            class3 = _list;
            class3Item = resp['Data'];
          });
          dropdownClass3 = getDropDownMenuItems(class3);
          currentClass3 = dropdownClass3[0].value;
          break;
      }
    }
  }

  void changeClass1(String selectedClass) {
    var _selectedItem = class1Item.firstWhere((item) {
      return item['Description'] == selectedClass;
    });
    initClass(_selectedItem['Code'], 2);
    setState(() {
      currentClass1 = selectedClass;
      equipmentClassCode = _selectedItem['Code'];
    });
  }

  void changeClass2(String selectedMethod) {
    var _selectedItem = class2Item.firstWhere((item) {
      return item['Description'] == selectedMethod;
    });
    var _code = '${_selectedItem['ParentCode']}${_selectedItem['Code']}';
    initClass(_code, 3);
    setState(() {
      currentClass2 = selectedMethod;
      equipmentClassCode += _selectedItem['Code'];
    });
  }

  void changeClass3(String selectedMethod) {
    setState(() {
      currentClass3 = selectedMethod;
    });
    var _item = class3Item.firstWhere((item) {
      return item['Description'] == selectedMethod;
    });
    setState(() {
      equipmentClassCode += _item['Code'];
    });
  }

  void initState() {
    super.initState();
    dropdownLevel = getDropDownMenuItems(assetLevel);
    currentLevel = dropdownLevel[0].value;
    dropdownStatus = getDropDownMenuItems(runningStatus);
    currentStatus = dropdownStatus[0].value;
    dropdownMachine = getDropDownMenuItems(machineStatus);
    currentMachine = dropdownMachine[0].value;
    dropdownMandatory = getDropDownMenuItems(mandatoryFlag);
    currentMandatory = dropdownMandatory[0].value;
    dropdownPeriod = getDropDownMenuItems(period);
    currentPeriod = dropdownPeriod[0].value;
    dropdownClass = getDropDownMenuItems(equipmentClass);
    currentClass = dropdownClass[0].value;
    model = MainModel.of(context);
    initDepart();
    initClass1();
    if (widget.equipment != null) {
      getDevice(widget.equipment['ID']);
    }
  }

  Future<Null> getDevice(int deviceId) async {
    var resp = await HttpRequest.request(
      '/Equipment/GetDeviceById',
      method: HttpRequest.GET,
      params: {
        'id': deviceId
      }
    );
    if (resp['ResultCode'] == '00') {
      var _data = resp['Data'];
      await initClass1();
      setState(() {
        currentClass1 = _data['EquipmentClass1']['Description'];
      });
      await initClass(_data['EquipmentClass1']['Code'], 2);
      setState(() {
        currentClass2 = _data['EquipmentClass2']['Description'];
      });
      await initClass(_data['EquipmentClass1']['Code']+_data['EquipmentClass2']['Code'], 3);
      setState(() {
        currentClass3 = _data['EquipmentClass3']['Description'];
        equipmentClassCode = _data['EquipmentClass1']['Code']+_data['EquipmentClass2']['Code']+_data['EquipmentClass3']['Code'];
      });
      setState(() {
        name.text = _data['Name'];
        equipmentCode.text = _data['EquipmentCode'];
        serialCode.text = _data['SerialCode'];
        responseTime.text = _data['ResponseTimeLength'].toString();
        assetCode.text = _data['AssetCode'];
        depreciationYears.text = _data['DepreciationYears'].toString();
        contractName.text = _data['SaleContractName'];
        purchaseWay.text = _data['PurchaseWay'];
        purchaseAmount.text = _data['PurchaseAmount'].toString();
        installSite.text = _data['InstalSite'];
        warrantyStatus.text = _data['WarrantyStatus'];
        maintainPeriod.text = _data['MaintenancePeriod'].toString();
        patrolPeriod.text = _data['PatrolPeriod'].toString();
        correctionPeriod.text = _data['CorrectionPeriod'].toString();
        manufacturer = _data['Manufacturer'];
        currentClass = _data['EquipmentLevel']['Name'];
        currentFixed = _data['FixedAsset']?'是':'否';
        currentLevel = _data['AssetLevel']['Name'];
        validationStartDate = _data['ValidityStartDate'].toString().split('T')[0];
        validationEndDate = _data['ValidityEndDate'].toString().split('T')[0];
        installStartDate = _data['InstalStartDate'].toString().split('T')[0];
        installEndDate = _data['InstalEndDate'].toString().split('T')[0];
        purchaseDate = _data['PurchaseDate'].toString().split('T')[0];
        currentOrigin = _data['OriginType'];
        currentDepartment = _data['Department']['Name'];
        currentCheck = _data['Accepted']?'已验收':'未验收';
        checkDate = _data['AcceptanceDate'].toString().split('T')[0];
        currentStatus = _data['UsageStatus']['Name'];
        currentMachine = _data['EquipmentStatus']['Name'];
        mandatoryFlag = _data['MandatoryTestStatus']['Name'];
        mandatoryDate = _data['MandatoryTestDate'].toString().split('T')[0];
        currentRecall = _data['RecallFlag']?'是':'否';

      });
    }
  }

  void switchAsset(value) {
    print(value);
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

  List<ExpansionPanel> buildExpansion() {
    List<ExpansionPanel> _list = [];
    //device info
    _list.add(ExpansionPanel(
        headerBuilder: (context, isExpanded) {
          return ListTile(
              leading: new Icon(
                Icons.info,
                size: 24.0,
                color: Colors.blue,
              ),
              title: Text(
                '设备信息',
                style:
                    new TextStyle(fontSize: 22.0, fontWeight: FontWeight.w400),
              ));
        },
        body: new Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.0),
          child: new Column(
            children: <Widget>[
              BuildWidget.buildRow('设备编号', '系统自动生成'),
              BuildWidget.buildInput('设备名称', name, lines: 1),
              BuildWidget.buildInput('设备型号', equipmentCode, lines: 1),
              BuildWidget.buildInput('设备序列号', serialCode, lines: 1),
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
                            '设备厂商',
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
                        flex: 3,
                        child: new Text(
                          manufacturer == null ? '' : manufacturer['Name'],
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
                              final _searchResult = await showSearch(
                                  context: context,
                                  delegate: SearchBarVendor(),
                                  hintText: '请输厂商名称');
                              print(_searchResult);
                              if (_searchResult != null &&
                                  _searchResult != 'null') {
                                setState(() {
                                  manufacturer = jsonDecode(_searchResult);
                                });
                              }
                            })),
                  ],
                ),
              ),
              BuildWidget.buildInput('标准响应时间', responseTime, lines: 1),
              BuildWidget.buildDropdown('等级', currentClass, dropdownClass, changeClass),
              BuildWidget.buildDropdown('设备类别(I)', currentClass1, dropdownClass1, changeClass1),
              BuildWidget.buildDropdown('设备类别(II)', currentClass2, dropdownClass2, changeClass2),
              BuildWidget.buildDropdown('设备类别(III)', currentClass3, dropdownClass3, changeClass3),
              BuildWidget.buildRow('分类编码', equipmentClassCode),
            ],
          ),
        ),
        isExpanded: true));
    //asset info
    _list.add(ExpansionPanel(
        headerBuilder: (context, isExpanded) {
          return ListTile(
              leading: new Icon(
                Icons.web_asset,
                size: 24.0,
                color: Colors.blue,
              ),
              title: Text(
                '资产信息',
                style:
                    new TextStyle(fontSize: 22.0, fontWeight: FontWeight.w400),
              ));
        },
        body: new Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.0),
          child: new Column(
            children: <Widget>[
              BuildWidget.buildRadio(
                  '固定资产', isFixed, currentFixed, changeValue),
              BuildWidget.buildInput('资产编号', assetCode, lines: 1),
              BuildWidget.buildDropdown(
                  '资产等级', currentLevel, dropdownLevel, changeLevel),
              BuildWidget.buildInput('折旧年限', depreciationYears, lines: 1),
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
                            '注册证有效日期',
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
                      flex: 3,
                      child: new MaterialButton(
                        onPressed: () async {
                          var _date = await pickDate();
                          setState(() {
                            validationStartDate = _date;
                          });
                        },
                        child: new Text(validationStartDate),
                      ),
                    ),
                    new Expanded(
                      flex: 3,
                      child: new MaterialButton(
                        onPressed: () async {
                          var _date = await pickDate();
                          setState(() {
                            validationEndDate = _date;
                          });
                        },
                        child: new Text(validationEndDate),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        isExpanded: true));
    //purchasing info
    _list.add(ExpansionPanel(
        headerBuilder: (context, isExpanded) {
          return ListTile(
              leading: new Icon(
                Icons.shopping_basket,
                size: 24.0,
                color: Colors.blue,
              ),
              title: Text(
                '采购信息',
                style:
                    new TextStyle(fontSize: 22.0, fontWeight: FontWeight.w400),
              ));
        },
        body: new Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.0),
          child: new Column(
            children: <Widget>[
              BuildWidget.buildInput('销售合同名称', contractName, lines: 1),
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
                            '经销商',
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
                        flex: 3,
                        child: new Text(
                          manufacturer == null ? '' : manufacturer['Name'],
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
                              final _searchResult = await showSearch(
                                  context: context,
                                  delegate: SearchBarVendor(),
                                  hintText: '请输厂商名称');
                              print(_searchResult);
                              if (_searchResult != null &&
                                  _searchResult != 'null') {
                                setState(() {
                                  manufacturer = jsonDecode(_searchResult);
                                });
                              }
                            })),
                  ],
                ),
              ),
              BuildWidget.buildInput('购入方式', purchaseWay, lines: 1),
              BuildWidget.buildInput('采购金额', purchaseAmount, lines: 1),
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
                            '采购日期',
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
                      child: new MaterialButton(
                        onPressed: () async {
                          var _date = await pickDate();
                          setState(() {
                            purchaseDate = _date;
                          });
                        },
                        child: new Text(purchaseDate),
                      ),
                    ),
                  ],
                ),
              ),
              BuildWidget.buildRadio('设备产地', origin, currentOrigin, changeOrigin)
            ],
          ),
        ),
        isExpanded: true));
    //status info
    _list.add(ExpansionPanel(
        headerBuilder: (context, isExpanded) {
          return ListTile(
              leading: new Icon(
                Icons.network_check,
                size: 24.0,
                color: Colors.blue,
              ),
              title: Text(
                '使用状态',
                style:
                    new TextStyle(fontSize: 22.0, fontWeight: FontWeight.w400),
              ));
        },
        body: new Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.0),
          child: new Column(
            children: <Widget>[
              departments==null?new Container():BuildWidget.buildDropdown('使用科室', currentDepartment, dropdownDepartments, changeDepartment),
              BuildWidget.buildInput('安装地点', installSite, lines: 1),
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
                            '安装日期',
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
                      flex: 3,
                      child: new MaterialButton(
                        onPressed: () async {
                          var _date = await pickDate();
                          setState(() {
                            installStartDate = _date;
                          });
                        },
                        child: new Text(installStartDate),
                      ),
                    ),
                    new Expanded(
                      flex: 3,
                      child: new MaterialButton(
                        onPressed: () async {
                          var _date = await pickDate();
                          setState(() {
                            installEndDate = _date;
                          });
                        },
                        child: new Text(installEndDate),
                      ),
                    ),
                  ],
                ),
              ),
              BuildWidget.buildRadio('验收状态', checkStatus, currentCheck, changeCheck),
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
                            '验收时间',
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
                      child: new MaterialButton(
                        onPressed: () async {
                          var _date = await pickDate();
                          setState(() {
                            checkDate = _date;
                          });
                        },
                        child: new Text(checkDate),
                      ),
                    ),
                  ],
                ),
              ),
              BuildWidget.buildDropdown('使用状态', currentStatus, dropdownStatus, changeStatus),
              BuildWidget.buildDropdown('设备状态', currentMachine, dropdownMachine, changeMachine),
              BuildWidget.buildDropdown('强检标记', currentMandatory, dropdownMandatory, changeMandatory),
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
                            '强检时间',
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
                      child: new MaterialButton(
                        onPressed: () async {
                          var _date = await pickDate();
                          setState(() {
                            mandatoryDate = _date;
                          });
                        },
                        child: new Text(mandatoryDate),
                      ),
                    ),
                  ],
                ),
              ),
              BuildWidget.buildInput('维保状态', warrantyStatus, lines: 1),
              BuildWidget.buildRadio('召回标记', recall, currentRecall, changeRecall),
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
                            '召回时间',
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
                      child: new MaterialButton(
                        onPressed: () async {
                          var _date = await pickDate();
                          setState(() {
                            recallDate = _date;
                          });
                        },
                        child: new Text(recallDate),
                      ),
                    ),
                  ],
                ),
              ),
              BuildWidget.buildDropdownWithInput('巡检周期', patrolPeriod, currentPeriod, dropdownPeriod, changePeriod, inputType: TextInputType.number),
              BuildWidget.buildDropdownWithInput('保养周期', maintainPeriod, currentPeriod, dropdownPeriod, changePeriod, inputType: TextInputType.number),
              BuildWidget.buildDropdownWithInput('校正周期', correctionPeriod, currentPeriod, dropdownPeriod, changePeriod, inputType: TextInputType.number),
            ],
          ),
        ),
        isExpanded: true));

    return _list;
  }

  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('添加设备'),
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
              onPressed: () {},
            ),
            new IconButton(
                icon: Icon(Icons.crop_free),
                color: Colors.white,
                iconSize: 30.0,
                onPressed: () {})
          ],
        ),
        body: new Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Card(
            child: new ListView(
              children: <Widget>[
                new ExpansionPanelList(
                  children: buildExpansion(),
                ),
                SizedBox(height: 24.0),
                new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    new Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5.0),
                      child: new RaisedButton(
                        onPressed: () {},
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        padding: EdgeInsets.all(12.0),
                        color: new Color(0xff2E94B9),
                        child:
                            Text('保存', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                    new Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5.0),
                      child: new RaisedButton(
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
                    ),
                  ],
                )
              ],
            ),
          ),
        ));
  }
}
