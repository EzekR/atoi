import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:atoi/models/main_model.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/cupertino.dart';

class ReportChart extends StatefulWidget {
  _ReportChartState createState() => _ReportChartState();
}

class _ReportChartState extends State<ReportChart> {

  List<charts.Series> seriesList;
  bool animate;

  List _mainMenu = [
    '时间类型',
    '设备类型',
    '资产类型',
    '设备年限',
    '设备产地',
    '设备科室',
    '厂商分布'
  ];

  List _month = [
    '1月',
    '2月',
    '3月',
    '4月',
    '5月',
    '6月',
    '7月',
    '8月',
    '9月',
    '10月',
    '11月',
    '12月'
  ];

  List _year = [
    '2018',
    '2019',
    '2020'
  ];

  List<DropdownMenuItem<String>> _dropDownMenuItems;
  List<DropdownMenuItem<String>> _dropDownMenuMonth;
  List<DropdownMenuItem<String>> _dropDownMenuYear;
  String _currentMenu;
  String _currentMonth;
  String _currentYear;

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

  void changeMenu(String selected) {
    setState(() {
      _currentMenu = selected;
    });
  }

  void changeMonth(String selected) {
    setState(() {
      _currentMonth = selected;
    });
  }

  void changeYear(String selected) {
    setState(() {
      _currentYear = selected;
    });
  }


  void _showCupertinoPicker(BuildContext cxt, List itemList){
    List<Widget> _list = [];
    for(var item in itemList) {
      _list.add(
        Text(
          item,
          style: new TextStyle(
            color: Colors.black54,
            fontSize: 14.0,
            fontWeight: FontWeight.w400
          ),
        )
      );
    }
    final picker  = CupertinoPicker(
        itemExtent: 24,
        backgroundColor: Colors.white,
        onSelectedItemChanged: (position){
          print('The position is $position');
        },
        children: _list
    );

    showCupertinoModalPopup(context: cxt, builder: (cxt){
      return Container(
        height: 200,
        child: picker,
      );
    }).then((result) {
      print(result);
    });
  }

  void initState() {
    super.initState();
    _dropDownMenuItems = getDropDownMenuItems(_mainMenu);
    _currentMenu = _dropDownMenuItems[0].value;
    _dropDownMenuMonth = getDropDownMenuItems(_month);
    _currentMonth = _dropDownMenuMonth[0].value;
    _dropDownMenuYear = getDropDownMenuItems(_year);
    _currentYear = _dropDownMenuYear[0].value;
    _createData();
  }

  Row buildPickerRow() {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        new DropdownButton(
            items: _dropDownMenuItems,
            value: _currentMenu,
            onChanged: changeMenu
        ),
        new DropdownButton(
            items: _dropDownMenuYear,
            value: _currentYear,
            onChanged: changeYear
        ),
        new DropdownButton(
            items: _dropDownMenuMonth,
            value: _currentMonth,
            onChanged: changeMonth
        ),
      ],
    );
  }

  Column buildTable() {
    var _dataList = [
      {
        'year': '2015',
        'data': '10086'
      },
      {
        'year': '2015',
        'data': '10086'
      },
      {
        'year': '2015',
        'data': '10086'
      },
      {
        'year': '2015',
        'data': '10086'
      },
      {
        'year': '2015',
        'data': '10086'
      },
      {
        'year': '2015',
        'data': '10086'
      },
      {
        'year': '2015',
        'data': '10086'
      },
    ];
    List<ListTile> _list = [
      ListTile(
        title: new Text('年份'),
        trailing: new Text('数据'),
        onTap: () {
          _showCupertinoPicker(context, _month);
        },
      )
    ];
    for(var _data in _dataList) {
      _list.add(
        ListTile(
          title: new Text(_data['year']),
          trailing: new Text(_data['data']),
        )
      );
    }
    return new Column(
      children: _list,
    );
  }

  void _createData() {
    final data = [
      new OrdinalSales('2014', 5),
      new OrdinalSales('2015', 25),
      new OrdinalSales('2016', 100),
      new OrdinalSales('2017', 75),
      new OrdinalSales('2018', 5),
      new OrdinalSales('2019', 25),
      new OrdinalSales('2020', 100),
      new OrdinalSales('2021', 75),
    ];

    var _list = [
      new charts.Series<OrdinalSales, String>(
        id: 'Sales',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (OrdinalSales sales, _) => sales.year,
        measureFn: (OrdinalSales sales, _) => sales.sales,
        data: data,
      )
    ];
    setState(() {
      seriesList = _list;
    });
  }

  Container buildChart() {
    return new Container(
      height: 300.0,
      child: new charts.BarChart(
        seriesList,
        animate: true,
      ),
    );
  }

  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (context, child, mainModel) {
        return new Scaffold(
            appBar: new AppBar(
              leading: new Icon(Icons.menu),
              title: new Text('报表详情'),
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
                buildPickerRow(),
                buildChart(),
                new Padding(
                  padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
                  child: new Text('设备数据',
                    style: new TextStyle(
                      fontSize: 16.0
                    ),
                  ),
                ),
                buildTable()
              ],
            )
        );
      },
    );
  }
}

class OrdinalSales {
  final String year;
  final int sales;

  OrdinalSales(this.year, this.sales);
}