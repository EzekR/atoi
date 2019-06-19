import 'package:flutter/material.dart';

class ManagerAssignPage extends StatefulWidget {
  static String tag = 'mananger-assign-page';

  @override
  _ManagerAssignPageState createState() => new _ManagerAssignPageState();

}

class _ManagerAssignPageState extends State<ManagerAssignPage> {

  var _isExpandedBasic = true;
  var _isExpandedDetail = false;
  var _isExpandedAssign = false;

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
    '紧急',
    '特急'
  ];

  List _deviceStatuses = [
    '正常',
    '勉强使用',
    '停机'
  ];

  List _engineerNames = [
    '张三',
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
            child: const Text('Jin'),
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
                          title: Text('设备基本信息')
                        );
                      },
                      body: new Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: new Column(
                          children: <Widget>[
                            buildTextField('设备系统编号', 'ZC00000001', false),
                            buildTextField('设备名称', '医用磁共振设备', false),
                            buildTextField('使用科室', '磁共振', false),
                            buildTextField('设备厂商', '飞利浦', false),
                            buildTextField('资产等级', '重要', false),
                            buildTextField('设备型号', 'Philips 781-296', false),
                            buildTextField('安装地点', '磁共振1室', false),
                            buildTextField('保修状况', '保内', false),
                          ],
                        ),
                      ),
                      isExpanded: _isExpandedBasic,
                  ),
                  new ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return ListTile(
                          title: Text('请求内容')
                      );
                    },
                    body: new Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: new Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          buildTextField('类型', '客户请求-报修', false),
                          buildTextField('主题', '系统报错', false),
                          buildTextField('故障描述', '系统报错，设备无法启动', false),
                          buildTextField('故障分类', '未知', false),
                          buildTextField('请求人', '马云', false),
                          new Padding(
                            padding: EdgeInsets.symmetric(vertical: 5.0),
                            child: new Text('处理方式',
                              style: new TextStyle(
                                fontSize: 14.0,
                                color: Colors.grey
                              ),
                            ),
                          ),
                          new DropdownButton(
                            value: _currentMethod,
                            items: _dropDownMenuItems,
                            onChanged: changedDropDownMethod,
                          ),
                          new Padding(
                            padding: EdgeInsets.symmetric(vertical: 5.0),
                            child: new Text('优先级',
                              style: new TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.grey
                              ),
                            ),
                          ),
                          new DropdownButton(
                            value: _currentPriority,
                            items: _dropDownMenuPris,
                            onChanged: changedDropDownPri,
                          ),
                          new Padding(
                            padding: EdgeInsets.symmetric(vertical: 5.0),
                            child: new Text('请求附件',
                              style: new TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.grey
                              ),
                            ),
                          ),
                          new Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              new Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Image.asset(
                                  'assets/mri.jpg',
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
                          title: Text('派工内容'),
                          subtitle: Text('编号:PGD00000001'),
                      );
                    },
                    body: new Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: new Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new Padding(
                            padding: EdgeInsets.symmetric(vertical: 5.0),
                            child: new Text('派工类型',
                              style: new TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.grey
                              ),
                            ),
                          ),
                          new DropdownButton(
                            value: _currentType,
                            items: _dropDownMenuTypes,
                            onChanged: changedDropDownType,
                          ),
                          new Padding(
                            padding: EdgeInsets.symmetric(vertical: 5.0),
                            child: new Text('紧急程度',
                              style: new TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.grey
                              ),
                            ),
                          ),
                          new DropdownButton(
                            value: _currentLevel,
                            items: _dropDownMenuLevels,
                            onChanged: changedDropDownLevel,
                          ),
                          new Padding(
                            padding: EdgeInsets.symmetric(vertical: 5.0),
                            child: new Text('机器状态',
                              style: new TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.grey
                              ),
                            ),
                          ),
                          new DropdownButton(
                            value: _currentStatus,
                            items: _dropDownMenuStatuses,
                            onChanged: changedDropDownStatus,
                          ),
                          new Padding(
                            padding: EdgeInsets.symmetric(vertical: 5.0),
                            child: new Text('工程师姓名',
                              style: new TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.grey
                              ),
                            ),
                          ),
                          new DropdownButton(
                            value: _currentName,
                            items: _dropDownMenuNames,
                            onChanged: changedDropDownName,
                          ),
                          buildTextField('主管备注', '', true),
                          new MaterialButton(
                            child: new Text('选择日期'),
                            onPressed: () {
                              showDatePicker(
                                context: context,
                                initialDate: new DateTime.now(),
                                firstDate: new DateTime.now().subtract(new Duration(days: 30)), // 减 30 天
                                lastDate: new DateTime.now().add(new Duration(days: 30)),       // 加 30 天
                                locale: Locale('zh')
                              ).then((DateTime val) {
                                print(val);   // 2018-07-12 00:00:00.000
                              }).catchError((err) {
                                print(err);
                              });
                            },
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
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('已安排'),
                          )
                        );
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: EdgeInsets.all(12.0),
                      color: Theme.of(context).accentColor,
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
                      color: Theme.of(context).accentColor,
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