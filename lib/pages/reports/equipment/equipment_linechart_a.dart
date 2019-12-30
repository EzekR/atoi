import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:atoi/models/main_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:atoi/utils/http_request.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:atoi/utils/report_dimensions.dart';

class EquipmentLinechartA extends StatefulWidget {

  EquipmentLinechartA({Key key, this.chartName, this.endpoint, this.labelY}):super(key: key);
  final String endpoint;
  final String chartName;
  final String labelY;
  _EquipmentLinechartAState createState() => _EquipmentLinechartAState();
}

class _EquipmentLinechartAState extends State<EquipmentLinechartA> {

  bool animate;

  List _dimensionList = [];
  List _dimSlice = [];
  List _rawList = [];
  List _tableData = [];
  String _tableName = '年份';
  String _currentDimension = '';
  ScrollController _scrollController;
  String _dim1 = ReportDimensions.DIMS[3]['Name'];
  String _dim2 = ReportDimensions.TIME_TYPES[0];
  String _dim3 = ReportDimensions.YEARS[0].toString();
  String _dim4 = ReportDimensions.MONTHS[0].toString();

  Map _tableTitle = {
    'EquipmentRatioReport': ['当年数量', '去年数量', '增长率（%）'],
    'FailureRatioReport': ['当年故障率', '去年故障率', '同比（%）'],
    'BootRatioReport': ['当年开机率', '去年开机率', '同比（%）'],
    'ExpenditureRatioReport': ['当年支出', '去年支出', '同比（%）'],
    'EquipmentIncomeReport': ['当年收入', '去年收入', '同比（%）'],
    'EquipmentIncomeRatioReport': ['当年收入', '去年收入', '同比（%）'],
    'IncomeRatioExpenditureReport': ['收入', '支出', '收支比（%）'],
    'RepairRequestGrowthRatioReport': ['当年数量', '去年数量', '增长率（%）'],
    'RepairRatioReport?requestType=1&status=3': ['非供应商维修数', '维修总数', '自修率（%）'],
    'Supplier_RepairRatioReport?requestType=1&status=3': ['供应商维修数', '维修总数', '供应商维修率（%）'],
  };

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
    _currentDimension = _dim1;
    getChartData(_dim1, _dim3, _dim4);
  }

  showPickerModal(BuildContext context) {
    Picker(
        cancelText: '取消',
        confirmText: '确认',
        //selecteds: [_dimSlice.indexWhere((elem) => elem['Name']==_dim1)],
        adapter: PickerDataAdapter<String>(pickerdata: _dimensionList),
        hideHeader: false,
        title: new Text("请选择维度"),
        selectedTextStyle: TextStyle(color: Colors.blue),
        onConfirm: (Picker picker, List value) {
          var _selected = picker.getSelectedValues();
          getChartData(_selected[0], _selected[2].toString(), _selected[3].toString());
          setState(() {
            _currentDimension = _selected[0];
            _dim1 = _selected[0];
            _dim2 = _selected[1].toString();
            _dim3 = _selected[2].toString();
            _dim4 = _selected[3].toString();
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
          'month': month==' '?0:month
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
        new Text(_dim1),
        new Text(_dim2),
        new Text('年份:$_dim3'),
        new Text(_dim2=='月'?'月份:$_dim4':''),
      ],
    );
  }

  Card buildTable() {
    var _dataTable = new DataTable(
        columns: [
          DataColumn(label: Text(_currentDimension, textAlign: TextAlign.center, style: new TextStyle(color: Colors.blue, fontSize: 14.0),)),
          DataColumn(label: Text(_tableTitle[widget.endpoint][0], textAlign: TextAlign.center, style: new TextStyle(color: Colors.blue, fontSize: 14.0),)),
          DataColumn(label: Text(_tableTitle[widget.endpoint][1], textAlign: TextAlign.center, style: new TextStyle(color: Colors.blue, fontSize: 14.0),)),
          DataColumn(label: Text(_tableTitle[widget.endpoint][2], textAlign: TextAlign.center, style: new TextStyle(color: Colors.blue, fontSize: 14.0),)),
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
            labelRotation:60
          ),
          primaryYAxis: NumericAxis(
              title: AxisTitle(
                  text: widget.labelY
              )
          ),
          series: <LineSeries<EquipmentData, String>>[
            LineSeries<EquipmentData, String>(
              // Bind data source
                dataSource: _tableData.map<EquipmentData>((item) => EquipmentData(item['type'], item['ratio'])).toList(),
                xValueMapper: (EquipmentData data, _) => data.type,
                yValueMapper: (EquipmentData data, _) => data.Growth
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
                _tableData!=null&&_tableData.isNotEmpty?buildTable():new Center(
                  child: Text('暂无数据'),
                )
              ],
            )
        );
      },
    );
  }
}

class EquipmentData {
  final String type;
  final double Growth;

  EquipmentData(this.type, this.Growth);
}
