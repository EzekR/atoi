import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:atoi/utils/http_request.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:atoi/utils/constants.dart';
import 'package:atoi/widgets/build_widget.dart';
import 'dart:convert';
import 'package:photo_view/photo_view.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:atoi/models/models.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
  ConstantsModel model;

  List _serviceResults = [
    '待分配',
    '问题升级',
    '待第三方支持',
    '已解决'
  ];

  List<DropdownMenuItem<String>> _dropDownMenuItems;
  String _currentResult;
  Map<String, dynamic> _report = {};
  Map<String, dynamic> _dispatch = {};

  String _userName = '';
  String _mobile = '';
  var _accessory;
  List<dynamic> imageAttach = [];

  Future<Null> getRole() async {
    var prefs = await _prefs;
    var userName = prefs.getString('userName');
    var mobile = prefs.getString('mobile');
    setState(() {
      _userName = userName;
      _mobile = mobile;
    });
  }

  List iterateMap(Map item) {
    var _list = [];
    item.forEach((key, val) {
      _list.add(key);
    });
    return _list;
  }

  void initDropdown() {
    _serviceResults = iterateMap(model.SolutionStatus);
    _dropDownMenuItems = getDropDownMenuItems(_serviceResults);
    _currentResult = _dropDownMenuItems[0].value;
  }

  void initState(){
    getRole();
    model = MainModel.of(context);
    initDropdown();
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
      maxLines: 3,
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
      var attachImage = await getAttachFile(resp['Data']['FileInfo']['ID']);
      if (attachImage.isNotEmpty) {
        setState(() {
          var decoded = base64Decode(attachImage);
          imageAttach.add(decoded);
        });
      }
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
      print(widget.request);
      setState(() {
        //resp['Data']['Request']['Equipments'].length>0?_equipment = resp['Data']['Request']['Equipments'][0]:null;
        resp['Data']['Request']['RequestType']['ID'] != 14?_equipment = resp['Data']['Request']['Equipments'][0]:_equipment = {};
        _dispatch = resp['Data'];
      });
    }
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

  Future<String> getAttachFile(int fileId) async {
    String _image = '';
    var resp = await HttpRequest.request(
      '/DispatchReport/DownloadUploadfile',
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

  Future<Null> approveReport() async {
    final SharedPreferences prefs = await _prefs;
    var UserId = await prefs.getInt('userID');
    Map<String, dynamic> _data = {
      'userID': UserId,
      'reportID': widget.reportId,
      'solutionResultID': model.SolutionStatus[_currentResult],
      'comments': _comment.text
    };
    Fluttertoast.showToast(
        msg: "正在提交...",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 16.0
    );
    var _response = await HttpRequest.request(
        '/DispatchReport/ApproveDispatchReport',
        method: HttpRequest.POST,
        data: _data
    );
    Fluttertoast.cancel();
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
      Fluttertoast.showToast(
          msg: "正在提交...",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.black54,
          textColor: Colors.white,
          fontSize: 16.0
      );
      var _response = await HttpRequest.request(
          '/DispatchReport/RejectDispatchReport',
          method: HttpRequest.POST,
          data: _data
      );
      Fluttertoast.cancel();
      print(_response);
      if (_response['ResultCode'] == '00') {
        showDialog(
            context: context,
            builder: (context) =>
                AlertDialog(
                  title: new Text('已退回'),
                )
        ).then((result) =>
          Navigator.of(context, rootNavigator: true).pop(result)
        );
      }
    }
  }

  Column buildImageColumn() {
    if (imageAttach == null) {
      return new Column();
    } else {
      List<Widget> _list = [];
      for(var file in imageAttach) {
        _list.add(new Container(
          child: new PhotoView(imageProvider: MemoryImage(file)),
          width: 400.0,
          height: 400.0,
        ));
      }
      return new Column(children: _list);
    }
  }

  List<Widget> buildAccessory() {
    List<Widget> _list = [];
    if (_accessory != null) {
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
    }
    return _list;
  }

  List<ExpansionPanel> buildExpansion() {
    List<ExpansionPanel> _list = [];
    if (_dispatch['Request']['RequestType']['ID'] != 14) {
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
                BuildWidget.buildRow('服务范围', _equipment['ContractScope']['Name']??''),
              ],
            ),
          ),
          isExpanded: _isExpandedBasic,
        ),
      );
    }

    _list.addAll([
      new ExpansionPanel(
        headerBuilder: (context, isExpanded) {
          return ListTile(
            leading: new Icon(Icons.description,
              size: 24.0,
              color: Colors.blue,
            ),
            title: Text('派工内容',
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
            children: <Widget>[
              BuildWidget.buildRow('派工单编号', widget.request['OID']),
              BuildWidget.buildRow('派工单状态', widget.request['Status']['Name']),
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
            title: Text('作业报告信息',
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              BuildWidget.buildRow('作业报告编号', _report['OID']),
              BuildWidget.buildRow('作业报告类型', _report['Type']['Name']),
              BuildWidget.buildRow('发生频率', _report['FaultFrequency']),
              BuildWidget.buildRow('系统状态', _report['FaultSystemStatus']),
              BuildWidget.buildRow('错误代码', _report['FaultCode']),
              BuildWidget.buildRow('故障描述', _report['FaultDesc']),
              BuildWidget.buildRow('分析原因', _report['SolutionCauseAnalysis']),
              BuildWidget.buildRow('处理方法', _report['SolutionWay']),
              BuildWidget.buildRow('备注', _report['SolutionUnsolvedComments']),
              _report['DelayReason']!=''?BuildWidget.buildRow('误工说明', _report['DelayReason']):new Container(),
              widget.status==3?BuildWidget.buildRow('作业结果', _report['SolutionResultStatus']['Name']):BuildWidget.buildDropdown('作业结果', _currentResult, _dropDownMenuItems, changedDropDownMethod),
              BuildWidget.buildRow('附件', ''),
              buildImageColumn(),
              widget.status==3?BuildWidget.buildRow('审批备注', _report['FujiComments']??''):new Container()
            ],
          ),
        ),
        isExpanded: _isExpandedAssign,
      ),
    ]);

    if (_dispatch['Request']['RequestType']['ID'] == 1) {
      _list.add(
        new ExpansionPanel(
          headerBuilder: (context, isExpanded) {
            return ListTile(
              leading: new Icon(Icons.settings,
                size: 24.0,
                color: Colors.blue,
              ),
              title: Text('零配件信息',
                style: new TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.w400
                ),
              ),
            );
          },
          body: _accessory!=null?new Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: new Column(
              children: buildAccessory(),
            ),
          ):new Container(),
          isExpanded: _isExpandedComponent,
        ),
      );
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
          new Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 19.0),
            child: Text(_userName),
          ),
        ],
      ),
      body: _report.isEmpty||_dispatch.isEmpty?new Center(child: SpinKitRotatingPlain(color: Colors.blue,),):new Padding(
        padding: EdgeInsets.symmetric(vertical: 5.0),
        child: new Card(
          child: new ListView(
            children: <Widget>[
              new ExpansionPanelList(
                animationDuration: Duration(milliseconds: 200),
                expansionCallback: (index, isExpanded) {
                  setState(() {
                    if (index == 0) {
                      if (_dispatch['Request']['RequestType']['ID']==14) {
                        _isExpandedDetail = !isExpanded;
                      } else {
                        _isExpandedBasic = !isExpanded;
                      }
                    } else {
                      if (index == 1) {
                        if (_dispatch['Request']['RequestType']['ID']==14) {
                          _isExpandedAssign = !isExpanded;
                        } else {
                          _isExpandedDetail = !isExpanded;
                        }
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
                children: buildExpansion(),
              ),
              SizedBox(height: 24.0),
              widget.status==3?new Container():buildTextField('审批备注', _comment, true),
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
                      borderRadius: BorderRadius.circular(6),
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
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: EdgeInsets.all(12.0),
                    color: new Color(0xffD25565),
                    child: Text('退回报告', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
              SizedBox(height: 24.0),
            ],
          ),
        ),
      ),
    );
  }
}
