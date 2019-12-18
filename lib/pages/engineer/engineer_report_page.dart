import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:atoi/utils/http_request.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:atoi/utils/constants.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:atoi/pages/engineer/engineer_report_accessory.dart';
import 'package:atoi/widgets/build_widget.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:typed_data';
import 'package:atoi/models/models.dart';
import 'package:flutter/cupertino.dart';

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
  bool _isDelayed = false;
  var _accessory = [];
  ConstantsModel model;
  bool hold = false;
  int _reportId;
  var _report;
  bool _edit = true;
  String _acceptDate = 'YY-MM-DD';

  List _serviceResults = [];
  List _sources = [];
  List _providers = [];

  List _reportType = [
    '是',
    '否'
  ];

  List _serviceScope = [
    '是',
    '否'
  ];

  String _currentType = '是';
  String _currentScope = '是';

  void changeType(value) {
    setState(() {
      _currentType = value;
    });
  }

  void changeScope(value) {
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
  //List<dynamic> _imageList = [];
  var _imageList;
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
    setState(() {
      _currentPrivate = value;
    });
  }

  void changeRecall(value) {
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

  void showSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return new ListView(
            shrinkWrap: true,
            children: <Widget>[
              ListTile(
                trailing: new Icon(Icons.collections),
                title: new Text('从相册添加'),
                onTap: () {
                  getImage(ImageSource.gallery);
                },
              ),
              ListTile(
                trailing: new Icon(Icons.add_a_photo),
                title: new Text('拍照添加'),
                onTap: () {
                  getImage(ImageSource.camera);
                },
              ),
            ],
          );
        });
  }

  Future getImage(ImageSource sourceType) async {
    var image = await ImagePicker.pickImage(
      source: sourceType,
    );
    if (image != null) {
      var bytes = await image.readAsBytes();
      var _compressed = await FlutterImageCompress.compressWithList(bytes,
          minWidth: 480, minHeight: 600);
      setState(() {
        _imageList = _compressed;
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
    var prefs = await _prefs;
    var userID = prefs.getInt('userID');
    var reportId = widget.reportId;
    var resp = await HttpRequest.request('/DispatchReport/GetDispatchReport',
        method: HttpRequest.GET,
        params: {'userID': userID, 'dispatchReportId': reportId});
    print(resp);
    if (resp['ResultCode'] == '00') {
      var data = resp['Data'];
      setState(() {
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
        _acceptDate = data['AcceptanceDate'];
        _currentType = data['Type']['ID']==1?'是':'否';
      });
      await getImageFile(resp['Data']['FileInfo']['ID']);
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
      });
      var _createTime = DateTime.parse(resp['Data']['CreateDate']);
      var _startTime = DateTime.parse(resp['Data']['StartDate']);
      var _duration = _startTime.difference(_createTime).inMinutes;
      if (_duration >
          resp['Data']['Request']['Equipments'][0]['ResponseTimeLength']) {
        setState(() {
          _isDelayed = true;
        });
      }
    }
  }

  Future<Null> uploadReport(int statusId) async {
    //if (_isDelayed && _delay.text.isEmpty) {
    //  showDialog(
    //      context: context,
    //      builder: (context) => CupertinoAlertDialog(
    //            title: new Text('误工说明不可为空'),
    //          ));
    //  return;
    //}
    if ((_dispatch['RequestType']['ID'] == 3 && _currentPrivate == '是' && _imageList == null) || (_dispatch['RequestType']['ID'] == 2 && _currentProvider != '管理方' && _imageList == null)) {
      showDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
                title: new Text('附件不可为空'),
              ));
      return;
    }
    Map _json;
    if (_imageList != null) {
      var content = base64Encode(_imageList);
      _json = {
        'FileContent': content,
        'FileName': 'dispatch_${widget.dispatchId}_report_attachment.jpg',
        'ID': 0,
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
      'ServiceScope': _currentScope=='是'?true:false,
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
      'FileInfo': _json,
      'ReportAccessories': _accessory,
      'ID': widget.reportId
    };
    switch (_dispatch['RequestType']['ID']) {
      case 1:
        _data['Type'] = {'ID': 101};
        break;
      case 2:
        _data['Type'] = {
          'ID': 201
        };
        break;
      case 3:
        _data['Type'] = {'ID': 301};
        break;
      case 4:
        _data['Type'] = {'ID': 401};
        break;
      case 5:
        _data['Type'] = {'ID': 501};
        break;
      case 6:
        _data['Type'] = {'ID': 601};
        break;
      case 7:
        _data['Type'] = {'ID': 701};
        break;
      case 9:
        _data['Type'] = {'ID': 901};
        break;
      default:
        _data['Type'] = {'ID': 1};
        break;
    }
    if (_currentType == '是') {
      _data['Type'] = {
        'ID': 1
      };
    }
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
            return statusId==1?getReport(resp['Data']):Navigator.of(context, rootNavigator: true).pop(result);
          });
    } else {
      showDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
                title: new Text(resp['ResultMessage']),
              ));
    }
  }

  Future<String> pickDate({String initialTime}) async {
    DateTime _time;
    _time = DateTime.tryParse(initialTime)??DateTime.now();
    var val = await showDatePicker(
        context: context,
        initialDate: _time,
        firstDate:
        new DateTime.now().subtract(new Duration(days: 3650)), // 减 30 天
        lastDate: new DateTime.now().add(new Duration(days: 3650)), // 加 30 天
        locale: Locale('zh'));
    return val==null?initialTime:val.toString().split(' ')[0];
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
    _currentResult = _dropDownMenuItems[3].value;
    _currentSource = _dropDownMenuSources[0].value;
    _currentProvider = _dropDownMenuProviders[0].value;
  }

  void initState() {
    model = MainModel.of(context);
    initDropdown();
    getDispatch();
    getRole();
    if (widget.reportId != null) {
      setState(() {
        _reportId = widget.reportId;
      });
      getReport(_reportId);
    }
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
            style: new TextStyle(fontSize: 20.0),
          )));
    }
    return items;
  }

  Column buildField(String label, TextEditingController controller,
      {String hintText, int maxLength}) {
    String hint = hintText ?? '';
    maxLength = maxLength??500;
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        new Text(
          label,
          style: new TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600),
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
        ),
        new SizedBox(
          height: 5.0,
        )
      ],
    );
  }

  void changedDropDownMethod(String selectedMethod) {
    setState(() {
      _currentResult = selectedMethod;
    });
  }

  void changedDropDownSource(String selectedMethod) {
    setState(() {
      _currentSource = selectedMethod;
    });
  }

  void changedDropDownProvider(String selectedMethod) {
    setState(() {
      _currentProvider = selectedMethod;
    });
  }

  void changedStatus(String selectedMethod) {
    setState(() {
      _currentStatus = selectedMethod;
    });
  }

  TextField buildTextField(
      String labelText, String defaultText, bool isEnabled) {
    return new TextField(
      decoration: InputDecoration(
          labelText: labelText,
          labelStyle: new TextStyle(fontSize: 20.0),
          fillColor: AppConstants.AppColors['app_accent_m'],
          filled: true,
          disabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 1))),
      controller: new TextEditingController(text: defaultText),
      enabled: isEnabled,
      style: new TextStyle(fontSize: 20.0),
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
              style: new TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600),
            ),
          ),
          new Expanded(
            flex: 6,
            child: new Text(
              defaultText,
              style: new TextStyle(
                  fontSize: 20.0,
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
              style: new TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600),
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
            width: 100.0,
            child: Image.memory(Uint8List.fromList(_imageList)),
          ),
          widget.status == 0 || widget.status == 1
              ? new Padding(
                  padding: EdgeInsets.symmetric(horizontal: 0.0),
                  child: new IconButton(
                      icon: Icon(Icons.cancel),
                      color: Colors.white,
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

    return new Row(
        mainAxisAlignment: MainAxisAlignment.center, children: _list);
  }

  List<Widget> buildReportList() {
    List<Widget> _list = [];
    var _date = DateTime.parse(_dispatch['StartDate']);
    var _formatDate =
        '${_date.year}-${_date.month}-${_date.day} ${_date.hour}:${_date.minute}';
    _list.addAll([
      _reportOID != null
          ? BuildWidget.buildRow('报告编号', _reportOID)
          : new Container(),
      BuildWidget.buildRow('开始时间', _formatDate),
      _fujiComments.isNotEmpty
          ? BuildWidget.buildRow('审批结果', _fujiComments)
          : new Container(),
      BuildWidget.buildRadio('是否通用报告', _reportType, _currentType, changeType),
      new Divider(),
    ]);

    if (_currentType == '是') {
      _list.addAll(
        [
          _edit?buildField('报告明细:', _analysis):BuildWidget.buildRow('报告明细', _analysis.text),
          _edit?buildField('结果:', _result):BuildWidget.buildRow('结果', _result.text),
        ]
      );
    } else {
      switch (_dispatch['RequestType']['ID']) {
        case 1:
          _list.addAll(
            [
              _edit?buildField('错误代码:', _code):BuildWidget.buildRow('错误代码', _code.text),
              BuildWidget.buildRow('设备状态（报修）', _dispatch['MachineStatus']['Name']),
              _edit?BuildWidget.buildDropdownLeft('设备状态（离场）:', _currentStatus, _dropDownMenuStatus, changedStatus):BuildWidget.buildRow('设备状态（离场）', _report['EquipmentStatus']['Name']),
              _edit?buildField('详细故障描述:', _description):BuildWidget.buildRow('详细故障描述', _description.text),
              _edit?buildField('分析原因:', _analysis):BuildWidget.buildRow('详细故障描述', _analysis.text),
              _edit?buildField('详细处理方法:', _solution):BuildWidget.buildRow('详细处理方法', _solution.text),
              _edit?buildField('结果:', _result):BuildWidget.buildRow('结果', _result.text),
            ]
          );
          break;
        case 4:
          _list.addAll(
              [
                _edit?buildField('报告明细:', _analysis):BuildWidget.buildRow('报告明细', _analysis.text),
                _edit?buildField('结果:', _result):BuildWidget.buildRow('结果', _result.text),
              ]
          );
          break;
        case 3:
          _list.addAll(
            [
              _edit?buildField('强检要求:', _description):BuildWidget.buildRow('强检要求', _description.text),
              _edit?buildField('报告明细:', _analysis):BuildWidget.buildRow('报告明细', _analysis.text),
              _edit?buildField('结果:', _result):BuildWidget.buildRow('结果', _result.text),
              _edit?BuildWidget.buildRadio('专用报告', _isPrivate, _currentPrivate, changePrivate):BuildWidget.buildRow('专用报告', _currentPrivate),
              _edit?BuildWidget.buildRadio('待召回', _isRecall, _currentRecall, changeRecall):BuildWidget.buildRow('待召回', _currentRecall),
            ]
          );
          break;
        case 2:
          _list.addAll(
            [
              _edit?buildField('报告明细:', _analysis):BuildWidget.buildRow('报告明细', _analysis.text),
              _edit?buildField('结果:', _result):BuildWidget.buildRow('结果', _result.text),
            ]
          );
          break;
        case 5:
          _list.addAll(
              [
                _edit?buildField('报告明细:', _analysis):BuildWidget.buildRow('报告明细', _analysis.text),
                _edit?buildField('结果:', _result):BuildWidget.buildRow('结果', _result.text),
              ]
          );
          break;
        case 7:
          _list.addAll(
              [
                _edit?buildField('报告明细:', _analysis):BuildWidget.buildRow('报告明细', _analysis.text),
                _edit?buildField('结果:', _result):BuildWidget.buildRow('结果', _result.text),
              ]
          );
          break;
        case 9:
          _list.addAll(
              [
                _edit?buildField('报告明细:', _analysis):BuildWidget.buildRow('报告明细', _analysis.text),
                _edit?buildField('结果:', _result):BuildWidget.buildRow('结果', _result.text),
                _edit?
                new Padding(
                  padding: EdgeInsets.symmetric(vertical: 5.0),
                  child: new Row(
                    children: <Widget>[
                      new Expanded(
                        flex: 4,
                        child: new Wrap(
                          alignment: WrapAlignment.end,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: <Widget>[
                            new Text(
                              '报废时间',
                              style: new TextStyle(
                                  fontSize: 20.0, fontWeight: FontWeight.w600),
                            )
                          ],
                        ),
                      ),
                      new Expanded(
                        flex: 1,
                        child: new Text(
                          '：',
                          style: new TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      new Expanded(
                        flex: 4,
                        child: new Text(
                          _acceptDate,
                          style: new TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.w400,
                              color: Colors.black54
                          ),
                        ),
                      ),
                      new Expanded(
                        flex: 2,
                        child: new IconButton(
                            icon: Icon(Icons.calendar_today, color: AppConstants.AppColors['btn_main'],),
                            onPressed: () async {
                              var _date = await pickDate(initialTime: _acceptDate);
                              setState(() {
                                _acceptDate = _date;
                              });
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
                _edit?BuildWidget.buildInputLeft('资产金额', _purchaseAmount):BuildWidget.buildRow('资产金额', _dispatch['Request']['Equipments'][0]['PurchaseAmount'].toString()),
                _edit?BuildWidget.buildRadio('整包范围', _serviceScope, _currentScope, changeScope):BuildWidget.buildRow('整包范围', _dispatch['Request']['Equipments'][0]['ServiceScope']?'是':'否'),
                _edit?buildField('报告明细:', _analysis):BuildWidget.buildRow('报告明细', _analysis.text),
                _edit?buildField('结果:', _result):BuildWidget.buildRow('结果', _result.text),
              ]
          );
          break;
      }

      _list.addAll(
        [
          _edit?BuildWidget.buildDropdownLeft('作业报告结果:', _currentResult, _dropDownMenuItems, changedDropDownMethod):BuildWidget.buildRow('作业报告结果', _currentResult),
          _currentResult=='问题升级'?buildField('问题升级', _unsolved):new Container(),
          _currentResult=='待第三方支持'?BuildWidget.buildDropdownLeft('服务提供方', _currentProvider, _dropDownMenuProviders, changedDropDownProvider):new Container()
        ]
      );

    }

    _list.addAll([
          _edit?new Padding(
              padding: EdgeInsets.symmetric(vertical: 5.0),
              child: new Row(
                children: <Widget>[
                  new Text(
                    '添加附件：',
                    style: new TextStyle(
                        fontSize: 20.0, fontWeight: FontWeight.w600),
                  ),
                  new IconButton(
                      icon: Icon(Icons.add_a_photo),
                      onPressed: () {
                        showSheet(context);
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
                      child: new Image.memory(
                          base64Decode(_acc['ImageNew']['FileContent'])),
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
                      child: new Image.memory(
                          base64Decode(_acc['ImageOld']['FileContent'])),
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
    if (_dispatch['RequestType']['ID'] != 14) {
      _list.add(
        new ExpansionPanel(
          headerBuilder: (context, isExpanded) {
            return ListTile(
              leading: new Icon(
                Icons.info,
                size: 24.0,
                color: Colors.blue,
              ),
              title: Text(
                '设备基本信息',
                style:
                    new TextStyle(fontSize: 22.0, fontWeight: FontWeight.w400),
              ),
            );
          },
          body: new Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: new Column(
              children: buildEquipments(),
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
            leading: new Icon(
              Icons.description,
              size: 24.0,
              color: Colors.blue,
            ),
            title: Text(
              '派工内容',
              style: new TextStyle(fontSize: 22.0, fontWeight: FontWeight.w400),
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
              BuildWidget.buildRow('工程师姓名', _dispatch['Engineer']['Name']),
              //widget.status==3||widget.status==2?new Container():BuildWidget.buildRow('处理方式', _dispatch['Request']['DealType']['Name']),
              BuildWidget.buildRow('紧急程度', _dispatch['Request']==null?'':_dispatch['Request']['Priority']['Name']??''),
              _dispatch['RequestType']['ID'] == 14
                  ? new Container()
                  : BuildWidget.buildRow(
                      '机器状态', _dispatch['MachineStatus']['Name']),
              BuildWidget.buildRow(
                  '出发时间',
                  AppConstants.TimeForm(
                      _dispatch['ScheduleDate'], 'yyyy-mm-dd')),
              BuildWidget.buildRow('备注', _dispatch['LeaderComments']),
            ],
          ),
        ),
        isExpanded: _isExpandedDetail,
      ),
      new ExpansionPanel(
        headerBuilder: (context, isExpanded) {
          return ListTile(
            leading: new Icon(
              Icons.perm_contact_calendar,
              size: 24.0,
              color: Colors.blue,
            ),
            title: Text(
              '作业报告信息',
              style: new TextStyle(fontSize: 22.0, fontWeight: FontWeight.w400),
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
        isExpanded: _isExpandedAssign,
      ),
    ]);
    if (_dispatch['RequestType']['ID'] == 1) {
      _list.add(
        new ExpansionPanel(
          headerBuilder: (context, isExpanded) {
            return ListTile(
              leading: new Icon(
                Icons.settings,
                size: 24.0,
                color: Colors.blue,
              ),
              title: Text(
                '零配件信息',
                style:
                    new TextStyle(fontSize: 22.0, fontWeight: FontWeight.w400),
              ),
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
        BuildWidget.buildRow('名称', _equipment['Name'] ?? ''),
        BuildWidget.buildRow('型号', _equipment['EquipmentCode'] ?? ''),
        BuildWidget.buildRow('序列号', _equipment['SerialCode'] ?? ''),
        BuildWidget.buildRow('使用科室', _equipment['Department']['Name'] ?? ''),
        BuildWidget.buildRow('安装地点', _equipment['InstalSite'] ?? ''),
        BuildWidget.buildRow('设备厂商', _equipment['Manufacturer']['Name'] ?? ''),
        BuildWidget.buildRow('资产等级', _equipment['AssetLevel']['Name'] ?? ''),
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
            widget.status == 2 || widget.status == 3 ? '查看报告' : '上传报告'),
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
      body: _dispatch.isEmpty
          ? new Center(
              child: new SpinKitRotatingPlain(color: Colors.blue),
            )
          : new Padding(
              padding: EdgeInsets.symmetric(vertical: 5.0),
              child: new Card(
                child: new ListView(
                  children: <Widget>[
                    new ExpansionPanelList(
                      animationDuration: Duration(milliseconds: 200),
                      expansionCallback: (index, isExpanded) {
                        setState(() {
                          if (index == 0) {
                            _dispatch['RequestType']['ID'] == 14
                                ? _isExpandedDetail = !isExpanded
                                : _isExpandedBasic = !isExpanded;
                          } else {
                            if (index == 1) {
                              _dispatch['RequestType']['ID'] == 14
                                  ? _isExpandedAssign = !isExpanded
                                  : _isExpandedDetail = !isExpanded;
                            } else {
                              if (index == 2) {
                                _dispatch['RequestType']['ID'] == 14
                                    ? _isExpandedComponent = !isExpanded
                                    : _isExpandedAssign = !isExpanded;
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
                    widget.status == 0 || widget.status == 1
                        ? new Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              new RaisedButton(
                                onPressed: () {
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
