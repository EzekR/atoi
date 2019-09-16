import 'package:flutter/material.dart';
import 'package:atoi/utils/http_request.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:atoi/utils/constants.dart';
import 'package:photo_view/photo_view.dart';
import 'dart:convert';
import 'package:atoi/widgets/build_widget.dart';

class ManagerCompletePage extends StatefulWidget {
  static String tag = 'mananger-complete-page';
  ManagerCompletePage({Key key, this.requestId}):super(key: key);
  final int requestId;

  @override
  _ManagerCompletePageState createState() => new _ManagerCompletePageState();

}

class _ManagerCompletePageState extends State<ManagerCompletePage> {

  var _isExpandedBasic = true;
  var _isExpandedDetail = false;
  var _isExpandedAssign = false;
  var _isExpandedJournal = false;
  var _isExpandedReport = false;
  var _isExpandedAcc = false;
  Map<String, dynamic> _request = {};
  var _dispatch;
  var _journal;
  var _report;


  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

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

  String _userName = '';
  String _mobile = '';

  Future<Null> getRole() async {
    var prefs = await _prefs;
    var userName = prefs.getString('userName');
    var mobile = prefs.getString('mobile');
    setState(() {
      _userName = userName;
      _mobile = mobile;
    });
  }
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
  List<dynamic> imageBytes = [];
  List<int> _imageBytes = [];
  var _accessory;

