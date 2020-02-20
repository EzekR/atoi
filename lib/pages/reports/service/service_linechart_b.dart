import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:atoi/models/main_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:atoi/utils/http_request.dart';
import 'package:atoi_charts/charts.dart';
import 'package:atoi/utils/report_dimensions.dart';
import 'package:should_rebuild/should_rebuild.dart';

class ServiceLinechartB extends StatefulWidget {

  ServiceLinechartB({Key key, this.chartName, this.endpoint, this.status, this.requestType, this.labelY}):super(key: key);
  final String chartName;
  final String endpoint;
  final String requestType;
  final String status;
  final String labelY;
  _ServiceLinechartBState createState() => _ServiceLinechartBState();
}

class _ServiceLinechartBState extends State<ServiceLinechartB> {

  bool animate;

  List _dimensionList = [];
  List _rawList = [];
  List _tableData = [];
  String _tableName = '年份';
  String _currentDimension = '';
  ScrollController _scrollController;
  String _dim1 = '月';
  String _dim2 = '2020';
  List _years = ReportDimensions.YEARS;

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
    getChartData(_dim1, _dim2);
  }

  showPickerModal(BuildContext context) {
    Picker(
        cancelText: '取消',
        confirmText: '确认',
        selecteds: [_dim1=='年'?0:1, _dim2==' '?0:_years.indexOf(int.parse(_dim2))],
        adapter: PickerDataAdapter<String>(pickerdata: _dimensionList),
        hideHeader: false,
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
    ).showModal(context);
  }

  Future<Null> getChartData(String type, String year) async {
    var _data = {};
    if (type == '月') {
      _data['year'] = year;
    } else {
      _data['year'] = 0;
    }
    var resp = await HttpRequest.request(
        '/Report/${widget.endpoint}',
        method: HttpRequest.POST,
        data: _data
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
        new Text('时间维度分类：$_dim1'),
        new Text(_dim1=='月'?'年份：$_dim2':_dim2),
      ],
    );
  }

  String trimNum(String num) {
    var _list = num.split('.');
    if (_list[1] == '0') {
      return _list[0];
    } else {
      return num;
    }
  }

  Card buildTable() {
    var _dataTable = new DataTable(
        columns: [
          DataColumn(label: Text('类型', textAlign: TextAlign.center, style: new TextStyle(color: Colors.blue, fontSize: 14.0),)),
          DataColumn(label: Text('达标数量', textAlign: TextAlign.center, style: new TextStyle(color: Colors.blue, fontSize: 14.0),)),
          DataColumn(label: Text('总数量', textAlign: TextAlign.center, style: new TextStyle(color: Colors.blue, fontSize: 14.0),)),
          DataColumn(label: Text('达标率（%）', textAlign: TextAlign.center, style: new TextStyle(color: Colors.blue, fontSize: 14.0),)),
        ],
        rows: _tableData.map((item) => DataRow(
            cells: [
              DataCell(Text(item['type'])),
              DataCell(Text(trimNum(item['cur'].toString()))),
              DataCell(Text(trimNum(item['last'].toString()))),
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
  final ScrollController scrollController;
  BuildChart({this.labelY, this.tableData, this.scrollController});

  Widget build(BuildContext context) {
    print(tableData.length);
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
                      ),
                      majorTickLines: MajorTickLines(
                        width: 0
                      )
                    ),
                    primaryYAxis: NumericAxis(
                        title: AxisTitle(
                            text: labelY
                        ),
                        minimum: 0,
                        maximum: 100,
                        interval: 10,
                        majorGridLines: MajorGridLines(
                          dashArray: [5, 5]
                        )
                    ),
                    tooltipBehavior: TooltipBehavior(
                      enable: true,
                      header: labelY
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
              ),

            ],
          ),
        )
    );
  }
}

