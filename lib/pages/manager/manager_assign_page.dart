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
import 'package:atoi/models/manager_model.dart';

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
  String departureDate = '';

  Map<String, dynamic> _request = {};

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  List<dynamic> imageBytes = [];

  List _handleMethods = [
    '现场服务',
    '电话解决',
    '远程服务',
    '第三方支持'
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

  List _deviceStatuses = [
    '正常',
    '勉强使用',
    '停机'
  ];

  List _engineerNames = [];

  Map<String, int> _engineers = {};
  //final String roleName = await LocalStorage().getStorage('roleName', String);

  List<DropdownMenuItem<String>> _dropDownMenuItems;
  List<DropdownMenuItem<String>> _dropDownMenuPris;
  List<DropdownMenuItem<String>> _dropDownMenuTypes;
  List<DropdownMenuItem<String>> _dropDownMenuLevels;
  List<DropdownMenuItem<String>> _dropDownMenuStatuses;
  List<DropdownMenuItem<String>> _dropDownMenuNames;

  var _leaderComment = new TextEditingController();

  String _currentMethod;
  String _currentPriority;
  String _currentType;
  String _currentLevel;
  String _currentStatus;
  String _currentName;

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
        getImage(file['ID']);
      }
      setState(() {
        _request = resp['Data'];
        _currentType = _request['RequestType']['Name'];
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

  Future<Null> getEngineers() async {
    List<String> _listName = [];
    Map<String, int> _listID = {};
    var resp = await HttpRequest.request(
      '/User/GetAdmins',
      method: HttpRequest.GET
    );
    print(resp);
    if (resp['ResultCode'] == '00') {
      for (var item in resp['Data']) {
        _listName.add(item['Name']);
        _listID[item['Name']] = item['ID'];
      }
      print(_listID);
      setState(() {
        _engineerNames = _listName;
        _engineers = _listID;
        _dropDownMenuNames = getDropDownMenuItems(_engineerNames);
        _currentName = _dropDownMenuNames[0].value;
      });
    }
  }

  void initState() {
    _dropDownMenuItems = getDropDownMenuItems(_handleMethods);
    _currentMethod = _dropDownMenuItems[0].value;
    _dropDownMenuPris = getDropDownMenuItems(_priorities);
    _currentPriority = _dropDownMenuPris[0].value;
    _dropDownMenuTypes = getDropDownMenuItems(_assignTypes);
    _dropDownMenuLevels = getDropDownMenuItems(_levels);
    _dropDownMenuStatuses = getDropDownMenuItems(_deviceStatuses);
    _currentLevel = _dropDownMenuLevels[0].value;
    _currentStatus = _dropDownMenuStatuses[0].value;
    getRequest();
    getEngineers();
    ManagerModel model = MainModel.of(context);
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
        builder: (context) => AlertDialog(
          title: new Text('终止请求成功'),
        )
      ).then((result) =>
        Navigator.of(context, rootNavigator: true).pop(result)
      );
    } else {
      showDialog(context: context,
        builder: (context) => AlertDialog(
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
            'ID': AppConstants.PriorityID[_currentPriority],
          },
          'DealType': {
            'ID': AppConstants.DealType[_currentMethod]
          },
          'FaultDesc': _request['FaultDesc'],
          'FaultType': {
            'ID': _request['FaultType']['ID']
          }
        },
        'Urgency': {
          'ID': AppConstants.UrgencyID[_currentLevel]
        },
        'Engineer': {
          'ID': _engineers[_currentName]
        },
        'MachineStatus': {
          'ID': AppConstants.MachineStatus[_currentStatus]
        },
        'ScheduleDate': departureDate,
        'LeaderComments': _leaderComment.text,
        'RequestType': {
          'ID': AppConstants.RequestType[_currentType]
        }
      }
    };
    var resp = await HttpRequest.request(
      '/Request/CreateDispatch',
      method: HttpRequest.POST,
      data: _data
    );
    print(resp);
    if (resp['ResultCode'] == '00') {
      showDialog(context: context,
        builder: (context) => AlertDialog(
          title: new Text('安排派工成功'),
        )
      ).then((result) =>
        Navigator.of(context, rootNavigator: true).pop(result)
      );
    } else {
      showDialog(context: context,
        builder: (context) => AlertDialog(
          title: new Text('派工失败:'),
          actions: <Widget>[
            new Text(resp['ResultMessage'])
          ],
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
          buildRow('系统编号:', _equipment['OID']??''),
          buildRow('设备名称：', _equipment['Name']??''),
          buildRow('设备型号：', _equipment['EquipmentCode']??''),
          buildRow('设备序列号：', _equipment['SerialCode']??''),
          buildRow('使用科室：', _equipment['Department']['Name']??''),
          buildRow('安装地点：', _equipment['InstalSite']??''),
          buildRow('设备厂商：', _equipment['Manufacturer']['Name']??''),
          buildRow('资产等级：', _equipment['AssetLevel']['Name']??''),
          buildRow('维保状态：', _equipment['WarrantyStatus']??''),
          buildRow('服务范围：', _equipment['ContractScopeComments']??''),
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
              title: new Align(
                  child: Text('请求内容',
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
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              buildRow('类型：', _request['SourceType']),
              buildRow('主题：', _request['SubjectName']),
              buildRow(AppConstants.Remark[_request['RequestType']['ID']], _request['FaultDesc']),
              _request['FaultType']['ID'] != 0?buildRow(AppConstants.RemarkType[_request['RequestType']['ID']], _request['FaultType']['Name']):new Container(),
              _request['RequestType']['ID'] == 3?buildRow('是否召回：', _request['IsRecall']?'是':'否'):new Container(),
              buildRow('请求人：', _request['RequestUser']['Name']),
              buildDropdown('处理方式：', _currentMethod, _dropDownMenuItems, changedDropDownMethod),
              buildDropdown('紧急程度：', _currentPriority, _dropDownMenuPris, changedDropDownPri),
              new Padding(
                padding: EdgeInsets.symmetric(vertical: 5.0),
                child: new Text('请求附件:',
                  style: new TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w600
                  ),
                ),
              ),
              buildImageColumn(),
              //new Row(
              //  mainAxisAlignment: MainAxisAlignment.start,
              //  children: <Widget>[
              //    new Padding(
              //      padding: const EdgeInsets.all(10.0),
              //      child: new Container(
              //        child: imageBytes.isEmpty?new Stack():new PhotoView(
              //            imageProvider: MemoryImage(imageBytes),
              //        ),
              //      ),
              //    ),
              //  ],
              //),
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
            title: new Align(
                child: Text('派工内容',
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
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            buildDropdown('派工类型：', _currentType, _dropDownMenuTypes, changedDropDownType),
            buildDropdown('紧急程度：', _currentLevel, _dropDownMenuLevels, changedDropDownLevel),
            buildDropdown('机器状态：', _currentStatus, _dropDownMenuStatuses, changedDropDownStatus),
            _engineerNames.isEmpty?new Container():buildDropdown('工程师姓名：', _currentName, _dropDownMenuNames, changedDropDownName),
            new MaterialButton(
              child: new Align(
                alignment: Alignment(-1.1, 0.0),
                child: new Text(
                  '出发时间:',
                  style: new TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 20.0
                  ),
                ),
              ),
              onPressed: () {
                showDatePicker(
                    context: context,
                    initialDate: new DateTime.now(),
                    firstDate: new DateTime.now().subtract(new Duration(days: 30)), // 减 30 天
                    lastDate: new DateTime.now().add(new Duration(days: 30)),       // 加 30 天
                    locale: Locale('zh')
                ).then((DateTime val) {
                  print(val); // 2018-07-12 00:00:00.000
                  var date = '${val.year}-${val.month}-${val.day}';
                  setState(() {
                    departureDate = date;
                  });
                }).catchError((err) {
                  print(err);
                });
              },
            ),
            departureDate != ''?new Text(departureDate):new Container(),
            new Padding(
              padding: EdgeInsets.symmetric(vertical: 5.0),
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Text(
                    '主管备注：',
                    style: new TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w600
                    ),
                  ),
                  new TextField(
                    controller: _leaderComment,
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
              new Icon(Icons.face),
              new Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 19.0),
                child: const Text('超级管理员'),
              ),
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
                          }
                          _isExpandedBasic = !isExpanded;
                        } else {
                          if (index == 1) {
                            if (_request['RequestType']['ID'] == 14) {
                              _isExpandedAssign = !isExpanded;
                            }
                            _isExpandedDetail = !isExpanded;
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
                            assignRequest();
                            model.getRequests();
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
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
                            terminate();
                            model.getRequests();
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: EdgeInsets.all(12.0),
                          color: new Color(0xffD25565),
                          child: Text('终止请求', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}