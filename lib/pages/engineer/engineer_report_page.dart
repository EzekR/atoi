import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:atoi/utils/http_request.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:atoi/utils/constants.dart';

class EngineerReportPage extends StatefulWidget {
  static String tag = 'engineer-report-page';
  EngineerReportPage({Key key, this.dispatchId}):super(key: key);
  final int dispatchId;

  @override
  _EngineerReportPageState createState() => new _EngineerReportPageState();
}

class _EngineerReportPageState extends State<EngineerReportPage> {

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
  var _dispatch = {};
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  var _frequency = new TextEditingController();
  var _code = new TextEditingController();
  var _status = new TextEditingController();
  var _description = new TextEditingController();
  var _analysis = new TextEditingController();
  var _solution = new TextEditingController();
  var _delay = new TextEditingController();
  var _unsolved = new TextEditingController();

  Future<Null> getDispatch() async {
    var prefs = await _prefs;
    var userID = prefs.getInt('userID');
    var dispatchId = widget.dispatchId;
    var resp = await HttpRequest.request(
        '/Dispatch/GetDispatchByID',
        method: HttpRequest.GET,
        params: {
          'userID': userID,
          'dispatchID': dispatchId
        }
    );
    print(resp);
    if (resp['ResultCode'] == '00') {
      setState(() {
        _dispatch = resp['Data'];
      });
    }
  }

  Future<Null> uploadReport() async {
    if (_frequency.text.isEmpty || _code.text.isEmpty || _status.text.isEmpty || _description.text.isEmpty || _analysis.text.isEmpty || _solution.text.isEmpty) {
      showDialog(context: context,
        builder: (context) => AlertDialog(
          title: new Text('报告不可有空字段'),
        )
      );
    } else {
      var prefs = await _prefs;
      var userID = prefs.getInt('userID');
      var _data = {
        'userID': userID,
        'dispatchReport': {
          'Dispatch': {
            'ID': widget.dispatchId
          },
          'Type': {
            'ID': 1,
            'Name': '通用作业报告'
          },
          'FaultFrequency': _frequency.text,
          'FaultCode': _code.text,
          'FaultSystemStatus': _status.text,
          'FaultDesc': _description.text,
          'SolutionCauseAnalysis': _analysis.text,
          'SolutionWay': _solution.text,
          'SolutionResultStatus': {
            'ID': AppConstants.SolutionStatus[_currentResult],
            'Name': _currentResult
          },
          'SolutionUnsolvedComments': _unsolved.text,
          'DelayReason': _delay.text,
          'Status': {
            'ID': 2,
            'Name': '待审批'
          }
        }
      };
      var resp = await HttpRequest.request(
          '/DispatchReport/SaveDispatchReport',
          method: HttpRequest.POST,
          data: _data
      );
      print(resp);
      if (resp['ResultCode'] == '00') {
        showDialog(context: context,
            builder: (context) =>
                AlertDialog(
                    title: new Text('上传报告成功')
                )
        ).then((result) =>
            Navigator.of(context, rootNavigator: true).pop(result)
        );
      }
    }
  }

  void initState(){
    _dropDownMenuItems = getDropDownMenuItems(_serviceResults);
    _currentResult = _dropDownMenuItems[0].value;
    getDispatch();
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

  Column buildField(String label, TextEditingController controller) {
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        new Text(
          label,
          style: new TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w600
          ),
        ),
        new TextField(
          controller: controller,
        ),
        new SizedBox(height: 5.0,)
      ],
    );
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

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('上传报告'),
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
            child: const Text('武田信玄'),
          ),
        ],
      ),
      body: _dispatch.isEmpty?new Center(child: new SpinKitRotatingPlain(color: Colors.blue),):new Padding(
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
                          buildRow('设备系统编号：', _dispatch['Request']['Equipments'][0]['OID']),
                          buildRow('设备名称：', _dispatch['Request']['Equipments'][0]['Name']),
                          buildRow('使用科室：', _dispatch['Request']['Equipments'][0]['Department']['Name']),
                          buildRow('设备厂商：', _dispatch['Request']['Equipments'][0]['Manufacturer']['Name']),
                          buildRow('资产等级：', _dispatch['Request']['Equipments'][0]['AssetLevel']['Name']),
                          //buildRow('设备型号：', _dispatch['Request']['Equipments'][0]['SerialCode']),
                          buildRow('保修状况：', _dispatch['Request']['Equipments'][0]['WarrantyStatus']),
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
                              child: Text('派工内容',
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
                          buildRow('派工单编号：', _dispatch['OID']),
                          buildRow('类型：', _dispatch['Request']['SourceType']),
                          buildRow('请求人：', _dispatch['Request']['RequestUser']['Name']),
                          buildRow('处理方式：', _dispatch['Request']['DealType']['Name']),
                          buildRow('紧急程度：', _dispatch['Request']['Priority']['Name']),
                          buildRow('机器状态：', _dispatch['MachineStatus']['Name']),
                          buildRow('出发时间：', _dispatch['ScheduleDate']),
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
                          buildField('发生频率：', _frequency),
                          buildField('系统状态：', _status),
                          buildField('错误代码：', _code	),
                          buildField('故障描述：', _description),
                          buildField('分析原因：', _analysis),
                          buildField('处理方法：', _solution),
                          buildField('未解决备注：', _unsolved),
                          buildField('误工说明：', _delay),
                          buildDropdown('作业结果：', _currentResult, _dropDownMenuItems, changedDropDownMethod),
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
                      uploadReport();
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: EdgeInsets.all(12.0),
                    color: new Color(0xff2E94B9),
                    child: Text('上传报告', style: TextStyle(color: Colors.white)),
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
