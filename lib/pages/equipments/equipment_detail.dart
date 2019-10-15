import 'package:flutter/material.dart';
import 'package:atoi/widgets/build_widget.dart';
import 'package:atoi/widgets/search_bar_vendor.dart';
import 'dart:convert';
import 'package:scoped_model/scoped_model.dart';
import 'package:atoi/models/models.dart';

class EquipmentDetail extends StatefulWidget {
  EquipmentDetail({Key key, this.equipment}):super(key: key);
  final Map equipment;
  _EquipmentDetailState createState() => _EquipmentDetailState();
}

class _EquipmentDetailState extends State<EquipmentDetail> {
  List assetLevel = ['重要', '一般', '特殊'];
  List<DropdownMenuItem<String>> dropdownLevel;
  String currentLevel;
  String startDate = '起始';
  String endDate = '结束';
  String purchaseDate = '采购日期';
  String checkDate = '验收时间';
  String mandatoryDate = '强检时间';
  String recallDate = '召回时间';

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
    dropdownDepartments = getDropDownMenuItems(departments);
    currentDepartment = dropdownDepartments[0].value;
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
    ConstantsModel model = MainModel.of(context);
    setState(() {
      departments = model.DepartmentsList;
    });
    initDepart();
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
              BuildWidget.buildInput('设备名称', new TextEditingController()),
              BuildWidget.buildInput('设备型号', new TextEditingController()),
              BuildWidget.buildInput('设备序列号', new TextEditingController()),
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
              BuildWidget.buildInput('标准响应时间', new TextEditingController()),
              BuildWidget.buildInput('分类编码', new TextEditingController()),
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
              BuildWidget.buildInput('资产编号', new TextEditingController()),
              BuildWidget.buildInput('资产等级', new TextEditingController()),
              BuildWidget.buildDropdown(
                  '资产等级', currentLevel, dropdownLevel, changeLevel),
              BuildWidget.buildInput('折旧年限', new TextEditingController()),
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
                            startDate = _date;
                          });
                        },
                        child: new Text(startDate),
                      ),
                    ),
                    new Expanded(
                      flex: 3,
                      child: new MaterialButton(
                        onPressed: () async {
                          var _date = await pickDate();
                          setState(() {
                            endDate = _date;
                          });
                        },
                        child: new Text(endDate),
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
              BuildWidget.buildInput('销售合同名称', new TextEditingController()),
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
              BuildWidget.buildInput('购入方式', new TextEditingController()),
              BuildWidget.buildInput('采购金额', new TextEditingController()),
              BuildWidget.buildInput('采购日期', new TextEditingController()),
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
              BuildWidget.buildInput('设备产地', new TextEditingController()),
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
              BuildWidget.buildDropdown('使用科室', currentDepartment, dropdownDepartments, changeDepartment),
              BuildWidget.buildInput('安装地点', new TextEditingController()),
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
                            startDate = _date;
                          });
                        },
                        child: new Text(startDate),
                      ),
                    ),
                    new Expanded(
                      flex: 3,
                      child: new MaterialButton(
                        onPressed: () async {
                          var _date = await pickDate();
                          setState(() {
                            endDate = _date;
                          });
                        },
                        child: new Text(endDate),
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
              BuildWidget.buildInput('维保状态', new TextEditingController()),
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
              BuildWidget.buildDropdownWithInput('巡检周期', new TextEditingController(), currentPeriod, dropdownPeriod, changePeriod, inputType: TextInputType.number),
              BuildWidget.buildDropdownWithInput('保养周期', new TextEditingController(), currentPeriod, dropdownPeriod, changePeriod, inputType: TextInputType.number),
              BuildWidget.buildDropdownWithInput('校正周期', new TextEditingController(), currentPeriod, dropdownPeriod, changePeriod, inputType: TextInputType.number),
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
                          borderRadius: BorderRadius.circular(24),
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
                          borderRadius: BorderRadius.circular(24),
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
