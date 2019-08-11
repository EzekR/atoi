import 'package:flutter/material.dart';
import 'package:atoi/utils/http_request.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:convert';
import 'package:atoi/utils/constants.dart';

class ManagerAuditVoucherPage extends StatefulWidget {
  static String tag = 'manager-audit-voucher-page';
  ManagerAuditVoucherPage({Key key, this.journalId, this.request}):super(key: key);
  final int journalId;
  final Map request;

  @override
  _ManagerAuditVoucherPageState createState() => new _ManagerAuditVoucherPageState();
}

class _ManagerAuditVoucherPageState extends State<ManagerAuditVoucherPage> {

  var _isExpandedBasic = true;
  var _isExpandedDetail = false;
  var _isExpandedAssign = false;
  Map<String, dynamic> _dispatch = {};
  var _equipment = {};
  TextEditingController _comment = new TextEditingController();

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  List _serviceResults = [
    '完成',
    '待跟进'
  ];

  List<int> imageBytes;

  Map<String, dynamic> _journal = {};

  Future<Null> getJournal() async {
    var prefs = await _prefs;
    var userId = prefs.getInt('userID');
    var journalId = widget.journalId;
    var resp = await HttpRequest.request(
      '/DispatchJournal/GetDispatchJournal',
      method: HttpRequest.GET,
      params: {
        'userID': userId,
        'dispatchJournalId': journalId
      },
    );
    print(resp);
    if (resp['ResultCode'] == '00') {
      setState(() {
        _journal = resp['Data'];
        imageBytes = base64Decode(resp['Data']['FileContent']);
      });
    }
  }

  List<DropdownMenuItem<String>> _dropDownMenuItems;
  String _currentResult;

  void initState(){
    _dropDownMenuItems = getDropDownMenuItems(_serviceResults);
    _currentResult = _dropDownMenuItems[0].value;
    print('widget info:${widget.request}');
    getDispatch();
    getJournal();
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Expanded(
            flex: 4,
            child: new Text(
              labelText,
              style: new TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.justify,
            ),
          ),
          new Expanded(
            flex: 1,
            child: new Text(':',
              style: new TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w600
              ),
            ),
          ),
          new Expanded(
            flex: 5,
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

  Future<Null> approveJournal() async {
    final SharedPreferences prefs = await _prefs;
    var UserId = await prefs.getInt('userID');
    Map<String, dynamic> _data = {
      'userID': UserId,
      'dispatchJournalID': widget.journalId,
      'resultStatusID': AppConstants.ResultStatusID[_currentResult]
    };
    var _response = await HttpRequest.request(
      '/DispatchJournal/ApproveDispatchJournal',
      method: HttpRequest.POST,
      data: _data
    );
    print(_response);
    if (_response['ResultCode'] == '00') {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: new Text('通过凭证'),
          )
      ).then((result) {
        Navigator.of(context, rootNavigator: true).pop(result);
      });
    } else {
      showDialog(context: context,
        builder: (context) => AlertDialog(
          title: new Text(_response['ResultMessage'])
        )
      );
    }
  }

  Future<Null> rejectJournal() async {
    final SharedPreferences prefs = await _prefs;
    var UserId = await prefs.getInt('userID');
    print(widget.journalId);
    Map<String, dynamic> _data = {
      'userID': UserId,
      'dispatchJournalID': widget.journalId,
      'comment': _comment.text
    };
    var _response = await HttpRequest.request(
        '/DispatchJournal/RejectDispatchJournal',
        method: HttpRequest.POST,
        data: _data
    );
    print(_response);
    if (_response['ResultCode'] == '00') {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: new Text('拒绝凭证'),
          )
      );
    } else {
      showDialog(context: context,
        builder: (context) => AlertDialog(
          title: new Text(_response['ResultMessage']),
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('审核凭证'),
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
      body: _journal.isEmpty?new Center(child: SpinKitRotatingPlain(color: Colors.blue,),):new Padding(
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
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: new Column(
                        children: <Widget>[
                          buildRow('系统编号', _equipment['OID']??''),
                          buildRow('设备名称', _equipment['Name']??''),
                          buildRow('设备型号', _equipment['EquipmentCode']??''),
                          buildRow('设备序列号', _equipment['SerialCode']??''),
                          buildRow('使用科室', _equipment['Department']['Name']??''),
                          buildRow('安装地点', _equipment['InstalSite']??''),
                          buildRow('设备厂商', _equipment['Manufacturer']['Name']??''),
                          buildRow('资产等级', _equipment['AssetLevel']['Name']??''),
                          buildRow('维保状态', _equipment['WarrantyStatus']??''),
                          buildRow('服务范围', _equipment['ContractScopeComments']??''),
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
                          buildRow('派工单编号', widget.request['OID']),
                          buildRow('紧急程度', widget.request['Urgency']['Name']),
                          buildRow('派工类型', widget.request['RequestType']['Name']),
                          buildRow('机器状态', widget.request['MachineStatus']['Name']),
                          buildRow('工程师姓名', _dispatch['Engineer']['Name']),
                          buildRow('备注', widget.request['LeaderComments']),
                          buildRow('出发时间', widget.request['ScheduleDate']),
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
                              child: Text('服务详情信息',
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          buildRow('服务凭证编号', _journal['OID']),
                          buildRow('故障现象/错误代码/事由', _journal['FaultCode']),
                          buildRow('工作内容', _journal['JobContent']),
                          buildRow('待跟进问题', _journal['FollowProblem']),
                          buildRow('待确认问题', _journal['UnconfirmedProblem']),
                          buildRow('建议留言', _journal['Advice']),
                          new Padding(
                            padding: EdgeInsets.symmetric(vertical: 5.0),
                            child: new Text('客户签名：',
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
                                child: Image.memory(
                                  imageBytes??[],
                                  width: 300.0,
                                ),
                              ),
                            ],
                          ),
                          buildDropdown('服务结果：', _currentResult, _dropDownMenuItems, changedDropDownMethod),
                          buildTextField('审批备注', _comment, true),
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
                  new RaisedButton(
                    onPressed: () {
                      approveJournal();
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: EdgeInsets.all(12.0),
                    color: new Color(0xff2E94B9),
                    child: Text('通过凭证', style: TextStyle(color: Colors.white)),
                  ),
                  new RaisedButton(
                    onPressed: () {
                      rejectJournal();
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: EdgeInsets.all(12.0),
                    color: new Color(0xffD25565),
                    child: Text('退回凭证', style: TextStyle(color: Colors.white)),
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