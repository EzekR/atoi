import 'package:flutter/material.dart';

class EngineerStartPage extends StatefulWidget {
  static String tag = 'engineer-start-page';

  @override
  _EngineerStartPageState createState() => new _EngineerStartPageState();

}

class _EngineerStartPageState extends State<EngineerStartPage> {

  var _isExpandedBasic = true;
  var _isExpandedDetail = false;
  var _isExpandedAssign = false;

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
            child: const Text('Jin'),
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
                          title: Text('设备基本信息')
                      );
                    },
                    body: new Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: new Column(
                        children: <Widget>[
                          buildTextField('设备系统编号', 'ZC00000001', false),
                          buildTextField('设备名称', '医用磁共振设备', false),
                          buildTextField('使用科室', '磁共振', false),
                          buildTextField('设备厂商', '飞利浦', false),
                          buildTextField('资产等级', '重要', false),
                          buildTextField('设备型号', 'Philips 781-296', false),
                          buildTextField('安装地点', '磁共振1室', false),
                          buildTextField('保修状况', '保内', false),
                        ],
                      ),
                    ),
                    isExpanded: _isExpandedBasic,
                  ),
                  new ExpansionPanel(
                    headerBuilder: (context, isExpanded) {
                      return ListTile(
                          title: Text('请求内容')
                      );
                    },
                    body: new Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: new Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          buildTextField('类型', '客户请求-报修', false),
                          buildTextField('主题', '系统报错', false),
                          buildTextField('故障描述', '系统报错，设备无法启动', false),
                          buildTextField('故障分类', '未知', false),
                          buildTextField('请求人', '马云', false),
                          buildTextField('处理方式', '现场处理', false),
                          buildTextField('优先级', '中', false),
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
                        title: Text('派工内容'),
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
                          buildTextField('派工类型', '维修', false),
                          buildTextField('紧急程度', '普通', false),
                          buildTextField('机器状态', '正常', false),
                          buildTextField('工程师', '张三', false),
                          buildTextField('主管备注', '请立即解决', false),
                          buildTextField('出发日期', '2019年6月20日14点', false),
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
                  new Expanded(
                    flex: 5,
                    child: new RaisedButton(
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
                      color: new Color(0xfffd5f00),
                      child: Text(
                          '开始作业',
                          style: TextStyle(
                            color: Colors.white
                          )
                      ),
                    ),
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
