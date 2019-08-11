import 'package:flutter/material.dart';
import 'package:atoi/pages/engineer/signature_page.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:atoi/utils/http_request.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:atoi/utils/constants.dart';

class EngineerVoucherPage extends StatefulWidget {
  static String tag = 'engineer-voucher-page';
  EngineerVoucherPage({Key key, this.dispatchId, this.journalId}):super(key: key);
  final int dispatchId;
  final int journalId;

  @override
  _EngineerVoucherPageState createState() => new _EngineerVoucherPageState();
}

class _EngineerVoucherPageState extends State<EngineerVoucherPage> {

  var _isExpandedBasic = false;
  var _isExpandedDetail = false;
  var _isExpandedAssign = true;
  var _faultCode = new TextEditingController();
  var _jobContent = new TextEditingController();
  var _followProblem = new TextEditingController();
  var _unconfirmed = new TextEditingController();
  var _advice = new TextEditingController();
  String _signature;

  List _serviceResults = [
    '完成',
    '待跟进'
  ];

  Map<String, dynamic> _dispatch = {};

  List<DropdownMenuItem<String>> _dropDownMenuItems;
  String _currentResult;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<Null> getJournal() async {
    var _journalId = widget.journalId;
    if (_journalId !=0) {
      var prefs = await _prefs;
      var userID = prefs.getInt('userID');
      var resp = await HttpRequest.request(
        '/DispatchJournal/GetDispatchJournal',
        method: HttpRequest.GET,
        params: {
          'userID': userID,
          'dispatchJournalId': _journalId
        }
      );
      print(resp);
      if (resp['ResultCode'] == '00') {
        var _data = resp['Data'];
        setState(() {
          _signature = _data['FileContent'];
          _img = base64Decode(_signature).buffer.asByteData();
          _faultCode.text = _data['FaultCode'];
          _jobContent.text = _data['JobContent'];
          _followProblem.text = _data['FollowProblem'];
          _unconfirmed.text = _data['UnconfirmedProblem'];
          _advice.text = _data['Advice'];
        });
      }
    }
  }

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

  Future<Null> uploadJournal() async {
    if (_img.buffer.lengthInBytes == 0 ) {
      showDialog(context: context,
          builder: (context) => AlertDialog(
          title: new Text('签名不可为空'),
        )
      );
      return;
    }
    if (_jobContent.text.isEmpty) {
      showDialog(context: context,
          builder: (context) => AlertDialog(
            title: new Text('工作内容不可为空'),
          )
      );
      return;
    }
    if (_faultCode.text.isEmpty) {
      showDialog(context: context,
        builder: (context) => AlertDialog(
          title: new Text('故障事由不可为空'),
        )
      );
    } else {
      var prefs = await _prefs;
      var userId = prefs.getInt('userID');
      var dispatchId = widget.dispatchId;
      var image = base64Encode(_img.buffer.asUint8List());
      var status = AppConstants.ResultStatusID[_currentResult];
      var resp = await HttpRequest.request(
          '/DispatchJournal/SaveDispatchJournal',
          method: HttpRequest.POST,
          data: {
            'userID': userId,
            'dispatchJournalInfo': {
              'ID': 0,
              'dispatch': {
                'ID': dispatchId
              },
              'FaultCode': _faultCode.text,
              'JobContent': _jobContent.text,
              'FollowProblem': _followProblem.text,
              'UnconfirmedProblem': _unconfirmed.text,
              'ResultStatus': {
                'ID': status
              },
              'FileContent': image
            }
          }
      );
      print(resp);
      if (resp['ResultCode'] == '00') {
        showDialog(context: context,
            builder: (context) =>
                AlertDialog(
                    title: new Text('上传凭证成功')
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

  TextField buildTextField(String labelText, String defaultText, bool isEnabled) {
    return new TextField(
      decoration: InputDecoration(
          labelText: labelText,
          labelStyle: new TextStyle(
              fontSize: 28.0,
              fontWeight: FontWeight.w600,
              color: Colors.black
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
          fontSize: 20.0,
          color: Colors.grey
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

  Column buildField(String label, String defaultText) {
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
          controller: new TextEditingController(text: defaultText),
        ),
        new SizedBox(height: 5.0,)
      ],
    );
  }

  Column buildEditor(String label, TextEditingController controller) {
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

  ByteData _img = ByteData(0);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    toSignature (BuildContext context) async {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SignaturePage()),
      );
      setState(() {
        _img = result;
      });
    }

    return new Scaffold(
      appBar: new AppBar(
        title: new Text('上传凭证'),
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
      body: _dispatch.isEmpty?new Center(child: new SpinKitRotatingPlain(color: Colors.blue)):new Padding(
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
                          buildRow('系统编号:', _dispatch['Request']['Equipments'][0]['OID']??''),
                          buildRow('设备名称：', _dispatch['Request']['Equipments'][0]['Name']??''),
                          buildRow('设备型号：', _dispatch['Request']['Equipments'][0]['EquipmentCode']??''),
                          buildRow('设备序列号：', _dispatch['Request']['Equipments'][0]['SerialCode']??''),
                          buildRow('使用科室：', _dispatch['Request']['Equipments'][0]['Department']['Name']??''),
                          buildRow('安装地点：', _dispatch['Request']['Equipments'][0]['InstalSite']??''),
                          buildRow('设备厂商：', _dispatch['Request']['Equipments'][0]['Manufacturer']['Name']??''),
                          buildRow('资产等级：', _dispatch['Request']['Equipments'][0]['AssetLevel']['Name']??''),
                          buildRow('维保状态：', _dispatch['Request']['Equipments'][0]['WarrantyStatus']??''),
                          buildRow('服务范围：', _dispatch['Request']['Equipments'][0]['ContractScope']['Name']??''),
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
                          buildRow('派工类型：', _dispatch['RequestType']['Name']),
                          buildRow('工程师姓名：', _dispatch['Engineer']['Name']),
                          buildRow('处理方式：', _dispatch['Request']['DealType']['Name']),
                          buildRow('紧急程度：', _dispatch['Request']['Priority']['Name']),
                          buildRow('机器状态：', _dispatch['MachineStatus']['Name']),
                          buildRow('出发时间：', AppConstants.TimeForm(_dispatch['ScheduleDate'], 'yyyy-mm-dd')),
                          buildRow('备注：', _dispatch['LeaderComments']),
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
                          buildRow('客户姓名：', _dispatch['Request']['RequestUser']['Name']),
                          buildRow('客户电话：', _dispatch['Request']['RequestUser']['Mobile']),
                          buildEditor('故障现象/错误代码/事由：', _faultCode),
                          buildEditor('工作内容：', _jobContent),
                          buildEditor('待跟进问题：', _followProblem),
                          buildEditor('待确认问题：', _unconfirmed),
                          buildEditor('建议留言：', _advice),
                          buildDropdown('服务结果：', _currentResult, _dropDownMenuItems, changedDropDownMethod),
                          new Padding(
                            padding: EdgeInsets.symmetric(vertical: 5.0),
                            child: new Text('客户签名：',
                              style: new TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w600
                              ),
                            ),
                          ),
                          _img.buffer.lengthInBytes == 0? new RaisedButton(onPressed: () {toSignature(context);}, child: new Icon(Icons.add_box)):new Container(width: 400.0, height: 400.0, child: new Image.memory(_img.buffer.asUint8List())),
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
                      uploadJournal();
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: EdgeInsets.all(12.0),
                    color: new Color(0xff2E94B9),
                    child: Text('上传凭证', style: TextStyle(color: Colors.white)),
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


