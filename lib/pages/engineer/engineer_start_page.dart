import 'package:flutter/material.dart';
import 'package:atoi/utils/http_request.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:atoi/utils/constants.dart';
import 'package:atoi/widgets/build_widget.dart';
import 'package:atoi/models/models.dart';
import 'package:flutter/cupertino.dart';

class EngineerStartPage extends StatefulWidget {
  static String tag = 'engineer-start-page';

  EngineerStartPage({Key key, this.dispatchId}):super(key: key);
  final int dispatchId;

  @override
  _EngineerStartPageState createState() => new _EngineerStartPageState();

}

class _EngineerStartPageState extends State<EngineerStartPage> {

  var _isExpandedBasic = false;
  var _isExpandedDetail = false;
  var _isExpandedAssign = true;
  ConstantsModel model;

  Map<String, dynamic> _dispatch = {};

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

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
  Future<Null> startDispatch() async {
    var prefs = await _prefs;
    var userID = prefs.getInt('userID');
    Map<String, dynamic> params = {
      'userID': userID,
      'dispatchID': widget.dispatchId
    };
    var resp = await HttpRequest.request(
      '/Dispatch/StartDispatch',
      method: HttpRequest.POST,
      data: params
    );
    print(resp);
    if (resp['ResultCode'] == '00') {
    showDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
      title: new Text('开始作业成功'),
      )
    ).then((result) {
      Navigator.of(context, rootNavigator: true).pop(result);
    });
    } else {
      showDialog(context: context,
        builder: (context) => CupertinoAlertDialog(title: new Text(resp['ResultMessage']),)
      );
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
        'dispatchId': dispatchId
      }
    );
    print(resp);
    if (resp['ResultCode'] == '00') {
      setState(() {
        _dispatch = resp['Data'];
      });
    }
  }

  void initState() {
    model = MainModel.of(context);
    getDispatch();
    getRole();
    super.initState();
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

  List<Widget> buildEquipments() {
    var _equipments = _dispatch['Request']['Equipments'];
    List<Widget> _list = [];
    for(var _equipment in _equipments) {
      var equipList = [
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
        new Divider()
      ];
      _list.addAll(equipList);
    }
    return _list;
  }

  List<ExpansionPanel> buildExpansion() {
    List<ExpansionPanel> _list = [];
    if (_dispatch['Request']['RequestType']['ID'] !=14) {
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
                  style: new TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.w400
                  ),
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
      );
    }
    _list.addAll(
      [
        new ExpansionPanel(
          headerBuilder: (context, isExpanded) {
            return ListTile(
                leading: new Icon(
                  Icons.description,
                  size: 24.0,
                  color: Colors.blue,
                ),
                title: new Text(
                  '请求详细信息',
                  style: new TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 22.0
                  ),
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
                BuildWidget.buildRow('服务申请编号', _dispatch['Request']['OID']),
                BuildWidget.buildRow('类型', _dispatch['Request']['SourceType']),
                _dispatch['Request']['RequestType']['ID']==14?BuildWidget.buildRow('主题', '${_dispatch['Request']['RequestType']['Name']}'):
                BuildWidget.buildRow('主题', '${_dispatch['Request']['EquipmentName']}--${_dispatch['Request']['RequestType']['Name']}'),
                BuildWidget.buildRow(model.Remark[_dispatch['Request']['RequestType']['ID']], _dispatch['Request']['FaultDesc']),
                _dispatch['Request']['RequestType']['ID']==2||_dispatch['Request']['RequestType']['ID']==3||_dispatch['Request']['RequestType']['ID']==7?BuildWidget.buildRow(model.RemarkType[_dispatch['Request']['RequestType']['ID']], _dispatch['Request']['FaultType']['Name']):new Container(),
                _dispatch['Request']['RequestType']['ID']==3?BuildWidget.buildRow('是否召回', _dispatch['Request']['IsRecall']?'是':'否'):new Container(),
                _dispatch['RequestType']['ID']==1?BuildWidget.buildRow('机器状态', _dispatch['MachineStatus']['Name']):new Container(),
                BuildWidget.buildRow('请求人', _dispatch['Request']['RequestUser']['Name']),
                BuildWidget.buildRow('处理方式', _dispatch['Request']['DealType']['Name']),
                BuildWidget.buildRow('当前状态', _dispatch['Request']['Status']['Name']),
                BuildWidget.buildRow('请求来源', _dispatch['Request']['Source']['Name']),
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
                '派工内容',
                style: new TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.w400
                ),
              ),
              subtitle: Text('派工单编号: ${_dispatch['OID']}'),
            );
          },
          body: new Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                BuildWidget.buildRow('派工类型', _dispatch['RequestType']['Name']),
                BuildWidget.buildRow('派工单状态', _dispatch['Status']['Name']),
                BuildWidget.buildRow('紧急程度', _dispatch['Urgency']['Name']),
                BuildWidget.buildRow('机器状态', _dispatch['MachineStatus']['Name']),
                BuildWidget.buildRow('工程师姓名', _dispatch['Engineer']['Name']),
                BuildWidget.buildRow('主管备注', _dispatch['LeaderComments']),
                BuildWidget.buildRow('出发时间', DateTime.tryParse(_dispatch['ScheduleDate']).toString().split(':00.000')[0]),
              ],
            ),
          ),
          isExpanded: _isExpandedAssign,
        ),
      ]
    );
    return _list;
  }

  @override
  Widget build(BuildContext context){
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('服务工单信息'),
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
                      _dispatch['Request']['RequestType']['ID']==14?_isExpandedDetail=!isExpanded:_isExpandedBasic = !isExpanded;
                    } else {
                      if (index == 1) {
                        _dispatch['Request']['RequestType']['ID']==14?_isExpandedAssign=!isExpanded:_isExpandedDetail = !isExpanded;
                      } else {
                        _isExpandedAssign =!isExpanded;
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
                      startDispatch();
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: EdgeInsets.all(12.0),
                    color: new Color(0xff2E94B9),
                    child: Text(
                        '开始作业',
                        style: TextStyle(
                            color: Colors.white
                        )
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
