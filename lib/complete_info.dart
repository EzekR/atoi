import 'package:flutter/material.dart';
import 'package:atoi/widgets/build_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:atoi/utils/http_request.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/cupertino.dart';

class CompleteInfo extends StatefulWidget {
  _CompleteInfoState createState() => new _CompleteInfoState();
}

class _CompleteInfoState extends State<CompleteInfo> {

  Map userInfo = {};
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  TextEditingController _name = new TextEditingController();
  TextEditingController _mobile = new TextEditingController();
  TextEditingController _email = new TextEditingController();
  TextEditingController _addr = new TextEditingController();
  TextEditingController _newPass = new TextEditingController();
  List<String> departmentNames = [];
  List<dynamic> departments = [];
  var currentDepart;
  var dropdownItems;
  var emailReg = RegExp(r"[w!#$%&'*+/=?^_`{|}~-]+(?:.[w!#$%&'*+/=?^_`{|}~-]+)*@(?:[w](?:[w-]*[w])?.)+[w](?:[w-]*[w])?");
  var emailValid = RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");


  Future<Null> getUserInfo() async {
    var prefs = await _prefs;
    var _userInfo = prefs.getString('userInfo');
    print(_userInfo);
    var decoded = jsonDecode(_userInfo);
    setState(() {
      userInfo = decoded;
      _name.text = decoded['Name'];
      _mobile.text = decoded['Mobile'];
      _email.text = decoded['Email'];
      _addr.text = decoded['Address'];
      currentDepart = decoded['Department']['Name']??'';
    });
  }
  void initState() {
    super.initState();
    getUserInfo();
    getDepartments();
  }

  Future<Null> getDepartments() async {
    var resp = await HttpRequest.request(
      '/User/GetDepartments',
      method: HttpRequest.GET
    );
    if (resp['ResultCode'] == '00') {
      for(var depart in resp['Data']) {
        departmentNames.add(depart['Name']);
      }
      setState(() {
        departments = resp['Data'];
        departmentNames = departmentNames;
      });
      dropdownItems = getDropDownMenuItems(departmentNames);
    }
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
      currentDepart = selectedMethod;
    });
  }

  Row buildDropdown(String title, String currentItem, List dropdownItems, Function changeDropdown) {
    return new Row(
      children: <Widget>[
        new Expanded(
          flex: 2,
          child: new Wrap(
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              new Text(
                title,
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
          flex: 8,
          child: new DropdownButton(
            value: currentItem,
            items: dropdownItems,
            onChanged: changeDropdown,
            isDense: true,
            isExpanded: true,
          ),
        )
      ],
    );
  }

  Future<Null> submit() async {
    var _depart = departments.firstWhere((depart) => depart['Name']==currentDepart, orElse: () => null);
    var _data = {
      'info': {
        'ID': userInfo['ID'],
        'Name': _name.text,
        'Mobile': _mobile.text,
        'Email': _email.text,
        'Address': _addr.text,
      }
    };
    var prefs = await _prefs;
    userInfo['Name'] = _name.text;
    userInfo['Mobile'] = _mobile.text;
    userInfo['Email'] = _email.text;
    userInfo['Address'] = _addr.text;
    userInfo['Department'] = _depart;
    prefs.setString('userInfo', jsonEncode(userInfo));
    if (_email.text.isNotEmpty&&!emailValid.hasMatch(_email.text)) {
      showDialog(context: context,
          builder: (context) => CupertinoAlertDialog(
            title: new Text('请输入正确的邮箱格式'),
          )
      );
      return;
    }
    if (_newPass.text.isNotEmpty) {
      _data['info']['LoginPwd'] = _newPass.text;
    }
    if (userInfo['Role']['ID'] == 4) {
      _data['info']['Department'] = _depart;
    }
    var resp = await HttpRequest.request(
      '/User/UpdateUserInfo',
      method: HttpRequest.POST,
      data: _data
    );
    if (resp['ResultCode'] == '00') {
      showDialog(context: context,
        builder: (context) => CupertinoAlertDialog(
          title: new Text('更新信息成功'),
        )
      ).then((result) {
        Navigator.of(context, rootNavigator: true).pop();
      });
    }
  }

  List<Widget> buildInfo() {
    List<Widget> _list = [
      new SizedBox(height: 20.0,),
      BuildWidget.buildRow('用户名/手机号', userInfo['LoginID']),
      new Divider(),
      BuildWidget.buildInput('姓名', _name, lines: 1),
      BuildWidget.buildInput('电话', _mobile, lines: 1),
      BuildWidget.buildInput('邮箱', _email, lines: 1),
      BuildWidget.buildInput('地址', _addr, lines: 1),
      BuildWidget.buildInput('新密码', _newPass, lines: 1),
      new Divider(),
      userInfo['Role']['ID']==4?buildDropdown('科室', currentDepart, dropdownItems, changedDropDownMethod):new Container(),
      new SizedBox(height: 20.0,),
      new Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          new RaisedButton(
            onPressed: () {
              submit();
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            padding: EdgeInsets.all(12.0),
            color: new Color(0xff2E94B9),
            child: Text(
                '提交信息',
                style: TextStyle(
                    color: Colors.white
                )
            ),
          )
        ],
      ),
      new SizedBox(height: 40,),
      new ListTile(
        title: new Text('服务器：${HttpRequest.API_PREFIX}'),
      )
    ];
    return _list;
  }
  
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('个人信息'),
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
      ),
      body: userInfo.isEmpty?new Center(child: new SpinKitRotatingPlain(color: Colors.blue),):Center(
        child: ListView(
            shrinkWrap: false,
            padding: EdgeInsets.only(left: 24.0, right: 24.0),
            children: buildInfo()
        ),
      ),
    );
  }
}