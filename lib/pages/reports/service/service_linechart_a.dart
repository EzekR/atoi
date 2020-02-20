import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:atoi/models/main_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:atoi/utils/http_request.dart';
import 'package:atoi_charts/charts.dart';
import 'package:atoi/utils/report_dimensions.dart';
import 'package:should_rebuild/should_rebuild.dart';

class ServiceLinechartA extends StatefulWidget {

  ServiceLinechartA({Key key, this.chartName, this.endpoint, this.requestType, this.status, this.labelY}):super(key: key);
  final String endpoint;
  final String chartName;
  final String requestType;
  final String status;
  final String labelY;
  _ServiceLinechartAState createState() => _ServiceLinechartAState();
}

class _ServiceLinechartAState extends State<ServiceLinechartA> {

  bool animate;

  List _dimensionList = [];
  List _dimSlice = [];
  List _rawList = [];
  List _tableData = [];
  String _tableName = '年份';
  String _currentDimension = '';
  ScrollController _scrollController;
  List _years = ReportDimensions.YEARS;

  Future<void> initDimension() async {
    _dimSlice = ReportDimensions.DIMS.sublist(2, 8);
    List _list = _dimSlice.map((_dim) => {_dim['Name'].toString(): [
      {
        '年': ReportDimensions.YEARS.map((_year) => {_year.toString(): [' ']}).toList()
      },
      {
        '月': ReportDimensions.YEARS.map((_year) => {_year.toString(): ReportDimensions.MONTHS.map((month) => month.toString()).toList()}).toList()
      }
    ]
    }).toList();
    setState(() {
      _dimensionList = _list;
    });
  }

  void initState() {
    super.initState();
    initDimension();
  }

  showPickerModal(BuildContext context) {
    Picker(
        cancelText: '取消',
        confirmText: '确认',
        adapter: PickerDataAdapter<String>(pickerdata: _dimensionList),
        hideHeader: false,
        title: new Text("请选择统计维度"),
        selectedTextStyle: TextStyle(color: Colors.blue),
        onConfirm: (Picker picker, List value) {
          var _selected = picker.getSelectedValues();
          getChartData(_selected[0], _selected[2].toString(), _selected[3].toString());
          setState(() {
            _currentDimension = _selected[0];
          });
        }
    ).showModal(context);
  }

  Future<Null> getChartData(String type, String year, String month) async {
    var _select = ReportDimensions.DIMS.firstWhere((item) => item['Name']==type, orElse: ()=> null);
    var resp = await HttpRequest.request(
        '/Report/${widget.endpoint}',
        method: HttpRequest.POST,
        data: {
          'type': _select['ID'],
          'year': year,
          'month': month==' '?0:month,
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
        new FlatButton(
            onPressed: () {
              showPickerModal(context);
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
          DataColumn(label: Text(_currentDimension, textAlign: TextAlign.center, style: new TextStyle(color: Colors.blue, fontSize: 14.0),)),
          DataColumn(label: Text('当年故障率', textAlign: TextAlign.center, style: new TextStyle(color: Colors.blue, fontSize: 14.0),)),
          DataColumn(label: Text('去年故障率', textAlign: TextAlign.center, style: new TextStyle(color: Colors.blue, fontSize: 14.0),)),
          DataColumn(label: Text('同比（%）', textAlign: TextAlign.center, style: new TextStyle(color: Colors.blue, fontSize: 14.0),)),
        ],
        rows: _tableData.map((item) => DataRow(
            cells: [
              DataCell(Text(item['type'])),
              DataCell(Text(item['cur'].toString())),
              DataCell(Text(item['last'].toString())),
              DataCell(Text(item['ratio'].toString())),
            ]
        )).toList()
    );
    return new Card(
        child: new Container(
          height: _tableData.length*50.0+60.0,
          child: new ListView(
            scrollDirection: Axis.horizontal,
            controller: _scrollController,
            shrinkWrap: true,
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
          primaryXAxis: CategoryAxis(),
          series: <LineSeries<ServiceData, String>>[
            LineSeries<ServiceData, String>(
              // Bind data source
                dataSource: _tableData.map<ServiceData>((item) => ServiceData(item['type'], item['ratio'])).toList(),
                xValueMapper: (ServiceData data, _) => data.type,
                yValueMapper: (ServiceData data, _) => data.Growth,
                markerSettings: MarkerSettings(
                    isVisible: true
                ),
                dataLabelSettings: DataLabelSettings(
                  // Renders the data label
                    isVisible: true
                )
            )
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
              scrollDirection: Axis.vertical,
              controller: _scrollController,
              children: <Widget>[
                buildPickerRow(context),
                _tableData!=null&&_tableData.isNotEmpty?buildChart():new Container(),
                _tableData!=null&&_tableData.isNotEmpty?ShouldRebuild<BuildChart>(shouldRebuild: (_old, _new) => _old.tableData!=_new.tableData, child: BuildChart(labelY: widget.labelY, tableData: _tableData,),):new Container(),
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
  final double Growth;

  ServiceData(this.type, this.Growth);
}

class BuildChart extends StatelessWidget {
  final String labelY;
  final List tableData;
  BuildChart({this.labelY, this.tableData});

  Widget build(BuildContext context) {
    return new Container(
      child: SfCartesianChart(
        // Initialize category axis
          primaryXAxis: CategoryAxis(
              labelRotation: 90
          ),
          primaryYAxis: NumericAxis(
              title: AxisTitle(
                  text: labelY
              )
          ),
          series: <LineSeries<ServiceData, String>>[
            LineSeries<ServiceData, String>(
              // Bind data source
                dataSource: tableData.map<ServiceData>((item) => ServiceData(item['type'], item['ratio'])).toList(),
                xValueMapper: (ServiceData data, _) => data.type,
                yValueMapper: (ServiceData data, _) => data.Growth,
                markerSettings: MarkerSettings(
                    isVisible: true
                ),
                dataLabelSettings: DataLabelSettings(
                  // Renders the data label
                    isVisible: true
                )
            )
          ]
      ),
    );
  }
}
