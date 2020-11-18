import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ValuationAnalysis extends StatefulWidget {
  _ValuationAnalysisState createState() => new _ValuationAnalysisState();
}

class _ValuationAnalysisState extends State<ValuationAnalysis> {

  int currentTable = 0;
  bool showCost = true;
  int currentYear = 0;
  int currentMonth = 0;

  void initState() {
    super.initState();
  }

  List<Widget> buildTotal() {
    List<Widget> _list = [];

    return _list;
  }

  Container _buildContainerRow(Color fontColor) {
    return Container(
      height: 30.0,
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
                  color: Color.fromRGBO(0, 0, 0, 0.19),
                  width: 1.0,
                  style: BorderStyle.solid
              )
          )
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text("成本汇总",
            style: TextStyle(
                color: fontColor,
                fontSize: 13.0
            ),
          ),
          Text("26,624,863",
            style: TextStyle(
                color: fontColor,
                fontSize: 16.0
            ),
          ),
        ],
      ),
    );
  }

  Container _buildContainerSplit(Color fontColor) {
    return Container(
      height: 30.0,
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
                  color: Color.fromRGBO(0, 0, 0, 0.19),
                  width: 1.0,
                  style: BorderStyle.solid
              )
          )
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 6,
            child: Container(
              height: 30.0,
              decoration: BoxDecoration(
                  border: Border(
                      right: BorderSide(
                          color: Color.fromRGBO(0, 0, 0, 0.19),
                          width: 1.0,
                          style: BorderStyle.solid
                      )
                  )
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 12, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      '固定类',
                      style: TextStyle(
                          color: fontColor,
                          fontSize: 11.0
                      ),
                    ),
                    Text(
                      '5,464,125',
                      style: TextStyle(
                          color: fontColor,
                          fontSize: 11.0
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Container(
              child: Padding(
                padding: EdgeInsets.fromLTRB(12, 0, 0, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      '变动类-保养',
                      style: TextStyle(
                          color: fontColor,
                          fontSize: 11.0
                      ),
                    ),
                    Text(
                      '5,464,125',
                      style: TextStyle(
                          color: fontColor,
                          fontSize: 11.0
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Stack buildTopStack() {
    return Stack(
      children: <Widget>[
        Column(
          children: <Widget>[
            Container(
              height: 80.0,
              color: Color(0xff1D3F82),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.fromLTRB(16.0, 7.0, 0, 0),
                          child: Text("总报价",
                            style: TextStyle(
                                fontSize: 13.0,
                                color: Color.fromRGBO(255, 255, 255, 0.87)
                            ),
                          )
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.fromLTRB(16.0, 0, 0, 0),
                        child: Text(
                          '23,232,311',
                          style: TextStyle(
                              fontSize: 22.0,
                              color: Colors.white,
                              fontWeight: FontWeight.w400
                          ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 0, 16, 0),
                          child: Text(
                            '单位：千元',
                            style: TextStyle(
                                fontSize: 14.0,
                                color: Color.fromRGBO(255, 255, 255, 0.87),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              AnimatedContainer(
                color: Color(0xff41579B),
                height: showCost?220.0:0.0,
                duration: Duration(milliseconds: 200),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.0, 0, 16, 6),
                  child: Column(
                    children: <Widget>[
                      _buildContainerRow(Colors.white),
                      _buildContainerSplit(Colors.white),
                      _buildContainerSplit(Colors.white),
                      _buildContainerRow(Colors.white),
                      _buildContainerRow(Colors.white),
                      _buildContainerSplit(Colors.white),
                      _buildContainerRow(Colors.white),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Column(
            children: <Widget>[
              SizedBox(height: 30.0,),
              Align(
                alignment: FractionalOffset(0.5, 1.0),
                child: IconButton(
                  icon: Icon(Icons.arrow_drop_down_circle),
                  color: Color(0xff16A2B8),
                  iconSize: 28.0,
                  onPressed: () {
                    setState(() {
                      showCost = !showCost;
                    });
                  },
                ),
              )
            ],
          ),
        ],
      );
  }

  GestureDetector _buildAnnualTab(int index) {
    bool active = index == currentYear;
    return GestureDetector(
      onTap: () {
        setState(() {
          currentYear = index;
        });
      },
      child: Container(
        width: 120,
        decoration: BoxDecoration(
            color: active?Color(0xffE3F2FF):Color(0xff1A4182),
            border: Border(
                right: BorderSide(
                    color: Color(0xffE3F2FF),
                    width: 1.0,
                    style: BorderStyle.solid
                )
            )
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(18.0, 3, 0, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                height: 30,
                child: Text(
                  '第 1 年报价',
                  style: TextStyle(
                      fontSize: 13.0,
                      color: active?Color.fromRGBO(0, 0, 0, 0.85):Colors.white
                  ),
                ),
              ),
              Container(
                child: Text(
                  '17,868,968',
                  style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400,
                      color: active?Color.fromRGBO(0, 0, 0, 0.85):Colors.white
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Container buildAnnualSlider() {
    return Container(
      height: 60.0,
      color: Color(0xff1A4182),
      child: ListView(
        scrollDirection: Axis.horizontal,
        controller: ScrollController(),
        children: <Widget>[
          _buildAnnualTab(0),
          _buildAnnualTab(1),
          _buildAnnualTab(2),
          _buildAnnualTab(3),
          _buildAnnualTab(4),
        ],
      ),
    );
  }

  GestureDetector _buildMonthTab(int index) {
    bool active = index == currentMonth;
    return GestureDetector(
      onTap: () {
        setState(() {
          currentMonth = index;
        });
      },
      child: Container(
        width: 120.0,
        child: Center(
          child: Container(
            width: 100.0,
            height: 30.0,
            decoration: BoxDecoration(
              color: active?Color(0xff1A4182):Colors.white,
              borderRadius: BorderRadius.all(
                  Radius.circular(18.0)
              ),
              border: Border.all(
                color: active?Color(0xff1A4182):Color.fromRGBO(0,0,0, 0.12),
                width: 1.0,
              ),
            ),
            child: Center(
              child: Text("Nov 2020",
                style: TextStyle(
                  fontSize: 13.0,
                  color: active?Colors.white:Color.fromRGBO(0, 0, 0, 0.85)
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Container buildMonthSlider() {
    return Container(
      height: 50.0,
      child: ListView(
        scrollDirection: Axis.horizontal,
        controller: ScrollController(),
        children: <Widget>[
          _buildMonthTab(0),
          _buildMonthTab(1),
          _buildMonthTab(2),
          _buildMonthTab(3),
          _buildMonthTab(4),
          _buildMonthTab(5),
        ],
      ),
    );
  }

  Container buildMonthTable() {
    return Container(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
        child: Column(
          children: <Widget>[
            Container(
              height: 32.0,
              decoration: BoxDecoration(
                color: Color(0xffF2F3F5),
                borderRadius: BorderRadius.all(
                    Radius.circular(18.0)
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Nov 2020 报价',
                      style: TextStyle(
                          color: Color.fromRGBO(0, 0, 0, 0.75),
                          fontSize: 13.0
                      ),
                    ),
                    Text(
                      '17,868,968',
                      style: TextStyle(
                          color: Color.fromRGBO(0, 0, 0, 0.75),
                          fontSize: 13.0
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildContainerRow(Colors.black54),
            _buildContainerSplit(Colors.black54),
            _buildContainerSplit(Colors.black54),
            _buildContainerRow(Colors.black54),
            _buildContainerRow(Colors.black54),
            _buildContainerRow(Colors.black54),
          ],
        ),
      ),
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff41579B),
        title: Container(
          height: 55.0,
          width: 400.0,
          child: ListView(
            controller: new ScrollController(),
            scrollDirection: Axis.horizontal,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  setState(() {
                    currentTable = 0;
                  });
                },
                child: Container(
                  width: 100.0,
                  decoration: currentTable==0?BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              color: Color(0xff16A2B8),
                              width: 3.0,
                              style: BorderStyle.solid
                          )
                      )
                  ):BoxDecoration(),
                  child: Center(
                    child: Text("最终定价表",
                      style: currentTable==0?TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600
                      ):TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14.0
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    currentTable = 1;
                  });
                },
                child: Container(
                  width: 100.0,
                  decoration: currentTable==1?BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              color: Color(0xff16A2B8),
                              width: 3.0,
                              style: BorderStyle.solid
                          )
                      )
                  ):BoxDecoration(),
                  child: Center(
                    child: Text("成本明细",
                      style: currentTable==1?TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600
                      ):TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14.0
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    currentTable = 2;
                  });
                },
                child: Container(
                  width: 100.0,
                  decoration: currentTable==2?BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              color: Color(0xff16A2B8),
                              width: 3.0,
                              style: BorderStyle.solid
                          )
                      )
                  ):BoxDecoration(),
                  child: Center(
                    child: Text("分析",
                      style: currentTable==2?TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600
                      ):TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14.0
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        centerTitle: false,
      ),
      body: ListView(
        controller: ScrollController(),
        children: <Widget>[
          buildTopStack(),
          buildAnnualSlider(),
          Container(
            color: Color(0xffE3F2FF),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  _buildContainerRow(Colors.black),
                  _buildContainerSplit(Colors.black),
                  _buildContainerSplit(Colors.black),
                  _buildContainerRow(Colors.black),
                  _buildContainerRow(Colors.black),
                  _buildContainerRow(Colors.black),
                  _buildContainerSplit(Colors.black),
                  _buildContainerRow(Colors.black),
                ],
              ),
            ),
          ),
          buildMonthSlider(),
          buildMonthTable(),
        ],
      ),
    );
  }
}