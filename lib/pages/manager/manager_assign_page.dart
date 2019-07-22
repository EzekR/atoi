import 'package:flutter/material.dart';
import 'dart:async';
import 'package:atoi/utils/http_request.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:atoi/utils/constants.dart';

class ManagerAssignPage extends StatefulWidget {
  static String tag = 'mananger-assign-page';

  ManagerAssignPage({Key key, this.request}) : super(key: key);
  final Map request;
  @override
  _ManagerAssignPageState createState() => new _ManagerAssignPageState();

}

class _ManagerAssignPageState extends State<ManagerAssignPage> {

  var _isExpandedBasic = true;
  var _isExpandedDetail = false;
  var _isExpandedAssign = false;
  String departureDate = '';

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  String _imageUri = '';

  List _handleMethods = [
    '现场服务',
    '电话解决',
    '远程服务',
    '第三方支持'
  ];

  List _priorities = [
    '高','中','低'
  ];

  List _assignTypes = [
    '维修',
    '保养',
    '强检',
    '巡检',
    '校正',
    '设备新增',
    '不良事件',
    '合同档案',
    '验收安装',
    '调拨',
    '借用',
    '盘点',
    '报废',
    '其他服务'
  ];

  List _levels = [
    '普通',
    '紧急'
  ];

  List _deviceStatuses = [
    '正常',
    '勉强使用',
    '停机'
  ];

  List _engineerNames = [
    '张三  ',
    '李四'
  ];

  List<DropdownMenuItem<String>> _dropDownMenuItems;
  List<DropdownMenuItem<String>> _dropDownMenuPris;
  List<DropdownMenuItem<String>> _dropDownMenuTypes;
  List<DropdownMenuItem<String>> _dropDownMenuLevels;
  List<DropdownMenuItem<String>> _dropDownMenuStatuses;
  List<DropdownMenuItem<String>> _dropDownMenuNames;

  String _currentMethod;
  String _currentPriority;
  String _currentType;
  String _currentLevel;
  String _currentStatus;
  String _currentName;

  Future<Null> getRequest() async {

  }

  void initState() {
    _dropDownMenuItems = getDropDownMenuItems(_handleMethods);
    _currentMethod = _dropDownMenuItems[0].value;
    _dropDownMenuPris = getDropDownMenuItems(_priorities);
    _currentPriority = _dropDownMenuPris[1].value;
    _dropDownMenuTypes = getDropDownMenuItems(_assignTypes);
    _dropDownMenuLevels = getDropDownMenuItems(_levels);
    _dropDownMenuStatuses = getDropDownMenuItems(_deviceStatuses);
    _dropDownMenuNames = getDropDownMenuItems(_engineerNames);
    _currentType = _dropDownMenuTypes[0].value;
    _currentLevel = _dropDownMenuLevels[0].value;
    _currentStatus = _dropDownMenuStatuses[0].value;
    _currentName = _dropDownMenuNames[0].value;

    //getReport();
    super.initState();
  }

  List<DropdownMenuItem<String>> getDropDownMenuItems(List list) {
    List<DropdownMenuItem<String>> items = new List();
    for (String method in list) {
      items.add(new DropdownMenuItem(
          value: method,
          child: new Text(method,
            style: new TextStyle(
              fontSize: 20.0
            ),
          )
      ));
    }
    return items;
  }

  void changedDropDownMethod(String selectedMethod) {
    setState(() {
      _currentMethod = selectedMethod;
    });
  }

  void changedDropDownPri(String selectedMethod) {
    setState(() {
      _currentPriority = selectedMethod;
    });
  }

  void changedDropDownType(String selectedMethod) {
    setState(() {
      _currentType = selectedMethod;
    });
  }

  void changedDropDownLevel(String selectedMethod) {
    setState(() {
      _currentLevel = selectedMethod;
    });
  }

  void changedDropDownStatus(String selectedMethod) {
    setState(() {
      _currentStatus = selectedMethod;
    });
  }

