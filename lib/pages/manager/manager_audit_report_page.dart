import 'dart:developer';

import 'package:atoi/utils/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:atoi/utils/http_request.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:atoi/utils/constants.dart';
import 'package:atoi/widgets/build_widget.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:atoi/models/models.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'dart:io';
import 'package:atoi/pages/equipments/equipments_list.dart';
import 'dart:async';
import 'package:atoi/utils/image_util.dart';
import 'package:atoi/widgets/search_page.dart';
import 'package:atoi/permissions.dart';

/// 超管审核报告页面类
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

  List<bool> _expandList =  [false, false, false, true, false, false, false, false];
  List _equipments = [];
  var _comment = new TextEditingController();
  ConstantsModel model;
  var _unsolved = new TextEditingController();
  int _attachId;
  String _attachFile;
  ScrollController _scrollController = new ScrollController();
  GlobalKey scopeKey = new GlobalKey();

  List _serviceResults = [
    '待分配',
    '问题升级',
    '待第三方支持',
    '已解决'
  ];

  List _provider = [];

  List<DropdownMenuItem<String>> _dropDownMenuItems;
  List<DropdownMenuItem<String>> _dropDownMenuProviders;
  String _currentResult;
  String _currentProvider;
  String _currentScope;
  Map<String, dynamic> _report = {};
  Map<String, dynamic> _dispatch = {};

  String _userName = '';
  String _mobile = '';
  var _accessory;
  List reportAccess = [];
  List consumables = [];
  List services = [];
  List<dynamic> imageAttach = [];
  List<TextEditingController> equipmentComments = [];
  List<TextEditingController> equipmentStatus = [];

  List _serviceScope = ['是', '否'];
  Map techPermission;
  Map specialPermission;

  void changeScope(value) {
    FocusScope.of(context).requestFocus(new FocusNode());
    setState(() {
      _currentScope = value;
    });
  }

  Future<Null> getRole() async {
    var _prefs = await prefs;
    var userName = _prefs.getString('userName');
    var mobile = _prefs.getString('mobile');
    setState(() {
      _userName = userName;
      _mobile = mobile;
    });
  }

  void getPermission() async {
    SharedPreferences _prefs = await prefs;
    Permission permissionInstance = new Permission();
    permissionInstance.prefs = _prefs;
    permissionInstance.initPermissions();
    techPermission = permissionInstance.getTechPermissions('Operations', 'DispatchReport');
    specialPermission = permissionInstance.getSpecialPermissions('Operations', 'DispatchReport');
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
    _provider = iterateMap(model.ServiceProviders);
    _dropDownMenuItems = getDropDownMenuItems(_serviceResults);
    _dropDownMenuProviders = getDropDownMenuItems(_provider);
    _currentResult = _dropDownMenuItems[0].value;
    _currentProvider = _dropDownMenuProviders[0].value;
  }

  void initState(){
    getPermission();
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
                fontSize: 16.0
            ),
          )
      ));
    }
    return items;
  }

  void changedDropDownMethod(String selectedMethod) {
    FocusScope.of(context).requestFocus(new FocusNode());
    setState(() {
      _currentResult = selectedMethod;
    });
  }

  void changeProvider(String selectedMethod) {
    FocusScope.of(context).requestFocus(new FocusNode());
    setState(() {
      _currentProvider = selectedMethod;
    });
  }

  String formatTime(String time) {
    var _time = DateTime.tryParse(time);
    if (_time != null) {
      return '${_time.year}-${_time.month}-${_time.day} ${_time.hour}:${_time.minute}';
    } else {
      return 'YY-MM-DD';
    }
  }

  TextField buildTextField(String labelText, TextEditingController controller, bool isEnabled) {
    return new TextField(
      decoration: InputDecoration(
          labelText: labelText,
          labelStyle: new TextStyle(
              fontSize: 16.0
          ),
          disabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                  color: Colors.grey,
                  width: 1
              )
          )
      ),
      maxLines: 3,
      maxLength: 200,
      controller: controller,
      focusNode: _focusReport[3],
      enabled: isEnabled,
      style: new TextStyle(
          fontSize: 16.0
      ),
    );
  }

  Future<SharedPreferences> prefs = SharedPreferences.getInstance();

  Future<Null> getReport() async {
    var _prefs = await prefs;
    var userID = _prefs.getInt('userID');
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
        _unsolved.text = resp['Data']['SolutionUnsolvedComments'];
        _currentProvider = resp['Data']['ServiceProvider']['Name'];
        services = resp['Data']['ReportService'];
        consumables = resp['Data']['ReportConsumable'];
      });
      for(var item in resp['Data']['ReportComponent']) {
        reportAccess.add(jsonEncode(item));
      }
      _accessory = resp['Data']['ReportComponent'];
      for(var _acc in _accessory) {
        var _imageNew = _acc['FileInfos'].firstWhere((info) => info['FileType']==1, orElse: () => null);
        var _imageOld = _acc['FileInfos'].firstWhere((info) => info['FileType']==2, orElse: () => null);
        if (_imageNew != null) {
          var _fileNew = await getAccessoryFile(_imageNew['ID']);
          _imageNew['FileContent'] = base64Decode(_fileNew);
          setState(() {
            _acc['ImageNew'] = _imageNew;
          });
        }
        if (_imageOld != null) {
          var _fileOld = await getAccessoryFile(_imageOld['ID']);
          _imageOld['FileContent'] = base64Decode(_fileOld);
          setState(() {
            _acc['ImageOld'] = _imageOld;
          });
        }
      }
      setState(() {
        _accessory = _accessory;
      });
      if (resp['Data']['FileInfo']['ID'] != 0) {
        _attachId = resp['Data']['FileInfo']['ID'];
        if (ImageUtil.isImageFile(resp['Data']['FileInfo']['FileName'])) {
          var attachImage = await getAttachFile(resp['Data']['FileInfo']['ID']);
          if (attachImage.isNotEmpty) {
            setState(() {
              var decoded = base64Decode(attachImage);
              imageAttach.add(decoded);
            });
          }
        } else {
          setState(() {
            _attachFile = resp['Data']['FileInfo']['FileName'];
          });
        }
      }
    }
  }

  Future<Null> getDispatch() async {
    var _prefs = await prefs;
    var userID = _prefs.getInt('userID');
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
        if (resp['Data']['Request']['Equipments'] != null) {
          setState(() {
            _equipments = resp['Data']['Request']['Equipments'];
          });
        }
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
    setState(() {
      _attachId = fileId;
    });
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

  List<FocusNode> _focusReport = new List(4).map((item) {
    return new FocusNode();
  }).toList();

  Future<bool> saveInventoryEquipments() async {
    List _equipmentStock = [];
    for(int i=0; i<_equipments.length; i++) {
      _equipmentStock.add({
        'equipmentID': _equipments[i]['ID'],
        'stocktakingStatus': equipmentStatus[i].text,
        'stocktakingComments': equipmentComments[i].text,
        'assetType': _dispatch['Request']['AssetType']['ID']
      });
    }
    Map resp = await HttpRequest.request(
        '/Request/SaveStocktakingEquipments',
        method: HttpRequest.POST,
        data: {
          'requestID': _dispatch['Request']['ID'],
          'equipments': _equipments
        }
    );
    if (resp['ResultCode'] == '00') {
      return true;
    } else {
      return false;
    }
  }

  Future<Null> approveReport() async {
    setState(() {
      _expandList = _expandList.map((item) {
        return true;
      }).toList();
    });
    if (_currentResult == '问题升级' && _unsolved.text.isEmpty) {
      showDialog(context: context,
          builder: (context) => CupertinoAlertDialog(
            title: new Text('问题升级不可为空'),
          )
      ).then((result) => FocusScope.of(context).requestFocus(_focusReport[0]));
      return;
    }
    if ((_dispatch['RequestType']['ID'] == 2 && _currentProvider != '管理方' && _currentResult == '待第三方支持' && _report['Type']['ID'] == 201) || (_dispatch['RequestType']['ID'] == 3 && _report['Type']['ID'] != 1 && _report['IsPrivate'])) {
      if (imageAttach.isEmpty) {
        showDialog(context: context,
            builder: (context) => CupertinoAlertDialog(
              title: new Text('附件不可为空'),
            )
        ).then((result) => _scrollController.jumpTo(1400));
        return;
      }
    }
    if (_dispatch['RequestType']['ID'] == 6 && _currentScope == null) {
      showDialog(context: context,
          builder: (context) => CupertinoAlertDialog(
            title: new Text('整包范围不可为空'),
          )
      ).then((result) {
        Scrollable.ensureVisible(scopeKey.currentContext);
      });
      return;
    }
    final SharedPreferences _prefs = await prefs;
    var UserId = await _prefs.getInt('userID');
    var _body = new Map<String, dynamic>.from(_report);
    Map _json = {};
    _json['ID'] = _attachId??0;
    if (imageAttach.isNotEmpty) {
      var content = base64Encode(imageAttach[0]);
      _json = {
        'FileContent': content,
        'FileName': 'report_${_report['ID']}_report_attachment.jpg',
        'FileType': 1
      };
    }
    _body['Request'] = {
      'Equipments': _equipments
    };
    _body['FileInfo'] = _json;
    _body['Dispatch'] = {
      'ID': _dispatch['ID']
    };
    _body['SolutionUnsolvedComments'] = _unsolved.text;
    _body['SolutionResultStatus'] = {
      'ID': model.SolutionStatus[_currentResult]
    };
    _body['ServiceProvider'] = {
      'ID': model.ServiceProviders[_currentProvider]
    };
    _body['FujiComments'] = _comment.text;
    _body['ServiceScope'] = _currentScope=='是'?true:false;
    _body['ReportAccessories'] = reportAccess.map((item) {
      return jsonDecode(item);
    }).toList();
    Map<String, dynamic> _data = {
      'userID': UserId,
      'info': _body
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
      if (_dispatch['RequestType']['ID'] == 12) {
        saveInventoryEquipments();
      }
      showDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: new Text('通过报告'),
          )
      ).then((result) {
        Navigator.of(context).pop(result);
      });
    } else {
      showDialog(context: context,
        builder: (context) => CupertinoAlertDialog(
          title: new Text(_response['ResultMessage']),
        )
      );
    }
  }

  Future<Null> rejectReport() async {
    setState(() {
      _expandList = _expandList.map((item) {
        return true;
      }).toList();
    });
    if (_currentResult == '问题升级' && _unsolved.text.isEmpty) {
      showDialog(context: context,
          builder: (context) => CupertinoAlertDialog(
            title: new Text('问题升级不可为空'),
          )
      ).then((result) => FocusScope.of(context).requestFocus(_focusReport[0]));
      return;
    }
    if (_comment.text.isEmpty) {
      showDialog(context: context,
        builder: (context) => CupertinoAlertDialog(
          title: new Text('审批备注不可为空'),
        )
      ).then((result) {
        _scrollController.jumpTo(3000);
        Timer(const Duration(milliseconds: 500), () {
          FocusScope.of(context).unfocus();
          _focusReport[3].requestFocus();
        });
      });
      return;
    }
    if ((_dispatch['RequestType']['ID'] == 2 && _currentProvider != '管理方' && _report['Type']['ID'] == 201 && _currentResult == '待第三方支持') || (_dispatch['RequestType']['ID'] == 3 && _report['Type']['ID'] != 1 && _report['IsPrivate'])) {
      if (imageAttach.isEmpty) {
        showDialog(context: context,
            builder: (context) => CupertinoAlertDialog(
              title: new Text('附件不可为空'),
            )
        ).then((result) => _scrollController.jumpTo(1400));
        return;
      }
    }
    if (_dispatch['RequestType']['ID'] == 6 && _currentScope == null) {
      showDialog(context: context,
          builder: (context) => CupertinoAlertDialog(
            title: new Text('整包范围不可为空'),
          )
      ).then((result) {
        Scrollable.ensureVisible(scopeKey.currentContext);
      });
      return;
    }
    final SharedPreferences _prefs = await prefs;
    var UserId = await _prefs.getInt('userID');
    var _body = _report;
    Map _json = {};
    _json['ID'] = _attachId??0;
    if (imageAttach.isNotEmpty) {
      var content = base64Encode(imageAttach[0]);
      _json = {
        'FileContent': content,
        'FileName': 'report_${_report['ID']}_report_attachment.jpg',
        'FileType': 1
      };
    }
    _body['FileInfo'] = _json;
    //_body['Dispatch'] = {
    //  'ID': _dispatch['ID']
    //};
    _body['Dispatch']['ID'] = _dispatch['ID'];
    _body['SolutionUnsolvedComments'] = _unsolved.text;
    _body['SolutionResultStatus'] = {
      'ID': model.SolutionStatus[_currentResult]
    };
    _body['ServiceProvider'] = {
      'ID': _currentResult!='待第三方支持'?0:model.ServiceProviders[_currentProvider]
    };
    _body['FujiComments'] = _comment.text;
    _body['ReportAccessories'] = reportAccess.map((item) {
      return jsonDecode(item);
    }).toList();
    Map<String, dynamic> _data = {
      'userID': UserId,
      'info': _body
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
              CupertinoAlertDialog(
                title: new Text('已退回'),
              )
      ).then((result) =>
          Navigator.of(context, rootNavigator: true).pop(result)
      );
    } else {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text(_response['ResultMessage']),
      ));
    }
  }

  Future getImage() async {
    List<Asset> image = await MultiImagePicker.pickImages(
        maxImages: 1,
        enableCamera: true
    );
    if (image != null) {
      image.forEach((_image) async {
        var _data = await _image.getByteData();
        var compressed = await FlutterImageCompress.compressWithList(
          _data.buffer.asUint8List(),
          minHeight: 800,
          minWidth: 600,
        );
        setState(() {
          _attachFile = null;
          imageAttach.clear();
          imageAttach.add(Uint8List.fromList(compressed));
        });
      });
    }
  }

  Column buildImageColumn() {
    if (_attachFile != null) {
      return new Column(
        children: <Widget>[
          Stack(
            alignment: FractionalOffset(0.7, 0.7),
            children: <Widget>[
              Center(
                child: Text(
                  _attachFile,
                  style: TextStyle(
                      color: Colors.blue,
                      fontSize: 14
                  ),
                ),
              ),
              widget.status!=3?new IconButton(icon: Icon(Icons.cancel, color: Colors.blue,), onPressed: () {
                setState(() {
                  _attachFile = null;
                });
              }):new Container(),
            ],
          )
        ],
      );
    }
    if (imageAttach == null) {
      return new Column();
    } else {
      List<Widget> _list = [];
      for(var file in imageAttach) {
        _list.add(new Stack(
          alignment: FractionalOffset(1.0, 0.0),
          children: <Widget>[
            new Container(
              child: BuildWidget.buildPhotoPageList(context, file),
              width: 400.0,
              height: 400.0,
            ),
            widget.status!=3?new IconButton(icon: Icon(Icons.cancel, color: Colors.blue,), onPressed: () {
              setState(() {
                imageAttach.clear();
              });
            }):new Container(),
          ],
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
          BuildWidget.buildRow('简称', _acc['Component']['Name']),
          BuildWidget.buildRow('新装零件编号', _acc['NewInvComponent']['SerialCode']),
          BuildWidget.buildRow('金额（元/件）', CommonUtil.CurrencyForm(_acc['NewInvComponent']['Price'], digits: 0, times: 1)),
          BuildWidget.buildRow('附件', ''),
          new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _acc['ImageNew']!=null&&_acc['ImageNew']['FileContent']!=null?new Container(width: 100.0,
                child: BuildWidget.buildPhotoPageList(context, _acc['ImageNew']['FileContent'])):new Container()
            ],
          ),
          BuildWidget.buildRow('拆下零件编号', _acc['OldInvComponent']['SerialCode']),
          BuildWidget.buildRow('金额（元/件）', CommonUtil.CurrencyForm(_acc['OldInvComponent']['Price'], digits: 0, times: 1)),
          BuildWidget.buildRow('附件', ''),
          new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _acc['ImageOld']!=null&&_acc['ImageOld']['FileContent']!=null?new Container(width: 100.0,
                child: BuildWidget.buildPhotoPageList(context, _acc['ImageOld']['FileContent'])):new Container()
            ],
          ),
          new Divider()
        ];
        _list.addAll(_accList);
      }
    }
    return _list;
  }

  List<Widget> buildConsumable() {
    List<Widget> _list = [];
    if (consumables != null) {
      for (var item in consumables) {
        var consumableList = [
          BuildWidget.buildRow('简称', item['InvConsumable']['Consumable']['Name']),
          BuildWidget.buildRow('批次号', item['InvConsumable']['LotNum']),
          BuildWidget.buildRow('供应商', item['InvConsumable']['Supplier']['Name']),
          BuildWidget.buildRow('单价', item['InvConsumable']['Price'].toString()),
          BuildWidget.buildRow('数量', item['Qty'].toString()),
          new Divider()
        ];
        _list.addAll(consumableList);
      }
    }
    return _list;
  }

  List<Widget> buildService() {
    List<Widget> _list = [];
    if (services != null) {
      log("service:$services");
      for (var item in services) {
        var serviceList = [
          BuildWidget.buildRow('维修服务系统编号', item['Service']['OID']),
          BuildWidget.buildRow('服务名称', item['Service']['Name']),
          BuildWidget.buildRow('供应商', item['Service']['Supplier']['Name']),
          BuildWidget.buildRow('金额(元)', CommonUtil.CurrencyForm(item['Service']['Price'], digits: 0, times: 1)),
          new Divider()
        ];
        _list.addAll(serviceList);
      }
    }
    return _list;
  }

  List<Widget> buildReportContent() {
    List<Widget> _list = [];
    _list.addAll([
      BuildWidget.buildRow('作业报告编号', _report['OID']),
      BuildWidget.buildRow('作业报告类型', _report['Type']['Name']),
      BuildWidget.buildRow('开始时间', AppConstants.TimeForm(_report['Dispatch']['StartDate'].toString(), 'hh:mm')),
      widget.status==3?BuildWidget.buildRow('审批备注', _report['FujiComments']):new Container(),
      new Divider(),
    ]);
    switch (_report['Type']['ID']) {
      case 1:
        _list.addAll([
          BuildWidget.buildRow('报告明细', _report['SolutionCauseAnalysis']),
          BuildWidget.buildRow('结果', _report['Result']),
        ]);
        break;
      case 101:
        _list.addAll([
          BuildWidget.buildRow('错误代码', _report['FaultCode']),
          BuildWidget.buildRow('设备状态(报修)', _report['Dispatch']['MachineStatus']['Name']),
          BuildWidget.buildRow('设备状态(离场)', _report['EquipmentStatus']['Name']),
          BuildWidget.buildRow('详细故障描述', _report['FaultDesc']),
          BuildWidget.buildRow('分析原因', _report['SolutionCauseAnalysis']),
          BuildWidget.buildRow('详细处理方法', _report['SolutionWay']),
          BuildWidget.buildRow('结果', _report['Result']),
        ]);
        break;
      case 201:
        _list.addAll([
          BuildWidget.buildRow('报告明细', _report['SolutionCauseAnalysis']),
          BuildWidget.buildRow('结果', _report['Result']),
        ]);
        break;
      case 301:
        _list.addAll([
          BuildWidget.buildRow('强检要求', _report['FaultDesc']),
          BuildWidget.buildRow('报告明细', _report['SolutionCauseAnalysis']),
          BuildWidget.buildRow('结果', _report['Result']),
          BuildWidget.buildRow('专用报告', _report['IsPrivate']?'是':'否'),
          BuildWidget.buildRow('待召回', _report['IsRecall']?'是':'否'),
        ]);
        break;
      case 401:
        _list.addAll([
          BuildWidget.buildRow('报告明细', _report['SolutionCauseAnalysis']),
          BuildWidget.buildRow('结果', _report['Result']),
        ]);
        break;
      case 501:
        _list.addAll([
          BuildWidget.buildRow('报告明细', _report['SolutionCauseAnalysis']),
          BuildWidget.buildRow('结果', _report['Result']),
        ]);
        break;
      case 601:
        _list.addAll([
          BuildWidget.buildRow('资产金额', CommonUtil.CurrencyForm(_report['PurchaseAmount'], times: 1, digits: 0)),
          //BuildWidget.buildRow('整包范围', _report['ServiceScope']?'是':'否'),
          Container(
            key: scopeKey,
            child: widget.status!=3?BuildWidget.buildRadio('整包范围', _serviceScope, _currentScope, changeScope, required: true):BuildWidget.buildRow('整包范围', _report['ServiceScope']?'是':'否'),
          ),
          BuildWidget.buildRow('报告明细', _report['SolutionCauseAnalysis']),
          BuildWidget.buildRow('结果', _report['Result']),
        ]);
        break;
      case 701:
        _list.addAll([
          BuildWidget.buildRow('报告明细', _report['SolutionCauseAnalysis']),
          BuildWidget.buildRow('结果', _report['Result']),
        ]);
        break;
      case 901:
        _list.addAll([
          BuildWidget.buildRow('报告明细', _report['SolutionCauseAnalysis']),
          BuildWidget.buildRow('结果', _report['Result']),
          BuildWidget.buildRow('验收日期', _report['AcceptanceDate'].toString().split('T')[0]),
        ]);
        break;
      default:
        _list.addAll([
          BuildWidget.buildRow('报告明细', _report['SolutionCauseAnalysis']),
          BuildWidget.buildRow('结果', _report['Result']),
        ]);
        break;
    }
    _list.addAll([
      widget.status==3?BuildWidget.buildRow('作业报告结果', _currentResult):BuildWidget.buildDropdown('作业报告结果', _currentResult, _dropDownMenuItems, changedDropDownMethod),
      widget.status!=3&&_currentResult=='问题升级'?BuildWidget.buildInput('问题升级', _unsolved, maxLength: 500, focusNode: _focusReport[0], required: true):new Container(),
      widget.status==3&&_currentResult=='问题升级'?BuildWidget.buildRow('问题升级', _unsolved.text):new Container(),
      widget.status!=3&&_currentResult=='待第三方支持'?BuildWidget.buildDropdown('服务提供方', _currentProvider, _dropDownMenuProviders, changeProvider):new Container(),
      widget.status==3&&_currentResult=='待第三方支持'?BuildWidget.buildRow('服务提供方', _currentProvider):new Container(),
      BuildWidget.buildRow('备注', _report['Comments']),
      _report['DelayReason']!=''?BuildWidget.buildRow('误工说明', _report['DelayReason']):new Container(),
      new Padding(
        padding: EdgeInsets.symmetric(vertical: 5.0),
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            new Expanded(
              flex: 4,
              child: new Wrap(
                alignment: WrapAlignment.end,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  ((_dispatch['RequestType']['ID'] == 2 && _currentProvider != '管理方' && _report['Type']['ID'] == 201 && _currentResult == '待第三方支持') || (_dispatch['RequestType']['ID'] == 3 && _report['Type']['ID'] != 1 && _report['IsPrivate']))?new Text(
                    '*',
                    style: new TextStyle(
                        color: Colors.red
                    ),
                  ):Container(),
                  new Text(
                    '附件',
                    style: new TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600
                    ),
                  )
                ],
              ),
            ),
            new Expanded(
              flex: 1,
              child: new Text(
                '：',
                style: new TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            new Expanded(
              flex: 6,
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  widget.status!=3?IconButton(icon: Icon(Icons.add_a_photo), onPressed: () {
                    getImage();
                  }):new Container()
                ],
              )
            )
          ],
        ),
      ),
      buildImageColumn(),
    ]);
    return _list;
  }

  List<Widget> buildEquipments() {
    List<Widget> _list = [];
    equipmentComments = _equipments.map<TextEditingController>((item) => new TextEditingController(text: item['StocktakingComments'])).toList();
    equipmentStatus = _equipments.map<TextEditingController>((item) => new TextEditingController(text: item['StocktakingStatus'])).toList();
    for(int i=0; i<_equipments.length; i++) {
      _list.addAll([
        BuildWidget.buildRow('系统编号', _equipments[i]['OID']??''),
        BuildWidget.buildRow('资产编号', _equipments[i]['AssetCode']??''),
        BuildWidget.buildRow('名称', _equipments[i]['Name']??'', onTap: () => Navigator.of(context).push(new MaterialPageRoute(builder: (_) => new EquipmentsList(equipmentId: _equipments[i]['OID'], assetType: _equipments[i]['AssetType']['ID'],)))),
        BuildWidget.buildRow('型号', _equipments[i]['EquipmentCode']??''),
        BuildWidget.buildRow('序列号', _equipments[i]['SerialCode']??''),
        BuildWidget.buildRow('设备厂商', _equipments[i]['Manufacturer']['Name']??''),
        BuildWidget.buildRow('使用科室', _equipments[i]['Department']['Name']??''),
        BuildWidget.buildRow('安装地点', _equipments[i]['InstalSite']??''),
        BuildWidget.buildRow('维保状态', _equipments[i]['WarrantyStatus']??''),
        BuildWidget.buildRow('服务范围', _equipments[i]['ContractScope']['Name']??''),
        new Divider(),
      ]);
      if (_dispatch['Request']['RequestType']['ID'] == 12) {
        _list.addAll([
          BuildWidget.buildInput('盘点状态', equipmentStatus[i], lines: 1),
          BuildWidget.buildInput('备注', equipmentComments[i], lines: 1),
        ]);
      }
    }
    return _list;
  }

  List<ExpansionPanel> buildExpansion() {
    List<ExpansionPanel> _list = [];
    if (_dispatch['Request']['RequestType']['ID'] != 14) {
      _list.add(
        new ExpansionPanel(canTapOnHeader: true,
          headerBuilder: (context, isExpanded) {
            return ListTile(
              leading: new Icon(Icons.info,
                size: 20.0,
                color: Colors.blue,
              ),
              title: Text('设备基本信息',
                style: new TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w400
                ),
              ),
              trailing: IconButton(
                onPressed: () async {
                  print(widget.status);
                  if (widget.status >= 3 || _dispatch['Request']['RequestType']['ID']!=12) {
                    return;
                  }
                  final selected = await Navigator.of(context)
                      .push(new MaterialPageRoute(builder: (context) {
                    return SearchPage(equipments: _equipments, multiType: MultiSearchType.EQUIPMENT,);
                  }));
                  if (selected != null) {
                    setState(() {
                      _equipments = selected??[];
                    });
                  }
                },
                icon: Icon(Icons.add),
              ),
            );
          },
          body: new Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: new Column(
              children: buildEquipments()
            ),
          ),
          isExpanded: _expandList[0],
        ),
      );
    }

    _list.add(
      new ExpansionPanel(canTapOnHeader: true,
        headerBuilder: (context, isExpanded) {
          return ListTile(
            leading: new Icon(
              Icons.description,
              size: 20.0,
              color: Colors.blue,
            ),
            title: Text(
              '请求详细信息',
              style: new TextStyle(fontSize: 20.0, fontWeight: FontWeight.w400),
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
              BuildWidget.buildRow('服务申请编号', _dispatch['Request']['OID']),
              BuildWidget.buildRow('类型', _dispatch['Request']['SourceType']),
              BuildWidget.buildRow('主题', _dispatch['Request']['SubjectName']),
              BuildWidget.buildRow('请求人', _dispatch['Request']['RequestUser']['Name']),
              BuildWidget.buildRow('请求状态', _dispatch['Request']['Status']['Name']),
              BuildWidget.buildRow('请求来源', _dispatch['Request']['Source']['Name']),
              _dispatch['Request']['RequestType']['ID'] == 1?BuildWidget.buildRow('机器状态', _dispatch['Request']['MachineStatus']['Name']):new Container(),
              BuildWidget.buildRow(model.Remark[_dispatch['Request']['RequestType']['ID']], _dispatch['Request']['FaultDesc']),
              _dispatch['Request']['RequestType']['ID'] == 2 ||
                  _dispatch['Request']['RequestType']['ID'] == 3 ||
                  _dispatch['Request']['RequestType']['ID'] == 7
                  ? BuildWidget.buildRow(
                  model.RemarkType[_dispatch['Request']['RequestType']['ID']],
                  _dispatch['Request']['FaultType']['Name'])
                  : new Container(),
              _dispatch['Request']['Status']['ID'] == 1
                  ? new Container()
                  : BuildWidget.buildRow('处理方式', _dispatch['Request']['DealType']['Name']),
            ],
          ),
        ),
        isExpanded: _expandList[1],
      ),
    );

    _list.addAll([
      new ExpansionPanel(canTapOnHeader: true,
        headerBuilder: (context, isExpanded) {
          return ListTile(
            leading: new Icon(Icons.description,
              size: 20.0,
              color: Colors.blue,
            ),
            title: Text('派工内容',
              style: new TextStyle(
                  fontSize: 20.0,
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
              BuildWidget.buildRow('派工类型', widget.request['RequestType']['Name']),
              _dispatch['RequestType']['ID'] != 14?BuildWidget.buildRow('机器状态', widget.request['MachineStatus']['Name']):new Container(),
              BuildWidget.buildRow('紧急程度', widget.request['Urgency']['Name']),
              BuildWidget.buildRow('出发时间', AppConstants.TimeForm(_dispatch['ScheduleDate'].toString(), 'hh:mm')),
              BuildWidget.buildRow('工程师姓名', _dispatch['Engineer']['Name']),
              BuildWidget.buildRow('备注', _dispatch['LeaderComments']),
            ],
          ),
        ),
        isExpanded: _expandList[2],
      ),
      new ExpansionPanel(canTapOnHeader: true,
        headerBuilder: (context, isExpanded) {
          return ListTile(
            leading: new Icon(Icons.perm_contact_calendar,
              size: 20.0,
              color: Colors.blue,
            ),
            title: Text('作业报告信息',
              style: new TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w400
              ),
            ),
          );
        },
        body: new Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: buildReportContent()
          ),
        ),
        isExpanded: _expandList[3],
      ),
    ]);

    if (_dispatch['Request']['RequestType']['ID'] != 14 && _dispatch['Request']['RequestType']['ID'] != 12 && _dispatch['Request']['RequestType']['ID'] != 4) {
      _list.addAll([
        new ExpansionPanel(canTapOnHeader: true,
          headerBuilder: (context, isExpanded) {
            return ListTile(
              leading: new Icon(Icons.settings,
                size: 20.0,
                color: Colors.blue,
              ),
              title: Text('零配件信息',
                style: new TextStyle(
                    fontSize: 20.0,
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
          isExpanded: _expandList[4],
        ),
        new ExpansionPanel(canTapOnHeader: true,
          headerBuilder: (context, isExpanded) {
            return ListTile(
              leading: new Icon(Icons.battery_charging_full,
                size: 20.0,
                color: Colors.blue,
              ),
              title: Text('耗材信息',
                style: new TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w400
                ),
              ),
            );
          },
          body: consumables!=null?new Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: new Column(
              children: buildConsumable(),
            ),
          ):new Container(),
          isExpanded: _expandList[5],
        ),
        new ExpansionPanel(canTapOnHeader: true,
          headerBuilder: (context, isExpanded) {
            return ListTile(
              leading: new Icon(Icons.assignment_ind,
                size: 20.0,
                color: Colors.blue,
              ),
              title: Text('服务信息',
                style: new TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w400
                ),
              ),
            );
          },
          body: services!=null?new Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: new Column(
              children: buildService(),
            ),
          ):new Container(),
          isExpanded: _expandList[6],
        ),
      ]);
    }
    return _list;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(
            widget.status==3?'查看作业报告':'审核作业报告'
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
        ],
      ),
      body: _report.isEmpty||_dispatch.isEmpty?new Center(child: SpinKitThreeBounce(color: Colors.blue,),):new Padding(
        padding: EdgeInsets.symmetric(vertical: 5.0),
        child: new Card(
          child: new ListView(
            controller: _scrollController,
            children: <Widget>[
              new ExpansionPanelList(
                animationDuration: Duration(milliseconds: 200),
                expansionCallback: (index, isExpanded) {
                  setState(() {
                    _dispatch['Request']['RequestType']['ID'] != 14?
                    _expandList[index] = !isExpanded:
                        _expandList[index+1] = !isExpanded;
                  });
                },
                children: buildExpansion(),
              ),
              SizedBox(height: 20.0),
              widget.status==3?new Container():Container(
                child: buildTextField('审批备注', _comment, true),
              ),
              SizedBox(height: 20.0),
              widget.status==3?new Container():new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  new RaisedButton(
                    onPressed: () {
                      if (!specialPermission['Approve']) {
                        showDialog(context: context,
                            builder: (context) => CupertinoAlertDialog(
                              title: new Text('暂无审批权限'),
                            )
                        );
                        return;
                      }
                      FocusScope.of(context).requestFocus(new FocusNode());
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
                      if (!specialPermission['Approve']) {
                        showDialog(context: context,
                            builder: (context) => CupertinoAlertDialog(
                              title: new Text('暂无审批权限'),
                            )
                        );
                        return;
                      }
                      FocusScope.of(context).requestFocus(new FocusNode());
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
              SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }
}
