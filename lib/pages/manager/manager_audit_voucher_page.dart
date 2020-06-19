import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:atoi/utils/http_request.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:convert';
import 'package:atoi/utils/constants.dart';
import 'package:atoi/widgets/build_widget.dart';
import 'package:atoi/models/models.dart';
import 'package:fluttertoast/fluttertoast.dart';

/// 超管审核凭证页面类
class ManagerAuditVoucherPage extends StatefulWidget {
  static String tag = 'manager-audit-voucher-page';
  ManagerAuditVoucherPage({Key key, this.journalId, this.request, this.status}):super(key: key);
  final int journalId;
  final Map request;
  final int status;

  @override
  _ManagerAuditVoucherPageState createState() => new _ManagerAuditVoucherPageState();
}

class _ManagerAuditVoucherPageState extends State<ManagerAuditVoucherPage> {

  var _isExpandedBasic = true;
  var _isExpandedDetail = false;
  var _isExpandedAssign = false;
  var _isExpandedReq = false;
  List<bool> _expandList = [false, false, false, true];
  Map<String, dynamic> _dispatch = {};
  List _equipments = [];
  TextEditingController _comment = new TextEditingController();
  TextEditingController _follow = new TextEditingController();
  ConstantsModel model;
  ScrollController _scrollController = new ScrollController();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  List _serviceResults = [
    '完成',
    '待跟进'
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
  List<int> imageBytes;

  Map<String, dynamic> _journal = {};

  Future<Null> getJournal() async {
    var prefs = await _prefs;
    var userId = prefs.getInt('userID');
    var journalId = widget.journalId;
    var resp = await HttpRequest.request(
      '/DispatchJournal/GetDispatchJournal',
      method: HttpRequest.GET,
      params: {
        'userID': userId,
        'dispatchJournalId': journalId
      },
    );
    print(resp);
    if (resp['ResultCode'] == '00') {
      setState(() {
        _journal = resp['Data'];
        _currentResult = resp['Data']['ResultStatus']['Name'];
        _follow.text = resp['Data']['FollowProblem'];
        imageBytes = base64Decode(resp['Data']['FileContent']);
      });
    }
  }

  List<DropdownMenuItem<String>> _dropDownMenuItems;
  String _currentResult;

  List iterateMap(Map item) {
    var _list = [];
    item.forEach((key, val) {
      _list.add(key);
    });
    return _list;
  }

  void initDropdown() {
    _serviceResults = iterateMap(model.ResultStatusID);
    _dropDownMenuItems = getDropDownMenuItems(_serviceResults);
    _currentResult = _dropDownMenuItems[0].value;
  }

  void initState(){
    model = MainModel.of(context);
    getRole();
    initDropdown();
    getDispatch();
    getJournal();
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
      focusNode: _focusComment,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Expanded(
            flex: 4,
            child: new Text(
              labelText,
              style: new TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.justify,
            ),
          ),
          new Expanded(
            flex: 1,
            child: new Text(':',
              style: new TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w600
              ),
            ),
          ),
          new Expanded(
            flex: 5,
            child: new Text(
              defaultText,
              style: new TextStyle(
                  fontSize: 16.0,
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
                  fontSize: 16.0,
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
      setState(() {
        _dispatch = resp['Data'];
      });
      if (resp['Data']['Request']['Equipments'] != null) {
        setState(() {
          _equipments = resp['Data']['Request']['Equipments'];
        });
      }
    }
  }

  FocusNode _focusFollow = new FocusNode();

  Future<Null> approveJournal() async {
    setState(() {
      _expandList = _expandList.map((item) {
        return true;
      }).toList();
    });
    final SharedPreferences prefs = await _prefs;
    var UserId = await prefs.getInt('userID');
    if (_currentResult == '待跟进' && _follow.text.isEmpty) {
      showDialog(context: context,
          builder: (context) => CupertinoAlertDialog(
              title: new Text('待跟进问题不可为空')
          )
      ).then((result) => FocusScope.of(context).requestFocus(_focusFollow));
      return;
    }
    Map<String, dynamic> _data = {
      'userID': UserId,
      'dispatchJournalID': widget.journalId,
      'resultStatusID': model.ResultStatusID[_currentResult],
      'followProblem': _follow.text.toString(),
      'comments': _comment.text,
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
      '/DispatchJournal/ApproveDispatchJournal',
      method: HttpRequest.POST,
      data: _data
    );
    Fluttertoast.cancel();
    print(_response);
    if (_response['ResultCode'] == '00') {
      showDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: new Text('通过凭证'),
          )
      ).then((result) {
        Navigator.of(context, rootNavigator: true).pop(result);
      });
    } else {
      showDialog(context: context,
        builder: (context) => CupertinoAlertDialog(
          title: new Text(_response['ResultMessage'])
        )
      );
    }
  }

  FocusNode _focusComment = new FocusNode();