  void changedDropDownName(String selectedMethod) {
    setState(() {
      _currentName = selectedMethod;
    });
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

  Row buildDropdown(String title, String currentItem, List dropdownItems, Function changeDropdown) {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        new Expanded(
          flex: 4,
          child: new Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: new Text(
              title,
              style: new TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w600
              ),
            ),
          ),
        ),
        new Expanded(
          flex: 6,
          child: new DropdownButton(
            value: currentItem,
            items: dropdownItems,
            onChanged: changeDropdown,
          ),
        )
      ],
    );
  }

  Future assignRequest() async {
    var prefs = await _prefs;
    var userID = prefs.getInt('userID');
    Map<String, dynamic> _data = {
      'userID': userID,
      'RequestID': widget.request['ID'],
      'dispatchInfo': {
        'Request': {
          'ID': widget.request['ID']
        },
        'Urgency': {
          'ID': AppConstants().UrgencyID[_currentLevel]
        },
        'Engineer': {
          'ID': 32
        },
        'ScheduleDate': departureDate
      }
    };
    var resp = await HttpRequest.request(
      '/Request/CreateDispatch',
      method: HttpRequest.POST,
      data: _data
    );
    print(resp);
    if (resp['ResultCode'] == '00') {
      showDialog(context: context,
        builder: (context) => AlertDialog(
          title: new Text('安排派工成功'),
        )
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context){
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('安排派工'),
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
            child: const Text('上杉谦信'),
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
                        _isExpandedAssign =!isExpanded;
                      }
                    }
                  });
                },
                children: [
                  new ExpansionPanel(
                      headerBuilder: (context, isExpanded) {
                        return ListTile(
                          leading: new Icon(Icons.info,
                            size: 24.0,
                            color: Colors.blue,
                          ),
                          title: new Align(
                            child: Text('设备基本信息',
                              style: new TextStyle(
                                  fontSize: 22.0,
                                  fontWeight: FontWeight.w400
                              ),
                            ),
                            alignment: Alignment(-1.4, 0)
                          )
                        );
                      },
                      body: new Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.0),
                        child: new Column(
                          children: <Widget>[
                            buildRow('设备编号：', widget.request['EquipmentOID']),
                            buildRow('设备名称：', widget.request['EquipmentName']),
                            buildRow('使用科室：', widget.request['DepartmentName']),
                            buildRow('设备厂商：', widget.request['Equipments'][0]['Manufacturer']['OID']),
                            buildRow('资产等级：', widget.request['Equipments'][0]['AssetLevel']['ID'].toString()),
                            buildRow('设备型号：', widget.request['Equipments'][0]['SerialCode']),
                            buildRow('安装地点：', widget.request['Equipments'][0]['Department']['Name']),
                            buildRow('保修状况：', '保内'),
                            new Padding(padding: EdgeInsets.symmetric(vertical: 8.0))
                          ],
                        ),
                      ),
                      isExpanded: _isExpandedBasic,
                  ),
                  new ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return ListTile(
                          leading: new Icon(Icons.description,
                            size: 24.0,
                            color: Colors.blue,
                          ),
                          title: new Align(
                              child: Text('请求内容',
                                style: new TextStyle(
                                    fontSize: 22.0,
                                    fontWeight: FontWeight.w400
                                ),
                              ),
                              alignment: Alignment(-1.3, 0)
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
                          buildRow('类型：', widget.request['SourceType']),
                          buildRow('主题：', widget.request['Subject']),
                          buildRow('故障描述：', widget.request['FaultDesc']),
                          buildRow('故障分类：', widget.request['FaultType']['Name']),
                          buildRow('请求人：', widget.request['RequestUser']['Name']),
                          buildRow('联系电话：', widget.request['RequestUser']['Mobile']),
                          buildDropdown('处理方式：', _currentMethod, _dropDownMenuItems, changedDropDownMethod),
                          buildDropdown('优先级：', _currentPriority, _dropDownMenuPris, changedDropDownPri),
                          new Padding(
                            padding: EdgeInsets.symmetric(vertical: 5.0),
                            child: new Text('请求附件',
                              style: new TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w600
                              ),
                            ),
                          ),
                          new Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              new Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Image.network(
                                  _imageUri,
                                  width: 200.0,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    isExpanded: _isExpandedDetail,
                  ),
                  new ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return ListTile(
                          leading: new Icon(Icons.perm_contact_calendar,
                            size: 24.0,
                            color: Colors.blue,
                          ),
                          title: new Align(
                              child: Text('派工内容',
                                style: new TextStyle(
                                    fontSize: 22.0,
                                    fontWeight: FontWeight.w400
                                ),
                              ),
                              alignment: Alignment(-1.3, 0)
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
                          buildDropdown('派工类型：', _currentType, _dropDownMenuTypes, changedDropDownType),
                          buildDropdown('紧急程度：', _currentLevel, _dropDownMenuLevels, changedDropDownLevel),
                          buildDropdown('机器状态：', _currentStatus, _dropDownMenuStatuses, changedDropDownStatus),
                          buildDropdown('工程师姓名：', _currentName, _dropDownMenuNames, changedDropDownName),
                          new MaterialButton(
                            child: new Align(
                              alignment: Alignment(-1.1, 0.0),
                              child: new Text(
                                '选择日期',
                                style: new TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 20.0
                                ),
                              ),
                            ),
                            onPressed: () {
                              showDatePicker(
                                  context: context,
                                  initialDate: new DateTime.now(),
                                  firstDate: new DateTime.now().subtract(new Duration(days: 30)), // 减 30 天
                                  lastDate: new DateTime.now().add(new Duration(days: 30)),       // 加 30 天
                                  locale: Locale('zh')
                              ).then((DateTime val) {
                                print(val); // 2018-07-12 00:00:00.000
                                var date = '${val.year}-${val.month}-${val.day}';
                                setState(() {
                                  departureDate = date;
                                });
                              }).catchError((err) {
                                print(err);
                              });
                            },
                          ),
                          departureDate != ''?new Text(departureDate):new Container(),
                          new Padding(
                            padding: EdgeInsets.symmetric(vertical: 5.0),
                            child: new Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                new Text(
                                  '主管备注：',
                                  style: new TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.w600
                                  ),
                                ),
                                new TextField(

                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    isExpanded: _isExpandedAssign,
                  ),
                ],
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
                      onPressed: () {
                        assignRequest();
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: EdgeInsets.all(12.0),
                      color: new Color(0xff2E94B9),
                      child: Text('安排派工', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  new Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5.0),
                    child: new RaisedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('已取消')
                          )
                        );
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: EdgeInsets.all(12.0),
                      color: new Color(0xffD25565),
                      child: Text('拒绝请求', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}