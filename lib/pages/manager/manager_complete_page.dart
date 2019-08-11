import 'package:flutter/material.dart';
import 'package:atoi/utils/http_request.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:atoi/utils/constants.dart';
import 'package:photo_view/photo_view.dart';
import 'dart:convert';

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
  Map<String, dynamic> _request = {};

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

  void initState() {
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

  Padding _buildRow(String labelText, String defaultText) {
    return new Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: new Row(
        children: <Widget>[
          new Text(
            labelText,
            style: new TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w600
            ),
          ),
          new Text(
            defaultText,
            style: new TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w400,
                color: Colors.black54
            ),
          ),
        ],
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
          new Icon(Icons.face),
          new Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 19.0),
            child: const Text('上杉谦信'),
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
                      padding: EdgeInsets.symmetric(horizontal: 12.0),
                      child: new Column(
                        children: buildEquipment(),
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
                          buildRow('主题：', _request['Subject']),
                          buildRow(AppConstants.Remark[_request['RequestType']['ID']], _request['FaultDesc']),
                          _request['FaultType']['ID'] != 0?buildRow(AppConstants.RemarkType[_request['RequestType']['ID']], _request['FaultType']['Name']):new Container(),
                          buildRow('请求人：', _request['RequestUser']['Name']),
                          buildRow('处理方式：', _request['DealType']['Name']),
                          buildRow('紧急程度：', _request['Priority']['Name']),
                          new Padding(
                            padding: EdgeInsets.symmetric(vertical: 5.0),
                            child: new Text('请求附件：',
                              style: new TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w600
                              ),
                            ),
                          ),
                          buildImageColumn()
                        ],
                      ),
                    ),
                    isExpanded: _isExpandedDetail,
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
