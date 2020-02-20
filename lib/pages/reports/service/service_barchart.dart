import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:atoi/models/main_model.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/cupertino.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:atoi/utils/http_request.dart';
import 'package:atoi/utils/report_dimensions.dart';

class ServiceBarchart extends StatefulWidget {

  ServiceBarchart({Key key, this.endpoint, this.chartName, this.labelX, this.labelY}):super(key: key);
  final String endpoint;
  final String chartName;
  final String labelX;
  final String labelY;
  _ServiceBarchartState createState() => _ServiceBarchartState();
}

class _ServiceBarchartState extends State<ServiceBarchart> {

  List<charts.Series<dynamic, String>> seriesList;
  bool animate;

  List _dimensionList = [];
  List _rawList = [];
  List _tableData = [];
  String _tableName = '年份';
  String _currentDimension = '';
  String _dim1 = ReportDimensions.DIMS[1]['Name'];
  String _dim2 = ReportDimensions.YEARS[0].toString();
  List _years = ReportDimensions.YEARS;

  Future<void> initDimension() async {
    var _list = ReportDimensions.DIMS.map((_dim) => {
      _dim['Name'].toString(): _dim['ID'] == 2?ReportDimensions.YEARS.map((_year) => _year.toString()).toList():[' ']
    }).toList();
    setState(() {
      _dimensionList = _list;
    });
  }

  void initState() {
    super.initState();
    initDimension();
    _currentDimension = _dim1;
    getChartData(_dim1, _dim2);
  }

  showPickerDialog(BuildContext context) {
    Picker(
        cancelText: '取消',
        confirmText: '确认',
        selecteds: [ReportDimensions.DIMS.indexWhere((elem) => elem['Name']==_dim1), _years.indexOf(_dim2)<0?0:_years.indexOf(_dim2)],
        adapter: PickerDataAdapter<String>(pickerdata: _dimensionList),
        hideHeader: true,
        title: new Text("请选择统计维度"),
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
    var _select = ReportDimensions.DIMS.firstWhere((item) => item['Name']==type, orElse: ()=> null);
    var resp = await HttpRequest.request(
        '/Report/${widget.endpoint}',
        method: HttpRequest.POST,
        data: {
          'type': _select['ID'],
          'year': year==' '?0:year
        }
    );
    if (resp['ResultCode'] == '00') {
      var _data = resp['Data'];
      var _list = _data.map<EquipmentData>((item) => new EquipmentData(item['Item1'], item['Item2'])).toList();
      setState(() {
        seriesList = [
          new charts.Series<EquipmentData, String>(
              id: 'Sales',
              colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
              domainFn: (EquipmentData data, _) => data.type,
              measureFn: (EquipmentData data, _) => data.amount,
              data: _list,
              labelAccessorFn: (EquipmentData data, _) =>
              '${data.amount.toString()}'
          )
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
        new RaisedButton(
            onPressed: () {
              showPickerDialog(context);
            },
            child: new Row(
              children: <Widget>[
                new Icon(Icons.timeline, color: Colors.white,),
                new Text('选择维度', style: new TextStyle(color: Colors.white),)
              ],
            )
        ),
        new Text(_dim1??''),
        new Text(_dim1=='时间类型-月'?'年份：${_dim2}':''),
      ],
    );
  }

  Card buildTable() {
    var _dataTable = new DataTable(
        columns: [
          DataColumn(label: Text(_currentDimension, textAlign: TextAlign.center, style: new TextStyle(color: Colors.blue, fontSize: 14.0),)),
          DataColumn(label: Text(widget.labelY, textAlign: TextAlign.center, style: new TextStyle(color: Colors.blue, fontSize: 14.0),)),
        ],
        rows: _tableData.map((item) => DataRow(
            cells: [
              DataCell(Text(item['Item1'])),
              DataCell(Text(item['Item2'].toString()))
            ]
        )).toList()
    );
    return new Card(
      child: _dataTable,
    );
  }

  Column buildChart() {
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        new Container(
          height: _tableData.length*50.0+60.0,
          child: new charts.BarChart(
            seriesList,
            animate: true,
            vertical: false,
            barRendererDecorator: new charts.BarLabelDecorator<String>(),
            behaviors: [
              new charts.ChartTitle(widget.labelY,
                  behaviorPosition: charts.BehaviorPosition.bottom,
                  titleOutsideJustification:
                  charts.OutsideJustification.middleDrawArea),
            ],
          ),
        ),
      ],
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
              children: <Widget>[
                buildPickerRow(context),
                seriesList==null?new Container():buildChart(),
                new SizedBox(height: 8.0,),
                new Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new Text('数据列表')
                  ],
                ),
                _tableData!=null&&_tableData.isNotEmpty?buildTable():new Container(child: new Center(
                  child: Text('暂无数据'),
                ),),
              ],
            )
        );
      },
    );
  }
}

class EquipmentData {
  final String type;
  final double amount;

  EquipmentData(this.type, this.amount);
}
