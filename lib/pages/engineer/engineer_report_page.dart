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

  List _serviceResults = [];
  List _sources = [];
  List _providers = [];

  List<DropdownMenuItem<String>> _dropDownMenuItems;
  List<DropdownMenuItem<String>> _dropDownMenuSources;
  List<DropdownMenuItem<String>> _dropDownMenuProviders;
  String _currentResult;
  String _currentSource;
  String _currentProvider;

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
  //List<dynamic> _imageList = [];
  var _imageList;
  var _fujiComments = "";
  String _reportStatus = '新建';
  String _reportOID;

  String _userName = '';
  String _mobile = '';

  List _isPrivate = ['是', '否'];
  String _currentPrivate = '否';

  void changePrivate(value) {
    setState(() {
      _currentPrivate = value;
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

  Future<Null> getReport() async {
    if (widget.reportId != 0) {
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
    if (_isDelayed && _delay.text.isEmpty) {
      showDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
                title: new Text('误工说明不可为空'),
              ));
      return;
    }
    if (_frequency.text.isEmpty ||
        _code.text.isEmpty ||
        _status.text.isEmpty ||
        _analysis.text.isEmpty ||
        _solution.text.isEmpty) {
      showDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
                title: new Text('报告不可有空字段'),
              ));
    } else {
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
        'userID': userID,
        'DispatchReport': {
          'Dispatch': {'ID': widget.dispatchId},
          'FaultFrequency': _frequency.text,
          'FaultCode': _code.text,
          'FaultSystemStatus': _status.text,
          'FaultDesc': _description.text,
          'SolutionCauseAnalysis': _analysis.text,
          'SolutionWay': _solution.text,
          'SolutionResultStatus': {
            'ID': model.SolutionStatus[_currentResult],
            'Name': _currentResult
          },
          'IsPrivate': _currentPrivate == '是' ? 1 : 0,
          'ServiceProvider': model.ServiceProviders[_currentProvider],
          'SolutionUnsolvedComments': _unsolved.text,
          'DelayReason': _delay.text,
          'Status': {
            'ID': statusId,
          },
          'FileInfo': _json,
          'ReportAccessories': _accessory,
          'ID': widget.reportId
        }
      };
      switch (_dispatch['Request']['RequestType']['ID']) {
        case 2:
          _data['Type'] = {'ID': 201};
          break;
        case 3:
          _data['Type'] = {'ID': 301};
          break;
        case 4:
          _data['Type'] = {'ID': 401};
          break;
        default:
          _data['Type'] = {'ID': 1};
          break;
      }
      setState(() {
        hold = true;
      });
      var resp = await HttpRequest.request('/DispatchReport/SaveDispatchReport',
          method: HttpRequest.POST, data: _data);
      setState(() {
        hold = false;
      });
      if (resp['ResultCode'] == '00') {
        showDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
                title: statusId == 1
                    ? new Text('保存报告成功')
                    : new Text('上传报告成功'))).then(
            (result) => Navigator.of(context, rootNavigator: true).pop(result));
      } else {
        showDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
                  title: new Text(resp['ResultMessage']),
                ));
      }
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
    _serviceResults = iterateMap(model.SolutionStatus);
    _sources = iterateMap(model.AccessorySourceType);
    _providers = iterateMap(model.ServiceProviders);
    _dropDownMenuItems = getDropDownMenuItems(_serviceResults);
    _dropDownMenuSources = getDropDownMenuItems(_sources);
    _dropDownMenuProviders = getDropDownMenuItems(_providers);
    _currentResult = _dropDownMenuItems[3].value;
    _currentSource = _dropDownMenuSources[0].value;
    _currentProvider = _dropDownMenuProviders[0].value;
  }

  void initState() {
    model = MainModel.of(context);
    initDropdown();
    getDispatch();
    getReport();
    getRole();
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
      {String hintText}) {
    String hint = hintText ?? 'N/A';
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
      new Divider(),
    ]);

    switch (_dispatch['Request']['RequestType']['ID']) {
      case 4:
        _list.addAll([
          widget.status != 0 && widget.status != 1
              ? BuildWidget.buildRow('报告明细', _analysis.text)
              : buildField('报告明细：', _analysis),
          widget.status != 0 && widget.status != 1
              ? BuildWidget.buildRow('结果', _solution.text)
              : buildField('结果：', _solution),
          widget.status != 0 && widget.status != 1
              ? BuildWidget.buildRow('作业报告结果', _currentResult)
              : BuildWidget.buildDropdown('作业报告结果', _currentResult,
                  _dropDownMenuItems, changedDropDownMethod),
          _currentResult == '问题升级'
              ? (widget.status != 0 && widget.status != 1
                  ? BuildWidget.buildRow('问题升级', _unsolved.text)
                  : buildField('问题升级：', _unsolved))
              : new Container(),
        ]);
        break;
      case 3:
        _list.addAll([
          widget.status != 0 && widget.status != 1
              ? BuildWidget.buildRow('强检要求', _description.text)
              : buildField('强检要求：', _description,
                  hintText: 'FDA, Manufacture, Hospital, Etc..'),
          widget.status != 0 && widget.status != 1
              ? BuildWidget.buildRow('报告明细', _analysis.text)
              : buildField('报告明细：', _analysis),
          widget.status != 0 && widget.status != 1
              ? BuildWidget.buildRow('结果', _solution.text)
              : buildField('结果：', _solution),
          widget.status != 0 && widget.status != 1
              ? BuildWidget.buildRow('专用报告', _currentPrivate)
              : BuildWidget.buildRadio(
                  '专用报告', _isPrivate, _currentPrivate, changePrivate),
          widget.status != 0 && widget.status != 1
              ? BuildWidget.buildRow('作业报告结果', _currentResult)
              : BuildWidget.buildDropdown('作业报告结果', _currentResult,
                  _dropDownMenuItems, changedDropDownMethod),
          _currentResult == '问题升级'
              ? (widget.status != 0 && widget.status != 1
                  ? BuildWidget.buildRow('问题升级', _unsolved.text)
                  : buildField('问题升级：', _unsolved))
              : new Container(),
        ]);
        break;
      case 2:
        _list.addAll([
          widget.status != 0 && widget.status != 1
              ? BuildWidget.buildRow('报告明细', _analysis.text)
              : buildField('报告明细：', _analysis),
          widget.status != 0 && widget.status != 1
              ? BuildWidget.buildRow('结果', _solution.text)
              : buildField('结果：', _solution),
          widget.status != 0 && widget.status != 1
              ? BuildWidget.buildRow('服务提供方', _currentProvider)
              : BuildWidget.buildDropdown('服务提供方', _currentProvider,
                  _dropDownMenuProviders, changedDropDownProvider),
          widget.status != 0 && widget.status != 1
              ? BuildWidget.buildRow('作业报告结果', _currentResult)
              : BuildWidget.buildDropdown('作业报告结果', _currentResult,
                  _dropDownMenuItems, changedDropDownMethod),
          _currentResult == '问题升级'
              ? (widget.status != 0 && widget.status != 1
                  ? BuildWidget.buildRow('问题升级', _unsolved.text)
                  : buildField('问题升级：', _unsolved))
              : new Container(),
        ]);
        break;
      default:
        _list.addAll([
          widget.status != 0 && widget.status != 1
              ? BuildWidget.buildRow('发生频率', _frequency.text)
              : buildField('发生频率：', _frequency),
          widget.status != 0 && widget.status != 1
              ? BuildWidget.buildRow('故障描述', _description.text)
              : buildField('故障描述：', _description),
          widget.status != 0 && widget.status != 1
              ? BuildWidget.buildRow('系统状态', _status.text)
              : buildField('系统状态：', _status),
          widget.status != 0 && widget.status != 1
              ? BuildWidget.buildRow('错误代码', _code.text)
              : buildField('错误代码：', _code),
          widget.status != 0 && widget.status != 1
              ? BuildWidget.buildRow('分析原因', _analysis.text)
              : buildField('分析原因：', _analysis),
          widget.status != 0 && widget.status != 1
              ? BuildWidget.buildRow('处理方法', _solution.text)
              : buildField('处理方法：', _solution),
          widget.status != 0 && widget.status != 1
              ? BuildWidget.buildRow('备注', _unsolved.text)
              : buildField('备注：', _unsolved),
          (widget.status == 0 || widget.status == 1) && _isDelayed
              ? buildField('误工说明：', _delay)
              : new Container(),
          widget.status != 0 && widget.status != 1 && _isDelayed
              ? BuildWidget.buildRow('误工说明', _delay.text)
              : new Container(),
          widget.status != 0 && widget.status != 1
              ? BuildWidget.buildRow('作业结果', _currentResult)
              : BuildWidget.buildDropdown('作业结果：', _currentResult,
                  _dropDownMenuItems, changedDropDownMethod),
        ]);
    }

    _list.addAll([
      widget.status == 0 || widget.status == 1
          ? new Padding(
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
              BuildWidget.buildRow(
                  '紧急程度', _dispatch['Request']['Priority']['Name']),
              _dispatch['Request']['RequestType']['ID'] == 14
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
          new Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 5.0, vertical: 19.0),
            child: Text(_userName),
          ),
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
