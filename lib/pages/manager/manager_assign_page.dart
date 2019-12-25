import 'dart:core';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:atoi/utils/http_request.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:atoi/utils/constants.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:convert';
import 'package:photo_view/photo_view.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:atoi/models/models.dart';
import 'package:atoi/models/main_model.dart';
import 'package:atoi/widgets/build_widget.dart';
import 'package:flutter/cupertino.dart';

class ManagerAssignPage extends StatefulWidget {
  static String tag = 'mananger-assign-page';

  ManagerAssignPage({Key key, this.request}) : super(key: key);
  final Map request;
  @override
  _ManagerAssignPageState createState() => new _ManagerAssignPageState();

}

class _ManagerAssignPageState extends State<ManagerAssignPage> {

  var _isExpandedBasic = true;
  var _isExpandedDetail = false;
  var _isExpandedAssign = false;
  String departureDate = 'YY-MM-DD';
  String dispatchDate = 'YY-MM-DD';
  var _desc = new TextEditingController();

  Map<String, dynamic> _request = {};
  ConstantsModel model;
  List dispatches = [];

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

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  final List<dynamic> imageBytes = [];

  List _handleMethods = [
    '现场服务',
    '电话解决',
    '远程解决',
    '待第三方支持'
  ];

  List _priorities = [
    '普通',
    '紧急'
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
    '紧急'
  ];

  List _isRecall = [
    '是',
    '否'
  ];

  List _deviceStatuses = [
    '正常',
    '勉强使用',
    '停机'
  ];

  List _maintainType = [
    '原厂保养',
    '第三方保养',
    'FMTS保养'
  ];
  List _faultType = [
    '未知'
  ];
  List _mandatory = [
    '政府要求',
    '医院要求',
    '自主强检'
  ];
  List _badSource = [
    '政府通报',
    '医院自检',
    '召回事件'
  ];

  List _engineerNames = [];

  Map<String, int> _engineers = {};
  List<String> _fileNames = [];
  //final String roleName = await LocalStorage().getStorage('roleName', String);

  List<DropdownMenuItem<String>> _dropDownMenuItems;
  List<DropdownMenuItem<String>> _dropDownMenuPris;
  List<DropdownMenuItem<String>> _dropDownMenuTypes;
  List<DropdownMenuItem<String>> _dropDownMenuLevels;
  List<DropdownMenuItem<String>> _dropDownMenuStatuses;
  List<DropdownMenuItem<String>> _dropDownMenuStatusesReq;
  List<DropdownMenuItem<String>> _dropDownMenuNames;
  List<DropdownMenuItem<String>> _dropDownMenuMaintain;
  List<DropdownMenuItem<String>> _dropDownMenuFault;
  List<DropdownMenuItem<String>> _dropDownMenuSource;
  List<DropdownMenuItem<String>> _dropDownMenuMandatory;
  List<DropdownMenuItem<String>> _dropDownMenuRecall;


  var _leaderComment = new TextEditingController();

  String _currentMethod;
  String _currentPriority;
  String _currentType;
  String _currentLevel;
  String _currentStatus;
  String _currentStatusReq;
  String _currentName;
  String _currentMaintain;
  String _currentFault;
  String _currentSource;
  String _currentMandatory;
  String _currentRecall;


  Future<Null> getRequest() async {
    int requestId = widget.request['ID'];
    var prefs = await _prefs;
    var userId = prefs.getInt('userID');
    var params = {
      'userId': userId,
      'requestId': requestId
    };
    var resp = await HttpRequest.request(
      '/Request/GetRequestByID',
      method: HttpRequest.GET,
      params: params,
    );
    print(resp);
    if (resp['ResultCode'] == '00') {
      var files = resp['Data']['Files'];
      for (var file in files) {
        if (file['FileName'].split('.')[1] == 'jpg' || file['FileName'].split('.')[1] == 'png') {
          getImage(file['ID']);
        } else {
          _fileNames.add(file['FileName']);
        }
      }
      setState(() {
        _request = resp['Data'];
        _currentType = _request['RequestType']['Name'];
        _desc.text = resp['Data']['FaultDesc'];
        if (resp['Data']['MachineStatus']['ID'] != 0) {
          _currentStatusReq = _request['MachineStatus']['Name'];
          _currentStatus = _request['MachineStatus']['Name'];
        }
      });
      if (resp['Data']['RequestType']['ID'] == 2) {
        setState(() {
          _currentMaintain = resp['Data']['FaultType']['Name'];
        });
      }
      if (resp['Data']['RequestType']['ID'] == 3) {
        setState(() {
          _currentMandatory = resp['Data']['FaultType']['Name'];
        });
      }
      if (resp['Data']['RequestType']['ID'] == 7) {
        setState(() {
          _currentSource = resp['Data']['FaultType']['Name'];
        });
      }
    }
  }

