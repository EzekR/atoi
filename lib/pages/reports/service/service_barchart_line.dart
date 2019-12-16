import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:atoi/models/main_model.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/cupertino.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:atoi/utils/http_request.dart';
import 'package:atoi/utils/report_dimensions.dart';

class ServiceBarchartLine extends StatefulWidget {

  ServiceBarchartLine({Key key, this.endpoint, this.chartName, this.requestType, this.status}):super(key: key);
  final String endpoint;
  final String chartName;
  final String requestType;
  final String status;
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
        adapter: PickerDataAdapter<String>(pickerdata: _dimensionList),
        hideHeader: true,
        title: new Text("请选择维度"),
        selectedTextStyle: TextStyle(color: Colors.blue),
        onConfirm: (Picker picker, List value) {
          var _selected = picker.getSelectedValues();
          getChartData(_selected[0], _selected[1]);
          setState(() {
            _currentDimension = _selected[0];
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
      var _list = _data.map<ServiceData>((item) => new ServiceData(item['type'], item['total'], item['ratio'])).toList();
      setState(() {
        seriesList = [
          new charts.Series<ServiceData, String>(
            id: 'Sales',
            colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
            domainFn: (ServiceData data, _) => data.type,
            measureFn: (ServiceData data, _) => data.amount,
            data: _list,
          ),
          new charts.Series<ServiceData, String>(
              id: 'Mobile',
              colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
              domainFn: (ServiceData sales, _) => sales.type,
              measureFn: (ServiceData sales, _) => sales.ratio,
              data: _list)
            ..setAttribute(charts.rendererIdKey, 'customLine')
            ..setAttribute(charts.measureAxisIdKey, 'Mobile')
        ];
        _tableName = type;
        _tableData = _data;
      });
    }
  }

  Row buildPickerRow(BuildContext context) {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        new FlatButton(
            onPressed: () {
              showPickerDialog(context);
            },
            child: new Row(
              children: <Widget>[
                new Icon(Icons.timeline),
                new Text('维度')
              ],
            )
        ),
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
        height: _tableData.length*50.0,
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
      height: 400.0,
      child: new charts.OrdinalComboChart(
        seriesList,
        animate: true,
        defaultRenderer: new charts.BarRendererConfig(
            groupingType: charts.BarGroupingType.grouped),
        primaryMeasureAxis: new charts.NumericAxisSpec(
            tickProviderSpec:
            new charts.BasicNumericTickProviderSpec(desiredTickCount: 3)),
        secondaryMeasureAxis: new charts.NumericAxisSpec(
            tickProviderSpec:
            new charts.BasicNumericTickProviderSpec(desiredTickCount: 3)),
        customSeriesRenderers: [
          new charts.LineRendererConfig(
              customRendererId: 'customLine')
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
                seriesList==null?new Container():buildChart(),
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
  final double ratio;

  ServiceData(this.type, this.amount, this.ratio);
}
