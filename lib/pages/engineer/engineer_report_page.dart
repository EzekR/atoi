import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:atoi/utils/http_request.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:atoi/utils/constants.dart';
import 'dart:convert';
import 'package:atoi/pages/engineer/engineer_report_accessory.dart';
import 'package:atoi/widgets/build_widget.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:typed_data';
import 'package:atoi/models/models.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:date_format/date_format.dart';
import 'package:photo_view/photo_view.dart';
import 'package:atoi/utils/event_bus.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'dart:typed_data';
import 'package:uuid/uuid.dart';
import 'package:atoi/pages/equipments/equipments_list.dart';
import 'package:atoi/utils/image_util.dart';

/// 工程师报告页面
class EngineerReportPage extends StatefulWidget {
  static String tag = 'engineer-report-page';
  EngineerReportPage({Key key, this.dispatchId, this.reportId, this.status})
      : super(key: key);
  final int dispatchId;
  final int reportId;
  final int status;

  @override
  _EngineerReportPageState createState() => new _EngineerReportPageState();
}

class _EngineerReportPageState extends State<EngineerReportPage> {
  var _isExpandedBasic = false;
  var _isExpandedDetail = false;
  var _isExpandedAssign = true;
  var _isExpandedComponent = false;
  List<bool> _expandList = [false, false, false, true, false];
  bool _isDelayed = false;
  var _accessory = [];
  ConstantsModel model;
  bool hold = false;
  int _reportId;
  var _report;
  bool _edit = true;
  String _acceptDate = 'YY-MM-DD';
  EventBus bus = new EventBus();
  ScrollController _scrollController = new ScrollController();

  List _serviceResults = [];
  List _sources = [];
  List _providers = [];

  List _reportType = [];
  List _reportList = [];

  List _serviceScope = [
    '是',
    '否'
  ];

  String _currentType;
  String _currentScope = '是';

  void changeType(value) {
    FocusScope.of(context).requestFocus(new FocusNode());
    setState(() {
      _analysis.clear();
      _result.clear();
      _unsolved.clear();
      _comments.clear();
      _description.clear();
      _purchaseAmount.clear();
      _solution.clear();
      _code.clear();
      _currentPrivate = '否';
      _currentRecall = '否';
      _acceptDate = 'YY-MM-DD';
      _currentType = value;
    });
  }

  void changeScope(value) {
    FocusScope.of(context).requestFocus(new FocusNode());
    setState(() {
      _currentScope = value;
    });
  }

  List<DropdownMenuItem<String>> _dropDownMenuItems;
  List<DropdownMenuItem<String>> _dropDownMenuSources;
  List<DropdownMenuItem<String>> _dropDownMenuProviders;
  List<DropdownMenuItem<String>> _dropDownMenuStatus;
  String _currentResult;
  String _currentSource;
  String _currentProvider;
  String _currentStatus;

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
  var _result = new TextEditingController();
  var _purchaseAmount = new TextEditingController();
  var _comments = new TextEditingController();
  //List<dynamic> _imageList = [];
  var _imageList;
  String _attachFile;
  int _attachId;
  var _fujiComments = "";
  String _reportStatus = '新建';
  String _reportOID;

  String _userName = '';
  String _mobile = '';

  List _isPrivate = ['是', '否'];
  String _currentPrivate = '否';

  List _isRecall = ['是', '否'];
  String _currentRecall = '否';

  void changePrivate(value) {
    FocusScope.of(context).requestFocus(new FocusNode());
    setState(() {
      _currentPrivate = value;
    });
  }

  void changeRecall(value) {
    FocusScope.of(context).requestFocus(new FocusNode());
    setState(() {
      _currentRecall = value;
    });
  }
  Future<Null> getRole() async {
    var prefs = await _prefs;
    var userName = prefs.getString('userName');
    var mobile = prefs.getString('mobile');
    setState(() {
      _userName = userName;
      _mobile = mobile;
    });
  }