  Future<Null> getRequestDispatches() async {
    var resp = await HttpRequest.request(
      '/Dispatch/GetDispatchesByRequestID',
      method: HttpRequest.GET,
      params: {
        'id': widget.request['ID']
      }
    );
    if (resp['ResultCode'] == '00') {
      List _list = resp['Data'];
      _list.removeWhere((item) => (item['Status']['ID'] == -1 || item['Status']['ID'] ==4));
      setState(() {
        dispatches = _list;
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
        var decoded = base64Decode(resp['Data']);
        imageBytes.add(decoded);
      });
    }
  }

  Future<Null> getEngineers() async {
    List<String> _listName = [
      '--请选择--'
    ];
    Map<String, int> _listID = {};
    var resp = await HttpRequest.request(
      '/User/GetUsers4Dispatch',
      method: HttpRequest.GET
    );
    print(resp);
    if (resp['ResultCode'] == '00') {
      for (var item in resp['Data']) {
        _listName.add(item['Name']);
        _listID[item['Name']] = item['ID'];
      }
      List<dynamic> _list = [{
        'Name': '--请选择--',
        'HasOpenDispatch': false
      }];
      _list.addAll(resp['Data']);
      setState(() {
        _engineerNames = _listName;
        _engineers = _listID;
        _dropDownMenuNames = getDropDownMenuEngineer(_list);
        _currentName = _dropDownMenuNames[0].value;
      });
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
    //get key
    _handleMethods = iterateMap(model.DealType);
    _priorities = iterateMap(model.PriorityID);
    _assignTypes = iterateMap(model.RequestType);
    _levels = iterateMap(model.UrgencyID);
    _deviceStatuses = iterateMap(model.MachineStatus);
    _maintainType = iterateMap(model.FaultMaintain);
    _mandatory = iterateMap(model.FaultCheck);
    _badSource = iterateMap(model.FaultBad);

    //init dropdown menu
    _dropDownMenuItems = getDropDownMenuItems(_handleMethods);
    _currentMethod = _dropDownMenuItems[0].value;
    _dropDownMenuPris = getDropDownMenuItems(_priorities);
    _currentPriority = _dropDownMenuPris[0].value;
    _dropDownMenuTypes = getDropDownMenuItems(_assignTypes);
    _dropDownMenuLevels = getDropDownMenuItems(_levels);
    _dropDownMenuStatuses = getDropDownMenuItems(_deviceStatuses);
    _dropDownMenuStatusesReq = getDropDownMenuItems(_deviceStatuses);
    _currentLevel = _dropDownMenuLevels[0].value;
    _currentStatus = _dropDownMenuStatuses[0].value;
    _currentStatusReq = _dropDownMenuStatuses[0].value;
    _dropDownMenuFault = getDropDownMenuItems(_faultType);
    _currentFault = _dropDownMenuFault[0].value;
    _dropDownMenuMaintain = getDropDownMenuItems(_maintainType);
    _dropDownMenuSource = getDropDownMenuItems(_badSource);
    _dropDownMenuMandatory = getDropDownMenuItems(_mandatory);
    _dropDownMenuRecall = getDropDownMenuItems(_isRecall);
    _currentRecall = _dropDownMenuRecall[0].value;
  }

  void initState() {
    model = MainModel.of(context);
    initDropdown();
    getRole();
    List time = new DateTime.now().toString().split('.')[0].split(':');
    time.removeLast();
    dispatchDate = time.join(':');
    getRequest();
    getEngineers();
    getRequestDispatches();
    super.initState();
  }

  List<DropdownMenuItem<String>> getDropDownMenuEngineer(List list) {
    List<DropdownMenuItem<String>> items = new List();
    for (var method in list) {
      items.add(new DropdownMenuItem(
          value: method['Name'],
          child: new Text(method['Name'],
            style: new TextStyle(
                fontSize: 20.0,
                color: method['HasOpenDispatch']?Colors.redAccent:Colors.grey
            ),
          )
      ));
    }
    return items;
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

  void changedDropDownStatusReq(String selectedMethod) {
    setState(() {
      _currentStatusReq = selectedMethod;
    });
  }

  void changedDropDownName(String selectedMethod) {
    setState(() {
      _currentName = selectedMethod;
    });
  }

  void changedDropDownFault(String selectedMethod) {
    setState(() {
      _currentFault = selectedMethod;
    });
  }
  void changedDropDownMaintain(String selectedMethod) {
    setState(() {
      _currentMaintain = selectedMethod;
    });
  }
  void changedDropDownSource(String selectedMethod) {
    setState(() {
      _currentSource = selectedMethod;
    });
  }
  void changedDropDownMandatory(String selectedMethod) {
    setState(() {
      _currentMandatory= selectedMethod;
    });
  }
  void changedDropDownRecall(String selectedMethod) {
    setState(() {
      _currentRecall= selectedMethod;
    });
  }

  Column buildImageColumn() {
    if (imageBytes == null) {
      return Column();
    } else {
      List<Widget> _list = [];
      for(var file in imageBytes) {
        _list.add(Container(
          child: PhotoView(imageProvider: MemoryImage(file)),
          width: 400.0,
          height: 400.0,
        ));
        _list.add(SizedBox(height: 8.0,));
      }
      return Column(children: _list);
    }
  }

  Column buildFileName() {
    if (_fileNames.length == 0) {
      return new Column();
    } else {
      List<Widget> _list = [];
      for(var _name in _fileNames) {
        _list.add(new ListTile(
          title: new Row(
            children: <Widget>[
              new Expanded(
                  flex: 4,
                  child: new Container()
              ),
              new Expanded(
                  flex: 6,
                  child: new Text(
                    _name,
                    style: new TextStyle(
                        color: Colors.blue
                    ),
                  ),
              ),
            ],
          )
        ));
      }
      return new Column(children: _list,);
    }
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
            child: new Wrap(
              //mainAxisAlignment: MainAxisAlignment.end,
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                new Text(
                  labelText,
                  style: new TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w600
                  ),
                )
              ],
            ),
          ),
          new Expanded(
            flex: 1,
            child: new Text(
              '',
              style: new TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w600,
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
          flex: 5,
          child: new DropdownButton(
            value: currentItem,
            items: dropdownItems,
            onChanged: changeDropdown,
          ),
        )
      ],
    );
  }

  Future<Null> terminate() async {
    var prefs = await _prefs;
    var userID = prefs.getInt('userID');
    Map<String, dynamic> _data = {
      'userID': userID,
      'requestID': _request['ID']
    };
    var resp = await HttpRequest.request(
      '/Request/EndRequest',
      method: HttpRequest.POST,
      data: _data
    );
    print(resp);
    if (resp['ResultCode'] == '00') {
      showDialog(context: context,
        builder: (context) => CupertinoAlertDialog(
          title: new Text('终止请求成功'),
        )
      ).then((result) =>
        Navigator.of(context, rootNavigator: true).pop()
      );
    } else {
      showDialog(context: context,
        builder: (context) => CupertinoAlertDialog(
          title: new Text(resp['ResultMessage']),
        )
      );
    }
  }

  Future assignRequest() async {
    var prefs = await _prefs;
    var userID = prefs.getInt('userID');
    Map<String, dynamic> _data = {
      'userID': userID,
      'dispatchInfo': {
        'Request': {
          'ID': _request['ID'],
          'Priority': {
            'ID': model.PriorityID[_currentPriority],
          },
          'DealType': {
            'ID': model.DealType[_currentMethod]
          },
          'MachineStatus': {
            'ID': model.MachineStatus[_currentStatusReq]
          },
          'FaultDesc': _desc.text,
          'IsRecall': _request['IsRecall']
        },
        'Urgency': {
          'ID': model.UrgencyID[_currentLevel]
        },
        'Engineer': {
          'ID': _engineers[_currentName]
        },
        'MachineStatus': {
          'ID': model.MachineStatus[_currentStatus]
        },
        'ScheduleDate': dispatchDate,
        'LeaderComments': _leaderComment.text,
        'RequestType': {
          'ID': model.RequestType[_currentType]
        }
      }
    };
    switch (_request['RequestType']['ID']) {
      case 1:
        _data['dispatchInfo']['Request']['FaultType'] = {
          //'ID': model.FaultRepair[_currentFault]
          'ID': 1
        };
        break;
      case 2:
        _data['dispatchInfo']['Request']['FaultType'] = {
          'ID': model.FaultMaintain[_currentMaintain]
        };
        break;
      case 3:
        _data['dispatchInfo']['Request']['FaultType'] = {
          'ID': model.FaultCheck[_currentMandatory]
        };
        break;
      case 7:
        _data['dispatchInfo']['Request']['FaultType'] = {
          'ID': model.FaultBad[_currentSource]
        };
        break;
      default:
        _data['dispatchInfo']['Request']['FaultType'] = {
          'ID': _request['FaultType']['ID']
        };
    }
    var resp = await HttpRequest.request(
      '/Request/CreateDispatch',
      method: HttpRequest.POST,
      data: _data
    );
    print(resp);
    if (resp['ResultCode'] == '00') {
      showDialog(context: context,
        builder: (context) => CupertinoAlertDialog(
          title: new Text('安排派工成功'),
        )
      ).then((result) =>
        Navigator.of(context, rootNavigator: true).pop(result)
      );
    } else {
      showDialog(context: context,
        builder: (context) => CupertinoAlertDialog(
          title: new Text(resp['ResultMessage']),
        )
      );
    }
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

  List<dynamic> _buildExpansion() {
    List<ExpansionPanel> _list = [];
    if (_request['RequestType']['ID'] != 14) {
      _list.add(new ExpansionPanel(
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
      ));
    }
    _list.add(new ExpansionPanel(
        headerBuilder: (context, isExpanded) {
          return ListTile(
              leading: new Icon(Icons.description,
                size: 24.0,
                color: Colors.blue,
              ),
              title: Text('请求内容',
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
              BuildWidget.buildInput(model.Remark[_request['RequestType']['ID']], _desc, maxLength: 200),
              _request['RequestType']['ID']==1?BuildWidget.buildDropdown('机器状态', _currentStatusReq, _dropDownMenuStatusesReq, changedDropDownStatusReq):new Container(),
              _request['RequestType']['ID']==2?BuildWidget.buildDropdown('保养类型', _currentMaintain, _dropDownMenuMaintain, changedDropDownMaintain):new Container(),
              _request['RequestType']['ID']==3?BuildWidget.buildDropdown('强检原因', _currentMandatory, _dropDownMenuMandatory, changedDropDownMandatory):new Container(),
              _request['RequestType']['ID']==7?BuildWidget.buildDropdown('来源', _currentSource, _dropDownMenuSource, changedDropDownSource):new Container(),
              _request['RequestType']['ID']==3?BuildWidget.buildRow('是否召回', _request['IsRecall']?'是':'否'):new Container(),
              BuildWidget.buildRow('请求人', _request['RequestUser']['Name']),
              BuildWidget.buildDropdown('处理方式', _currentMethod, _dropDownMenuItems, changedDropDownMethod),
              //BuildWidget.buildDropdown('紧急程度', _currentPriority, _dropDownMenuPris, changedDropDownPri),
              BuildWidget.buildRow('请求附件', ''),
              buildImageColumn(),
              buildFileName()
            ],
          ),
        ),
        isExpanded: _isExpandedDetail,
      ),
    );
    _list.add(new ExpansionPanel(
      headerBuilder: (context, isExpanded) {
        return ListTile(
            leading: new Icon(Icons.perm_contact_calendar,
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
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            BuildWidget.buildDropdown('派工类型', _currentType, _dropDownMenuTypes, changedDropDownType),
            BuildWidget.buildDropdown('紧急程度', _currentLevel, _dropDownMenuLevels, changedDropDownLevel),
            _currentType!='其他服务'?BuildWidget.buildDropdown('机器状态', _currentStatus, _dropDownMenuStatuses, changedDropDownStatus):new Container(),
            _engineerNames.isEmpty?new Container():BuildWidget.buildDropdown('工程师姓名', _currentName, _dropDownMenuNames, changedDropDownName),
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
                          '出发时间',
                          style: new TextStyle(
                              fontSize: 20.0,
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
                        fontSize: 20.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  new Expanded(
                    flex: 4,
                    child: new Text(
                      dispatchDate,
                      style: new TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                          color: Colors.black54
                      ),
                    ),
                  ),
                  new Expanded(
                    flex: 2,
                    child: new IconButton(
                      color: AppConstants.AppColors['btn_main'],
                      icon: Icon(Icons.calendar_today),
                      onPressed: () {
                        var _initTime = DateTime.tryParse(dispatchDate);
                        showDatePicker(
                            context: context,
                            initialDate: _initTime??DateTime.now(),
                            firstDate: _initTime??DateTime.now(),
                            lastDate: new DateTime.now().add(new Duration(days: 30)),
                            locale: Locale('zh')
                        ).then((DateTime val) {
                          showTimePicker(context: (context), initialTime: TimeOfDay.fromDateTime(_initTime)??TimeOfDay.now()).then((TimeOfDay selectTime) {
                            var _time = selectTime.format(context);
                            setState(() {
                              dispatchDate = '${val.toString().split(' ')[0]} ${_time}';
                            });
                          });
                        }).catchError((err) {
                          print(err);
                        });
                      },
                    ),
                  )
                ],
              ),
            ),
            new Padding(
              padding: EdgeInsets.symmetric(vertical: 5.0),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Align(
                    alignment: Alignment(-0.62, 0),
                    child: new Text(
                      '主管备注：',
                      style: new TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w600
                      ),
                    ),
                  ),
                  new TextField(
                    controller: _leaderComment,
                    maxLength: 200,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      isExpanded: _isExpandedAssign,
    ));
    return _list;
  }

  @override
  Widget build(BuildContext context){
    return ScopedModelDescendant<MainModel>(
      builder: (context, child, model) {
        return new Scaffold(
          appBar: new AppBar(
            title: new Text('分配请求'),
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
          body: _request.isEmpty?new Center(child: SpinKitRotatingPlain(color: Colors.blue),):new Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: new Card(
              child: new ListView(
                children: <Widget>[
                  new ExpansionPanelList(
                    animationDuration: Duration(milliseconds: 200),
                    expansionCallback: (index, isExpanded) {
                      setState(() {
                        if (index == 0) {
                          if (_request['RequestType']['ID'] == 14) {
                            _isExpandedDetail = !isExpanded;
                          } else {
                            _isExpandedBasic = !isExpanded;
                          }
                        } else {
                          if (index == 1) {
                            if (_request['RequestType']['ID'] == 14) {
                              _isExpandedAssign = !isExpanded;
                            } else {
                              _isExpandedDetail = !isExpanded;
                            }
                          } else {
                            _isExpandedAssign =!isExpanded;
                          }
                        }
                      });
                    },
                    children: _buildExpansion(),
                  ),
                  SizedBox(height: 24.0),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      new Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5.0),
                        child: new RaisedButton(
                          onPressed: () {
                            if (_currentName == '--请选择--') {
                              showDialog(context: context,
                                  builder: (context) => CupertinoAlertDialog(
                                    title: new Text('请选择工程师'),
                                  )
                              );
                              return;
                            }
                            if (_desc.text.isEmpty) {
                              showDialog(context: context,
                                  builder: (context) => CupertinoAlertDialog(
                                    title: new Text(
                                        '${model.Remark[_request['RequestType']['ID']]}不可为空'
                                    ),
                                  )
                              );
                              return;
                            }
                            if (dispatches.length > 0) {
                              showDialog(context: context,
                                  builder: (context) => CupertinoAlertDialog(
                                    title: new Text('已有派工,是否继续派工?'),
                                    actions: <Widget>[
                                      new Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          new Container(
                                            width: 100.0,
                                            child: RaisedButton(
                                              //padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                                              child: Text('确认', style: TextStyle(color: Colors.white),),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              color: AppConstants.AppColors['btn_cancel'],
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                assignRequest();
                                                model.getRequests();
                                              },
                                            ),
                                          ),
                                          new SizedBox(
                                            width: 10.0,
                                          ),
                                          new Container(
                                            width: 100.0,
                                            child: RaisedButton(
                                              child: Text('取消', style: TextStyle(color: Colors.white),),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              color: AppConstants.AppColors['btn_main'],
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  )
                              );
                            } else {
                              assignRequest();
                              model.getRequests();
                            }
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: EdgeInsets.all(12.0),
                          color: new Color(0xff2E94B9),
                          child: Text('安排派工', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      new Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5.0),
                        child: new RaisedButton(
                          onPressed: () {
                            //terminate();
                            //model.getRequests();
                            showDialog(context: context,
                              builder: (context) => CupertinoAlertDialog(
                                title: new Text('是否终止请求？'),
                                actions: <Widget>[
                                  new Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      new Container(
                                        width: 100.0,
                                        child: RaisedButton(
                                          //padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                                          child: Text('确认', style: TextStyle(color: Colors.white),),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          color: AppConstants.AppColors['btn_cancel'],
                                          onPressed: () {
                                            terminate();
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ),
                                      new SizedBox(
                                        width: 10.0,
                                      ),
                                      new Container(
                                        width: 100.0,
                                        child: RaisedButton(
                                          child: Text('取消', style: TextStyle(color: Colors.white),),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          color: AppConstants.AppColors['btn_main'],
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              )
                            );
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: EdgeInsets.all(12.0),
                          color: new Color(0xffD25565),
                          child: Text('终止请求', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.0),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}