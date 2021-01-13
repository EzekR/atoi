import 'package:atoi/pages/valuation/valuation_analysis.dart';
import 'package:atoi/pages/valuation/valuation_equipment.dart';
import 'package:atoi/utils/common.dart';
import 'package:atoi/widgets/build_widget.dart';
import 'package:flutter/material.dart';
import 'package:atoi/utils/constants.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:date_format/date_format.dart';

class ValuationCondition extends StatefulWidget {
  final Map condition;
  final int historyID;
  ValuationCondition({Key key, this.condition, this.historyID}):super(key:key);
  _ValuationConditionState createState() => new _ValuationConditionState();
}

class _ValuationConditionState extends State<ValuationCondition> {

  bool editable = false;
  String startDate;
  String contractDate;
  TextEditingController contractYears = new TextEditingController();
  List hospitalLevels = [
    {
      'value': 1,
      'text': '1级'
    },
    {
      'value': 2,
      'text': '2级'
    },
    {
      'value': 3,
      'text': '3级'
    },
  ];
  int hospitalLevel = 1;
  String referenceFactor;
  TextEditingController importCosting = new TextEditingController();
  TextEditingController marginProfitRatio = new TextEditingController();
  TextEditingController riskRatio = new TextEditingController();
  TextEditingController varRatio = new TextEditingController();
  List varTypes = [
    {
      'value': 0,
      'text': '导入期'
    },
    {
      'value': 1,
      'text': '稳定期'
    },
  ];
  int varType = 0;
  String engineersEstimation;
  TextEditingController engineersReservation = new TextEditingController();

  void changeLevel(val) {
    setState(() {
      hospitalLevel = val;
    });
  }

  void changeVar(val) {
    setState(() {
      varType = val;
    });
  }

  void initState() {
    super.initState();
    startDate =  formatDate(DateTime.now(), [yyyy, '-', mm]);
    contractDate =  formatDate(DateTime.now(), [yyyy, '-', mm]);
  }

  List<Widget> buildConditions() {
    List<Widget> _list = [
      BuildWidget.buildRow('评估开始月', CommonUtil.TimeForm(widget.condition['AddDate'].toString(), 'yyyy-mm-dd')),
      BuildWidget.buildRow('合同开始月', CommonUtil.TimeForm(widget.condition['ContractStartDate'].toString(), 'yyyy-mm-dd')),
      BuildWidget.buildRow('合同年限', widget.condition['Years'].toString()),
      BuildWidget.buildRow('医院等级', widget.condition['HospitalLevel']['ID'].toString()+'级'),
      BuildWidget.buildRow('参考系数', widget.condition['HospitalFactor1'].toString()),
      BuildWidget.buildRow('导入期成本', widget.condition['ImportCost'].toString()),
      BuildWidget.buildRow('边际利润率', widget.condition['ProfitMargins'].toString()),
      BuildWidget.buildRow('风险控制度', widget.condition['RiskRatio'].toString()),
      BuildWidget.buildRow('VaR资产金额比例', widget.condition['VarAmount'].toString()),
      BuildWidget.buildRow('VaR类型', widget.condition['VaRType']['Name']),
      BuildWidget.buildRow('预测工程师数量', widget.condition['ComputeEngineer'].toString()),
      BuildWidget.buildRow('预定工程师数量', widget.condition['ForecastEngineer'].toString()),
      SizedBox(height: 18.0,),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RaisedButton(
            onPressed: () {
              Navigator.of(context).push(new MaterialPageRoute(builder: (_) => ValuationAnalysis(historyID: widget.historyID,)));
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            padding: EdgeInsets.all(12.0),
            color: new Color(0xff2E94B9),
            child: Text('执行结果', style: TextStyle(color: Colors.white)),
          ),
        ],
      )
    ];

