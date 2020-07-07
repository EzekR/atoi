import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:atoi_charts/charts.dart';
import 'package:badges/badges.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:spider_chart/spider_chart.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:atoi/pages/superuser/superuser_home.dart';

class Dashboard extends StatefulWidget {
  _DashboardState createState() => new _DashboardState();
}

class _DashboardState extends State<Dashboard> {

  int currentTab = 0;
  int currentEvent = 0;
  bool isDetailPage = false;

  List<IncomeData> incomeData = [
    IncomeData(1, 100.0, -80.0, 0),
    IncomeData(2, 100.0, -80.0, 0),
    IncomeData(3, 80.0, -80.0, -20),
    IncomeData(4, 50, -50.0, -10),
    IncomeData(5, 100.0, -80.0, 0),
    IncomeData(6, 80.0, -80.0, -20),
    IncomeData(7, 50, -50.0, -10),
    IncomeData(8, 100.0, -80.0, 0),
    IncomeData(9, 80.0, -80.0, -20),
    IncomeData(10, 50, -50.0, -10),
    IncomeData(11, 40, -40.0, -40),
    IncomeData(12, 100.0, -80.0, 0),
    IncomeData(13, 40, -40.0, -40),
    IncomeData(14, 100.0, -80.0, 0),
    IncomeData(15, 40, -40.0, -40),
    IncomeData(16, 100.0, -80.0, 0),
    IncomeData(17, 80.0, -80.0, -20),
    IncomeData(18, 50, -50.0, -10),
    IncomeData(19, 40, -40.0, -40),
    IncomeData(20, 100.0, -80.0, 0),
  ];

  List<RequestData> requestData = [
    RequestData('1', 23, Color(0xff385A95)),
    RequestData('2', 20, Color(0xffCD6750)),
    RequestData('3', 12, Color(0xffD8A92E)),
    RequestData('4', 10, Color(0xff21C4BF)),
    RequestData('5', 3, Color(0xff3aab64)),
  ];

  void initState() {
    super.initState();
  }

