import 'package:flutter/material.dart';
import 'package:atoi/pages/reports/equipment/equipment_assets.dart';
import 'package:atoi/pages/reports/equipment/equipment_barchart.dart';
import 'package:atoi/pages/reports/equipment/equipment_linechart.dart';
import 'package:atoi/pages/reports/equipment/equipment_linechart_a.dart';
import 'package:atoi/pages/reports/service/service_barchart.dart';
import 'package:atoi/pages/reports/service/service_barchart_a.dart';
import 'package:atoi/pages/reports/service/service_barchart_line.dart';
import 'package:atoi/pages/reports/service/service_linechart.dart';
import 'package:atoi/pages/reports/service/service_linechart_a.dart';
import 'package:atoi/pages/reports/service/service_linechart_b.dart';

class ReportList extends StatefulWidget {
  _ReportListState createState() => _ReportListState();
}

class _ReportListState extends State<ReportList> {

  void initState() {
    super.initState();
  }

  void showBottomAll(List items) {
    List<Widget> _list = [];

    for(var item in items) {
      _list.add(
        Card(
          child: ListTile(
            title: new Center(
              child: Text(item['name'],
                style: new TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20.0,
                    color: Colors.blue
                ),
              ),
            ),
            onTap: () {
              switch (item['type']) {
                case 'barchart_1':
                  Navigator.of(context).push(new MaterialPageRoute(builder: (context) => new EquipmentBarchart(chartName: item['name'], endpoint: item['endpoint'],)));
                  break;
                case 'barchart_2':
                  Navigator.of(context).push(new MaterialPageRoute(builder: (context) => new EquipmentAssets(chartName: item['name'], endpoint: item['endpoint'],)));
                  break;
                case 'linechart_1':
                  Navigator.of(context).push(new MaterialPageRoute(builder: (context) => new EquipmentLinechart(chartName: item['name'], endpoint: item['endpoint'],)));
                  break;
                case 'linechart_2':
                  Navigator.of(context).push(new MaterialPageRoute(builder: (context) => new EquipmentLinechartA(chartName: item['name'], endpoint: item['endpoint'],)));
                  break;
                case 's_barchart_1':
                  Navigator.of(context).push(new MaterialPageRoute(builder: (context) => new ServiceBarchart(chartName: item['name'], endpoint: item['endpoint'],)));
                  break;
                case 's_barchart_2':
                  Navigator.of(context).push(new MaterialPageRoute(builder: (context) => new ServiceAssets(chartName: item['name'], endpoint: item['endpoint'],)));
                  break;
                case 's_barchart_line':
                  Navigator.of(context).push(new MaterialPageRoute(builder: (context) => new ServiceBarchartLine(chartName: item['name'], endpoint: item['endpoint'],)));
                  break;
                case 's_linechart_1':
                  Navigator.of(context).push(new MaterialPageRoute(builder: (context) => new ServiceLinechart(chartName: item['name'], endpoint: item['endpoint'],)));
                  break;
                case 's_linechart_2':
                  Navigator.of(context).push(new MaterialPageRoute(builder: (context) => new ServiceLinechartA(chartName: item['name'], endpoint: item['endpoint'],)));
                  break;
                case 's_linechart_3':
                  Navigator.of(context).push(new MaterialPageRoute(builder: (context) => new ServiceLinechartB(chartName: item['name'], endpoint: item['endpoint'],)));
                  break;
              }
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
                  {
                    'name': '设备数量',
                    'type': 'barchart_1',
                    'endpoint': 'EquipmentCountReport'
                  },
                  {
                    'name': '设备增长率',
                    'type': 'linechart_2',
                    'endpoint': 'EquipmentRatioReport'
                  },
                ];
                showBottomAll(_list);
              },
            ),
            new Divider(color: Color(0xffEBEEF5), height: 2.0,),
            new ListTile(
              leading: Icon(Icons.assignment_late, color: Color(0xff2F5C85),),
              title: new Text('设备故障报表'),
              onTap: () {
                var _list = [
                  {
                    'name': '设备故障时间(天)',
                    'type': 'barchart_2',
                    'endpoint': 'EquipmentRepairTimeDayReport'
                  },
                  {
                    'name': '设备故障时间(小时)',
                    'type': 'barchart_2',
                    'endpoint': 'EquipmentRepairTimeHourReport'
                  },
                  {
                    'name': '设备故障率',
                    'type': 'linechart_1',
                    'endpoint': 'EquipmentRapirRatioReport'
                  },
                  {
                    'name': '设备故障率同比',
                    'type': 'linechart_2',
                    'endpoint': 'FailureRatioReport'
                  },
                ];
                showBottomAll(_list);
              },
            ),
            new Divider(color: Color(0xffEBEEF5),),
            new ListTile(
              leading: Icon(Icons.settings_power, color: Color(0xff2F5C85),),
              title: new Text('设备开机报表'),
              onTap: () {
                var _list = [
                  {
                    'name': '设备开机率',
                    'type': 'linechart_1',
                    'endpoint': 'EquipmentBootRatioReport'
                  },
                  {
                    'name': '设备开机率同比',
                    'type': 'linechart_2',
                    'endpoint': 'BootRatioReport'
                  },
                ];
                showBottomAll(_list);
              },
            ),
            new Divider(color: Color(0xffEBEEF5),),
            new ListTile(
              leading: Icon(Icons.account_balance, color: Color(0xff2F5C85),),
              title: new Text('设备资产报表'),
              onTap: () {
                var _list = [
                  {
                    'name': '设备采购价格',
                    'type': 'barchart_2',
                    'endpoint': 'EquipmentPurchase'
                  },
                  {
                    'name': '服务合同金额',
                    'type': 'barchart_2',
                    'endpoint': 'ContractAmount'
                  },
                  {
                    'name': '服务合同年限',
                    'type': 'barchart_2',
                    'endpoint': 'ContractYears'
                  },
                  {
                    'name': '设备折旧剩余年限',
                    'type': 'barchart_2',
                    'endpoint': 'DepreciationYears'
                  },
                  {
                    'name': '设备折旧率',
                    'type': 'barchart_2',
                    'endpoint': 'DepreciationRate'
                  },
                  {
                    'name': '设备折旧费用',
                  },
                  {
                    'name': '设备资产价值',
                  },
                ];
                showBottomAll(_list);
              },
            ),
            new Divider(color: Color(0xffEBEEF5),),
            new ListTile(
              leading: Icon(Icons.pageview, color: Color(0xff2F5C85),),
              title: new Text('设备检查报表'),
              onTap: () {
                var _list = [
                  {
                    'name': '设备检查人次',
                    'type': 'barchart_1',
                    'endpoint': 'ServiceCountReport'
                  },
                  {
                    'name': '设备检查费用',
                    'type': 'depreciation_rate'
                  },
                  {
                    'name': '设备检查收入',
                    'type': 'barchart_2',
                    'endpoint': 'EquipmentSumIncome'
                  },
                ];
                showBottomAll(_list);
              },
            ),
            new Divider(color: Color(0xffEBEEF5),),
            new ListTile(
              leading: Icon(Icons.arrow_upward, color: Color(0xff2F5C85),),
              title: new Text('支出报表'),
              onTap: () {
                var _list = [
                  {
                    'name': '设备零配件花费总额',
                    'type': 'barchart_1',
                    'endpoint': 'PartExpenditureReport'
                  },
                  {
                    'name': '设备备件花费总额',
                    'type': ''
                  },
                  {
                    'name': '设备服务人工费用总额',
                    'type': ''
                  },
                  {
                    'name': '设备总支出',
                    'type': ''
                  },
                  {
                    'name': '设备总支出同比',
                    'type': 'linechart_2',
                    'endpoint': 'ExpenditureRatioReport'
                  },
                ];
                showBottomAll(_list);
              },
            ),
            new Divider(color: Color(0xffEBEEF5),),
            new ListTile(
              leading: Icon(Icons.arrow_downward, color: Color(0xff2F5C85), textDirection: TextDirection.ltr,),
              title: new Text('收入报表'),
              onTap: () {
                var _list = [
                  {
                    'name': '设备总收入',
                    'type': 'barchart_1',
                    'endpoint': 'EquipmentIncomeReport'
                  },
                  {
                    'name': '设备总收入同比',
                    'type': 'linechart_2',
                    'endpoint': 'EquipmentIncomeReport'
                  },
                ];
                showBottomAll(_list);
              },
            ),
            new Divider(color: Color(0xffEBEEF5),),
            new ListTile(
              leading: Icon(Icons.swap_vert, color: Color(0xff2F5C85),),
              title: new Text('收支报表'),
              onTap: () {
                var _list = [
                  {
                    'name': '设备总收支比',
                    'type': 'linechart_2',
                    'endpoint': 'IncomeRatioExpenditureReport'
                  },
                ];
                showBottomAll(_list);
              }
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
              onTap: () {
                var _list = [
                  {
                    'name': '派工响应时间',
                    'type': 's_barchart_2',
                    'endpoint': 'ResponseDispatchTime'
                  },
                  {
                    'name': '派工执行率',
                    'type': 's_linechart_1',
                    'endpoint': 'DispatchRatio?status=4'
                  },
                  {
                    'name': '服务合格率',
                    'type': 's_barchart_line',
                    'endpoint': 'RequestFinishedRateReport'
                  },
                  {
                    'name': '服务时间达标率',
                    'type': 's_linechart_2',
                    'endpoint': 'PassServiceRatioReport'
                  },
                ];
                showBottomAll(_list);
              },
            ),
            new Divider(color: Color(0xffEBEEF5), height: 2.0,),
            new ListTile(
              leading: Icon(Icons.speaker_phone, color: Color(0xff2F5C85),),
              title: new Text('维修请求报表'),
              onTap: () {
                var _list = [
                  {
                    'name': '维修请求数量统计',
                    'type': 's_barchart_1',
                    'endpoint': 'ReportRequestCount?requestType=1&status=0'
                  },
                  {
                    'name': '维修请求未关闭数量',
                    'type': 's_barchart_1',
                    'endpoint': 'ReportRequestCount?requestType=1&status=1'
                  },
                  {
                    'name': '维修请求未响应数量',
                    'type': 's_barchart_1',
                    'endpoint': 'ReportRequestCount?requestType=1&status=2'
                  },
                  {
                    'name': '维修请求已关闭数量',
                    'type': 's_barchart_1',
                    'endpoint': 'ReportRequestCount?requestType=1&status=3'
                  },
                  {
                    'name': '维修请求增长率',
                    'type': 's_linechart_2',
                    'endpoint': 'RepairRequestGrowthRatioReport'
                  },
                  {
                    'name': '维修请求响应率',
                    'type': 's_linechart_1',
                    'endpoint': 'RequestRatioReport?requestType=1&status=4'
                  },
                  {
                    'name': '维修请求响应时间',
                    'type': 's_barchart_2',
                    'endpoint': 'RepairResponseTimeReport?requestType=1'
                  },
                ];
                showBottomAll(_list);
              },
            ),
            new Divider(color: Color(0xffEBEEF5),),
            new ListTile(
              leading: Icon(Icons.build, color: Color(0xff2F5C85),),
              title: new Text('设备维修方式报表'),
              onTap: () {
                var _list = [
                  {
                    'name': '设备自修率',
                    'type': 's_linechart_2',
                    'endpoint': 'RepairRatioReport?requestType=1&status=3'
                  },
                  {
                    'name': '设备供应商维修率',
                    'type': 's_linechart_2',
                    'endpoint': 'Supplier_RepairRatioReport?requestType=1&status=3'
                  },
                ];
                showBottomAll(_list);
              },
            ),
            new Divider(color: Color(0xffEBEEF5),),
            new ListTile(
              leading: Icon(Icons.assignment_turned_in, color: Color(0xff2F5C85),),
              title: new Text('保养请求报表'),
              onTap: () {
                var _list = [
                  {
                    'name': '设备实际保养数量',
                    'type': 's_barchart_1',
                    'endpoint': 'ReportRequestCount?requestType=2&status=3'
                  },
                  {
                    'name': '设备计划保养数量',
                    'type': 's_barchart_1',
                    'endpoint': 'ReportRequestCount?requestType=2&status=0'
                  },
                  {
                    'name': '设备保养率',
                    'type': 's_linechart_1',
                    'endpoint': 'RequestRatioReport?requestType=2&status=3'
                  },
                  {
                    'name': '设备供应商保养数',
                    'type': 's_barchart_1',
                    'endpoint': 'ResultCount_supplierReport?requestType=2&status=3'
                  },
                  {
                    'name': '设备内部保养数',
                    'type': 's_barchart_1',
                    'endpoint': 'ResultCount_self?requestType=2&status=3'
                  },
                ];
                showBottomAll(_list);
              },
            ),
            new Divider(color: Color(0xffEBEEF5),),
            new ListTile(
              leading: Icon(Icons.group, color: Color(0xff2F5C85),),
              title: new Text('巡检请求报表'),
              onTap: () {
                var _list = [
                  {
                    'name': '设备实际巡检数量',
                    'type': 's_barchart_1',
                    'endpoint': 'ReportRequestCount?requestType=4&status=3'
                  },
                  {
                    'name': '设备计划巡检数量',
                    'type': 's_barchart_1',
                    'endpoint': 'ReportRequestCount?requestType=4&status=0'
                  },
                  {
                    'name': '设备巡检率',
                    'type': 's_linechart_1',
                    'endpoint': 'RequestRatioReport?requestType=4&status=3'
                  },
                ];
                showBottomAll(_list);
              },
            ),
            new Divider(color: Color(0xffEBEEF5),),
            new ListTile(
              leading: Icon(Icons.store_mall_directory, color: Color(0xff2F5C85),),
              title: new Text('强检请求报表'),
              onTap: () {
                var _list = [
                  {
                    'name': '设备实际强检数量',
                    'type': 's_barchart_1',
                    'endpoint': 'ReportRequestCount?requestType=3&status=3'
                  },
                  {
                    'name': '设备未完成强检数量',
                    'type': 's_barchart_1',
                    'endpoint': 'ReportRequestCount?requestType=3&status=1'
                  },
                  {
                    'name': '设备待召回请求数量',
                    'type': 's_barchart_1',
                    'endpoint': 'ReportRequestCount?requestType=-1&status=1'
                  },
                  {
                    'name': '设备计划强检数量',
                    'type': 's_barchart_1',
                    'endpoint': 'ReportRequestCount?requestType=3&status=0'
                  },
                  {
                    'name': '设备强检率',
                    'type': 's_linechart_1',
                    'endpoint': 'RequestRatioReport?requestType=3&status=3'
                  },
                ];
                showBottomAll(_list);
              },
            ),
            new Divider(color: Color(0xffEBEEF5),),
            new ListTile(
              leading: Icon(Icons.visibility, color: Color(0xff2F5C85),),
              title: new Text('校正请求报表'),
              onTap: () {
                var _list = [
                  {
                    'name': '设备实际校正数量',
                    'type': 's_barchart_1',
                    'endpoint': 'ReportRequestCount?requestType=5&status=3'
                  },
                  {
                    'name': '设备计划校正数量',
                    'type': 's_barchart_1',
                    'endpoint': 'ReportRequestCount?requestType=5&status=0'
                  },
                  {
                    'name': '设备校正率',
                    'type': 's_linechart_1',
                    'endpoint': 'RequestRatioReport?requestType=5&status=3'
                  },
                ];
                showBottomAll(_list);
              },
            ),
            new Divider(color: Color(0xffEBEEF5),),
            new ListTile(
              leading: Icon(Icons.phonelink_ring, color: Color(0xff2F5C85),),
              title: new Text('调拨请求报表'),
              onTap: () {
                var _list = [
                  {
                    'name': '设备调拨数量',
                    'type': 's_barchart_1',
                    'endpoint': 'ReportRequestCount?requestType=10&status=0'
                  },
                  {
                    'name': '设备调拨响应率',
                    'type': 's_linechart_1',
                    'endpoint': 'RequestRatioReport?requestType=10&status=4'
                  },
                  {
                    'name': '设备调拨响应时间',
                    'type': 's_barchart_2',
                    'endpoint': 'RepairResponseTimeReport?requestType=10'
                  },
                  {
                    'name': '设备调拨完成率',
                    'type': 's_linechart_1',
                    'endpoint': 'RequestRatioReport?requestType=10&status=3'
                  },
                ];
                showBottomAll(_list);
              },
            ),
            new Divider(color: Color(0xffEBEEF5),),
          ],
        )
    );
  }
}