import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:atoi/models/main_model.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/cupertino.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:atoi/utils/http_request.dart';
import 'package:atoi/utils/report_dimensions.dart';

class ServiceAssets extends StatefulWidget {
  static String tag = '设备数量';
  ServiceAssets({Key key, this.assetType, this.endpoint, this.chartName, this.requestType, this.status, this.labelY}):super(key: key);
  final String assetType;
  final String endpoint;
  final String chartName;
  final String requestType;
  final String status;
  final String labelY;
  _ServiceAssetsState createState() => _ServiceAssetsState();
}

class _ServiceAssetsState extends State<ServiceAssets> {

  List<charts.Series<dynamic, String>> seriesList;
  bool animate;

  List _dimensionList = [];
  List _rawList = [];
  List _tableData = [];
  String _tableName = '年份';
  String _currentDimension = '';
  List _years = ReportDimensions.YEARS;

  Future<void> initDimension() async {
    var _list = ReportDimensions.YEARS.map((_year) => {
      _year.toString(): ReportDimensions.MONTHS.map((_month) => _month.toString()).toList()
    }).toList();
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
        title: new Text("请选择统计维度"),
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

  Future<Null> getChartData(String year, String month) async {
    var resp = await HttpRequest.request(
        '/Report/${widget.endpoint}',
        method: HttpRequest.POST,
        data: {
          'year': year,
          'month': month,
        }
    );
    if (resp['ResultCode'] == '00') {
      var _data = resp['Data'];
      var _list = _data.map<ServiceData>((item) => new ServiceData(item['Item1'], item['Item2'])).toList();
      setState(() {
        seriesList = [
          new charts.Series<ServiceData, String>(
            id: 'Sales',
            colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
            domainFn: (ServiceData data, _) => data.type,
            measureFn: (ServiceData data, _) => data.amount,
            data: _list,
          )
        ];
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
          DataColumn(label: Text('阶段', textAlign: TextAlign.center, style: new TextStyle(color: Colors.blue, fontSize: 14.0),)),
          DataColumn(label: Text(widget.assetType=='contract_amount'||widget.assetType=='contract_years'?'合同条数':'设备数量', textAlign: TextAlign.center, style: new TextStyle(color: Colors.blue, fontSize: 14.0),)),
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

  Container buildChart() {
    return new Container(
      height: _tableData.length*50.0+60.0,
      child: new charts.BarChart(
        seriesList,
        animate: true,
        vertical: false,
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

class ServiceData {
  final String type;
  final double amount;

  ServiceData(this.type, this.amount);
}
