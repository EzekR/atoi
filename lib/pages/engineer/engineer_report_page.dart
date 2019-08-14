import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:atoi/utils/http_request.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:atoi/utils/constants.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:atoi/pages/engineer/engineer_report_accessory.dart';
import 'package:atoi/widgets/build_widget.dart';

class EngineerReportPage extends StatefulWidget {
  static String tag = 'engineer-report-page';
  EngineerReportPage({Key key, this.dispatchId, this.reportId, this.status}):super(key: key);
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

  List _serviceResults = [
    '待分配',
    '问题升级',
    '第三方解决',
    '已解决'
  ];

  List _sources = [
    '外部供应商',
    '备件库'
  ];


  List<DropdownMenuItem<String>> _dropDownMenuItems;
  List<DropdownMenuItem<String>> _dropDownMenuSources;
  String _currentResult;
  String _currentSource;
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
  List<dynamic> _imageList = [];

  Future getImage() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800.0
    );
    if (image != null) {
      setState(() {
        _imageList.add(image);
      });
    }
  }

  Future<Null> getReport() async {
    if (widget.reportId != 0) {
      var prefs = await _prefs;
      var userID = prefs.getInt('userID');
      var reportId = widget.reportId;
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
        var data = resp['Data'];
        setState(() {
          _frequency.text = data['FaultFrequency'];
          _code.text = data['FaultCode'];
          _status.text = data['FaultSystemStatus'];
          _description.text = data['FaultDesc'];
          _analysis.text = data['SolutionCauseAnalysis'];
          _solution.text = data['SolutionWay'];
          //_currentResult = data['SolutionResultStatus']['Name']??_currentResult;
          _delay.text = data['DelayReason'];
          _unsolved.text = data['SolutionUnsolvedComments'];
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
      var _createTime = DateTime.parse(resp['Data']['CreateDate']);
      var _startTime = DateTime.parse(resp['Data']['StartDate']);
      var _duration = _startTime.difference(_createTime).inSeconds;
      if (_duration > resp['Data']['Request']['Equipments'][0]['ResponseTimeLength']) {
        setState(() {
          _isDelayed = true;
        });
      }
    }
  }

  Future<Null> uploadReport() async {
    if (_frequency.text.isEmpty || _code.text.isEmpty || _status.text.isEmpty || _analysis.text.isEmpty || _solution.text.isEmpty) {
      showDialog(context: context,
        builder: (context) => AlertDialog(
          title: new Text('报告不可有空字段'),
        )
      );
    } else {
      List<dynamic> Files = [];
      for(var image in _imageList) {
        List<int> imageBytes = await image.readAsBytes();
        var content = base64Encode(imageBytes);
        Map _json = {
          'FileContent': content,
          'FileName': image.path,
          'ID': 0,
          'FileType': 1
        };
        Files.add(_json);
      }
      var prefs = await _prefs;
      var userID = prefs.getInt('userID');
      var _data = {
        'userID': userID,
        'dispatchReport': {
          'Dispatch': {
            'ID': widget.dispatchId
          },
          'Type': {
            'ID': 1,
            'Name': '通用作业报告'
          },
          'FaultFrequency': _frequency.text,
          'FaultCode': _code.text,
          'FaultSystemStatus': _status.text,
          'FaultDesc': _description.text,
          'SolutionCauseAnalysis': _analysis.text,
          'SolutionWay': _solution.text,
          'SolutionResultStatus': {
            'ID': AppConstants.SolutionStatus[_currentResult],
            'Name': _currentResult
          },
          'SolutionUnsolvedComments': _unsolved.text,
          'DelayReason': _delay.text,
          'Status': {
            'ID': 2,
            'Name': '待审批'
          },
          'Files': Files,
          'ReportAccessories': _accessory
        }
      };
      var resp = await HttpRequest.request(
          '/DispatchReport/SaveDispatchReport',
          method: HttpRequest.POST,
          data: _data
      );
      print(resp);
      if (resp['ResultCode'] == '00') {
        showDialog(context: context,
            builder: (context) =>
                AlertDialog(
                    title: new Text('上传报告成功')
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
  }

  void initState(){
    _dropDownMenuItems = getDropDownMenuItems(_serviceResults);
    _dropDownMenuSources = getDropDownMenuItems(_sources);
    _currentResult = _dropDownMenuItems[0].value;
    _currentSource = _dropDownMenuSources[0].value;
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

  Column buildField(String label, TextEditingController controller) {
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

  Row buildImageRow(List imageList) {
    List<Widget> _list = [];

    if (imageList.length >0 ){
      for(var image in imageList) {
        _list.add(
            new Container(
              width: 100.0,
              child: Image.file(image),
            )
        );
      }
    } else {
      _list.add(new Container());
    }

    _list.add(new IconButton(icon: Icon(Icons.add_a_photo), onPressed: () {
      getImage();
    }));

    return new Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: _list
    );
  }

  List<Widget> buildAccessory() {
    List<Widget> _list = [];
    var _name = new TextEditingController();
    var _vendor = new TextEditingController();
    var _number = new TextEditingController();
    var _price = new TextEditingController();
    var _amount = new TextEditingController();
    var _imageNew;
    var _imagePre;
    var _numberPre =  new TextEditingController();

    void saveAccessory(Map accessory) async {
//      if (_imageNew == null || _imagePre == null) {
//        return;
//      }
//      var _newByte = await _imageNew.readAsBytes();
//      var imageNew = base64Encode(_newByte);
//      var _oldByte = await _imagePre.readAsBytes();
//      var imageOld = base64Encode(_oldByte);
//      var data = {
//        'Name': _name.text,
//        'Source': {
//          'Name': _currentSource,
//          'ID': AppConstants.AccessorySourceType[_currentSource]
//        },
//        'Supplier': {
//          'Name': _vendor.text
//        },
//        'NewSerialCode': _number.text,
//        'OldSerialCode': _numberPre.text,
//        'Qty': _amount.text,
//        'Amount': _price.text,
//        'FileInfos': [
//          {
//            'FileName': _imageNew.path,
//            'ID': 0,
//            'FileType': 1,
//            'FileContent': imageNew
//          },
//          {
//            'FileName': _imagePre.path,
//            'ID': 0,
//            'FileType': 1,
//            'FileContent': imageOld
//          },
//        ]
//      };
      setState(() {
        _accessory.add(accessory);
      });
    }

    void _addAccessory() async {
      showDialog(context: context,
        builder: (context) => SimpleDialog(
          title: new Text('新增零件'),
          contentPadding: EdgeInsets.all(8.0),
          children: <Widget>[
            buildField('名称', _name),
            BuildWidget.buildDropdown('来源', _currentSource, _dropDownMenuSources, changedDropDownSource),
            _currentSource=='外部供应商'?buildField('外部供应商', _vendor):new Container(),
            buildField('新装编号', _number),
            buildField('新装部件金额（元/件）', _price),
            buildField('数量', _amount),
            new Text('附件'),
            new Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                new IconButton(icon: Icon(Icons.add_a_photo), onPressed: () async {
                  _imageNew = await ImagePicker.pickImage(
                      source: ImageSource.camera,
                      maxWidth: 800.0
                  );
                }),
                _imageNew==null?new Container():new Container(width: 100.0, child: new Image.file(_imageNew),)
              ],
            ),
            buildField('拆下编号', _numberPre),
            new Text('附件'),
            new Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                new IconButton(icon: Icon(Icons.add_a_photo), onPressed: () async {
                  _imagePre = await ImagePicker.pickImage(
                      source: ImageSource.camera,
                      maxWidth: 800.0
                  );
                }),
                _imagePre==null?new Container():new Container(width: 100.0, child: new Image.file(_imagePre),)
              ],
            ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                new RaisedButton(
                  onPressed: () {
                    //saveAccessory();
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: EdgeInsets.all(12.0),
                  color: new Color(0xff2E94B9),
                  child: Text('保存', style: TextStyle(color: Colors.white)),
                ),
                new RaisedButton(
                  onPressed: () {
                    //uploadReport();
                    Navigator.of(context).pop();
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: EdgeInsets.all(12.0),
                  color: new Color(0xff2E94B9),
                  child: Text('取消', style: TextStyle(color: Colors.white)),
                ),
              ],
            )
          ],
        )
      );
    }
    _list.add(new Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        new Text('新增零件'),
        new IconButton(icon: Icon(Icons.add), onPressed: () async {
          //_addAccessory();
          final _acc = await Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
            return new EngineerReportAccessory();
          }));
          print(_acc);
          if (_acc != null) {
            saveAccessory(_acc);
          }
        })
      ],
    )); 
    if (_accessory != null) {
      for(var _acc in _accessory) {
        var _accList = [
          BuildWidget.buildRow('名称', _acc['Name']),
          BuildWidget.buildRow('来源', _acc['Source']['Name']),
          BuildWidget.buildRow('外部供应商', _acc['Supplier']['Name']),
          BuildWidget.buildRow('新装零件编号', _acc['NewSerialCode']),
          BuildWidget.buildRow('金额（元/件）', _acc['Amount']),
          BuildWidget.buildRow('数量', _acc['Qty']),
          new Divider()
        ];
        _list.addAll(_accList);
      }
    }
    return _list;
  }

  List<ExpansionPanel> buildExpansion() {
    var _list = [
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
            children: buildEquipments(),
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
              BuildWidget.buildRow('派工单编号', _dispatch['OID']),
              BuildWidget.buildRow('派工类型', _dispatch['RequestType']['Name']),
              BuildWidget.buildRow('工程师姓名', _dispatch['Engineer']['Name']),
              BuildWidget.buildRow('处理方式', _dispatch['Request']['DealType']['Name']),
              BuildWidget.buildRow('紧急程度', _dispatch['Request']['Priority']['Name']),
              BuildWidget.buildRow('机器状态', _dispatch['MachineStatus']['Name']),
              BuildWidget.buildRow('出发时间', AppConstants.TimeForm(_dispatch['ScheduleDate'], 'yyyy-mm-dd')),
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
            title: new Align(
                child: Text('作业报告信息',
                  style: new TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.w400
                  ),
                ),
                alignment: Alignment(-1.3, 0)
            ),
          );
        },
        body: new Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              buildField('发生频率：', _frequency),
              buildField('故障描述：', _description),
              buildField('系统状态：', _status),
              buildField('错误代码：', _code	),
              buildField('分析原因：', _analysis),
              buildField('处理方法：', _solution),
              buildField('未解决备注：', _unsolved),
              _isDelayed?buildField('误工说明：', _delay):new Container(),
              BuildWidget.buildDropdown('作业结果', _currentResult, _dropDownMenuItems, changedDropDownMethod),
              new Padding(
                padding: EdgeInsets.symmetric(vertical: 5.0),
                child: new Text('上传附件',
                  style: new TextStyle(
                      fontSize: 16.0,
                      color: Colors.grey
                  ),
                ),
              ),
              buildImageRow(_imageList)
            ],
          ),
        ),
        isExpanded: _isExpandedAssign,
      ),
    ];
    if (_dispatch['RequestType']['ID'] == 1) {
      _list.add(
        new ExpansionPanel(
          headerBuilder: (context, isExpanded) {
            return ListTile(
                leading: new Icon(Icons.settings,
                  size: 24.0,
                  color: Colors.blue,
                ),
                title: new Align(
                    child: Text('零配件信息',
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
    var _equipments = _dispatch['Request']['Equipments'];
    List<Widget> _list = [];
    for(var _equipment in _equipments) {
      var equipList = [
        BuildWidget.buildRow('系统编号:', _equipment['OID']??''),
        BuildWidget.buildRow('名称', _equipment['Name']??''),
        BuildWidget.buildRow('型号', _equipment['EquipmentCode']??''),
        BuildWidget.buildRow('序列号', _equipment['SerialCode']??''),
        BuildWidget.buildRow('使用科室', _equipment['Department']['Name']??''),
        BuildWidget.buildRow('安装地点', _equipment['InstalSite']??''),
        BuildWidget.buildRow('设备厂商', _equipment['Manufacturer']['Name']??''),
        BuildWidget.buildRow('资产等级', _equipment['AssetLevel']['Name']??''),
        BuildWidget.buildRow('维保状态', _equipment['WarrantyStatus']??''),
        BuildWidget.buildRow('服务范围', _equipment['ContractScope']['Name']??''),
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
            widget.status==2||widget.status==3?'查看报告':'上传报告'
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
          new Icon(Icons.face),
          new Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 19.0),
            child: const Text('武田信玄'),
          ),
        ],
      ),
      body: _dispatch.isEmpty?new Center(child: new SpinKitRotatingPlain(color: Colors.blue),):new Padding(
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
              new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  new RaisedButton(
                    onPressed: () {
                      uploadReport();
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: EdgeInsets.all(12.0),
                    color: new Color(0xff2E94B9),
                    child: Text('上传报告', style: TextStyle(color: Colors.white)),
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
