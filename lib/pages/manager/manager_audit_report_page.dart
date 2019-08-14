import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:atoi/utils/http_request.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:atoi/utils/constants.dart';
import 'package:atoi/widgets/build_widget.dart';

class ManagerAuditReportPage extends StatefulWidget {
  static String tag = 'manager-audit-report-page';
  ManagerAuditReportPage({Key key, this.reportId, this.request, this.status}): super(key: key);
  final int reportId;
  final Map request;
  final int status;

  @override
  _ManagerAuditReportPageState createState() => new _ManagerAuditReportPageState();
}

class _ManagerAuditReportPageState extends State<ManagerAuditReportPage> {

  var _isExpandedBasic = false;
  var _isExpandedDetail = false;
  var _isExpandedAssign = true;
  var _isExpandedComponent = false;
  var _equipment = {};
  var _comment = new TextEditingController();

  List _serviceResults = [
    '待分配',
    '问题升级',
    '待第三方解决',
    '已解决'
  ];

  List<DropdownMenuItem<String>> _dropDownMenuItems;
  String _currentResult;
  Map<String, dynamic> _report = {};
  Map<String, dynamic> _dispatch = {};

  void initState(){
    _dropDownMenuItems = getDropDownMenuItems(_serviceResults);
    getDispatch();
    getReport();
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

  TextField buildTextField(String labelText, TextEditingController controller, bool isEnabled) {
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
      controller: controller,
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

  Future<Null> getReport() async {
    var prefs = await _prefs;
    var userID = prefs.getInt('userID');
    var reportId = widget.reportId;
    var resp = await HttpRequest.request(
      '/DispatchReport/GetDispatchReport',
      method: HttpRequest.GET,
      params: {
        'userID': userID,
        'DispatchReportId': reportId
      }
    );
    print(resp);
    if (resp['ResultCode'] == '00') {
      setState(() {
        _currentResult = resp['Data']['SolutionResultStatus']['Name'];
        _report = resp['Data'];
      });
    }
  }

  Future<Null> getDispatch() async {
    var prefs = await _prefs;
    var userID = prefs.getInt('userID');
    var dispatchId = widget.request['ID'];
    var resp = await HttpRequest.request(
      '/Dispatch/GetDispatchByID',
      method: HttpRequest.GET,
      params: {
        'userID': userID,
        'dispatchId': dispatchId
      }
    );
    print(resp);
    if (resp['ResultCode'] == '00') {
      setState(() {
        _equipment = resp['Data']['Request']['Equipments'][0];
        _dispatch = resp['Data'];
      });
    }
  }

  Future<Null> approveReport() async {
    final SharedPreferences prefs = await _prefs;
    var UserId = await prefs.getInt('userID');
    Map<String, dynamic> _data = {
      'userID': UserId,
      'reportID': widget.reportId,
      'solutionResultID': AppConstants.SolutionStatus[_currentResult],
      'comments': 'api'
    };
    var _response = await HttpRequest.request(
        '/DispatchReport/ApproveDispatchReport',
        method: HttpRequest.POST,
        data: _data
    );
    print(_response);
    if (_response['ResultCode'] == '00') {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: new Text('通过报告'),
          )
      ).then((result) {
        Navigator.of(context).pop(result);
      });
    } else {
      showDialog(context: context,
        builder: (context) => AlertDialog(
          title: new Text(_response['ResultMessage']),
        )
      );
    }
  }

  Future<Null> rejectReport() async {
    if (_comment.text.isEmpty) {
      showDialog(context: context,
        builder: (context) => AlertDialog(
          title: new Text('备注不可为空'),
        )
      );
    } else {
      final SharedPreferences prefs = await _prefs;
      var UserId = await prefs.getInt('userID');
      Map<String, dynamic> _data = {
        'userID': UserId,
        'reportID': widget.reportId,
        'comments': _comment.text
      };
      var _response = await HttpRequest.request(
          '/DispatchReport/RejectDispatchReport',
          method: HttpRequest.POST,
          data: _data
      );
      print(_response);
      if (_response['ResultCode'] == '00') {
        showDialog(
            context: context,
            builder: (context) =>
                AlertDialog(
                  title: new Text('退回报告成功'),
                )
        ).then((result) =>
          Navigator.of(context, rootNavigator: true).pop(result)
        );
      }
    }
  }

