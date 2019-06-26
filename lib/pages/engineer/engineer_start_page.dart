import 'package:flutter/material.dart';

class EngineerStartPage extends StatefulWidget {
  static String tag = 'engineer-start-page';

  @override
  _EngineerStartPageState createState() => new _EngineerStartPageState();

}

class _EngineerStartPageState extends State<EngineerStartPage> {

  var _isExpandedBasic = false;
  var _isExpandedDetail = false;
  var _isExpandedAssign = true;

  void initState() {
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
                          buildRow('设备系统编号：', 'ZC00000001'),
                          buildRow('设备名称：', '医用磁共振设备'),
                          buildRow('使用科室：', '磁共振'),
                          buildRow('设备厂商：', '飞利浦'),
                          buildRow('资产等级：', '重要'),
                          buildRow('设备型号：', 'Philips 781-296'),
                          buildRow('安装地点：', '磁共振1室'),
                          buildRow('保修状况：', '保内'),
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
                          buildRow('类型：', '客户请求-报修'),
                          buildRow('主题：', '系统报错'),
                          buildRow('故障描述：', '系统报错，设备无法启动'),
                          buildRow('故障分类：', '未知'),
                          buildRow('请求人：', '马云'),
                          buildRow('处理方式：', '现场处理'),
                          buildRow('优先级：', '中'),
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
                          buildRow('派工类型：', '维修'),
                          buildRow('紧急程度：', '普通'),
                          buildRow('机器状态：', '正常'),
                          buildRow('工程师：', '张三'),
                          buildRow('主管备注：', '请立即解决'),
                          buildRow('出发日期：', '2019年6月20日14点'),
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
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('开始作业'),
                          )
                      );
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
