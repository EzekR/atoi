import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:atoi/models/main_model.dart';
import 'package:should_rebuild/should_rebuild.dart';
import 'package:atoi_charts/charts.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:atoi/utils/http_request.dart';
import 'package:atoi/utils/report_dimensions.dart';

class ServiceBarchartB extends StatefulWidget {

  ServiceBarchartB({Key key, this.endpoint, this.chartName, this.requestType, this.status, this.labelY}):super(key: key);
  final String endpoint;
  final String chartName;
  final String requestType;
  final String status;
  final String labelY;
  _ServiceBarchartBState createState() => _ServiceBarchartBState();
}

class _ServiceBarchartBState extends State<ServiceBarchartB> {

  bool animate;

  List _dimensionList = [];
  List _dimSlice = [];
  List _rawList = [];
  List _tableData = [];
  String _tableName = '年份';
  String _currentDimension = '';
  String _dim1 = ReportDimensions.DIMS[2]['Name'];
  String _dim2 = '年';
  List _years = ReportDimensions.YEARS;
  ScrollController _scrollController;

  Future<void> initDimension() async {
    setState(() {
      _dimSlice = ReportDimensions.DIMS.sublist(2, 8);
    });
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
    getChartData(_dim1, '2020');
  }

  showPickerDialog(BuildContext context) {
    Picker(
        cancelText: '取消',
        confirmText: '确认',
        selecteds: [_dimSlice.indexWhere((item) => item['Name']==_dim1), _dim2=='年'?0:1],
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
    var _select = ReportDimensions.DIMS.firstWhere((item) => item['Name']==type, orElse: ()=> null);
    var resp = await HttpRequest.request(
        '/Report/${widget.endpoint}',
        method: HttpRequest.POST,
        data: {
          'type': _select['ID'],
          'year': 2020,
          'month': 0
        }
    );
    if (resp['ResultCode'] == '00') {
      var _data = resp['Data'];
      var _list = _data.map<ServiceData>((item) => new ServiceData(item['Item1'], item['Item2'])).toList();
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
                new Text('维度', style: new TextStyle(color: Colors.white),)
              ],
            )
        ),
        new Text('$_dim1'),
        new Text('时间维度分类: $_dim2')
      ],
    );
  }

  Card buildTable() {
    var _dataTable = new DataTable(
        columns: [
          DataColumn(label: Text(_currentDimension, textAlign: TextAlign.center, style: new TextStyle(color: Colors.blue, fontSize: 14.0),)),
          DataColumn(label: Text('请求数量（条）', textAlign: TextAlign.center, style: new TextStyle(color: Colors.blue, fontSize: 14.0),)),
        ],
        rows: _tableData.map((item) => DataRow(
            cells: [
              DataCell(Text(item['Item1'])),
              DataCell(Text(item['Item2'].toString().split('.')[0]))
            ]
        )).toList()
    );
    return new Card(
      child: _dataTable,
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
                _tableData!=null&&_tableData.isNotEmpty?ShouldRebuild<BuildChart>(shouldRebuild: (_old, _new) => _old.tableData!=_new.tableData, child: BuildChart(labelY: widget.labelY, tableData: _tableData, scrollController: _scrollController,),):new Container(),
                new SizedBox(height: 22.0,),
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

class BuildChart extends StatelessWidget {
  final String labelY;
  final List tableData;
  final ScrollController scrollController;
  BuildChart({this.labelY, this.tableData, this.scrollController});

  Widget build(BuildContext context) {
    print(tableData.length);
    var max = tableData.reduce((a, b) => b['Item2']>=a['Item2']?b:a);
    return new Card(
        child: new Container(
          height: 400.0,
          child: new ListView(
            scrollDirection: Axis.horizontal,
            controller: scrollController,
            shrinkWrap: true,
            children: <Widget>[
              new Container(
                width: tableData.length>10?tableData.length*50.0:400.0,
                child: SfCartesianChart(
                  // Initialize category axis
                    primaryXAxis: CategoryAxis(
                        labelRotation: 90,
                        majorGridLines: MajorGridLines(
                            width: 0
                        )
                    ),
                    primaryYAxis: NumericAxis(
                        title: AxisTitle(
                            text: labelY
                        ),
                        majorGridLines: MajorGridLines(
                            dashArray: [5, 5]
                        ),
                        minimum: 0,
                        interval: max['Item2']<10?1:(max['Item2']~/10).toDouble(),
                    ),
                    tooltipBehavior: TooltipBehavior(
                      enable: true,
                      header: labelY
                    ),
                    series: <ChartSeries<ServiceData, String>>[
                      ColumnSeries<ServiceData, String>(
                        // Bind data source
                          dataSource: tableData.map<ServiceData>((item) => ServiceData(item['Item1'], item['Item2'])).toList(),
                          xValueMapper: (ServiceData data, _) => data.type,
                          yValueMapper: (ServiceData data, _) => data.amount,
                          dataLabelSettings: DataLabelSettings(
                            // Renders the data label
                              isVisible: true,
                              labelAlignment: ChartDataLabelAlignment.outer
                          ),
                          enableTooltip: true
                      )
                    ]
                ),
              ),
            ],
          ),
        )
    );
  }
}