  Future<Null> rejectJournal() async {
    setState(() {
      _expandList = _expandList.map((item) {
        return true;
      }).toList();
    });
    final SharedPreferences prefs = await _prefs;
    var UserId = await prefs.getInt('userID');
    print(widget.journalId);
    if (_comment.text.isEmpty) {
      showDialog(context: context,
          builder: (context) => CupertinoAlertDialog(
              title: new Text('审批备注不可为空')
          )
      ).then((result) {
        _scrollController.jumpTo(1800);
        FocusScope.of(context).requestFocus(_focusComment);
      });
      return;
    }
    if (_currentResult =='待跟进' && _follow.text.isEmpty) {
      showDialog(context: context,
          builder: (context) => CupertinoAlertDialog(
              title: new Text('待跟进问题不可为空')
          )
      ).then((result) => FocusScope.of(context).requestFocus(_focusFollow));
      return;
    }
    Map<String, dynamic> _data = {
      'userID': UserId,
      'dispatchJournalID': widget.journalId,
      'resultStatusID': model.ResultStatusID[_currentResult],
      'followProblem': _follow.text.toString(),
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
        '/DispatchJournal/RejectDispatchJournal',
        method: HttpRequest.POST,
        data: _data
    );
    Fluttertoast.cancel();
    print(_response);
    if (_response['ResultCode'] == '00') {
      showDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: new Text('已退回'),
          )
      ).then((result) {
        Navigator.of(context, rootNavigator: true).pop();
      });
    } else {
      showDialog(context: context,
        builder: (context) => CupertinoAlertDialog(
          title: new Text(_response['ResultMessage']),
        )
      );
    }
  }

  List<ExpansionPanel> buildExpansion() {
    List<ExpansionPanel> _list = [];
    if (_dispatch.isNotEmpty&&_dispatch['Request']['RequestType']['ID'] != 14) {
      _list.add(
        new ExpansionPanel(
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
            );
          },
          body: new Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: new Column(
              children: _equipments.map((_equipment) => [
                BuildWidget.buildRow('系统编号', _equipment['OID']??''),
                BuildWidget.buildRow('资产编号', _equipment['AssetCode']??''),
                BuildWidget.buildRow('名称', _equipment['Name']??''),
                BuildWidget.buildRow('型号', _equipment['EquipmentCode']??''),
                BuildWidget.buildRow('序列号', _equipment['SerialCode']??''),
                BuildWidget.buildRow('设备厂商', _equipment['Manufacturer']['Name']??''),
                BuildWidget.buildRow('使用科室', _equipment['Department']['Name']??''),
                BuildWidget.buildRow('安装地点', _equipment['InstalSite']??''),
                BuildWidget.buildRow('维保状态', _equipment['WarrantyStatus']??''),
                BuildWidget.buildRow('服务范围', _equipment['ContractScope']['Name']??''),
                new Divider(),
              ]).toList().reduce((_listA, _listB) {
                _listA.addAll(_listB);
                return _listA;
              }),
            ),
          ),
          isExpanded: _expandList[0],
        ),
      );
    }

    _list.add(
      new ExpansionPanel(
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
      new ExpansionPanel(
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
              _dispatch['RequestType']['ID']!=14?BuildWidget.buildRow('机器状态', widget.request['MachineStatus']['Name']):new Container(),
              BuildWidget.buildRow('紧急程度', widget.request['Urgency']['Name']),
              BuildWidget.buildRow('出发时间',AppConstants.TimeForm(widget.request['ScheduleDate'], 'hh:mm')),
              BuildWidget.buildRow('工程师姓名', _dispatch['Engineer']['Name']??''),
              BuildWidget.buildRow('备注', _dispatch['LeaderComments']),
            ],
          ),
        ),
        isExpanded: _expandList[2],
      ),
      new ExpansionPanel(
        headerBuilder: (context, isExpanded) {
          return ListTile(
              leading: new Icon(Icons.perm_contact_calendar,
                size: 20.0,
                color: Colors.blue,
              ),
              title: Text('服务详情信息',
                style: new TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w400
                ),
              )
          );
        },
        body: new Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              BuildWidget.buildRow('服务凭证编号', _journal['OID']),
              BuildWidget.buildRow('故障现象/错误代码/事由', _journal['FaultCode']),
              BuildWidget.buildRow('工作内容', _journal['JobContent']),
              widget.status==3?BuildWidget.buildRow('服务结果', _currentResult):BuildWidget.buildDropdown('服务结果', _currentResult, _dropDownMenuItems, changedDropDownMethod, context: context),
              widget.status!=3&&_currentResult=='待跟进'?BuildWidget.buildInput('待跟进问题', _follow, focusNode: _focusFollow, required: true):new Container(),
              widget.status==3&&_currentResult=='待跟进'?BuildWidget.buildRow('待跟进问题', _follow.text):new Container(),
              BuildWidget.buildRow('建议留言', _journal['Advice']),
              BuildWidget.buildRow('客户姓名', _journal['UserName']??''),
              BuildWidget.buildRow('客户电话', _journal['UserMobile']??''),
              BuildWidget.buildRow('客户签名', ''),
              new Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  new Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                      width: 300.0,
                      height: 300.0,
                      child: BuildWidget.buildPhotoPageList(context, imageBytes),
                    )
                  ),
                ],
              ),
              widget.status==3?BuildWidget.buildRow('审批备注', _journal['FujiComments']??''):new Container()
            ],
          ),
        ),
        isExpanded: _expandList[3],
      ),
    ]);

    return _list;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(
            widget.status==3?'查看服务凭证':'审核服务凭证'
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
      body: _journal.isEmpty?new Center(child: SpinKitThreeBounce(color: Colors.blue,),):new Padding(
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
              widget.status==3?new Container():buildTextField('审批备注', _comment, true),
              SizedBox(height: 20.0),
              widget.status==3?new Container():new Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  new RaisedButton(
                    onPressed: () {
                      FocusScope.of(context).requestFocus(new FocusNode());
                      approveJournal();
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: EdgeInsets.all(12.0),
                    color: new Color(0xff2E94B9),
                    child: Text('通过凭证', style: TextStyle(color: Colors.white)),
                  ),
                  new RaisedButton(
                    onPressed: () {
                      FocusScope.of(context).requestFocus(new FocusNode());
                      rejectJournal();
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: EdgeInsets.all(12.0),
                    color: new Color(0xffD25565),
                    child: Text('退回凭证', style: TextStyle(color: Colors.white)),
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