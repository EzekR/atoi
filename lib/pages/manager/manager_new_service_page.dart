import 'package:flutter/material.dart';
import 'package:atoi/widgets/search_bar.dart';
import 'package:atoi/models/models.dart';
import 'package:scoped_model/scoped_model.dart';

class ManagerNewServicePage extends StatefulWidget{
  static String tag = 'manager-new-service-page';
  final String type;

  ManagerNewServicePage({this.type});

  _ManagerNewServicePageState createState() => new _ManagerNewServicePageState();
}

class _ManagerNewServicePageState extends State<ManagerNewServicePage> {

  var _isExpandedBasic = true;
  var _isExpandedDetail = false;
  var _isExpandedAssign = false;

  MainModel mainModel = MainModel();

  List _serviceResults = [
    '未知',
    '已知'
  ];

  List<DropdownMenuItem<String>> _dropDownMenuItems;
  String _currentResult;

  void initState(){
    _dropDownMenuItems = getDropDownMenuItems(_serviceResults);
    _currentResult = _dropDownMenuItems[0].value;

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
      _currentResult = selectedMethod;
    });
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

  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (context, child, mainModel) {
        print('page data:'+mainModel.result.toString());
        return new Scaffold(
          appBar: new AppBar(
            title: new Text('新增${widget.type}'),
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
              new IconButton(
                icon: Icon(Icons.search),
                color: Colors.white,
                iconSize: 30.0,
                onPressed: () =>
                    showSearch(context: context, delegate: SearchBarDelegate())
                ,
              ),
              new IconButton(
                  icon: Icon(Icons.crop_free),
                  color: Colors.white,
                  iconSize: 30.0,
                  onPressed: () {})
            ],
          ),
          body: new Padding(
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
                            children: <Widget>[
                              buildRow('设备编号：', mainModel.result['equipNo']),
                              buildRow('设备名称：', mainModel.result['name']),
                              buildRow('使用科室：', mainModel.result['department']),
                              buildRow('设备厂商：', mainModel.result['manufacturer']),
                              buildRow('资产等级：', mainModel.result['equipLevel']),
                              buildRow('设备型号：', mainModel.result['model']),
                              buildRow('安装地点：', mainModel.result['location']),
                              buildRow('保修状况：', mainModel.result['guarantee']),
                              new Padding(padding: EdgeInsets.symmetric(vertical: 8.0))
                            ],
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
                                  child: Text('请求详细信息',
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
                            children: <Widget>[
                              buildRow('类型：', widget.type),
                              buildRow('请求人：', '超级管理员'),
                              new Padding(
                                  padding: EdgeInsets.symmetric(vertical: 5.0),
                                  child: new Row(
                                    children: <Widget>[
                                      new Expanded(
                                        flex: 4,
                                        child: new Text(
                                          '主题：',
                                          style: new TextStyle(
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.w600
                                          ),
                                        ),
                                      ),
                                      new Expanded(
                                        flex: 6,
                                        child: new TextField(),
                                      )
                                    ],
                                  ),
                              ),
                              new Padding(
                                  padding: EdgeInsets.symmetric(vertical: 5.0),
                                  child: new Row(
                                    children: <Widget>[
                                      new Expanded(
                                        flex: 4,
                                        child: new Text(
                                          '故障分类：',
                                          style: new TextStyle(
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.w600
                                          ),
                                        ),
                                      ),
                                      new Expanded(
                                        flex: 6,
                                        child: new DropdownButton(
                                          value: _currentResult,
                                          items: _dropDownMenuItems,
                                          onChanged: changedDropDownMethod,
                                        ),
                                      )
                                    ],
                                  ),
                              ),
                              new Padding(padding: EdgeInsets.symmetric(vertical: 8.0))
                            ],
                          ),
                        ),
                        isExpanded: _isExpandedDetail,
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
                          showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('提交请求'),
                              )
                          );
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: EdgeInsets.all(12.0),
                        color: new Color(0xff2E94B9),
                        child: Text('提交请求', style: TextStyle(color: Colors.white)),
                      ),
                      new RaisedButton(
                        onPressed: () {
                          Navigator.of(context).pop;
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: EdgeInsets.all(12.0),
                        color: new Color(0xffD25565),
                        child: Text('返回主页', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  )
                ],

              ),
            ),
          )
        );
      },
    );
  }
}

