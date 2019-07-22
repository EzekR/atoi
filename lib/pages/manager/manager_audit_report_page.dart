import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:atoi/utils/http_request.dart';

class ManagerAuditReportPage extends StatefulWidget {
  static String tag = 'manager-audit-report-page';
  ManagerAuditReportPage({Key key, this.request, this.reportId}): super(key: key);
  final Map request;
  final String reportId;

  @override
  _ManagerAuditReportPageState createState() => new _ManagerAuditReportPageState();
}

class _ManagerAuditReportPageState extends State<ManagerAuditReportPage> {

  var _isExpandedBasic = false;
  var _isExpandedDetail = false;
  var _isExpandedAssign = true;
  var _isExpandedComponent = false;

  List _serviceResults = [
    '待分配',
    '问题升级',
    '待第三方解决',
    '已解决'
  ];

  List<DropdownMenuItem<String>> _dropDownMenuItems;
  String _currentResult;

  void initState(){
    _dropDownMenuItems = getDropDownMenuItems(_serviceResults);
    _currentResult = _dropDownMenuItems[0].value;

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
      _currentResult = selectedMethod;
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
          fontSize: 20.0
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

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<Null> approveReport() async {
    final SharedPreferences prefs = await _prefs;
    var UserId = await prefs.getString('userId');
    Map<String, dynamic> _data = {
      'userID': UserId,
      'reportID': widget.reportId,
      'solutionResultID': '2',
      'comments': 'api'
    };
    var _response = await HttpRequest.request(
        '/DispatchReport/ApproveDispatchReport',
        method: HttpRequest.POST,
        data: _data
    );
    print(_response);
    if (_response['ErrorCode'] == '00') {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: new Text('通过报告'),
          )
      );
    }
  }

  Future<Null> rejectReport() async {
    final SharedPreferences prefs = await _prefs;
    var UserId = await prefs.getString('userId');
    Map<String, dynamic> _data = {
      'userID': UserId,
      'ReportID': widget.reportId,
      'comments': 'api'
    };
    var _response = await HttpRequest.request(
        '/DispatchReport/RejectDispatchReport',
        method: HttpRequest.POST,
        data: _data
    );
    print(_response);
    if (_response['ErrorCode'] == '00') {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: new Text('拒绝报告'),
          )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('审核报告'),
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
                        if (index == 2) {
                          _isExpandedAssign = !isExpanded;
                        } else {
                          _isExpandedComponent = !isExpanded;
                        }
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
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: new Column(
                        children: <Widget>[
                          buildRow('设备编号：', 'ZC00000001'),
                          buildRow('设备名称：', '医用磁共振设备'),
                          buildRow('使用科室：', '磁共振'),
                          buildRow('设备厂商：', '飞利浦'),
                          buildRow('资产等级：', '重要'),
                          buildRow('设备型号：', 'Philips 781-296'),
                          buildRow('安装地点：', '磁共振1室'),
                          buildRow('保修状况：', '保内'),
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
                              child: Text('派工单信息',
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
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: new Column(
                        children: <Widget>[
                          buildRow('派工单编号：', 'PGD00000001'),
                          buildRow('紧急程度：', '紧急'),
                          buildRow('派工类型：', '保内维修'),
                          buildRow('机器状态：', '停机'),
                          buildRow('工程师姓名：', '马云'),
                          buildRow('工作任务：', '系统报错'),
                          buildRow('出发时间：', '2019-01-01'),
                          buildRow('备注：', '' ),
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
                              child: Text('作业报告',
                                style: new TextStyle(
                                    fontSize: 22.0,
                                    fontWeight: FontWeight.w400
                                ),
                              ),
                              alignment: Alignment(-1.3, 0)
                          ),
                      );
                    },
                    body: new Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          buildRow('作业报告编号：', 'ZYBG00000001'),
                          buildRow('作业报告类型：', '通用作业报告'),
                          buildRow('发生频率：', '一直'),
                          buildRow('设备状态：', '正常'),
                          buildRow('错误代码：', 'oxe2135	'),
                          buildRow('故障描述：', '系统无法启动'),
                          buildRow('分析原因：', '这个是分析原因内容'),
                          buildRow('处理方法：', '更新球馆	'),
                          buildRow('结果：', '联络外部供应商更换球馆'),
                          buildRow('未解决备注：', '这个是未解决备注内容'),
                          buildRow('误工说明：', '误工说明原因的信息'),
                          buildDropdown('作业报告结果：', _currentResult, _dropDownMenuItems, changedDropDownMethod)
                        ],
                      ),
                    ),
                    isExpanded: _isExpandedAssign,
                  ),
                  new ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return ListTile(
                          leading: new Icon(Icons.settings,
                            size: 24.0,
                            color: Colors.blue,
                          ),
                          title: new Align(
                              child: Text('零配件信息',
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
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: new Column(
                        children: <Widget>[
                        ],
                      ),
                    ),
                    isExpanded: _isExpandedComponent,
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
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('通过凭证'),
                          )
                      );
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: EdgeInsets.all(12.0),
                    color: new Color(0xff2E94B9),
                    child: Text('通过报告', style: TextStyle(color: Colors.white)),
                  ),
                  new RaisedButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                              title: Text('退回报告')
                          )
                      );
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: EdgeInsets.all(12.0),
                    color: new Color(0xffD25565),
                    child: Text('退回报告', style: TextStyle(color: Colors.white)),
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
