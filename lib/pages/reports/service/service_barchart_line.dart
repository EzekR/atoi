import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:atoi/models/main_model.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/cupertino.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:atoi/utils/http_request.dart';
import 'package:atoi/utils/report_dimensions.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ServiceBarchartLine extends StatefulWidget {

  ServiceBarchartLine({Key key, this.endpoint, this.chartName, this.requestType, this.status, this.labelY}):super(key: key);
  final String endpoint;
  final String chartName;
  final String requestType;
  final String status;
  final String labelY;
  _ServiceBarchartLineState createState() => _ServiceBarchartLineState();
}

class _ServiceBarchartLineState extends State<ServiceBarchartLine> {

  List<charts.Series<dynamic, String>> seriesList;
  bool animate;

  List _dimensionList = [];
  List _rawList = [];
  List _tableData = [];
  String _tableName = '年份';
  String _currentDimension = '';
  ScrollController _scrollController;
  String _dim1 = '年';
  String _dim2 = '2019';

  Future<void> initDimension() async {
    List _list = [
      {
        '年': [' ']
      },
      {
        '月': ReportDimensions.YEARS.map((_year) => _year.toString()).toList()
      }
    ];
    setState(() {
      _dimensionList = _list;
    });
  }

  void initState() {
    super.initState();
    initDimension();
  }

  showPickerDialog(BuildContext context) {
    Picker(
        cancelText: '取消',
        confirmText: '确认',
        selecteds: [_dim1=='年'?0:1, ReportDimensions.YEARS.indexOf(int.parse(_dim2))],
        adapter: PickerDataAdapter<String>(pickerdata: _dimensionList),
        hideHeader: true,
        title: new Text("请选择维度"),
        selectedTextStyle: TextStyle(color: Colors.blue),
        onConfirm: (Picker picker, List value) {
          var _selected = picker.getSelectedValues();
          getChartData(_selected[0], _selected[1]);
          setState(() {
            _currentDimension = _selected[0];
            _dim1 = _selected[0];
            _dim2 = _selected[1];
          });
        }
    ).showDialog(context);
  }

  Future<Null> getChartData(String type, String year) async {
    var resp = await HttpRequest.request(
        '/Report/${widget.endpoint}',
        method: HttpRequest.POST,
        data: {
          'year': type=='年'?0:year
        }
    );
    if (resp['ResultCode'] == '00') {
      var _data = resp['Data'];
      setState(() {
        _tableName = type;
        _tableData = _data;
      });
    }
  }

  Row buildPickerRow(BuildContext context) {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        new RaisedButton(
            onPressed: () {
              showPickerDialog(context);
            },
            child: new Row(
              children: <Widget>[
                new Icon(Icons.timeline, color: Colors.white,),
                new Text('维度', style: TextStyle(color: Colors.white),)
              ],
            )
        ),
        new Text('时间维度分类 $_dim1'),
        new Text(_dim1=='月'?'年份 $_dim2':_dim2)
      ],
    );
  }

  Card buildTable() {
    var _dataTable = new DataTable(
        columns: [
          DataColumn(label: Text('时间', textAlign: TextAlign.center, style: new TextStyle(color: Colors.blue, fontSize: 14.0),)),
          DataColumn(label: Text('合格数', textAlign: TextAlign.center, style: new TextStyle(color: Colors.blue, fontSize: 14.0),)),
          DataColumn(label: Text('服务总数', textAlign: TextAlign.center, style: new TextStyle(color: Colors.blue, fontSize: 14.0),)),
          DataColumn(label: Text('合格率（%）', textAlign: TextAlign.center, style: new TextStyle(color: Colors.blue, fontSize: 14.0),)),
        ],
        rows: _tableData.map((item) => DataRow(
            cells: [
              DataCell(Text(item['type'])),
              DataCell(Text(item['total'].toString())),
              DataCell(Text(item['passed'].toString())),
              DataCell(Text(item['ratio'].toString()))
            ]
        )).toList()
    );
    return new Card(
      child: new Container(
        height: _tableData.length*50.0+60.0,
        child: new ListView(
          scrollDirection: Axis.horizontal,
          controller: _scrollController,
          children: <Widget>[
            _dataTable
          ],
        ),
      )
    );
  }

  Container buildChart() {
    return new Container(
      child: SfCartesianChart(
        // Initialize category axis
          primaryXAxis: CategoryAxis(
              labelRotation: 60
          ),
          primaryYAxis: NumericAxis(
              title: AxisTitle(
                  text: '请求数量（条）'
              )
          ),
          axes: [
            NumericAxis(
                name: 'yAxis',
                opposedPosition: true,
                title: AxisTitle(
                    text: '合格率（%）'
                )
            )
          ],
          series: <ChartSeries>[
            ColumnSeries<ServiceData, String>(
                dataSource: _tableData.map<ServiceData>((item) => ServiceData(item['type'], item['total'])).toList(),
                xValueMapper: (ServiceData data, _) => data.type,
                yValueMapper: (ServiceData data, _) => data.amount
            ),
            LineSeries<ServiceRatio, String>(
                dataSource: _tableData.map<ServiceRatio>((item) => ServiceRatio(item['type'], item['ratio'])).toList(),
                xValueMapper: (ServiceRatio data, _) => data.type,
                yValueMapper: (ServiceRatio data, _) => data.ratio,
                yAxisName: 'yAxis'
            ),
          ]
      ),
    );
  }

  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (context, child, mainModel) {
        return new Scaffold(
            appBar: new AppBar(
              title: new Text(widget.chartName),
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
              controller: _scrollController,
              children: <Widget>[
                buildPickerRow(context),
                _tableData==null?new Container():buildChart(),
                new SizedBox(height: 8.0,),
                new Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new Text('数据列表')
                  ],
                ),
                _tableData!=null&&_tableData.isNotEmpty?buildTable():new Container()
              ],
            )
        );
      },
    );
  }
}

class ServiceData {
  final String type;
  final double amount;

  ServiceData(this.type, this.amount);
}

class ServiceRatio {
  final String type;
  final double ratio;

  ServiceRatio(this.type, this.ratio);
}
