import 'package:flutter/material.dart';
import 'package:atoi/utils/http_request.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

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

  Map<String, dynamic> _dispatch = {};

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<Null> startDispatch() async {
    var prefs = await _prefs;
    var userID = prefs.getInt('userID');
    Map<String, dynamic> params = {
      'userID': userID,
      'dispatchId': widget.dispatchId
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
      builder: (context) => AlertDialog(
      title: new Text('开始作业'),
      )
    ).then((result) {
      Navigator.of(context, rootNavigator: true).pop(result);
    });
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
    getDispatch();
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

  @override
  Widget build(BuildContext context){
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('派工单详情'),
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
                        _isExpandedAssign =!isExpanded;
                      }
                    }
                  });
                },
                children: [
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
                        children: <Widget>[
                          buildRow('设备系统编号：', _dispatch['Request']['Equipments'][0]['OID']),
                          buildRow('设备名称：', _dispatch['Request']['Equipments'][0]['Name']),
                          buildRow('使用科室：', _dispatch['Request']['Equipments'][0]['Department']['Name']),
                          buildRow('设备厂商：', _dispatch['Request']['Equipments'][0]['Manufacturer']['Name']),
                          buildRow('资产等级：', _dispatch['Request']['Equipments'][0]['AssetLevel']['Name']),
                          buildRow('设备型号：', _dispatch['Request']['Equipments'][0]['SerialCode']),
                          buildRow('保修状况：', _dispatch['Request']['Equipments'][0]['WarrantyStatus']),
                        ],
                      ),
                    ),
                    isExpanded: _isExpandedBasic,
                  ),
                  new ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return ListTile(
                          leading: new Icon(
                            Icons.description,
                            size: 24.0,
                            color: Colors.blue,
                          ),
                          title: new Text(
                            '请求内容',
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
                          buildRow('类型：', _dispatch['Request']['SourceType']),
                          buildRow('主题：', _dispatch['Request']['RequestType']['Name']),
                          buildRow('故障描述：', _dispatch['Request']['FaultDesc']),
                          buildRow('故障分类：', _dispatch['Request']['FaultType']['Name']),
                          buildRow('请求人：', _dispatch['Request']['RequestUser']['Name']),
                          buildRow('处理方式：', _dispatch['Request']['DealType']['Name']),
                          buildRow('优先级：', _dispatch['Request']['Priority']['Name']),
                          new Padding(
                            padding: EdgeInsets.symmetric(vertical: 5.0),
                            child: new Text('请求附件',
                              style: new TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.grey
                              ),
                            ),
                          ),
                          new Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              new Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Image.asset(
                                  'assets/mri.jpg',
                                  width: 200.0,
                                ),
                              ),
                            ],
                          ),
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
                        subtitle: Text('编号:PGD00000001'),
                      );
                    },
                    body: new Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: new Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          buildRow('派工类型：', _dispatch['RequestType']['Name']),
                          buildRow('紧急程度：', _dispatch['Urgency']['Name']),
                          buildRow('机器状态：', _dispatch['MachineStatus']['Name']),
                          buildRow('工程师：', _dispatch['Engineer']['Name']),
                          buildRow('主管备注：', _dispatch['LeaderComments']),
                          buildRow('出发日期：', _dispatch['ScheduleDate']),
                        ],
                      ),
                    ),
                    isExpanded: _isExpandedAssign,
                  ),
                ],
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
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: EdgeInsets.all(12.0),
                    color: Colors.indigo,
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
