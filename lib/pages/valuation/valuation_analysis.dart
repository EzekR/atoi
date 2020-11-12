import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ValuationAnalysis extends StatefulWidget {
  _ValuationAnalysisState createState() => new _ValuationAnalysisState();
}

class _ValuationAnalysisState extends State<ValuationAnalysis> {

  int currentTable = 0;

  void initState() {
    super.initState();
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
        leading: Icon(Icons.menu),
      ),
      body: ListView(
        controller: ScrollController(),
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Center(
                      child: IconButton(
                        icon: Icon(Icons.arrow_drop_down_circle),
                        color: Color(0xff16A2B8),
                        iconSize: 28.0,
                        onPressed: () {

                        },
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
          Container(
            color: Color(0xff41579B),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  Container(
                    height: 40.0,
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
                            color: Colors.white,
                            fontSize: 16.0
                          ),
                        ),
                        Text("26,624,863",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          Container(
            height: 60.0,
            color: Color(0xff1A4182),
            child: ListView(
              scrollDirection: Axis.horizontal,
              controller: ScrollController(),
              children: <Widget>[
                Container(
                  width: 120,
                  child: Center(
                    child: Text("1"),
                  ),
                ),
                Container(
                  width: 120,
                  child: Center(
                    child: Text("1"),
                  ),
                ),
                Container(
                  width: 120,
                  child: Center(
                    child: Text("1"),
                  ),
                ),
                Container(
                  width: 120,
                  child: Center(
                    child: Text("1"),
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: Color(0xffE3F2FF),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  Container(
                    height: 40.0,
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
                              color: Colors.white,
                              fontSize: 16.0
                          ),
                        ),
                        Text("26,624,863",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          Container(
            height: 50.0,
            child: ListView(
              scrollDirection: Axis.horizontal,
              controller: ScrollController(),
              children: <Widget>[
                Container(
                  width: 120.0,
                  child: Center(
                    child: Container(
                      width: 100.0,
                      height: 30.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(18.0)
                        ),
                        border: Border.all(
                          color: Color.fromRGBO(0,0,0, 0.12),
                          width: 1.0,
                        ),
                      ),
                      child: Center(
                        child: Text("Nov 2020"),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 120.0,
                  child: Center(
                    child: Container(
                      width: 100.0,
                      height: 30.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                            Radius.circular(18.0)
                        ),
                        border: Border.all(
                          color: Color.fromRGBO(0,0,0, 0.12),
                          width: 1.0,
                        ),
                      ),
                      child: Center(
                        child: Text("Nov 2020"),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 120.0,
                  child: Center(
                    child: Container(
                      width: 100.0,
                      height: 30.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                            Radius.circular(18.0)
                        ),
                        border: Border.all(
                          color: Color.fromRGBO(0,0,0, 0.12),
                          width: 1.0,
                        ),
                      ),
                      child: Center(
                        child: Text("Nov 2020"),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 120.0,
                  child: Center(
                    child: Container(
                      width: 100.0,
                      height: 30.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                            Radius.circular(18.0)
                        ),
                        border: Border.all(
                          color: Color.fromRGBO(0,0,0, 0.12),
                          width: 1.0,
                        ),
                      ),
                      child: Center(
                        child: Text("Nov 2020"),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 120.0,
                  child: Center(
                    child: Container(
                      width: 100.0,
                      height: 30.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                            Radius.circular(18.0)
                        ),
                        border: Border.all(
                          color: Color.fromRGBO(0,0,0, 0.12),
                          width: 1.0,
                        ),
                      ),
                      child: Center(
                        child: Text("Nov 2020"),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 120.0,
                  child: Center(
                    child: Container(
                      width: 100.0,
                      height: 30.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                            Radius.circular(18.0)
                        ),
                        border: Border.all(
                          color: Color.fromRGBO(0,0,0, 0.12),
                          width: 1.0,
                        ),
                      ),
                      child: Center(
                        child: Text("Nov 2020"),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 120.0,
                  child: Center(
                    child: Container(
                      width: 100.0,
                      height: 30.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                            Radius.circular(18.0)
                        ),
                        border: Border.all(
                          color: Color.fromRGBO(0,0,0, 0.12),
                          width: 1.0,
                        ),
                      ),
                      child: Center(
                        child: Text("Nov 2020"),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 120.0,
                  child: Center(
                    child: Container(
                      width: 100.0,
                      height: 30.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                            Radius.circular(18.0)
                        ),
                        border: Border.all(
                          color: Color.fromRGBO(0,0,0, 0.12),
                          width: 1.0,
                        ),
                      ),
                      child: Center(
                        child: Text("Nov 2020"),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 120.0,
                  child: Center(
                    child: Container(
                      width: 100.0,
                      height: 30.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                            Radius.circular(18.0)
                        ),
                        border: Border.all(
                          color: Color.fromRGBO(0,0,0, 0.12),
                          width: 1.0,
                        ),
                      ),
                      child: Center(
                        child: Text("Nov 2020"),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 120.0,
                  child: Center(
                    child: Container(
                      width: 100.0,
                      height: 30.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                            Radius.circular(18.0)
                        ),
                        border: Border.all(
                          color: Color.fromRGBO(0,0,0, 0.12),
                          width: 1.0,
                        ),
                      ),
                      child: Center(
                        child: Text("Nov 2020"),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 120.0,
                  child: Center(
                    child: Container(
                      width: 100.0,
                      height: 30.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                            Radius.circular(18.0)
                        ),
                        border: Border.all(
                          color: Color.fromRGBO(0,0,0, 0.12),
                          width: 1.0,
                        ),
                      ),
                      child: Center(
                        child: Text("Nov 2020"),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}