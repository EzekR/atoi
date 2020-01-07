import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:atoi/models/main_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:atoi/utils/http_request.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:atoi/utils/report_dimensions.dart';

class ServiceLinechart extends StatefulWidget {

  ServiceLinechart({Key key, this.chartName, this.endpoint, this.status, this.requestType, this.labelY}):super(key: key);
  final String chartName;
  final String endpoint;
  final String requestType;
  final String status;
  final String labelY;
  _ServiceLinechartState createState() => _ServiceLinechartState();
}

class _ServiceLinechartState extends State<ServiceLinechart> {

  bool animate;

  List _dimensionList = [];
  List _dimSlice = [];
  List _rawList = [];
  List _tableData = [];
  String _tableName = '年份';
  String _currentDimension = '';
  ScrollController _scrollController;
  String _dim1 = ReportDimensions.DIMS[2]['Name'];
  String _dim2 = ReportDimensions.TIME_TYPES[0];

  Map _tableTitle = {
    'RequestRatioReport?requestType=1&status=4': ['响应数量', '计划总数'],
    'DispatchRatio?status=4': ['执行数', '派工总数'],
    'RequestRatioReport?requestType=2&status=3': ['实际数量', '计划总数'],
    'RequestRatioReport?requestType=4&status=3': ['实际数量', '计划总数'],
    'RequestRatioReport?requestType=3&status=3': ['实际数量', '计划总数'],
    'RequestRatioReport?requestType=5&status=3': ['实际数量', '计划总数'],
    'RequestRatioReport?requestType=10&status=4': ['响应数量', '计划总数'],
    'RequestRatioReport?requestType=10&status=3': ['完成数量', '计划总数'],
  };

  Future<void> initDimension() async {
    _dimSlice = ReportDimensions.DIMS.sublist(2, 8);
    List _list = _dimSlice.map((item) => {
      item['Name'].toString(): [
        '年',
        '月'
      ]
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

  showPickerModal(BuildContext context) {
    Picker(
        cancelText: '取消',
        confirmText: '确认',
        adapter: PickerDataAdapter<String>(pickerdata: _dimensionList),
        hideHeader: false,
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
    ).showModal(context);
  }

  Future<Null> getChartData(String type, String year) async {
    var _select = ReportDimensions.DIMS.firstWhere((item) => item['Name']==type, orElse: ()=> null);
    var resp = await HttpRequest.request(
        '/Report/${widget.endpoint}',
        method: HttpRequest.POST,
        data: {
          'type': _select['ID'],
          'byYear': year=='年'?true:false,
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
              showPickerModal(context);
            },
            child: new Row(
              children: <Widget>[
                new Icon(Icons.timeline, color: Colors.white,),
                new Text('维度', style: TextStyle(color: Colors.white),)
              ],
            )
        ),
        new Text(_dim1??''),
        new Text(_dim2),
      ],
    );
  }

  Card buildTable() {
    var _dataTable = new DataTable(
        columns: [
          DataColumn(label: Text(_currentDimension, textAlign: TextAlign.center, style: new TextStyle(color: Colors.blue, fontSize: 14.0),)),
          DataColumn(label: Text(_tableTitle[widget.endpoint][0], textAlign: TextAlign.center, style: new TextStyle(color: Colors.blue, fontSize: 14.0),)),
          DataColumn(label: Text(_tableTitle[widget.endpoint][1], textAlign: TextAlign.center, style: new TextStyle(color: Colors.blue, fontSize: 14.0),)),
          DataColumn(label: Text(widget.labelY, textAlign: TextAlign.center, style: new TextStyle(color: Colors.blue, fontSize: 14.0),)),
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
          primaryXAxis: CategoryAxis(
            labelRotation: 60
          ),
          primaryYAxis: NumericAxis(
              title: AxisTitle(
                  text: widget.labelY
              )
          ),
          series: <LineSeries<ServiceData, String>>[
            LineSeries<ServiceData, String>(
              // Bind data source
                dataSource: _tableData.map<ServiceData>((item) => ServiceData(item['type'], item['ratio'])).toList(),
                xValueMapper: (ServiceData data, _) => data.type,
                yValueMapper: (ServiceData data, _) => data.Growth
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
  final double Growth;

  ServiceData(this.type, this.Growth);
}
