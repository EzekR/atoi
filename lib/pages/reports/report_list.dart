import 'package:flutter/material.dart';
import 'package:atoi/pages/reports/report_chart.dart';

class ReportList extends StatefulWidget {
  _ReportListState createState() => _ReportListState();
}

class _ReportListState extends State<ReportList> {

  void initState() {
    super.initState();
  }

  void showBottomModal(List items) {
    List<Widget> _list = [];

    for(var item in items) {
      _list.add(
          Card(
            child: ListTile(
              title: new Center(
                child: Text(item,
                  style: new TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 20.0,
                      color: Colors.blue
                  ),
                ),
              ),
              onTap: () {
                Navigator.of(context).push(new MaterialPageRoute(builder: (_) {
                  return new ReportChart();
                }));
              },
            ),
          ),
      );
    }

    showModalBottomSheet(
        context: context,
        builder: (context) {
          return new ListView(
            children: _list,
            shrinkWrap: true,
          );
        }
    );
  }

  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          leading: new Icon(Icons.menu),
          title: new Text('报表'),
          elevation: 0.7,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  new Color(0xff2D577E),
                  new Color(0xff4F8EAD)
                ],
              ),
            ),
          ),
        ),
        body: new ListView(
          children: <Widget>[
            new Container(
              decoration: BoxDecoration(
                color: Color.fromRGBO(47,92,133,0.20),
              ),
              child: new Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                child: new Row(
                  children: <Widget>[
                    new Text('设备绩效',
                      style: new TextStyle(
                        color: Color(0xff2D5972)
                      ),
                    )
                  ],
                ),
              ),
            ),
            new ListTile(
              leading: Icon(Icons.receipt, color: Color(0xff2F5C85),),
              title: new Text('设备数量报表'),
              onTap: () {
                var _list = [
                  '设备数量统计',
                  '设备数量增长率'
                ];
                showBottomModal(_list);
              },
            ),
            new Divider(color: Color(0xffEBEEF5), height: 2.0,),
            new ListTile(
              leading: Icon(Icons.assignment_late, color: Color(0xff2F5C85),),
              title: new Text('设备故障报表'),
            ),
            new Divider(color: Color(0xffEBEEF5),),
            new ListTile(
              leading: Icon(Icons.settings_power, color: Color(0xff2F5C85),),
              title: new Text('设备开机报表'),
            ),
            new Divider(color: Color(0xffEBEEF5),),
            new ListTile(
              leading: Icon(Icons.account_balance, color: Color(0xff2F5C85),),
              title: new Text('设备资产报表'),
            ),
            new Divider(color: Color(0xffEBEEF5),),
            new ListTile(
              leading: Icon(Icons.pageview, color: Color(0xff2F5C85),),
              title: new Text('设备检查报表'),
            ),
            new Divider(color: Color(0xffEBEEF5),),
            new ListTile(
              leading: Icon(Icons.open_in_browser, color: Color(0xff2F5C85),),
              title: new Text('支出报表'),
            ),
            new Divider(color: Color(0xffEBEEF5),),
            new ListTile(
              leading: Icon(Icons.open_in_browser, color: Color(0xff2F5C85),),
              title: new Text('收入报表'),
            ),
            new Divider(color: Color(0xffEBEEF5),),
            new ListTile(
              leading: Icon(Icons.swap_vert, color: Color(0xff2F5C85),),
              title: new Text('收支报表'),
            ),
            new Divider(color: Color(0xffEBEEF5),),
            new Container(
              decoration: BoxDecoration(
                color: Color.fromRGBO(47,92,133,0.20),
              ),
              child: new Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                child: new Row(
                  children: <Widget>[
                    new Text('服务绩效',
                      style: new TextStyle(
                          color: Color(0xff2D5972)
                      ),
                    )
                  ],
                ),
              ),
            ),
            new ListTile(
              leading: Icon(Icons.receipt, color: Color(0xff2F5C85),),
              title: new Text('客户请求报表'),
            ),
            new Divider(color: Color(0xffEBEEF5), height: 2.0,),
            new ListTile(
              leading: Icon(Icons.speaker_phone, color: Color(0xff2F5C85),),
              title: new Text('维修请求报表'),
            ),
            new Divider(color: Color(0xffEBEEF5),),
            new ListTile(
              leading: Icon(Icons.build, color: Color(0xff2F5C85),),
              title: new Text('设备维修方式报表'),
            ),
            new Divider(color: Color(0xffEBEEF5),),
            new ListTile(
              leading: Icon(Icons.assignment_turned_in, color: Color(0xff2F5C85),),
              title: new Text('保养请求报表'),
            ),
            new Divider(color: Color(0xffEBEEF5),),
            new ListTile(
              leading: Icon(Icons.group, color: Color(0xff2F5C85),),
              title: new Text('巡检请求报表'),
            ),
            new Divider(color: Color(0xffEBEEF5),),
            new ListTile(
              leading: Icon(Icons.store_mall_directory, color: Color(0xff2F5C85),),
              title: new Text('强检请求报表'),
            ),
            new Divider(color: Color(0xffEBEEF5),),
            new ListTile(
              leading: Icon(Icons.visibility, color: Color(0xff2F5C85),),
              title: new Text('校正请求报表'),
            ),
            new Divider(color: Color(0xffEBEEF5),),
            new ListTile(
              leading: Icon(Icons.phonelink_ring, color: Color(0xff2F5C85),),
              title: new Text('调拨请求报表'),
            ),
            new Divider(color: Color(0xffEBEEF5),),
          ],
        )
    );
  }
}