  List<Widget> buildAccessory() {
    var _accessory = _report['ReportAccessories'];
    List<Widget> _list = [];
    for (var _acc in _accessory) {
      var _accList = [
        BuildWidget.buildRow('名称', _acc['Name']),
        BuildWidget.buildRow('来源', _acc['Source']['Name']),
        BuildWidget.buildRow('外部供应商', _acc['Supplier']['Name']),
        BuildWidget.buildRow('新装零件编号', _acc['NewSerialCode']),
        BuildWidget.buildRow('金额（元/件）', _acc['Amount']),
        BuildWidget.buildRow('数量', _acc['Qty']),
        new Divider()
      ];
      _list.addAll(_accList);
    }
    return _list;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(
            widget.status==3?'查看报告':'审核报告'
        ),
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
      body: _report.isEmpty||_equipment.isEmpty?new Center(child: SpinKitRotatingPlain(color: Colors.blue,),):new Padding(
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
                          BuildWidget.buildRow('系统编号', _equipment['OID']??''),
                          BuildWidget.buildRow('名称', _equipment['Name']??''),
                          BuildWidget.buildRow('型号', _equipment['EquipmentCode']??''),
                          BuildWidget.buildRow('序列号', _equipment['SerialCode']??''),
                          BuildWidget.buildRow('使用科室', _equipment['Department']['Name']??''),
                          BuildWidget.buildRow('安装地点', _equipment['InstalSite']??''),
                          BuildWidget.buildRow('设备厂商', _equipment['Manufacturer']['Name']??''),
                          BuildWidget.buildRow('资产等级', _equipment['AssetLevel']['Name']??''),
                          BuildWidget.buildRow('维保状态', _equipment['WarrantyStatus']??''),
                          BuildWidget.buildRow('服务范围', _equipment['ContractScopeComments']??''),
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
                          BuildWidget.buildRow('派工单编号', widget.request['OID']),
                          BuildWidget.buildRow('紧急程度', widget.request['Urgency']['Name']),
                          BuildWidget.buildRow('派工类型', widget.request['RequestType']['Name']),
                          BuildWidget.buildRow('机器状态', widget.request['MachineStatus']['Name']),
                          BuildWidget.buildRow('工程师姓名', _dispatch['Engineer']['Name']),
                          BuildWidget.buildRow('出发时间',AppConstants.TimeForm(widget.request['ScheduleDate'], 'yyyy-mm-dd')),
                          BuildWidget.buildRow('备注', _dispatch['LeaderComments']),
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
                              child: Text('作业报告信息',
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
                          BuildWidget.buildRow('作业报告编号', _report['OID']),
                          BuildWidget.buildRow('作业报告类型', _report['Type']['Name']),
                          BuildWidget.buildRow('发生频率', _report['FaultFrequency']),
                          BuildWidget.buildRow('系统状态', _report['Dispatch']['MachineStatus']['Name']??'正常'),
                          BuildWidget.buildRow('错误代码', _report['FaultCode']),
                          BuildWidget.buildRow('故障描述', _report['FaultDesc']),
                          BuildWidget.buildRow('分析原因', _report['SolutionCauseAnalysis']),
                          BuildWidget.buildRow('处理方法', _report['SolutionWay']),
                          BuildWidget.buildRow('未解决备注', _report['SolutionUnsolvedComments']),
                          BuildWidget.buildRow('误工说明', _report['DelayReason']),
                          BuildWidget.buildDropdown('作业结果', _currentResult, _dropDownMenuItems, changedDropDownMethod),
                          buildTextField('审批备注', _comment, true),
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
                        children: buildAccessory(),
                      ),
                    ),
                    isExpanded: _isExpandedComponent,
                  ),
                ],
              ),
              SizedBox(height: 24.0),
              widget.status==3?new Container():new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  new RaisedButton(
                    onPressed: () {
                      approveReport();
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
                      rejectReport();
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
