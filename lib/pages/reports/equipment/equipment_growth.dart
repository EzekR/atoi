import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:atoi/models/main_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:atoi/utils/http_request.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class EquipmentGrowth extends StatefulWidget {
  static String tag = '设备增长率';
  _EquipmentGrowthState createState() => _EquipmentGrowthState();
}

class _EquipmentGrowthState extends State<EquipmentGrowth> {

  bool animate;

  List _dimensionList = [];
  List _rawList = [];
  List _tableData = [];
  String _tableName = '年份';
  String _currentDimension = '';
  ScrollController _scrollController;

  Future<void> initDimension() async {
    var resp = await HttpRequest.request(
        '/Report/GetDimensionList',
        method: HttpRequest.GET
    );
    if (resp['ResultCode'] == '00') {
      var _data = resp['Data'];
      List _list = [];
      List _years = [];
      List _months = [];
      for(var i=1969; i<2020; i++) {
        _years.add({
          i.toString(): [' ']
        });
        _months.add({
          i.toString(): [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
        });
      }
      for(var i=2; i<_data.length; i++) {
        _list.add(
          {
            _data[i]['Name'].toString(): [
              {
                '年': _years
              },
              {
                '月': _months
              }
            ]
          }
        );
      }
      setState(() {
        _dimensionList = _list;
        _rawList = _data;
      });
    }
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
        title: new Text("请选择维度"),
        selectedTextStyle: TextStyle(color: Colors.blue),
        onConfirm: (Picker picker, List value) {
          var _selected = picker.getSelectedValues();
          getChartData(_selected[0], _selected[2], _selected[3]);
          setState(() {
            _currentDimension = _selected[0];
          });
        }
    ).showModal(context);
  }

  Future<Null> getChartData(String type, String year, String month) async {
    var _select = _rawList.firstWhere((item) => item['Name']==type, orElse: ()=> null);
    var resp = await HttpRequest.request(
        '/Report/EquipmentRatioReport',
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
          DataColumn(label: Text('类型', textAlign: TextAlign.center, style: new TextStyle(color: Colors.blue, fontSize: 14.0),)),
          DataColumn(label: Text('当年', textAlign: TextAlign.center, style: new TextStyle(color: Colors.blue, fontSize: 14.0),)),
          DataColumn(label: Text('去年', textAlign: TextAlign.center, style: new TextStyle(color: Colors.blue, fontSize: 14.0),)),
          DataColumn(label: Text('增长率（%）', textAlign: TextAlign.center, style: new TextStyle(color: Colors.blue, fontSize: 14.0),)),
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
        height: _tableData.length*50.0,
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
              scrollDirection: Axis.vertical,
              controller: _scrollController,
              children: <Widget>[
                buildPickerRow(context),
                _tableData!=null&&_tableData.isNotEmpty?buildChart():new Container(),
                _tableData!=null&&_tableData.isNotEmpty?buildTable():new Container()
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