  void showBottomSheet() {
    showModalBottomSheet(context: context, builder: (context) {
      return Container(
        height: 400,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
          color: Colors.white
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 22.0),
          child: Column(
            children: <Widget>[
              Container(
                height: 300,
                child: ListView(
                  children: <Widget>[
                    Container(
                      height: 64.0,
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: Color.fromRGBO(0, 0, 0, 0.1),
                                  width: 1.0
                              )
                          )
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '科室',
                            style: TextStyle(
                                fontSize: 17.0,
                                color: Colors.black
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      height: 64.0,
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: Color.fromRGBO(0, 0, 0, 0.1),
                                  width: 1.0
                              )
                          )
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            '收入',
                            style: TextStyle(
                                fontSize: 17.0,
                                color: Colors.black
                            ),
                          ),
                          Icon(
                            Icons.check,
                            color: Color(0xff39649C),
                            size: 18.0,
                          )
                        ],
                      ),
                    ),
                    Container(
                      height: 64.0,
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: Color.fromRGBO(0, 0, 0, 0.1),
                                  width: 1.0
                              )
                          )
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '支出',
                            style: TextStyle(
                                fontSize: 17.0,
                                color: Colors.black
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 50.0,
                child: Container(
                  width: 322.0,
                  height: 40.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(4.0)),
                    color: Color(0xff39649C)
                  ),
                  child: Center(
                    child: Text(
                      '确定',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16.0
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 24,
              )
            ],
          )
        ),
      );
    });
  }

  // top tab
  GestureDetector buildTab(String tabTitle, int index) {
    bool isActive = (index==currentTab);
    BoxDecoration _dec = new BoxDecoration(
      color: isActive?Colors.white:Color(0xff385A95),
      borderRadius: BorderRadius.circular(16.0),
      border: Border.all(
        color: Colors.white
      )
    );
    return new GestureDetector(
      onTap: () {
        setState(() {
          currentTab = index;
        });
      },
      child: new Container(
        height: 32.0,
        width: 75.0,
        decoration: _dec,
        child: Center(
          child: Text(
            tabTitle,
            style: TextStyle(
                color: isActive?Color(0xff385A95):Colors.white,
                fontSize: 12.0
            ),
          ),
        ),
      ),
    );
  }

  // info card
  Padding buildCard(Widget child) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 7.0),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Color.fromRGBO(3, 17, 62, 0.23),
                  blurRadius: 7
              ),
            ]
        ),
        child: child,
      ),
    );
  }

  // asset overview
  Padding buildAsset() {
    return new Padding(
      padding: EdgeInsets.all(23.0),
      child: Container(
        child: Column(
          children: <Widget>[
            Container(
              height: 66.0,
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 6,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(right: BorderSide(color: Color(0xffebebeb),))
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '设备数量(台)',
                            style: TextStyle(
                              color: Color(0xff666666),
                              fontSize: 11.0
                            ),
                          ),
                          SizedBox(
                            height: 8.0,
                          ),
                          Text(
                            '2,698',
                            style: TextStyle(
                              color: Color(0xff385A95),
                              fontSize: 24.0,
                              fontWeight: FontWeight.w600
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: Container(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(23.0, 0, 0, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              '设备金额(万元)',
                              style: TextStyle(
                                  color: Color(0xff666666),
                                  fontSize: 11.0
                              ),
                            ),
                            SizedBox(
                              height: 8.0,
                            ),
                            Text(
                              '26,983.45',
                              style: TextStyle(
                                  color: Color(0xff385A95),
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.w600
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Container(
              height: 23.0,
              decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xffebebeb),))
              ),
            ),
            SizedBox(
              height: 23.0,
            ),
            Container(
              height: 66.0,
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 6,
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border(right: BorderSide(color: Color(0xffebebeb),))
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '折旧率',
                            style: TextStyle(
                                color: Color(0xff666666),
                                fontSize: 11.0
                            ),
                          ),
                          SizedBox(
                            height: 8.0,
                          ),
                          Text(
                            '67.96%',
                            style: TextStyle(
                                color: Color(0xff385A95),
                                fontSize: 24.0,
                                fontWeight: FontWeight.w600
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: Container(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(23.0, 0, 0, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              '当年服务人次(万人)',
                              style: TextStyle(
                                  color: Color(0xff666666),
                                  fontSize: 11.0
                              ),
                            ),
                            SizedBox(
                              height: 8.0,
                            ),
                            Text(
                              '232.11',
                              style: TextStyle(
                                  color: Color(0xff385A95),
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.w600
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // department income overview
  Padding buildIncome() {
    return new Padding(
      padding: EdgeInsets.all(23.0),
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              child: Text(
                '科室收支概览',
                style: TextStyle(
                  color: Color(0xff1e1e1e),
                  fontSize: 17.0,
                  fontWeight: FontWeight.w600
                ),
              ),
            ),
            SizedBox(
              height: 9.0,
            ),
            Container(
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 6,
                    child: Row(
                      children: <Widget>[
                        Text(
                          '排序：',
                          style: TextStyle(
                            color: Color(0xff666666),
                            fontSize: 11.0
                          ),
                        ),
                        Container(
                          height: 24.0,
                          width: 95.0,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Color(0xff7597D3)
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(2.0))
                          ),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  '科室',
                                  style: TextStyle(
                                      color: Color(0xff666666),
                                      fontSize: 11.0
                                  ),
                                ),
                                Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Color(0xff666666),
                                  size: 14.0,
                                )
                              ],
                            ),
                          )
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Row(
                      children: <Widget>[
                        Text(
                          '筛选：',
                          style: TextStyle(
                              color: Color(0xff666666),
                              fontSize: 11.0
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            showBottomSheet();
                          },
                          child: Container(
                              height: 24.0,
                              width: 95.0,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Color(0xff7597D3)
                                  ),
                                  borderRadius: BorderRadius.all(Radius.circular(2.0))
                              ),
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      '科室',
                                      style: TextStyle(
                                          color: Color(0xff666666),
                                          fontSize: 11.0
                                      ),
                                    ),
                                    Icon(
                                      Icons.keyboard_arrow_down,
                                      color: Color(0xff666666),
                                      size: 14.0,
                                    )
                                  ],
                                ),
                              )
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 9.0,
            ),
            Container(
              child: Row(
                children: <Widget>[
                  Container(
                    height: 9.0,
                    width: 9.0,
                    color: Color(0xff86C7E6),
                  ),
                  SizedBox(
                    width: 4.0,
                  ),
                  Text(
                    '收入',
                    style: TextStyle(
                      color: Color(0xff666666),
                      fontSize: 10.0
                    ),
                  ),
                  SizedBox(
                    width: 15.0,
                  ),
                  Container(
                    height: 9.0,
                    width: 9.0,
                    color: Color(0xff39649C),
                  ),
                  SizedBox(
                    width: 4.0,
                  ),
                  Text(
                    '支出',
                    style: TextStyle(
                        color: Color(0xff666666),
                        fontSize: 10.0
                    ),
                  ),
                  SizedBox(
                    width: 15.0,
                  ),
                  Container(
                    height: 9.0,
                    width: 9.0,
                    color: Color(0xffD64040),
                  ),
                  SizedBox(
                    width: 4.0,
                  ),
                  Text(
                    '亏损',
                    style: TextStyle(
                        color: Color(0xff666666),
                        fontSize: 10.0
                    ),
                  ),
                  SizedBox(
                    width: 15.0,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 9.0,
            ),
            Container(
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '2,698',
                            style: TextStyle(
                              color: Color(0xff1e1e1e),
                              fontSize: 15.0,
                              fontWeight: FontWeight.w600
                            ),
                          ),
                          SizedBox(
                            height: 4.0,
                          ),
                          Text(
                            '总收入(万元)',
                            style: TextStyle(
                              color: Color(0xff666666),
                              fontSize: 10.0
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '+23.2%',
                            style: TextStyle(
                                color: Color(0xffD64040),
                                fontSize: 15.0,
                                fontWeight: FontWeight.w600
                            ),
                          ),
                          SizedBox(
                            height: 4.0,
                          ),
                          Text(
                            '同比',
                            style: TextStyle(
                                color: Color(0xff666666),
                                fontSize: 10.0
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '2,698.22',
                            style: TextStyle(
                                color: Color(0xff1e1e1e),
                                fontSize: 15.0,
                                fontWeight: FontWeight.w600
                            ),
                          ),
                          SizedBox(
                            height: 4.0,
                          ),
                          Text(
                            '总支出(万元)',
                            style: TextStyle(
                                color: Color(0xff666666),
                                fontSize: 10.0
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '-12.33%',
                            style: TextStyle(
                                color: Color(0xff33B850),
                                fontSize: 15.0,
                                fontWeight: FontWeight.w600
                            ),
                          ),
                          SizedBox(
                            height: 4.0,
                          ),
                          Text(
                            '同比',
                            style: TextStyle(
                                color: Color(0xff666666),
                                fontSize: 10.0
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 9.0,
            ),
            Container(
              height: 200.0,
              width: 400.0,
              child: buildIncomeChart(),
            )
          ],
        ),
      ),
    );
  }

  // income chart
  Container buildIncomeChart() {
    return Container(
      child: SfCartesianChart(
          borderWidth: 0,
          plotAreaBorderWidth: 0.0,
          borderColor: Colors.white,
          primaryXAxis: NumericAxis(
            isVisible: false,
            majorGridLines: MajorGridLines(width: 0.0),
            majorTickLines: MajorTickLines(width: 0.0),
          ),
          primaryYAxis: NumericAxis(
            isVisible: false,
            majorGridLines: MajorGridLines(width: 0.0),
            majorTickLines: MajorTickLines(width: 0.0),
          ),
          palette: <Color>[
            Color(0xff86C7E6),
            Color(0xff39649C),
            Color(0xffD64040)
          ],
          tooltipBehavior: TooltipBehavior(
              enable: true,
              activationMode: ActivationMode.singleTap,
              elevation: 100.0,
              shouldAlwaysShow: true,
              builder: (dynamic data, dynamic point, dynamic series,
                  int pointIndex, int seriesIndex) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      isDetailPage = true;
                    });
                  },
                  child: Container(
                    height: 90,
                    width: 350,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      color: Color.fromRGBO(0, 0, 0, 0.83),
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(12, 5, 5, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '影像科',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.0
                            ),
                          ),
                          SizedBox(
                            height: 8.0,
                          ),
                          Row(
                            children: <Widget>[
                              Expanded(
                                flex: 4,
                                child: Text(
                                  '设备数量：20',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11.0
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 6,
                                child: Text(
                                  '设备价值：2,000万',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11.0
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 8.0,
                          ),
                          Row(
                            children: <Widget>[
                              Expanded(
                                flex: 4,
                                child: Text(
                                  '收入：2,000万',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11.0
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 6,
                                child: Text(
                                  '支出：2,000万',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11.0
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
          ),
          series: <ChartSeries<IncomeData, double>>[
            StackedColumnSeries<IncomeData, double>(
                dataSource: incomeData,
                xValueMapper: (IncomeData sales, _) => sales.x,
                yValueMapper: (IncomeData sales, _) => sales.income
            ),
            StackedColumnSeries<IncomeData, double>(
                dataSource: incomeData,
                xValueMapper: (IncomeData sales, _) => sales.x,
                yValueMapper: (IncomeData sales, _) => sales.expense
            ),
            StackedColumnSeries<IncomeData, double>(
                dataSource: incomeData,
                xValueMapper: (IncomeData sales, _) => sales.x,
                yValueMapper: (IncomeData sales, _) => sales.net
            ),
          ]
      ),
    );
  }

  //request chart
  Container buildRequestChart() {
    return Container(
      child: SfCircularChart(
          annotations: <CircularChartAnnotation>[
            CircularChartAnnotation(
              widget: Container(
                  height: 100,
                  width: 100,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        height: 15.0,
                      ),
                      Row(
                        children: <Widget>[
                          SizedBox(
                            width: 20.0,
                          ),
                          Text(
                            '40',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 39.0,
                              fontWeight: FontWeight.w600
                            ),
                          ),
                          Text(
                            '件',
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Color(0xff666666)
                            ),
                          )
                        ],
                      ),
                      Text(
                        '今日总报修',
                        style: TextStyle(
                            fontSize: 14.0,
                            color: Color(0xff666666)
                        ),
                      )
                    ],
                  )
              ),
            )
          ],
          series: <CircularSeries>[
            DoughnutSeries<RequestData, String>(
                explode: true,
                explodeIndex: 0,
                dataSource: requestData,
                pointColorMapper:(RequestData data,  _) => data.color,
                xValueMapper: (RequestData data, _) => data.x,
                yValueMapper: (RequestData data, _) => data.count,
                innerRadius: '75%',
            ),
          ],
      ),
    );
  }

  //current request
  Padding buildRequest() {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.0, 14.0, 24.0, 30),
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              child: Text(
                '当日报修',
                style: TextStyle(
                  fontSize: 17.0,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff1e1e1e)
                ),
              ),
            ),
            Container(
              height: 250.0,
              child: buildRequestChart(),
            ),
            Container(
              child: Center(
                child: Text(
                  '放射科 今日报修数：10',
                  style: TextStyle(
                    color: Color(0xff1e1e1e),
                    fontSize: 13.0
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              height: 300.0,
              child: ListView(
                children: new List(10).map((val) {
                  return Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: Text(
                              '1',
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Color(0xff1B85E7),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 8,
                            child: Text(
                              '超声诊断仪【ZC00001】请求维修···',
                              style: TextStyle(
                                  color: Color(0xff1e1e1e),
                                  fontSize: 14.0
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Container(
                              height: 20,
                              width: 35,
                              decoration: BoxDecoration(
                                  color: Color(0xffD64040),
                                  borderRadius: BorderRadius.all(Radius.circular(4.0))
                              ),
                              child: Center(
                                child: Text(
                                  '待派工',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10.0
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 11.0,
                      ),
                    ],
                  );
                }).toList(),
              ),
            )
          ],
        ),
      ),
    );
  }

  Expanded buildEventIcon(IconData eventIcon, String count, int index, String eventTitle) {
    bool isActive = index==currentEvent;
    return Expanded(
      flex: 3,
      child: GestureDetector(
        onTap: () {
          setState(() {
            currentEvent = index;
          });
        },
        child: Column(
          children: <Widget>[
            Container(
              child: Badge(
                position: BadgePosition(
                    right: -14,
                    top: -14
                ),
                badgeContent: Text(
                  count,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 11
                  ),
                ),
                badgeColor: Color(0xffD64040),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                      color: isActive?Color(0xff385A95):Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(100)),
                      border: Border.all(
                        color: Color(0xff385A95)
                      )
                  ),
                  child: Center(
                    child: Icon(
                      eventIcon,
                      color: isActive?Colors.white:Color(0xff385A95),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 6.0,
            ),
            Container(
              child: Center(
                child: Text(
                  eventTitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: isActive?Color(0xff385A95):Color(0xff333333)
                  ),
                ),
              ),
            )
          ],
        )
      )
    );
  }

  // events
  Padding buildEventType() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      child: Container(
        child: Row(
          children: <Widget>[
            buildEventIcon(Icons.build, '10', 0, '紧急维修'),
            buildEventIcon(Icons.local_car_wash, '10', 1, '召回事件'),
            buildEventIcon(Icons.speaker_phone, '10', 2, '强检事件'),
            buildEventIcon(Icons.calendar_today, '10', 3, '超期事件'),
          ],
        ),
      ),
    );
  }

  //event list item
  Column buildEventListItem() {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
              height: 32,
              width: 32,
              decoration: BoxDecoration(
                  color: Color(0xff385A95),
                  borderRadius: BorderRadius.all(Radius.circular(80))
              ),
              child: Center(
                child: Icon(
                  Icons.build,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
            SizedBox(
              width: 19,
            ),
            Expanded(
              flex: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '放射科 磁共振设备【zc001】等待维修…',
                    style: TextStyle(
                        color: Color(0xff1e1e1e),
                        fontSize: 14.0
                    ),
                  ),
                  Text(
                    '2020-03-08 17:22:33',
                    style: TextStyle(
                        color: Color(0xff333333),
                        fontSize: 11
                    ),
                  )
                ],
              ),
            )
          ],
        ),
        SizedBox(
          height: 24,
        ),
      ],
    );
  }

  Padding buildEventList() {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 19, 24, 19),
      child: Container(
        height: 400.0,
        child: ListView(
          children: <Widget>[
            buildEventListItem(),
            buildEventListItem(),
            buildEventListItem(),
            buildEventListItem(),
            buildEventListItem(),
          ],
        ),
      ),
    );
  }

  //key index
  Container buildProgressBar(String title, int planned, int finished, String percent) {
    return Container(
        height: 90,
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 60,
                  child: Text(
                    title,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff1e1e1e)
                    ),
                  ),
                ),
                SizedBox(
                  width: 27,
                ),
                Container(
                  height: 18,
                  width: 250,
                  color: Color(0xffE7EDF6),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 80,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [
                                  Color(0xff3FA6CC),
                                  Color(0xff39629B)
                                ]
                            )
                        ),
                      ),
                      Container(
                        width: 150,
                        decoration: BoxDecoration(
                            border: Border(
                                right: BorderSide(
                                  width: 1.0,
                                  color: Color(0xffCD6750),
                                )
                            )
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
            Row(
              children: <Widget>[
                Container(
                  width: 60,
                  child: Row(
                    children: <Widget>[
                      Text(
                        percent,
                        style: TextStyle(
                            color: Color(0xffD64040),
                            fontWeight: FontWeight.w600,
                            fontSize: 25
                        ),
                      ),
                      Text(
                        '%',
                        style: TextStyle(
                            color: Color(0xffD64040),
                            fontWeight: FontWeight.w600,
                            fontSize: 15
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 27,
                ),
                Text(
                  '已完成',
                  style: TextStyle(
                      color: Color(0xff333333),
                      fontSize: 13
                  ),
                ),
                Text(
                  finished.toString(),
                  style: TextStyle(
                      color: Color(0xff1e1e1e),
                      fontSize: 22
                  ),
                ),
                Text(
                  '件',
                  style: TextStyle(
                      color: Color(0xff333333),
                      fontSize: 13
                  ),
                ),
                SizedBox(
                  width: 50,
                ),
                Text(
                  '本月计划',
                  style: TextStyle(
                      color: Color(0xff333333),
                      fontSize: 13
                  ),
                ),
                Text(
                  planned.toString(),
                  style: TextStyle(
                      color: Color(0xff1e1e1e),
                      fontSize: 22
                  ),
                ),
                Text(
                  '件',
                  style: TextStyle(
                      color: Color(0xff333333),
                      fontSize: 13
                  ),
                ),
              ],
            )
          ],
        ),
      );
  }

  Padding buildKeyIndex() {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 19, 24, 19),
      child: Container(
        child: Column(
          children: <Widget>[
            Container(
              height: 300.0,
              child: buildGauge(),
            ),
            Container(
              height: 300.0,
              child: Column(
                children: <Widget>[
                  buildProgressBar('校准率', 100, 35, '35'),
                  buildProgressBar('保养率', 100, 35, '35'),
                  buildProgressBar('巡检率', 100, 35, '35'),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Container buildGauge() {
    return Container(
      child: SfRadialGauge(
          animationDuration: 1000,
          enableLoadingAnimation: true,
          axes:<RadialAxis>[
            RadialAxis(
              showLabels: false,
              pointers: [
                NeedlePointer(
                  value: 95,
                  needleColor: Color(0xffD64040),
                  knobStyle: KnobStyle(
                    color: Color(0xffD64040)
                  )
                ),
                MarkerPointer(value: 70),
              ],
              annotations: [
                GaugeAnnotation(
                  angle: 90,
                  positionFactor: 0.5,
                  widget: Container(
                    height: 80,
                    width: 60,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text(
                              '90',
                              style: TextStyle(
                                  color: Color(0xffD64040),
                                  fontSize: 30,
                                  fontWeight: FontWeight.w600
                              ),
                            ),
                            Text(
                              '%',
                              style: TextStyle(
                                  color: Color(0xffD64040),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600
                              ),
                            )
                          ],
                        ),
                        Text(
                          '开机率',
                          style: TextStyle(
                            color: Color(0xff1e1e1e),
                            fontWeight: FontWeight.w600,
                            fontSize: 14
                          ),
                        )
                      ],
                    ),
                  )
                )
              ],
              axisLineStyle: AxisLineStyle(thickness: 0.1,
                thicknessUnit: GaugeSizeUnit.factor,
                gradient: const SweepGradient(
                    colors: <Color>[Color(0xFF3FA5CC), Color(0xFF385A95)],
                    stops: <double>[0.25, 0.75]
                ),
              )
          ),
          ]
      ),
    );
  }
  
  // department detail
  GestureDetector buildDetail() {
    return GestureDetector(
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 14, 24, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                setState(() {
                  isDetailPage = false;
                });
              },
              child: Container(
                child: Text(
                  '设备收支概览',
                  style: TextStyle(
                      color: Color(0xff1e1e1e),
                      fontSize: 17.0,
                      fontWeight: FontWeight.w600
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 9.0,
            ),
            Container(
              child: Row(
                children: <Widget>[
                  Container(
                    height: 9.0,
                    width: 9.0,
                    color: Color(0xff86C7E6),
                  ),
                  SizedBox(
                    width: 4.0,
                  ),
                  Text(
                    '收入',
                    style: TextStyle(
                        color: Color(0xff666666),
                        fontSize: 10.0
                    ),
                  ),
                  SizedBox(
                    width: 15.0,
                  ),
                  Container(
                    height: 9.0,
                    width: 9.0,
                    color: Color(0xff39649C),
                  ),
                  SizedBox(
                    width: 4.0,
                  ),
                  Text(
                    '支出',
                    style: TextStyle(
                        color: Color(0xff666666),
                        fontSize: 10.0
                    ),
                  ),
                  SizedBox(
                    width: 15.0,
                  ),
                  Container(
                    height: 9.0,
                    width: 9.0,
                    color: Color(0xffD64040),
                  ),
                  SizedBox(
                    width: 4.0,
                  ),
                  Text(
                    '亏损',
                    style: TextStyle(
                        color: Color(0xff666666),
                        fontSize: 10.0
                    ),
                  ),
                  SizedBox(
                    width: 15.0,
                  ),
                ],
              ),
            ),
            Container(
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '2,698',
                            style: TextStyle(
                                color: Color(0xff1e1e1e),
                                fontSize: 15.0,
                                fontWeight: FontWeight.w600
                            ),
                          ),
                          SizedBox(
                            height: 4.0,
                          ),
                          Text(
                            '总收入(万元)',
                            style: TextStyle(
                                color: Color(0xff666666),
                                fontSize: 10.0
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '+23.2%',
                            style: TextStyle(
                                color: Color(0xffD64040),
                                fontSize: 15.0,
                                fontWeight: FontWeight.w600
                            ),
                          ),
                          SizedBox(
                            height: 4.0,
                          ),
                          Text(
                            '同比',
                            style: TextStyle(
                                color: Color(0xff666666),
                                fontSize: 10.0
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '2,698.22',
                            style: TextStyle(
                                color: Color(0xff1e1e1e),
                                fontSize: 15.0,
                                fontWeight: FontWeight.w600
                            ),
                          ),
                          SizedBox(
                            height: 4.0,
                          ),
                          Text(
                            '总支出(万元)',
                            style: TextStyle(
                                color: Color(0xff666666),
                                fontSize: 10.0
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '-12.33%',
                            style: TextStyle(
                                color: Color(0xff33B850),
                                fontSize: 15.0,
                                fontWeight: FontWeight.w600
                            ),
                          ),
                          SizedBox(
                            height: 4.0,
                          ),
                          Text(
                            '同比',
                            style: TextStyle(
                                color: Color(0xff666666),
                                fontSize: 10.0
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 200,
              child: buildIncomeChart(),
            )
          ],
        ),
      ),
    );
  }

  // equipment radar
  Padding buildRadar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 13, 24, 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                height: 18,
                width: 33,
                color: Color(0xff33B850),
                child: Center(
                  child: Text(
                    '正常',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                )
              ),
              Text(
                '医用磁共振成像系统-奥林巴斯-飞利浦',
                softWrap: true,
                style: TextStyle(
                  fontSize: 17,
                  color: Color(0xff1e1e1e),
                  fontWeight: FontWeight.w600
                ),
              ),
            ],
          ),
          Text(
            '781- -296 -资产编号20200107',
            style: TextStyle(
                fontSize: 17,
                color: Color(0xff1e1e1e),
                fontWeight: FontWeight.w600
            ),
          ),
          SizedBox(
            height: 14.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                '安装位置：放射科',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 17
                ),
              ),
              Text(
                '安装日期: 2020-01-07',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xff666666)
                ),
              ),
            ],
          ),
          SizedBox(
            height: 50,
          ),
          Container(
            height: 200,
            child: buildSpiderChart(),
          ),
          Container(
            height: 50,
            child: Row(
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.photo_library),
                  onPressed: () {
                    print('equipment pics');
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Container buildSpiderChart() {
    return Container(
      child: SpiderChart(
        data: [
          7,
          5,
          10,
          7,
          4,
        ],
        labels: [
          '维修',
          '保养',
          '巡检',
          '强检',
          '校正'
        ],
        maxValue: 10,
        colors: <Color>[
          Colors.red,
          Colors.green,
          Colors.blue,
          Colors.yellow,
          Colors.indigo,
        ],
      ),
    );
  }

  Padding buildTimeline() {
    return Padding(
      padding: EdgeInsets.fromLTRB(23, 25, 23, 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            '医用磁共振成像系统-奥林巴斯-飞利浦781- -296 -资产编号20200107',
            style: TextStyle(
                fontSize: 17,
                color: Color(0xff1e1e1e),
                fontWeight: FontWeight.w600
            ),
            softWrap: true,
          ),
          SizedBox(
            height: 14,
          ),
          Container(
            height: 300,
            child: ListView(
              children: <Widget>[
                TimelineTile(
                  alignment: TimelineAlign.left,
                  isFirst: true,
                  indicatorStyle: const IndicatorStyle(
                    width: 9,
                    color: Color(0xffD64040),
                    indicatorY: 0.3,
                  ),
                  bottomLineStyle: const LineStyle(
                    color: Color(0xffebebeb),
                    width: 4,
                  ),
                  rightChild: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 13),
                    child: Container(
                      constraints: const BoxConstraints(
                        minHeight: 40,
                      ),
                      child: Text(
                        '2020-02-17 维修; 000000336; 详细处理方法是处理方法',
                        style: TextStyle(
                            color: Color(0xff1e1e1e),
                            fontSize: 14
                        ),
                      ),
                    ),
                  )
                ),
                TimelineTile(
                    alignment: TimelineAlign.left,
                    indicatorStyle: const IndicatorStyle(
                      width: 9,
                      color: Color(0xffD64040),
                      indicatorY: 0.3,
                    ),
                    topLineStyle: const LineStyle(
                      color: Color(0xffebebeb),
                      width: 4,
                    ),
                    bottomLineStyle: const LineStyle(
                      color: Color(0xffebebeb),
                      width: 4,
                    ),
                    rightChild: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 13),
                      child: Container(
                        constraints: const BoxConstraints(
                          minHeight: 40,
                        ),
                        child: Text(
                          '2020-02-17 维修; 000000336; 详细处理方法是处理方法',
                          style: TextStyle(
                              color: Color(0xff1e1e1e),
                              fontSize: 14
                          ),
                        ),
                      ),
                    )
                ),
                TimelineTile(
                    alignment: TimelineAlign.left,
                    indicatorStyle: const IndicatorStyle(
                      width: 9,
                      color: Color(0xffD64040),
                      indicatorY: 0.3,
                    ),
                    topLineStyle: const LineStyle(
                      color: Color(0xffebebeb),
                      width: 4,
                    ),
                    bottomLineStyle: const LineStyle(
                      color: Color(0xffebebeb),
                      width: 4,
                    ),
                    rightChild: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 13),
                      child: Container(
                        constraints: const BoxConstraints(
                          minHeight: 40,
                        ),
                        child: Text(
                          '2020-02-17 维修; 000000336; 详细处理方法是处理方法',
                          style: TextStyle(
                              color: Color(0xff1e1e1e),
                              fontSize: 14
                          ),
                        ),
                      ),
                    )
                ),
                TimelineTile(
                    alignment: TimelineAlign.left,
                    indicatorStyle: const IndicatorStyle(
                      width: 9,
                      color: Color(0xffD64040),
                      indicatorY: 0.3,
                    ),
                    isLast: true,
                    topLineStyle: const LineStyle(
                      color: Color(0xffebebeb),
                      width: 4,
                    ),
                    bottomLineStyle: const LineStyle(
                      color: Color(0xffebebeb),
                      width: 4,
                    ),
                    rightChild: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 13),
                      child: Container(
                        constraints: const BoxConstraints(
                          minHeight: 40,
                        ),
                        child: Text(
                          '2020-02-17 维修; 000000336; 详细处理方法是处理方法',
                          style: TextStyle(
                              color: Color(0xff1e1e1e),
                              fontSize: 14
                          ),
                        ),
                      ),
                    )
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  List<Widget> listBuilder() {
    List<Widget> _list = [];
    // department detail
    if (!isDetailPage) {
      _list.add(
        SizedBox(
          height: 50.0,
        ),
      );
      switch (currentTab) {
        case 0:
          _list.addAll([
            buildCard(buildAsset()),
            buildCard(buildIncome()),
          ]);
          break;
        case 1:
          _list.add(
              buildCard(buildRequest())
          );
          break;
        case 2:
          _list.add(
              buildCard(buildEventType())
          );
          _list.add(
              buildCard(buildEventList())
          );
          break;
        case 3:
          _list.add(buildCard(buildKeyIndex()));
          break;
      }
    } else {
      _list.add(buildCard(buildDetail()));
      _list.add(buildCard(buildRadar()));
      _list.add(buildCard(buildTimeline()));
    }
    _list.add(
      Center(
        child: Text(
          '- 没有更多了 -',
          style: TextStyle(
              color: Color(0xff666666),
              fontSize: 12.0
          ),
        ),
      )
    );
    return _list;
  }

  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        bottomOpacity: 0,
        elevation: 0.0,
        title: Text('Dashboard'),
        backgroundColor: Color(0xff385A95),
        // linear gradient decoration
        //flexibleSpace: Container(
        //  decoration: BoxDecoration(
        //    gradient: LinearGradient(
        //      begin: Alignment.centerLeft,
        //      end: Alignment.centerRight,
        //      colors: [
        //        const Color(0xFF385A95),
        //        const Color(0xFF3FA5CC)
        //      ],
        //    ),
        //  ),
        //),
        actions: <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(new MaterialPageRoute(builder: (_) => SuperHome()));
            },
            child: Center(
              child: Text(
                'Super',
              ),
            ),
          )
        ],
      ),
      body: Container(
        color: Color(0xffd8e0ee),
        child: Stack(
          children: <Widget>[
            Container(
              child: CustomPaint(
                size: Size.infinite,
                painter: CurvePainter(),
              ),
            ),
            ListView(
                children: listBuilder()
            ),
            !isDetailPage?Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                buildTab('资产概览', 0),
                buildTab('当日报修', 1),
                buildTab('关键事件', 2),
                buildTab('关键指标', 3),
              ],
            ):Container(),
          ],
        ),
      ),
    );
  }
}

class CurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var gradient = LinearGradient(
      colors: [
        const Color(0xFF385A95),
        const Color(0xFF3FA5CC)
      ],
    );
    var rect = Offset.zero & size;
    var paint = Paint();
    paint.color = Color(0xff385A95);
    paint.style = PaintingStyle.fill;
    //paint.shader = gradient.createShader(rect);

    var path = Path();

    path.moveTo(0, size.height * 0.25);
    path.quadraticBezierTo(size.width / 2, size.height / 3, size.width, size.height * 0.25);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class IncomeData {
  final double x;
  final double income;
  final double expense;
  final double net;

  IncomeData(this.x, this.income, this.expense, this.net);
}

class RequestData {
  final String x;
  final int count;
  final Color color;

  RequestData(this.x, this.count, [this.color]);
}