    return _list;
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: Text('估价前提条件'),
        elevation: 0.7,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).accentColor
              ],
            ),
          ),
        ),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (val) {
              print(val);
              switch (val) {
                case 1:
                  Navigator.of(context).push(new MaterialPageRoute(builder: (_) => ValuationEquipment()));
                  break;
              }
            },
            icon: Icon(Icons.menu),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 1,
                child: Row(
                  children: <Widget>[
                    Icon(Icons.devices, color: Colors.blueAccent,),
                    SizedBox(width: 10.0,),
                    Text('设备清单')
                  ],
                ),
              ),
            ],
          )
        ],
      ),
      body: Card(
        child: ListView(
          children: editable?<Widget>[
            new Padding(
              padding: EdgeInsets.symmetric(vertical: 5.0),
              child: new Row(
                children: <Widget>[
                  new Expanded(
                    flex: 4,
                    child: new Wrap(
                      alignment: WrapAlignment.end,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: <Widget>[
                        new Text(
                          '*',
                          style: new TextStyle(
                              color: Colors.red
                          ),
                        ),
                        new Text(
                          '评估开始月',
                          style: new TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.w600),
                        )
                      ],
                    ),
                  ),
                  new Expanded(
                    flex: 1,
                    child: new Text(
                      '：',
                      style: new TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  new Expanded(
                    flex: 4,
                    child: new Text(
                      startDate,
                      style: new TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w400,
                          color: Colors.black54
                      ),
                    ),
                  ),
                  new Expanded(
                    flex: 2,
                    child: new IconButton(
                        icon: Icon(Icons.calendar_today, color: AppConstants.AppColors['btn_main'],),
                        onPressed: () async {
                          FocusScope.of(context).requestFocus(new FocusNode());
                          var _time = DateTime.tryParse(startDate)??DateTime.now();
                          DatePicker.showDatePicker(
                            context,
                            pickerTheme: DateTimePickerTheme(
                              showTitle: true,
                              confirm: Text('确认', style: TextStyle(color: Colors.blueAccent)),
                              cancel: Text('取消', style: TextStyle(color: Colors.redAccent)),
                            ),
                            minDateTime: DateTime.now().add(Duration(days: -7300)),
                            maxDateTime: DateTime.now().add(Duration(days: 365*10)),
                            initialDateTime: _time,
                            dateFormat: 'yyyy-MM',
                            locale: DateTimePickerLocale.en_us,
                            onClose: () => print(""),
                            onCancel: () => print('onCancel'),
                            onChange: (dateTime, List<int> index) {
                            },
                            onConfirm: (dateTime, List<int> index) {
                              var _date = formatDate(dateTime, [yyyy, '-', mm]);
                              setState(() {
                                startDate = _date;
                              });
                            },
                          );
                        }),
                  ),
                ],
              ),
            ),
            new Padding(
              padding: EdgeInsets.symmetric(vertical: 5.0),
              child: new Row(
                children: <Widget>[
                  new Expanded(
                    flex: 4,
                    child: new Wrap(
                      alignment: WrapAlignment.end,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: <Widget>[
                        new Text(
                          '*',
                          style: new TextStyle(
                              color: Colors.red
                          ),
                        ),
                        new Text(
                          '合同开始月',
                          style: new TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.w600),
                        )
                      ],
                    ),
                  ),
                  new Expanded(
                    flex: 1,
                    child: new Text(
                      '：',
                      style: new TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  new Expanded(
                    flex: 4,
                    child: new Text(
                      startDate,
                      style: new TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w400,
                          color: Colors.black54
                      ),
                    ),
                  ),
                  new Expanded(
                    flex: 2,
                    child: new IconButton(
                        icon: Icon(Icons.calendar_today, color: AppConstants.AppColors['btn_main'],),
                        onPressed: () async {
                          FocusScope.of(context).requestFocus(new FocusNode());
                          var _time = DateTime.tryParse(contractDate)??DateTime.now();
                          DatePicker.showDatePicker(
                            context,
                            pickerTheme: DateTimePickerTheme(
                              showTitle: true,
                              confirm: Text('确认', style: TextStyle(color: Colors.blueAccent)),
                              cancel: Text('取消', style: TextStyle(color: Colors.redAccent)),
                            ),
                            minDateTime: DateTime.now().add(Duration(days: -7300)),
                            maxDateTime: DateTime.now().add(Duration(days: 365*10)),
                            initialDateTime: _time,
                            dateFormat: 'yyyy-MM',
                            locale: DateTimePickerLocale.en_us,
                            onClose: () => print(""),
                            onCancel: () => print('onCancel'),
                            onChange: (dateTime, List<int> index) {
                            },
                            onConfirm: (dateTime, List<int> index) {
                              var _date = formatDate(dateTime, [yyyy, '-', mm]);
                              setState(() {
                                contractDate = _date;
                              });
                            },
                          );
                        }),
                  ),
                ],
              ),
            ),
            BuildWidget.buildInput('合同年限', contractYears, inputType: TextInputType.numberWithOptions(decimal: false), required: true, maxLength: 13, lines: 1),
            BuildWidget.buildDropdownWithList('医院等级', hospitalLevel, hospitalLevels, changeLevel, required: true),
            BuildWidget.buildRow('参考系数', referenceFactor??''),
            BuildWidget.buildInput('导入期成本', importCosting, inputType: TextInputType.numberWithOptions(), required: true, maxLength: 13, lines: 1),
            BuildWidget.buildInput('边际利润率', marginProfitRatio, inputType: TextInputType.numberWithOptions(), required: true, maxLength: 13, lines: 1),
            BuildWidget.buildInput('风险控制度', riskRatio, inputType: TextInputType.numberWithOptions(), required: true, maxLength: 13, lines: 1),
            BuildWidget.buildInput('VaR资产金额比例', varRatio, inputType: TextInputType.numberWithOptions(), required: true, maxLength: 13, lines: 1),
            BuildWidget.buildDropdownWithList('VaR类型', varType, varTypes, changeVar, required: true),
            Padding(
              padding: EdgeInsets.all(5.0),
              child: Row(
                children: <Widget>[
                  new Expanded(
                    flex: 4,
                    child: new Wrap(
                      alignment: WrapAlignment.end,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: <Widget>[
                        new Text(
                          '预测工程师数量',
                          style: new TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600
                          ),
                        )
                      ],
                    ),
                  ),
                  new Expanded(
                    flex: 1,
                    child: new Text(
                      '：',
                      style: new TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  new Expanded(
                    flex: 4,
                    child: new Text(
                      engineersEstimation??'',
                      style: new TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w400,
                          color: Colors.black54
                      ),
                    ),
                  ),
                  new Expanded(
                    flex: 2,
                    child: IconButton(
                      icon: Icon(Icons.refresh),
                      onPressed: () {

                      },
                      color: Colors.blueAccent,
                    ),
                  )
                ],
              ),
            ),
            BuildWidget.buildInput('预订工程师数量', engineersReservation, maxLength: 13, lines: 1, required: true),
            SizedBox(height: 18.0,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new RaisedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: EdgeInsets.all(12.0),
                  color: new Color(0xff2E94B9),
                  child:
                  Text('执行结果', style: TextStyle(color: Colors.white)),
                ),
              ],
            )
          ]:buildConditions(),
        ),
      ),
    );
  }
}