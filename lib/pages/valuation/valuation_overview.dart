import 'package:flutter/material.dart';
import 'package:atoi_charts/charts.dart';

class ValuationOverview extends StatefulWidget {
  _ValuationOverviewState createState() => new _ValuationOverviewState();
}

class _ValuationOverviewState extends State<ValuationOverview> {

  ScrollController _verticalController = new ScrollController();
  ScrollController _horizonController = new ScrollController();
  List<ChartData> chartData = [
    ChartData('David', 25, Color(0xff2FC25B)),
    ChartData('Steve', 38, Color(0xff1890FF)),
    ChartData('Jack', 34, Color(0xff13C2C2)),
    ChartData('Others', 52)
  ];

  void initState() {
    super.initState();
  }

  Padding renderMenuBox() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
      child: Container(
        height: 80,
        width: 120,
        color: Color(0xffE3F2FF),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text("·"),
                    Text("保养类")
                  ],
                ),
                IconButton(
                  onPressed: () {
                  },
                  icon: Icon(Icons.play_circle_filled, color: Color(0xff41579B),),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Container renderPie() {
    return Container(
      height: 400.0,
      width: 250.0,
      child: Center(
        child: SfCircularChart(series: <CircularSeries>[
          // Render pie chart
          PieSeries<ChartData, String>(
              dataSource: chartData,
              pointColorMapper:(ChartData data,  _) => data.color,
              xValueMapper: (ChartData data, _) => data.x,
              yValueMapper: (ChartData data, _) => data.y,
              dataLabelSettings: DataLabelSettings(
                isVisible: true,
                labelPosition: ChartDataLabelPosition.outside
              ),
              explode: true,
              explodeIndex: 1
          )
        ]
        ),
      ),
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("成本汇总"),
      ),
      body: ListView(
        controller: _verticalController,
        scrollDirection: Axis.vertical,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Container(
              child: Column(
                children: <Widget>[
                  Container(
                    child: Column(
                      children: <Widget>[
                        Container(
                          color: Color(0xff41579B),
                          height: 40.0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                child: Row(
                                  children: <Widget>[
                                    SizedBox(width: 12.0,),
                                    Icon(Icons.pie_chart, color: Colors.white,),
                                    SizedBox(width: 6.0,),
                                    Text("成本构成分析", style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                    ),)
                                  ],
                                ),
                              ),
                              Container(
                                child: Row(
                                  children: <Widget>[
                                    Text(
                                      "单位 : 千元",
                                      style: TextStyle(
                                          color: Color.fromRGBO(255, 255, 255, 0.85),
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.w200
                                      ),
                                    ),
                                    SizedBox(width: 12.0,)
                                  ],
                                )
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  renderPie(),
                  Container(
                    height: 100,
                    child: ListView(
                      controller: _horizonController,
                      scrollDirection: Axis.horizontal,
                      children: <Widget>[
                        renderMenuBox(),
                        renderMenuBox(),
                        renderMenuBox(),
                        renderMenuBox(),
                        renderMenuBox(),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.0,),
                  Container(),
                ],
              ),
            ),
          )
        ],
      )
    );
  }
}

class ChartData {
  ChartData(this.x, this.y, [this.color]);
  final String x;
  final double y;
  final Color color;
}