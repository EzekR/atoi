import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:atoi/models/main_model.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/cupertino.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:atoi/utils/http_request.dart';

class ReportChart extends StatefulWidget {
  _ReportChartState createState() => _ReportChartState();
}

class _ReportChartState extends State<ReportChart> {

  List<charts.Series<dynamic, String>> seriesList;
  bool animate;

  List _dimensionList = [];
  List _rawList = [];
  List _tableData = [];
  String _tableName = '年份';

  Future<void> initDimension() async {
    var resp = await HttpRequest.request(
      '/Report/GetDimensionList',
      method: HttpRequest.GET
    );
    if (resp['ResultCode'] == '00') {
      var _data = resp['Data'];
      var _list = _data.map((item) => {
        item['Name'].toString(): item['ID']==2?[2010,2011,2012,2013,2014,2015,2016,2017,2018,2019]:[' ']
      }).toList();
      print(_list);
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
        }
    ).showDialog(context);
  }

  Future<Null> getChartData(String type, String year) async {
    var _select = _rawList.firstWhere((item) => item['Name']==type, orElse: ()=> null);
    var resp = await HttpRequest.request(
      '/Report/EquipmentCountReport',
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

  Column buildTable() {
    List<ListTile> _list = [
      ListTile(
        title: new Text(_tableName, style: new TextStyle(color: Colors.blue),),
        trailing: new Text('数据', style: new TextStyle(color: Colors.blue),),
        onTap: () {
        },
      )
    ];
    if (_tableData.length > 0) {
      for(var item in _tableData) {
        _list.add(
            ListTile(
              title: new Text(item['Item1']),
              trailing: new Text(item['Item2'].toString()),
            )
        );
      }
    }
    return new Column(
      children: _list,
    );
  }

  Container buildChart() {
    return new Container(
      height: _tableData.length*40.toDouble(),
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
              leading: new Icon(Icons.menu),
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
              children: <Widget>[
                buildPickerRow(context),
                seriesList==null?new Container():buildChart(),
                buildTable()
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