  void initState() {
    getRole();
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
    getRequest();
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

  Future<Null> getDispatch() async {
    var resp = await HttpRequest.request(
      '/Dispatch/GetDispatchByRequestID',
      method: HttpRequest.GET,
      params: {
        'id': widget.requestId
      }
    );
    print(resp);
    if (resp['ResultCode'] == '00' && resp['Data'] != null) {
      setState(() {
        _dispatch = resp['Data'];
      });
      var journalId = resp['Data']['DispatchJournal']['ID'];
      var reportId = resp['Data']['DispatchReport']['ID'];
      var reportStatus = resp['Data']['DispatchReport']['Status']['ID'];
      if (journalId != 0) {
        getJournal(journalId);
      }
      if (reportId != 0 && reportStatus > 1) {
        getReport(reportId);
      }
    }
  }

  Future<Null> getJournal(int journalId) async {
    var prefs = await _prefs;
    var userID = prefs.getInt('userID');
    var resp = await HttpRequest.request(
      '/DispatchJournal/GetDispatchJournal',
      method: HttpRequest.GET,
      params: {
        'userID': userID,
        'dispatchJournalId': journalId
      }
    );
    print(resp);
    if (resp['ResultCode'] == '00') {
      setState(() {
        _journal = resp['Data'];
        _imageBytes = base64Decode(resp['Data']['FileContent']);
      });
    }
  }

  Future<Null> getReport(int reportId) async {
    var prefs = await _prefs;
    var userID = prefs.getInt('userID');
    var resp = await HttpRequest.request(
        '/DispatchReport/GetDispatchReport',
        method: HttpRequest.GET,
        params: {
          'userID': userID,
          'dispatchReportId': reportId
        }
    );
    print(resp);
    if (resp['ResultCode'] == '00') {
      setState(() {
        _report = resp['Data'];
      });
      _accessory = resp['Data']['ReportAccessories'];
      for(var _acc in _accessory) {
        var _imageNew = _acc['FileInfos'].firstWhere((info) => info['FileType']==1, orElse: () => null);
        var _imageOld = _acc['FileInfos'].firstWhere((info) => info['FileType']==2, orElse: () => null);
        if (_imageNew != null) {
          var _fileNew = await getAccessoryFile(_imageNew['ID']);
          _imageNew['FileContent'] = _fileNew;
          setState(() {
            _acc['ImageNew'] = _imageNew;
          });
        }
        if (_imageOld != null) {
          var _fileOld = await getAccessoryFile(_imageOld['ID']);
          _imageOld['FileContent'] = _fileOld;
          setState(() {
            _acc['ImageOld'] = _imageOld;
          });
        }
      }
      setState(() {
        _accessory = _accessory;
      });
    }
  }

  Future<Null> getImage(int fileId) async {
    var resp = await HttpRequest.request(
        '/Request/DownloadUploadFile',
        params: {
          'ID': fileId
        },
        method: HttpRequest.GET
    );
    print(resp);
    if (resp['ResultCode'] == '00') {
      setState(() {
        imageBytes.add(resp['Data']);
      });
    }
  }

  Future<Null> getRequest() async {
    var prefs = await _prefs;
    var userID = prefs.getInt('userID');
    var requestID = widget.requestId;
    var resp = await HttpRequest.request(
      '/Request/GetRequestByID',
      method: HttpRequest.GET,
      params: {
        'userID': userID,
        'requestID': requestID
      }
    );
    print(resp);
    if (resp['ResultCode'] == '00') {
      var files = resp['Data']['Files'];
      for (var file in files) {
        getImage(file['ID']);
      }
      await getDispatch();
      setState(() {
        _request = resp['Data'];
      });
    }
  }

  Column buildImageColumn() {
    if (imageBytes == null) {
      return new Column();
    } else {
      List<Widget> _list = [];
      for(var file in imageBytes) {
        _list.add(new Container(
          child: new PhotoView(imageProvider: MemoryImage(base64Decode(file))),
          width: 400.0,
          height: 400.0,
        ));
      }
      return new Column(children: _list);
    }
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

  Future<String> getAccessoryFile(int fileId) async {
    String _image = '';
    var resp = await HttpRequest.request(
        '/DispatchReport/DownloadAccessoryFile',
        method: HttpRequest.GET,
        params: {
          'ID': fileId
        }
    );
    if (resp['ResultCode'] == '00') {
      _image = resp['Data'];
    }
    return _image;
  }
  List<Widget> buildEquipment() {
    if (_request.isNotEmpty) {
      var _equipments = _request['Equipments'];
      List<Widget> _equipList = [];
      for (var _equipment in _equipments) {
        var _list = [
          BuildWidget.buildRow('系统编号', _equipment['OID']??''),
          BuildWidget.buildRow('名称', _equipment['Name']??''),
          BuildWidget.buildRow('型号', _equipment['EquipmentCode']??''),
          BuildWidget.buildRow('序列号', _equipment['SerialCode']??''),
          BuildWidget.buildRow('使用科室', _equipment['Department']['Name']??''),
          BuildWidget.buildRow('安装地点', _equipment['InstalSite']??''),
          BuildWidget.buildRow('设备厂商', _equipment['Manufacturer']['Name']??''),
          BuildWidget.buildRow('资产等级', _equipment['AssetLevel']['Name']??''),
          BuildWidget.buildRow('维保状态', _equipment['WarrantyStatus']??''),
          BuildWidget.buildRow('服务范围', _equipment['ContractScope']['Name']??''),
          new Padding(padding: EdgeInsets.symmetric(vertical: 8.0))
        ];
        _equipList.addAll(_list);
      }
      return _equipList;
    } else {
      return [];
    }
  }

  List<Widget> buildAccessory() {
    List<Widget> _list = [];
    for (var _acc in _accessory) {
      var _accList = [
        BuildWidget.buildRow('名称', _acc['Name']),
        BuildWidget.buildRow('来源', _acc['Source']['Name']),
        _acc['Source']['Name'] == '外部供应商' ? BuildWidget.buildRow(
            '外部供应商', _acc['Supplier']['Name']) : new Container(),
        BuildWidget.buildRow('新装零件编号', _acc['NewSerialCode']),
        BuildWidget.buildRow('附件', ''),
        new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _acc['ImageNew']!=null&&_acc['ImageNew']['FileContent']!=null?new Container(width: 100.0,
              child: new Image.memory(
                  base64Decode(_acc['ImageNew']['FileContent'])),):new Container()
          ],
        ),
        BuildWidget.buildRow('金额（元/件）', _acc['Amount'].toString()),
        BuildWidget.buildRow('数量', _acc['Qty'].toString()),
        BuildWidget.buildRow('拆下零件编号', _acc['OldSerialCode']),
        BuildWidget.buildRow('附件', ''),
        new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _acc['ImageOld']!=null&&_acc['ImageOld']['FileContent']!=null?new Container(width: 100.0,
              child: new Image.memory(
                  base64Decode(_acc['ImageOld']['FileContent'])),):new Container()
          ],
        ),
        new Divider()
      ];
      _list.addAll(_accList);
    }
    return _list;
  }

  List<ExpansionPanel> buildExpansion() {
    List<ExpansionPanel> _list = [];
    if (_request['RequestType']['ID'] != 14) {
      _list.add(
        new ExpansionPanel(
          headerBuilder: (context, isExpanded) {
            return ListTile(
              leading: new Icon(Icons.info,
                size: 24.0,
                color: Colors.blue,
              ),
              title: Text('设备基本信息',
                style: new TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.w400
                ),
              ),
            );
          },
          body: new Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            child: new Column(
              children: buildEquipment(),
            ),
          ),
          isExpanded: _isExpandedBasic,
        ),
      );
    }
    _list.add(
      new ExpansionPanel(
        headerBuilder: (context, isExpanded) {
          return ListTile(
              leading: new Icon(Icons.description,
                size: 24.0,
                color: Colors.blue,
              ),
              title: Text('请求详细信息',
                style: new TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.w400
                ),
              ),
          );
        },
        body: new Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              BuildWidget.buildRow('类型', _request['SourceType']),
              BuildWidget.buildRow('主题', _request['SubjectName']),
              BuildWidget.buildRow('请求状态', _request['Status']['Name']),
              BuildWidget.buildRow(AppConstants.Remark[_request['RequestType']['ID']], _request['FaultDesc']),
              _request['RequestType']['ID'] == 1||_request['RequestType']['ID'] == 2||_request['RequestType']['ID'] == 3||_request['RequestType']['ID'] == 7?BuildWidget.buildRow(AppConstants.RemarkType[_request['RequestType']['ID']], _request['FaultType']['Name']):new Container(),
              BuildWidget.buildRow('请求人', _request['RequestUser']['Name']),
              _request['Status']['ID']==1?new Container():BuildWidget.buildRow('处理方式', _request['DealType']['Name']),
              _request['Status']['ID']==1?new Container():BuildWidget.buildRow('当前状态', _request['Status']['Name']),
              //_request['Status']['ID']==1?new Container():BuildWidget.buildRow('紧急程度', _request['Priority']['Name']),
              BuildWidget.buildRow('请求附件', ''),
              buildImageColumn()
            ],
          ),
        ),
        isExpanded: _isExpandedDetail,
      ),
    );
    if (_dispatch != null) {
      _list.add(
        new ExpansionPanel(
            headerBuilder: (context, isExpanded) {
              return ListTile(
                  leading: new Icon(Icons.description,
                    size: 24.0,
                    color: Colors.blue,
                  ),
                  title: Text('派工内容信息',
                    style: new TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.w400
                    ),
                  ),
              );
            },
            body: new Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  BuildWidget.buildRow('派工单编号', _dispatch['OID']),
                  BuildWidget.buildRow('派工单状态', _dispatch['Status']['Name']),
                  BuildWidget.buildRow('派工类型', _dispatch['RequestType']['Name']),
                  BuildWidget.buildRow('工程师姓名', _dispatch['Engineer']['Name']),
                  BuildWidget.buildRow('紧急程度', _dispatch['Urgency']['Name']),
                  BuildWidget.buildRow('机器状态', _dispatch['MachineStatus']['Name']),
                  BuildWidget.buildRow('出发时间', AppConstants.TimeForm(_dispatch['ScheduleDate'], 'yyyy-mm-dd')),
                  BuildWidget.buildRow('备注', _dispatch['LeaderComments']),
                ],
              ),
            ),
          isExpanded: _isExpandedAssign,
        )
      );
    }
    if (_journal != null) {
      _list.add(
          new ExpansionPanel(
            headerBuilder: (context, isExpanded) {
              return ListTile(
                  leading: new Icon(Icons.description,
                    size: 24.0,
                    color: Colors.blue,
                  ),
                  title: Text('凭证信息',
                    style: new TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.w400
                    ),
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
                  BuildWidget.buildRow('服务凭证编号', _journal['OID']),
                  BuildWidget.buildRow('审批状态', _journal['Status']['Name']),
                  BuildWidget.buildRow('故障现象/错误代码/事由', _journal['FaultCode']),
                  BuildWidget.buildRow('工作内容', _journal['JobContent']),
                  BuildWidget.buildRow('待跟进问题', _journal['FollowProblem']),
                  BuildWidget.buildRow('待确认问题', _journal['UnconfirmedProblem']),
                  BuildWidget.buildRow('建议留言', _journal['Advice']),
                  BuildWidget.buildRow('服务结果', _journal['ResultStatus']['Name']),
                  BuildWidget.buildRow('客户签名', ''),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      new Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Image.memory(
                          _imageBytes??[],
                          width: 300.0,
                          height: 300.0,
                        ),
                      ),
                    ],
                  ),
                  _journal['FujiComments']!=''?BuildWidget.buildRow('审批备注', _journal['FujiComments']):new Container()
                ],
              ),
            ),
            isExpanded: _isExpandedJournal,
          )
      );
    }
    if (_report != null) {
      _list.add(
          new ExpansionPanel(
            headerBuilder: (context, isExpanded) {
              return ListTile(
                  leading: new Icon(Icons.description,
                    size: 24.0,
                    color: Colors.blue,
                  ),
                  title: Text('报告信息',
                    style: new TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.w400
                    ),
                  ),
              );
            },
            body: new Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  BuildWidget.buildRow('作业报告编号', _report['OID']),
                  BuildWidget.buildRow('作业报告类型', _report['Type']['Name']),
                  BuildWidget.buildRow('审批状态', _report['Status']['Name']),
                  BuildWidget.buildRow('发生频率', _report['FaultFrequency']),
                  BuildWidget.buildRow('系统状态', _report['FaultSystemStatus']??'正常'),
                  BuildWidget.buildRow('错误代码', _report['FaultCode']),
                  BuildWidget.buildRow('故障描述', _report['FaultDesc']),
                  BuildWidget.buildRow('分析原因', _report['SolutionCauseAnalysis']),
                  BuildWidget.buildRow('处理方法', _report['SolutionWay']),
                  BuildWidget.buildRow('未解决备注', _report['SolutionUnsolvedComments']),
                  _report['DelayReason']!=''?BuildWidget.buildRow('误工说明', _report['DelayReason']):new Container(),
                  BuildWidget.buildRow('作业结果', _report['SolutionResultStatus']['Name']),
                  _report['FujiComments']!=''?BuildWidget.buildRow('审批说明', _report['FujiComments']):new Container()
                ],
              ),
            ),
            isExpanded: _isExpandedReport,
          )
      );
    }
    if (_report !=null && _report['ReportAccessories'].isNotEmpty) {
      _list.add(
          new ExpansionPanel(
            headerBuilder: (context, isExpanded) {
              return ListTile(
                  leading: new Icon(Icons.description,
                    size: 24.0,
                    color: Colors.blue,
                  ),
                  title: Text('零件信息',
                    style: new TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.w400
                    ),
                  )
              );
            },
            body: new Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: buildAccessory(),
              ),
            ),
            isExpanded: _isExpandedAcc,
          )
      );
    }
    return _list;
  }

  @override
  Widget build(BuildContext context){
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('请求详情'),
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
          new Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 19.0),
            child: Text(_userName),
          ),
        ],
      ),
      body: _request.isEmpty?new Center(child: new SpinKitRotatingPlain(color: Colors.blue,),):new Padding(
        padding: EdgeInsets.symmetric(vertical: 5.0),
        child: new Card(
          child: new ListView(
            children: <Widget>[
              new ExpansionPanelList(
                animationDuration: Duration(milliseconds: 200),
                expansionCallback: (index, isExpanded) {
                  switch (index) {
                    case 0:
                      setState(() {
                        _request['RequestType']['ID']==14?_isExpandedDetail=!_isExpandedDetail:_isExpandedBasic = !_isExpandedBasic;
                      });
                      break;
                    case 1:
                      setState(() {
                        _request['RequestType']['ID']==14?_isExpandedAssign=!_isExpandedAssign:_isExpandedDetail = !_isExpandedDetail;
                      });
                      break;
                    case 2:
                      setState(() {
                        _request['RequestType']['ID']==14?_isExpandedJournal=!_isExpandedJournal:_isExpandedAssign = !_isExpandedAssign;
                      });
                      break;
                    case 3:
                      setState(() {
                        _request['RequestType']['ID']==14||_journal==null?_isExpandedReport=!_isExpandedReport:_isExpandedJournal = !_isExpandedJournal;
                      });
                      break;
                    case 4:
                      setState(() {
                        _journal==null||_report==null?_isExpandedAcc=!_isExpandedAcc:_isExpandedReport = !_isExpandedReport;
                      });
                      break;
                    case 5:
                      setState(() {
                        _isExpandedAcc = !_isExpandedAcc;
                      });
                  }
                },
                children: buildExpansion(),
              ),
              SizedBox(height: 24.0),
            ],
          ),
        ),
      ),
    );
  }
}