  Future getImage() async {
    setState(() {
      _attachFile = null;
    });
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
          _imageList = Uint8List.fromList(compressed);
        });
      });
    }
  }

  Future<Null> getImageFile(int fileId) async {
    var resp = await HttpRequest.request('/DispatchReport/DownloadUploadFile',
        method: HttpRequest.GET, params: {'ID': fileId});
    if (resp['ResultCode'] == '00') {
      setState(() {
        _imageList = base64Decode(resp['Data']);
      });
    }
  }

  Future<String> getAccessoryFile(int fileId) async {
    String _image = '';
    var resp = await HttpRequest.request(
        '/DispatchReport/DownloadAccessoryFile',
        method: HttpRequest.GET,
        params: {'ID': fileId});
    if (resp['ResultCode'] == '00') {
      _image = resp['Data'];
    }
    return _image;
  }

  Future<Null> getReport(int reportId) async {
    await getReportId(_dispatch['RequestType']['ID']);
    var prefs = await _prefs;
    var userID = prefs.getInt('userID');
    if (reportId != 0) {
      var resp = await HttpRequest.request('/DispatchReport/GetDispatchReport',
          method: HttpRequest.GET,
          params: {'userID': userID, 'dispatchReportId': reportId});
      print(resp);
      if (resp['ResultCode'] == '00') {
        var data = resp['Data'];
        setState(() {
          _report = data;
          _currentType = data['Type']['Name'];
          _frequency.text = data['FaultFrequency'];
          _code.text = data['FaultCode'];
          _status.text = data['FaultSystemStatus'];
          _description.text = data['FaultDesc'];
          _analysis.text = data['SolutionCauseAnalysis'];
          _solution.text = data['SolutionWay'];
          _currentResult = data['SolutionResultStatus']['Name'] == ''
              ? _currentResult
              : data['SolutionResultStatus']['Name'];
          _delay.text = data['DelayReason'];
          _unsolved.text = data['SolutionUnsolvedComments'];
          _accessory = data['ReportAccessories'];
          _fujiComments = data['FujiComments'];
          _reportStatus = data['Status']['Name'];
          _reportOID = data['OID'];
          if (data['EquipmentStatus']['ID'] != 0) {
            _currentStatus = data['EquipmentStatus']['Name'];
          }
          _purchaseAmount.text = data['PurchaseAmount'].toString();
          _currentScope = data['ServiceScope']?'是':'否';
          _result.text = data['Result'];
          _currentRecall = data['IsRecall']?'是':'否';
          _currentPrivate = data['IsPrivate']?'是':'否';
          if (data['AcceptanceDate'] != null) {
            _acceptDate = data['AcceptanceDate'].toString().split('T')[0];
          }
          _currentType = data['Type']['Name'];
          _comments.text = data['Comments'];
          _currentProvider = data['ServiceProvider']['ID']==0?_currentProvider:data['ServiceProvider']['Name'];
        });
        if (resp['Data']['FileInfo']['ID'] != 0) {
          _attachId = resp['Data']['FileInfo']['ID'];
          if (ImageUtil.isImageFile(resp['Data']['FileInfo']['FileName'])) {
            await getImageFile(resp['Data']['FileInfo']['ID']);
          } else {
            setState(() {
              _attachFile = resp['Data']['FileInfo']['FileName'];
            });
          }
        }
        for (var _acc in _accessory) {
          var _imageNew = _acc['FileInfos']
              .firstWhere((info) => info['FileType'] == 1, orElse: () => null);
          var _imageOld = _acc['FileInfos']
              .firstWhere((info) => info['FileType'] == 2, orElse: () => null);
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
  }

  Future<Null> getDispatch() async {
    var prefs = await _prefs;
    var userID = prefs.getInt('userID');
    var dispatchId = widget.dispatchId;
    var resp = await HttpRequest.request('/Dispatch/GetDispatchByID',
        method: HttpRequest.GET,
        params: {'userID': userID, 'dispatchID': dispatchId});
    print(resp);
    if (resp['ResultCode'] == '00') {
      setState(() {
        _dispatch = resp['Data'];
        _isDelayed = resp['Data']['Request']['IsDelay'];
      });
    }
  }

  Future<Null> getReportId(int reportType) async {
    var resp = await HttpRequest.request(
      '/DispatchReport/GetDispatchReportType',
      params: {
        'id': reportType
      }
    );
    if (resp['ResultCode'] == '00') {
      setState(() {
        _reportList = resp['Data'];
        _reportType = resp['Data'].map((item) => item['Name']).toList();
        _currentType = _reportType[_reportType.length-1];
      });
    }
  }

  List<FocusNode> _focusReport = new List(20).map((item) {
    return new FocusNode();
  }).toList();

  Future<Null> uploadReport(int statusId) async {
    setState(() {
      _expandList = _expandList.map((item) {
        return true;
      }).toList();
    });
    if (_dispatch['RequestType']['ID'] == 9 && _acceptDate == 'YY-MM-DD' && _currentType != '通用作业报告' && statusId == 2) {
      showDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: new Text('验收日期不可为空'),
          )).then((result) => _scrollController.jumpTo(1400.0));
      return;
    }
    if (statusId == 2 && _currentType != '通用作业报告') {
      if (_isDelayed && _delay.text.isEmpty) {
        showDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: new Text('误工说明不可为空'),
            )).then((result) => FocusScope.of(context).requestFocus(_focusReport[0]));
        return;
      }
      if ((_dispatch['RequestType']['ID'] == 3 && _currentPrivate == '是' && _imageList == null) || (_dispatch['RequestType']['ID'] == 2 && _currentResult == '待第三方支持' && _currentProvider != '管理方' && _imageList == null)) {
        showDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: new Text('附件不可为空'),
            )).then((result) => _scrollController.jumpTo(1800.0));
        return;
      }
      if (_dispatch['RequestType']['ID'] == 1 && _code.text.isEmpty) {
        showDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: new Text('错误代码不可为空'),
            )).then((result) => FocusScope.of(context).requestFocus(_focusReport[1]));
        return;
      }
      if (_dispatch['RequestType']['ID'] == 1 && _currentStatus == null) {
        showDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: new Text('设备状态（离场）不可为空'),
            )).then((result) => FocusScope.of(context).requestFocus(_focusReport[11]));
        return;
      }
      if (_dispatch['RequestType']['ID'] == 3 && _description.text.isEmpty) {
        showDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: new Text('强检要求不可为空'),
            )).then((result) => FocusScope.of(context).requestFocus(_focusReport[2]));
        return;
      }
      if (_dispatch['RequestType']['ID'] == 6 && (_purchaseAmount.text.isEmpty || double.tryParse(_purchaseAmount.text) == 0.0 || double.tryParse(_purchaseAmount.text) >= 100000000.0)) {
        showDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: new Text('资产金额需介于0到99999999.99之间'),
            )).then((result) => FocusScope.of(context).requestFocus(_focusReport[3]));
        return;
      }
      if (_dispatch['RequestType']['ID'] == 1 && _solution.text.isEmpty) {
        showDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: new Text('详细处理方法不可为空'),
            )).then((result) => FocusScope.of(context).requestFocus(_focusReport[4]));
        return;
      }
      if (_analysis.text.isEmpty) {
        showDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: new Text(_dispatch['RequestType']['ID']==1?'分析原因不可为空':'报告明细不可为空'),
            )).then((result) => FocusScope.of(context).requestFocus(_focusReport[5]));
        return;
      }
      if (_result.text.isEmpty) {
        showDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: new Text('结果不可为空'),
            )).then((result) => FocusScope.of(context).requestFocus(_focusReport[6]));
        return;
      }
      if (_currentResult == '问题升级' && _unsolved.text.isEmpty) {
        showDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: new Text('问题升级不可为空'),
            )).then((result) => FocusScope.of(context).requestFocus(_focusReport[7]));
        return;
      }
    }
    if (statusId == 2 && _currentType == '通用作业报告') {
      if (_analysis.text.isEmpty) {
        showDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: new Text('报告明细不可为空'),
            )).then((result) => FocusScope.of(context).requestFocus(_focusReport[5]));
        return;
      }
      if (_result.text.isEmpty) {
        showDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: new Text('结果不可为空'),
            )).then((result) => FocusScope.of(context).requestFocus(_focusReport[6]));
        return;
      }
      if (_currentResult == '问题升级' && _unsolved.text.isEmpty) {
        showDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: new Text('问题升级不可为空'),
            )).then((result) => FocusScope.of(context).requestFocus(_focusReport[7]));
        return;
      }
      if (_isDelayed && _delay.text.isEmpty) {
        showDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: new Text('误工说明不可为空'),
            )).then((result) => FocusScope.of(context).requestFocus(_focusReport[0]));
        return;
      }
    }
    Map _json = {};
    if (_attachId != null) {
      _json['ID'] = _attachId;
    } else {
      _json['ID'] = 0;
    }
    if (_imageList != null) {
      var content = base64Encode(_imageList);
      _json = {
        'FileContent': content,
        'FileName': 'dispatch_${widget.dispatchId}_report_attachment.jpg',
        'FileType': 1
      };
    }
    var prefs = await _prefs;
    var userID = prefs.getInt('userID');
    var _data = {
      'Dispatch': {'ID': widget.dispatchId},
      'FaultCode': _code.text,
      'FaultDesc': _description.text,
      'SolutionCauseAnalysis': _analysis.text,
      'SolutionWay': _solution.text,
      'SolutionResultStatus': {
        'ID': model.SolutionStatus[_currentResult],
        'Name': _currentResult
      },
      'EquipmentStatus': {
        'ID': model.MachineStatus[_currentStatus]
      },
      'PurchaseAmount': _purchaseAmount.text,
      //'ServiceScope': _currentScope=='是'?true:false,
      'Result': _result.text,
      'IsRecall': _currentRecall =='是'?true:false,
      'AcceptanceDate': _acceptDate,
      'IsPrivate': _currentPrivate == '是' ?true:false,
      'ServiceProvider': {
        'ID': model.ServiceProviders[_currentProvider]
      },
      'SolutionUnsolvedComments': _unsolved.text,
      'DelayReason': _delay.text,
      'Status': {
        'ID': statusId,
      },
      'Comments': _comments.text,
      'FileInfo': _json,
      'ReportAccessories': _accessory,
      'ID': _reportId
    };
    var _id = _reportList.firstWhere((item) => item['Name'] == _currentType, orElse: () => null);
    _data['Type'] = {
      'ID': _id['ID']??1
    };
    var _body = {
      'userID': userID,
      'DispatchReport': _data
    };
    setState(() {
      hold = true;
    });
    var resp = await HttpRequest.request('/DispatchReport/SaveDispatchReport',
        method: HttpRequest.POST, data: _body);
    setState(() {
      hold = false;
    });
    if (resp['ResultCode'] == '00') {
      setState(() {
        _reportId = resp['Data'];
      });
      showDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
              title: statusId == 1
                  ? new Text('保存报告成功')
                  : new Text('上传报告成功'))).then((result) {
                    return statusId == 1?getReport(resp['Data']):Navigator.of(context, rootNavigator: true).pop(result);
      });
    } else {
      showDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
                title: new Text(resp['ResultMessage']),
              ));
    }
  }

  List iterateMap(Map item) {
    var _list = [];
    item.forEach((key, val) {
      _list.add(key);
    });
    return _list;
  }

  void initDropdown() {
    model = MainModel.of(context);
    _serviceResults = iterateMap(model.SolutionStatus);
    _sources = iterateMap(model.AccessorySourceType);
    _providers = iterateMap(model.ServiceProviders);
    _dropDownMenuItems = getDropDownMenuItems(_serviceResults);
    _dropDownMenuSources = getDropDownMenuItems(_sources);
    _dropDownMenuProviders = getDropDownMenuItems(_providers);
    _dropDownMenuStatus = getDropDownMenuItems(iterateMap(model.MachineStatus));
    _currentStatus = _dropDownMenuStatus[0].value;
    _currentResult = _dropDownMenuItems[3].value;
    _currentSource = _dropDownMenuSources[0].value;
    _currentProvider = _dropDownMenuProviders[0].value;
  }

  void initState() {
    model = MainModel.of(context);
    initDropdown();
    getRole();
    getDispatch().then((result) {
      if (widget.reportId != null) {
        setState(() {
          _reportId = widget.reportId;
        });
        getReport(_reportId);
      }
    });
    if (widget.status != 0 && widget.status != 1) {
      setState(() {
        _edit = false;
      });
    } else {
      _edit = true;
    }
    super.initState();
  }

  List<DropdownMenuItem<String>> getDropDownMenuItems(List list) {
    List<DropdownMenuItem<String>> items = new List();
    for (String method in list) {
      items.add(new DropdownMenuItem(
          value: method,
          child: new Text(
            method,
            style: new TextStyle(fontSize: 16.0),
          )));
    }
    return items;
  }

  Column buildField(String label, TextEditingController controller,
      {String hintText, int maxLength, FocusNode focusNode, bool required}) {
    String hint = hintText ?? '';
    maxLength = maxLength??500;
    required = required??false;
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        new Row(
          children: <Widget>[
            required?new Text(
              '*',
              style: new TextStyle(
                  color: Colors.red
              ),
            ):Container(),
            new Text(
              label,
              style: new TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        new TextField(
          controller: controller,
          decoration: InputDecoration(
            fillColor: AppConstants.AppColors['app_accent_m'],
            filled: true,
            hintText: hint,
          ),
          maxLines: 3,
          maxLength: maxLength,
          focusNode: focusNode,
        ),
        new SizedBox(
          height: 5.0,
        )
      ],
    );
  }

  void changedDropDownMethod(String selectedMethod) {
    FocusScope.of(context).requestFocus(new FocusNode());
    setState(() {
      _currentResult = selectedMethod;
    });
  }

  void changedDropDownSource(String selectedMethod) {
    FocusScope.of(context).requestFocus(new FocusNode());
    setState(() {
      _currentSource = selectedMethod;
    });
  }

  void changedDropDownProvider(String selectedMethod) {
    FocusScope.of(context).requestFocus(new FocusNode());
    setState(() {
      _currentProvider = selectedMethod;
    });
  }

  void changedStatus(String selectedMethod) {
    FocusScope.of(context).requestFocus(new FocusNode());
    setState(() {
      _currentStatus = selectedMethod;
    });
  }

  TextField buildTextField(
      String labelText, String defaultText, bool isEnabled) {
    return new TextField(
      decoration: InputDecoration(
          labelText: labelText,
          labelStyle: new TextStyle(fontSize: 16.0),
          fillColor: AppConstants.AppColors['app_accent_m'],
          filled: true,
          disabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 1))),
      controller: new TextEditingController(text: defaultText),
      enabled: isEnabled,
      style: new TextStyle(fontSize: 16.0),
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
              style: new TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
            ),
          ),
          new Expanded(
            flex: 6,
            child: new Text(
              defaultText,
              style: new TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w400,
                  color: Colors.black54),
            ),
          )
        ],
      ),
    );
  }

  Row buildDropdown(String title, String currentItem, List dropdownItems,
      Function changeDropdown) {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        new Expanded(
          flex: 4,
          child: new Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: new Text(
              title,
              style: new TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
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

  Row buildImageRow() {
    List<Widget> _list = [];
    if (_imageList != null) {
      _list.add(new Stack(
        alignment: FractionalOffset(1.0, 0),
        children: <Widget>[
          new Container(
            width: 200.0,
            child: BuildWidget.buildPhotoPageList(context, _imageList),
          ),
          widget.status == 0 || widget.status == 1
              ? new Padding(
                  padding: EdgeInsets.symmetric(horizontal: 0.0),
                  child: new IconButton(
                      icon: Icon(Icons.cancel),
                      color: Colors.blue,
                      onPressed: () {
                        setState(() {
                          _imageList = null;
                        });
                      }),
                )
              : new Container()
        ],
      ));
      _list.add(new Container(
        width: 10,
      ));
    } else {
      _list.add(new Container());
    }

    if (_attachFile != null) {
      _list.add(
        Container(
          child: Text(
            _attachFile,
            style: TextStyle(
              color: Colors.blue,
              fontSize: 14
            ),
          ),
        )
      );
    }

    return new Row(
        mainAxisAlignment: MainAxisAlignment.center, children: _list);
  }

  List<Widget> buildReportList() {
    List<Widget> _list = [];
    _list.addAll([
      _reportOID != null
          ? BuildWidget.buildRow('作业报告编号', _reportOID)
          : new Container(),
      _edit?BuildWidget.buildRadioVert('作业报告类型', _reportType, _currentType, changeType):BuildWidget.buildRow('作业报告类型', _currentType),
      BuildWidget.buildRow('开始时间', AppConstants.TimeForm(_dispatch['StartDate'].toString(), 'hh:mm')),
      _fujiComments!=""||widget.status==3?BuildWidget.buildRow('审批备注', _fujiComments):new Container(),
      new Divider(),
    ]);

    if (_currentType == '通用作业报告') {
      _list.addAll(
        [
          _edit?buildField('报告明细:', _analysis, focusNode: _focusReport[5], required: true):BuildWidget.buildRow('报告明细', _analysis.text),
          _edit?buildField('结果:', _result, focusNode: _focusReport[6], required: true):BuildWidget.buildRow('结果', _result.text),
        ]
      );
      _list.addAll(
          [
            _edit?BuildWidget.buildDropdownLeft('作业报告结果:', _currentResult, _dropDownMenuItems, changedDropDownMethod, context: context, required: true):BuildWidget.buildRow('作业报告结果', _currentResult),
            !_edit&&_currentResult=='问题升级'?BuildWidget.buildRow('问题升级', _unsolved.text):new Container(),
            _edit&&_currentResult=='问题升级'?buildField('问题升级:', _unsolved, focusNode: _focusReport[7], required: true):new Container(),
            _edit&&_currentResult=='待第三方支持'?BuildWidget.buildDropdownLeft('服务提供方:', _currentProvider, _dropDownMenuProviders, changedDropDownProvider, context: context, required: true):new Container(),
            !_edit&&_currentResult=='待第三方支持'?BuildWidget.buildRow('服务提供方', _currentProvider):new Container(),
            _edit?buildField('备注:', _comments):BuildWidget.buildRow('备注', _comments.text),

          ]
      );
    } else {
      switch (_dispatch['RequestType']['ID']) {
        case 1:
          _list.addAll(
            [
              _edit?buildField('错误代码:', _code, maxLength: 20, focusNode: _focusReport[1], required: true):BuildWidget.buildRow('错误代码', _code.text),
              BuildWidget.buildRow('设备状态（报修）', _dispatch['MachineStatus']['Name']),
              _edit?BuildWidget.buildDropdownLeft('设备状态（离场）:', _currentStatus, _dropDownMenuStatus, changedStatus, focusNode: _focusReport[11], context: context, required: true):BuildWidget.buildRow('设备状态（离场）', _currentStatus??''),
              _edit?buildField('详细故障描述:', _description, focusNode: _focusReport[2], required: false):BuildWidget.buildRow('详细故障描述', _description.text),
              _edit?buildField('分析原因:', _analysis, focusNode: _focusReport[5], required: true):BuildWidget.buildRow('分析原因', _analysis.text),
              _edit?buildField('详细处理方法:', _solution, focusNode: _focusReport[4], required: true):BuildWidget.buildRow('详细处理方法', _solution.text),
              _edit?buildField('结果:', _result, focusNode: _focusReport[6], required: true):BuildWidget.buildRow('结果', _result.text),
            ]
          );
          break;
        case 4:
          _list.addAll(
              [
                _edit?buildField('报告明细:', _analysis, focusNode: _focusReport[5], required: true):BuildWidget.buildRow('报告明细', _analysis.text),
                _edit?buildField('结果:', _result, focusNode: _focusReport[6], required: true):BuildWidget.buildRow('结果', _result.text),
              ]
          );
          break;
        case 3:
          _list.addAll(
            [
              _edit?buildField('强检要求:', _description, hintText: 'FDA, 厂家要求, 政府要求等', focusNode: _focusReport[2], required: true):BuildWidget.buildRow('强检要求', _description.text),
              _edit?buildField('报告明细:', _analysis, focusNode: _focusReport[5], required: true):BuildWidget.buildRow('报告明细', _analysis.text),
              _edit?buildField('结果:', _result, focusNode: _focusReport[6], required: true):BuildWidget.buildRow('结果', _result.text),
              _edit?BuildWidget.buildRadioLeft('专用报告:', _isPrivate, _currentPrivate, changePrivate, required: true):BuildWidget.buildRow('专用报告', _currentPrivate),
              _edit?BuildWidget.buildRadioLeft('待召回:', _isRecall, _currentRecall, changeRecall, required: true):BuildWidget.buildRow('待召回', _currentRecall),
            ]
          );
          break;
        case 2:
          _list.addAll(
            [
              _edit?buildField('报告明细:', _analysis, focusNode: _focusReport[5], required: true):BuildWidget.buildRow('报告明细', _analysis.text),
              _edit?buildField('结果:', _result, focusNode: _focusReport[6], required: true):BuildWidget.buildRow('结果', _result.text),
            ]
          );
          break;
        case 5:
          _list.addAll(
              [
                _edit?buildField('报告明细:', _analysis, focusNode: _focusReport[5], required: true):BuildWidget.buildRow('报告明细', _analysis.text),
                _edit?buildField('结果:', _result, focusNode: _focusReport[6], required: true):BuildWidget.buildRow('结果', _result.text),
              ]
          );
          break;
        case 7:
          _list.addAll(
              [
                _edit?buildField('报告明细:', _analysis, focusNode: _focusReport[5], required: true):BuildWidget.buildRow('报告明细', _analysis.text),
                _edit?buildField('结果:', _result, focusNode: _focusReport[6], required: true):BuildWidget.buildRow('结果', _result.text),
              ]
          );
          break;
        case 9:
          _list.addAll(
              [
                _edit?buildField('报告明细:', _analysis, focusNode: _focusReport[5], required: true):BuildWidget.buildRow('报告明细', _analysis.text),
                _edit?buildField('结果:', _result, focusNode: _focusReport[6], required: true):BuildWidget.buildRow('结果', _result.text),
                _edit?
                new Padding(
                  padding: EdgeInsets.symmetric(vertical: 5.0),
                  child: new Row(
                    children: <Widget>[
                      new Expanded(
                        flex: 4,
                        child: new Wrap(
                          alignment: WrapAlignment.start,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: <Widget>[
                            new Text(
                              '*',
                              style: new TextStyle(
                                  color: Colors.red
                              ),
                            ),
                            new Text(
                              '验收日期:',
                              style: new TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.w600),
                            )
                          ],
                        ),
                      ),
                      new Expanded(
                        flex: 5,
                        child: new Text(
                          _acceptDate,
                          style: new TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w400,
                              color: Colors.black54
                          ),
                        ),
                      ),
                      new Expanded(
                        flex: 2,
                        child: new IconButton(
                            icon: Icon(Icons.calendar_today, color: AppConstants.AppColors['btn_main'],),
                            focusNode: _focusReport[9],
                            onPressed: () async {
                              DatePicker.showDatePicker(
                                context,
                                pickerTheme: DateTimePickerTheme(
                                  showTitle: true,
                                  confirm: Text('确认', style: TextStyle(color: Colors.blueAccent)),
                                  cancel: Text('取消', style: TextStyle(color: Colors.redAccent)),
                                ),
                                minDateTime: DateTime.parse('2000-01-01'),
                                maxDateTime: DateTime.parse('2030-01-01'),
                                initialDateTime: DateTime.tryParse(_acceptDate)??DateTime.now(),
                                dateFormat: 'yyyy-MM-dd',
                                locale: DateTimePickerLocale.en_us,
                                onClose: () => print(""),
                                onCancel: () => print('onCancel'),
                                onChange: (dateTime, List<int> index) {
                                },
                                onConfirm: (dateTime, List<int> index) {
                                  setState(() {
                                    _acceptDate = formatDate(dateTime, [yyyy,'-', mm, '-', dd]);
                                  });
                                },
                              );
                            }),
                      ),
                    ],
                  ),
                ):BuildWidget.buildRow('验收日期', _acceptDate)
              ]
          );
          break;
        case 6:
          _list.addAll(
              [
                _edit?BuildWidget.buildInputLeft('资产金额:', _purchaseAmount, inputType: TextInputType.numberWithOptions(decimal: true), maxLength: 11, lines: 1, focusNode: _focusReport[3], required: true):BuildWidget.buildRow('资产金额', _purchaseAmount.text),
                _edit?buildField('报告明细:', _analysis, focusNode: _focusReport[5], required: true):BuildWidget.buildRow('报告明细', _analysis.text),
                _edit?buildField('结果:', _result, focusNode: _focusReport[6], required: true):BuildWidget.buildRow('结果', _result.text),
              ]
          );
          break;
        default:
          _list.addAll(
              [
                _edit?buildField('报告明细:', _analysis, focusNode: _focusReport[5], required: true):BuildWidget.buildRow('报告明细', _analysis.text),
                _edit?buildField('结果:', _result, focusNode: _focusReport[6], required: true):BuildWidget.buildRow('结果', _result.text),
              ]
          );
          break;
      }

      _list.addAll(
        [
          _edit?BuildWidget.buildDropdownLeft('作业报告结果:', _currentResult, _dropDownMenuItems, changedDropDownMethod, context: context, required: true):BuildWidget.buildRow('作业报告结果', _currentResult),
          _edit&&_currentResult=='问题升级'?buildField('问题升级:', _unsolved, focusNode: _focusReport[7], required: true):new Container(),
          !_edit&&_currentResult=='问题升级'?BuildWidget.buildRow('问题升级', _unsolved.text):new Container(),
          _edit&&_currentResult=='待第三方支持'?BuildWidget.buildDropdownLeft('服务提供方:', _currentProvider, _dropDownMenuProviders, changedDropDownProvider, context: context, required: true):new Container(),
          !_edit&&_currentResult=='待第三方支持'?BuildWidget.buildRow('服务提供方', _currentProvider):new Container(),
          _edit?buildField('备注:', _comments, focusNode: _focusReport[19]):BuildWidget.buildRow('备注', _comments.text),

        ]
      );
    }

    if (_edit && _isDelayed && _dispatch['RequestType']['ID'] == 1 && _dispatch['Request']['LastStatus']['ID'] == 1) {
      _list.add(
          buildField('误工说明:', _delay, focusNode: _focusReport[0], required: true)
      );
    }
    if (!_edit && _isDelayed && _dispatch['RequestType']['ID'] == 1 && _delay.text.isNotEmpty) {
      _list.add(
          BuildWidget.buildRow('误工说明', _delay.text)
      );
    }
    _list.addAll([
          _edit?new Padding(
              padding: EdgeInsets.symmetric(vertical: 5.0),
              child: new Row(
                children: <Widget>[
                  ((_dispatch['RequestType']['ID'] == 3 && _currentPrivate == '是') || (_dispatch['RequestType']['ID'] == 2 && _currentResult == '待第三方支持' && _currentProvider != '管理方'))?new Text('*', style: TextStyle(color: Colors.red),):Container(),
                  new Text(
                    '添加附件：',
                    style: new TextStyle(
                        fontSize: 16.0, fontWeight: FontWeight.w600),
                  ),
                  new IconButton(
                      focusNode: _focusReport[10],
                      icon: Icon(Icons.add_a_photo),
                      onPressed: () {
                        getImage();
                      })
                ],
              ),
            )
          : BuildWidget.buildRow('附件', ''),
      buildImageRow()
    ]);



    return _list;
  }

  List<Widget> buildAccessory() {
    List<Widget> _list = [];

    void saveAccessory(Map accessory) async {
      setState(() {
        _accessory.add(accessory);
      });
    }

    _list.add(new Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        widget.status == 0 || widget.status == 1
            ? new Text('新增零件')
            : new Container(),
        widget.status == 0 || widget.status == 1
            ? new IconButton(
                icon: Icon(Icons.add),
                onPressed: () async {
                  //_addAccessory();
                  final _acc = await Navigator.of(context)
                      .push(new MaterialPageRoute(builder: (_) {
                    return new EngineerReportAccessory();
                  }));
                  print(_acc);
                  if (_acc != null) {
                    saveAccessory(_acc);
                  }
                })
            : new Container()
      ],
    ));
    if (_accessory != null) {
      for (var _acc in _accessory) {
        var _imageNew = _acc['FileInfos']
            .firstWhere((info) => info['FileType'] == 1, orElse: () => null);
        var _imageOld = _acc['FileInfos']
            .firstWhere((info) => info['FileType'] == 2, orElse: () => null);
        if (_imageNew != null) {
          _acc['ImageNew'] = _imageNew;
        }
        if (_imageOld != null) {
          _acc['ImageOld'] = _imageOld;
        }
        var _accList = [
          BuildWidget.buildRow('名称', _acc['Name']),
          BuildWidget.buildRow('来源', _acc['Source']['Name']),
          _acc['Source']['Name'] == '外部供应商'
              ? BuildWidget.buildRow('外部供应商', _acc['Supplier']['Name'])
              : new Container(),
          BuildWidget.buildRow('新装零件编号', _acc['NewSerialCode']),
          BuildWidget.buildRow('附件', ''),
          new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _acc['ImageNew'] != null &&
                      _acc['ImageNew']['FileContent'] != null
                  ? new Container(
                      width: 100.0,
                      child: BuildWidget.buildPhotoPageList(context, base64Decode(_acc['ImageNew']['FileContent'])),
                    )
                  : new Container()
            ],
          ),
          BuildWidget.buildRow('金额（元/件）', _acc['Amount'].toString()),
          BuildWidget.buildRow('数量', _acc['Qty'].toString()),
          BuildWidget.buildRow('拆下零件编号', _acc['OldSerialCode']),
          BuildWidget.buildRow('附件', ''),
          new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _acc['ImageOld'] != null &&
                      _acc['ImageOld']['FileContent'] != null
                  ? new Container(
                      width: 100.0,
                      child: BuildWidget.buildPhotoPageList(context, base64Decode(_acc['ImageOld']['FileContent'])),
                    )
                  : new Container()
            ],
          ),
          widget.status == 3 || widget.status == 2
              ? new Container()
              : new Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    new Text(
                      '删除零件',
                    ),
                    new IconButton(
                        icon: Icon(Icons.delete_forever),
                        onPressed: () {
                          setState(() {
                            _accessory.remove(_acc);
                          });
                        })
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
        new ExpansionPanel(canTapOnHeader: true,
          headerBuilder: (context, isExpanded) {
            return ListTile(
              leading: new Icon(
                Icons.info,
                size: 20.0,
                color: Colors.blue,
              ),
              title: Text(
                '设备基本信息',
                style:
                    new TextStyle(fontSize: 20.0, fontWeight: FontWeight.w400),
              ),
            );
          },
          body: new Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: new Column(
              children: buildEquipments(),
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
            leading: new Icon(
              Icons.description,
              size: 20.0,
              color: Colors.blue,
            ),
            title: Text(
              '派工内容',
              style: new TextStyle(fontSize: 20.0, fontWeight: FontWeight.w400),
            ),
          );
        },
        body: new Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: new Column(
            children: <Widget>[
              BuildWidget.buildRow('派工单编号', _dispatch['OID']),
              BuildWidget.buildRow('派工单状态', _dispatch['Status']['Name']),
              BuildWidget.buildRow('派工类型', _dispatch['RequestType']['Name']),
              _dispatch['RequestType']['ID'] == 14 ? new Container() : BuildWidget.buildRow('机器状态', _dispatch['MachineStatus']['Name']),
              BuildWidget.buildRow('紧急程度', _dispatch['Request']==null?'':_dispatch['Request']['Priority']['Name']??''),
              BuildWidget.buildRow('出发时间', AppConstants.TimeForm(_dispatch['ScheduleDate'], 'hh:mm')),
              BuildWidget.buildRow('工程师姓名', _dispatch['Engineer']['Name']),
              //widget.status==3||widget.status==2?new Container():BuildWidget.buildRow('处理方式', _dispatch['Request']['DealType']['Name']),
              BuildWidget.buildRow('备注', _dispatch['LeaderComments']),
            ],
          ),
        ),
        isExpanded: _expandList[2],
      ),
      new ExpansionPanel(canTapOnHeader: true,
        headerBuilder: (context, isExpanded) {
          return ListTile(
            leading: new Icon(
              Icons.perm_contact_calendar,
              size: 20.0,
              color: Colors.blue,
            ),
            title: Text(
              '作业报告信息',
              style: new TextStyle(fontSize: 20.0, fontWeight: FontWeight.w400),
            ),
          );
        },
        body: new Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: buildReportList(),
          ),
        ),
        isExpanded: _expandList[3],
      ),
    ]);
    if (_dispatch['RequestType']['ID'] != 4 && _dispatch['RequestType']['ID'] != 12 && _dispatch['RequestType']['ID'] != 14) {
      _list.add(
        new ExpansionPanel(canTapOnHeader: true,
          headerBuilder: (context, isExpanded) {
            return ListTile(
              leading: new Icon(
                Icons.settings,
                size: 20.0,
                color: Colors.blue,
              ),
              title: Text(
                '零配件信息',
                style:
                    new TextStyle(fontSize: 20.0, fontWeight: FontWeight.w400),
              ),
            );
          },
          body: new Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: new Column(
              children: buildAccessory(),
            ),
          ),
          isExpanded: _expandList[4],
        ),
      );
    }
    return _list;
  }

  List<Widget> buildEquipments() {
    var _equipments;
    _dispatch['Request'] == null
        ? _equipments = []
        : _equipments = _dispatch['Request']['Equipments'];
    List<Widget> _list = [];
    for (var _equipment in _equipments) {
      var equipList = [
        BuildWidget.buildRow('系统编号', _equipment['OID'] ?? ''),
        BuildWidget.buildRow('资产编号', _equipment['AssetCode']??''),
        BuildWidget.buildRow('名称', _equipment['Name']??'', onTap: () => Navigator.of(context).push(new MaterialPageRoute(builder: (_) => new EquipmentsList(equipmentId: _equipment['OID'],)))),
        BuildWidget.buildRow('型号', _equipment['EquipmentCode'] ?? ''),
        BuildWidget.buildRow('序列号', _equipment['SerialCode'] ?? ''),
        BuildWidget.buildRow('设备厂商', _equipment['Manufacturer']['Name'] ?? ''),
        BuildWidget.buildRow('使用科室', _equipment['Department']['Name'] ?? ''),
        BuildWidget.buildRow('安装地点', _equipment['InstalSite'] ?? ''),
        BuildWidget.buildRow('维保状态', _equipment['WarrantyStatus'] ?? ''),
        BuildWidget.buildRow('服务范围', _equipment['ContractScope']['Name'] ?? ''),
        new Divider()
      ];
      _list.addAll(equipList);
    }
    return _list;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(
            widget.status == 2 || widget.status == 3 ? '查看作业报告' : '提交作业报告'),
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
      body: _dispatch.isEmpty||_reportType.isEmpty
          ? new Center(
              child: new SpinKitThreeBounce(color: Colors.blue),
            )
          : new Padding(
              padding: EdgeInsets.symmetric(vertical: 5.0),
              child: new Card(
                child: new ListView(
                  controller: _scrollController,
                  children: <Widget>[
                    new ExpansionPanelList(
                      animationDuration: Duration(milliseconds: 200),
                      expansionCallback: (index, isExpanded) {
                        setState(() {
                          _dispatch['Request']['RequestType']['ID'] !=14?
                          _expandList[index] = !isExpanded:
                          _expandList[index+1] = !isExpanded;
                        });
                      },
                      children: buildExpansion(),
                    ),
                    SizedBox(height: 20.0),
                    widget.status == 0 || widget.status == 1
                        ? new Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              new RaisedButton(
                                onPressed: () {
                                  FocusScope.of(context).requestFocus(new FocusNode());
                                  return hold?null:uploadReport(2);
                                },
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                padding: EdgeInsets.all(12.0),
                                color: new Color(0xff2E94B9),
                                child: Text('上传报告',
                                    style: TextStyle(color: Colors.white)),
                              ),
                              new RaisedButton(
                                onPressed: () {
                                  FocusScope.of(context).requestFocus(new FocusNode());
                                  return hold?null:uploadReport(1);
                                },
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                padding: EdgeInsets.all(12.0),
                                color: new Color(0xff2E94B9),
                                child: Text('保存报告',
                                    style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          )
                        : new Container()
                  ],
                ),
              ),
            ),
    );
  }
}
