import 'dart:developer';

import 'package:atoi/pages/valuation/valuation_detail.dart';
import 'package:atoi/utils/common.dart';
import 'package:atoi/utils/http_request.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:atoi_charts/charts.dart';

class ValuationAnalysis extends StatefulWidget {
  final int historyID;
  final String pageState;
  ValuationAnalysis({Key key, this.historyID, this.pageState}):super(key: key);
  _ValuationAnalysisState createState() => new _ValuationAnalysisState();
}

class _ValuationAnalysisState extends State<ValuationAnalysis> {

  int currentTable = 0;
  bool showCost = true;
  int currentYear = 0;
  int currentMonth = 0;
  Map tableData;
  List<ColumnTotal> columnTotal = [];
  ColumnDetail columnActual;
  List<ColumnDetail> columnForecast = [];

  void getTableData() async {
    Map resp = await HttpRequest.request(
      '/Valuation/ValResult',
      method: HttpRequest.GET,
      params: {
        'valHisID': widget.historyID,
        'priceOnly': currentTable==1,
        'amountOnly': currentTable==0||currentTable==2
      }
    );
    if (resp['ResultCode'] == '00') {
      setState(() {
        tableData = resp['Data'];
      });
      currentTable==1?initColumnTotal():initColumnDetail();
    }
  }

  void initColumnTotal() {
    // total column
    columnTotal.clear();
    ColumnTotal _columnTotal = new ColumnTotal(
      year: '小计',
      total: tableData['AmountTotal'],
      fixed: tableData['FixedAmountTotal'],
      consumable: tableData['ConsumableAmountTotal'],
      repair: tableData['RepairAmountTotal'],
      importCost: tableData['ImportAmountTotal'],
      totalCost: tableData['TotalAmountTotal'],
      marginProfit: tableData['VaRProfitTotal'],
      marginRatio: tableData['VaRRates'],
      safeAmount: tableData['SafeProfitTotal'],
      quotation: tableData['PriceTotal']
    );
    columnTotal.add(_columnTotal);
    for (int i=0; i<tableData['FixedForecastAmount'].length; i++) {
      Map item = tableData['FixedForecastAmount'][i];
      List<ColumnTotal> _monthData = [];
      for(int j=0; j<tableData['FixedForecastAmount'][i]['data'].length; j++) {
        log("${tableData['ImportAmount'][i]['data'][j]}");
        ColumnTotal _columnMonth = new ColumnTotal(
            month: tableData['ForecastDate'][i*12+j]['Name'],
            total: tableData['AmountForecast'][i]['data'][j],
            fixed: item['data'][j],
            consumable: tableData['ConsumableForecastAmount'][i]['data'][j],
            repair: tableData['RepairForecastAmount'][i]['data'][j],
            importCost: tableData['ImportAmount'][i]['data'][j],
            totalCost: tableData['TotalAmount'][i]['data'][j],
            marginProfit: tableData['VaRProfit'][i]['data'][j],
            marginRatio: tableData['VaRRate'][i]['data'][j],
            safeAmount: tableData['SafeProfit'][i]['data'][j],
            quotation: tableData['Price'][i]['data'][j]
        );
        _monthData.add(_columnMonth);
      }
      ColumnTotal _columnTotal = new ColumnTotal(
        year: '第${item['year'].toStringAsFixed(0)}年',
        total: tableData['AmountForecast'][i]['sum'],
        fixed: item['sum'],
        consumable: tableData['ConsumableForecastAmount'][i]['sum'],
        repair: tableData['RepairForecastAmount'][i]['sum'],
        importCost: tableData['ImportAmount'][i]['sum'],
        totalCost: tableData['TotalAmount'][i]['sum'],
        marginProfit: tableData['VaRProfit'][i]['sum'],
        marginRatio: tableData['VaRRate'][i]['data'][0],
        safeAmount: tableData['SafeProfit'][i]['sum'],
        quotation: tableData['Price'][i]['sum'],
        monthDetail: _monthData
      );
      columnTotal.add(_columnTotal);
    }

    setState(() {
      columnTotal = columnTotal;
    });
  }

  void initColumnDetail() {
    columnForecast.clear();
    List<ColumnDetail> _month = [];
    for(int i=0; i<tableData['ActualDate'].length; i++) {
      Map item = tableData['ActualDate'][i];
      ColumnDetail _detail = new ColumnDetail(
        month: item['Name'],
        total: tableData['AmountActual'][0]['data'][i],
        fixed: tableData['FixedActualAmount'][0]['data'][i],
        system: tableData['SystemActualAmount'][0]['data'][i],
        labour: tableData['LabourActualAmount'][0]['data'][i],
        repairAndMaintain: tableData['ContractActualAmount'][0]['data'][i],
        maintain: tableData['ConsumableActualAmount'][0]['data'][i],
        spare: tableData['SpareActualAmount'][0]['data'][i],
        consumable: tableData['ConsumableActualAmount'][0]['data'][i],
        fixedPeriod: tableData['RegularActualAmount'][0]['data'][i],
        fixedQuantity: tableData['QuanTityActualAmount'][0]['data'][i],
        small: tableData['SmallActualAmount'][0]['data'][i],
        repair: tableData['RepairActualAmount'][0]['data'][i],
        componentCost: tableData['ComponentActualAmount'][0]['data'][i],
        essential: tableData['ImportantComponentActualAmount'][0]['data'][i],
        common: tableData['GeneralComponentActualAmount'][0]['data'][i],
        service: tableData['Repair3partyActualCost'][0]['data'][i],
        serviceEssential: tableData['ImportantRepair3partyActualCost'][0]['data'][i],
        serviceCommon: tableData['GeneralRepair3partyActualCost'][0]['data'][i],
      );
      _month.add(_detail);
    }

    ColumnDetail actual = new ColumnDetail(
      year: "第1年",
      total: tableData['AmountActual'][0]['sum'],
      fixed: tableData['FixedActualAmount'][0]['sum'],
      system: tableData['SystemActualAmount'][0]['sum'],
      labour: tableData['LabourActualAmount'][0]['sum'],
      repairAndMaintain: tableData['ContractActualAmount'][0]['sum'],
      maintain: tableData['ConsumableActualAmount'][0]['sum'],
      spare: tableData['SpareActualAmount'][0]['sum'],
      consumable: tableData['ConsumableActualAmount'][0]['sum'],
      fixedPeriod: tableData['RegularActualAmount'][0]['sum'],
      fixedQuantity: tableData['QuanTityActualAmount'][0]['sum'],
      small: tableData['SmallActualAmount'][0]['sum'],
      repair: tableData['RepairActualAmount'][0]['sum'],
      componentCost: tableData['ComponentActualAmount'][0]['sum'],
      essential: tableData['ImportantComponentActualAmount'][0]['sum'],
      common: tableData['GeneralComponentActualAmount'][0]['sum'],
      service: tableData['Repair3partyActualCost'][0]['sum'],
      serviceEssential: tableData['ImportantRepair3partyActualCost'][0]['sum'],
      serviceCommon: tableData['GeneralRepair3partyActualCost'][0]['sum'],
      monthDetail: _month
    );

    List<ColumnDetail> forecast = [];
    for(int j=0; j<tableData['AmountForecast'].length; j++) {
      Map item = tableData['AmountForecast'][j];
      List<ColumnDetail> _month = [];
      for(int k=0; k<tableData['AmountForecast'][0]['data'].length; k++) {
        ColumnDetail _monthDetail = new ColumnDetail(
          month: tableData['ForecastDate'][k+12*j]['Name'],
          total: tableData['AmountForecast'][j]['data'][k],
          fixed: tableData['FixedForecastAmount'][j]['data'][k],
          system: tableData['SystemForecastAmount'][j]['data'][k],
          labour: tableData['LabourForecastAmount'][j]['data'][k],
          repairAndMaintain: tableData['ContractForecastAmount'][j]['data'][k],
          maintain: tableData['ConsumableForecastAmount'][j]['data'][k],
          spare: tableData['SpareForecastAmount'][j]['data'][k],
          consumable: tableData['ConsumableForecastAmount'][j]['data'][k],
          fixedPeriod: tableData['RegularForecastAmount'][j]['data'][k],
          fixedQuantity: tableData['QuanTityForecastAmount'][j]['data'][k],
          small: tableData['SmallForecastAmount'][j]['data'][k],
          repair: tableData['RepairForecastAmount'][j]['data'][k],
          componentCost: tableData['ComponentForecastAmount'][j]['data'][k],
          essential: tableData['ImportantComponentForecastAmount'][j]['data'][k],
          common: tableData['GeneralComponentForecastAmount'][j]['data'][k],
          service: tableData['Repair3partyForecastCost'][j]['data'][k],
          serviceEssential: tableData['ImportantRepair3partyForecastCost'][j]['data'][k],
          serviceCommon: tableData['GeneralRepair3partyForecastCost'][j]['data'][k],
        );
        _month.add(_monthDetail);
      }
      ColumnDetail _detail = new ColumnDetail(
          year: "第${item['year'].toStringAsFixed(0)}年",
          total: tableData['AmountForecast'][j]['sum'],
          fixed: tableData['FixedForecastAmount'][j]['sum'],
          system: tableData['SystemForecastAmount'][j]['sum'],
          labour: tableData['LabourForecastAmount'][j]['sum'],
          repairAndMaintain: tableData['ContractForecastAmount'][j]['sum'],
          spare: tableData['SpareForecastAmount'][j]['sum'],
          consumable: tableData['ConsumableForecastAmount'][j]['sum'],
          maintain: tableData['ConsumableForecastAmount'][j]['sum'],
          fixedPeriod: tableData['RegularForecastAmount'][j]['sum'],
          fixedQuantity: tableData['QuanTityForecastAmount'][j]['sum'],
          small: tableData['SmallForecastAmount'][j]['sum'],
          repair: tableData['RepairForecastAmount'][j]['sum'],
          componentCost: tableData['ComponentForecastAmount'][j]['sum'],
          essential: tableData['ImportantComponentForecastAmount'][j]['sum'],
          common: tableData['GeneralComponentForecastAmount'][j]['sum'],
          service: tableData['Repair3partyForecastCost'][j]['sum'],
          serviceEssential: tableData['ImportantRepair3partyForecastCost'][j]['sum'],
          serviceCommon: tableData['GeneralRepair3partyForecastCost'][j]['sum'],
          monthDetail: _month
      );
      forecast.add(_detail);
    }
    ColumnDetail total = new ColumnDetail(
      year: "小计",
      total: tableData['AmountTotal'],
      fixed: tableData['FixedAmountTotal'],
      system: tableData['SystemAmountTotal'],
      labour: tableData['LabourAmountTotal'],
      repairAndMaintain: tableData['ContractAmountTotal'],
      spare: tableData['SpareAmountTotal'],
      consumable: tableData['ConsumableAmountTotal'],
      maintain: tableData['ConsumableAmountTotal'],
      fixedPeriod: tableData['RegularAmountTotal'],
      fixedQuantity: tableData['QuanTityAmountTotal'],
      small: tableData['SmallAmountTotal'],
      repair: tableData['RepairAmountTotal'],
      componentCost: tableData['ComponentAmountTotal'],
      essential: tableData['ImportantComponentAmountTotal'],
      common: tableData['GeneralComponentAmountTotal'],
      service: tableData['Repair3partyCostTotal'],
      serviceEssential: tableData['ImportantRepair3partyCostTotal'],
      serviceCommon: tableData['GeneralRepair3partyCostTotal'],
    );
    forecast.add(total);

    setState(() {
      columnActual = actual;
      columnForecast = forecast;
    });
    initChartData();
    initLineData();
  }

  void initState() {
    super.initState();
    getTableData();
  }

  List<Widget> buildTotal() {
    List<Widget> _list = [];

    return _list;
  }

  Container _buildContainerRow(Color fontColor, {String header, String tail}) {
    return Container(
      height: 30.0,
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
                  color: Color.fromRGBO(0, 0, 0, 0.19),
                  width: 1.0,
                  style: BorderStyle.solid
              )
          )
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(header??'',
            style: TextStyle(
                color: fontColor,
                fontSize: 13.0
            ),
          ),
          Text(tail??'',
            style: TextStyle(
                color: fontColor,
                fontSize: 16.0
            ),
          ),
        ],
      ),
    );
  }

  Container _buildContainerSplit(Color fontColor, {String headerLeft, String tailLeft, String headerRight, String tailRight}) {
    return Container(
      height: 30.0,
      decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
                  color: Color.fromRGBO(0, 0, 0, 0.19),
                  width: 1.0,
                  style: BorderStyle.solid
              )
          )
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 6,
            child: Container(
              height: 30.0,
              decoration: BoxDecoration(
                  border: Border(
                      right: BorderSide(
                          color: Color.fromRGBO(0, 0, 0, 0.19),
                          width: 1.0,
                          style: BorderStyle.solid
                      )
                  )
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 12, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      headerLeft??'',
                      style: TextStyle(
                          color: fontColor,
                          fontSize: 11.0,
                          fontWeight: FontWeight.w300
                      ),
                    ),
                    Text(
                      tailLeft??'',
                      style: TextStyle(
                          color: fontColor,
                          fontSize: 11.0,
                          fontWeight: FontWeight.w300
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Container(
              child: Padding(
                padding: EdgeInsets.fromLTRB(12, 0, 0, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      headerRight??'',
                      style: TextStyle(
                          color: fontColor,
                          fontSize: 11.0,
                          fontWeight: FontWeight.w300
                      ),
                    ),
                    Text(
                      tailRight??'',
                      style: TextStyle(
                          color: fontColor,
                          fontSize: 11.0,
                          fontWeight: FontWeight.w300
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Stack buildTopStack() {
    return Stack(
      children: <Widget>[
        Column(
          children: <Widget>[
            Container(
              height: 80.0,
              color: Color(0xff1D3F82),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.fromLTRB(16.0, 7.0, 0, 0),
                          child: Text("Actual",
                            style: TextStyle(
                                fontSize: 13.0,
                                color: Color.fromRGBO(255, 255, 255, 0.87)
                            ),
                          )
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.fromLTRB(16.0, 0, 0, 0),
                        child: Text(
                          CommonUtil.CurrencyForm(columnActual?.total, times: 1000, digits: 0, isFloor: false),
                          style: TextStyle(
                              fontSize: 22.0,
                              color: Colors.white,
                              fontWeight: FontWeight.w400
                          ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 0, 16, 0),
                          child: Text(
                            '单位：千元',
                            style: TextStyle(
                                fontSize: 14.0,
                                color: Color.fromRGBO(255, 255, 255, 0.87),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              AnimatedContainer(
                color: Color(0xff41579B),
                height: showCost?340.0:0.0,
                duration: Duration(milliseconds: 200),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16.0, 0, 16, 6),
                  child: Column(
                    children: <Widget>[
                      _buildContainerRow(Colors.white, header: '固定类', tail: CommonUtil.CurrencyForm(columnActual.fixed, times: 1000, digits: 0, isFloor: false)),
                      _buildContainerSplit(Colors.white, headerLeft: '信息系统使用费', tailLeft: CommonUtil.CurrencyForm(columnActual.system, times: 1000, digits: 0, isFloor: false,),
                        headerRight: '人工费', tailRight: CommonUtil.CurrencyForm(columnActual.labour, times: 1000, digits: 0, isFloor: false)
                      ),
                      _buildContainerSplit(Colors.white, headerLeft: '维保费', tailLeft: CommonUtil.CurrencyForm(columnActual.repairAndMaintain, times: 1000, digits: 0, isFloor: false),
                        headerRight: '备用机成本', tailRight: CommonUtil.CurrencyForm(columnActual.spare, times: 1000, digits: 0, isFloor: false)
                      ),
                      _buildContainerRow(Colors.white, header: '变动类-保养', tail: CommonUtil.CurrencyForm(columnActual?.maintain, times: 1000, digits: 0, isFloor: false)),
                      _buildContainerSplit(Colors.white, headerLeft: '耗材费', tailLeft: CommonUtil.CurrencyForm(columnActual.consumable, times: 1000, digits: 0, isFloor: false),
                          headerRight: '定期类', tailRight: CommonUtil.CurrencyForm(columnActual.fixedPeriod, times: 1000, digits: 0, isFloor: false)
                      ),
                      _buildContainerSplit(Colors.white, headerLeft: '定量类', tailLeft: CommonUtil.CurrencyForm(columnActual.fixedQuantity, times: 1000, digits: 0, isFloor: false),
                          headerRight: '小额汇总成本', tailRight: CommonUtil.CurrencyForm(columnActual.small, times: 1000, digits: 0, isFloor: false)
                      ),
                      _buildContainerRow(Colors.white, header: '变动类-维修', tail: CommonUtil.CurrencyForm(columnActual.repair, times: 1000, digits: 0, isFloor: false)),
                      _buildContainerSplit(Colors.white, headerLeft: '故障零件成本', tailLeft: CommonUtil.CurrencyForm(columnActual.componentCost, times: 1000, digits: 0, isFloor: false),
                          headerRight: '', tailRight: '',
                      ),
                      _buildContainerSplit(Colors.white, headerLeft: '重点设备', tailLeft: CommonUtil.CurrencyForm(columnActual.essential, times: 1000, digits: 0, isFloor: false),
                          headerRight: '一般设备', tailRight: CommonUtil.CurrencyForm(columnActual.common, times: 1000, digits: 0, isFloor: false)
                      ),
                      _buildContainerSplit(Colors.white, headerLeft: '外来服务费', tailLeft: CommonUtil.CurrencyForm(columnActual.service, times: 1000, digits: 0, isFloor: false),
                        headerRight: '', tailRight: '',
                      ),
                      _buildContainerSplit(Colors.white, headerLeft: '重点设备', tailLeft: CommonUtil.CurrencyForm(columnActual.serviceEssential, times: 1000, digits: 0, isFloor: false),
                          headerRight: '一般设备', tailRight: CommonUtil.CurrencyForm(columnActual.serviceCommon, times: 1000, digits: 0, isFloor: false)
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Column(
            children: <Widget>[
              SizedBox(height: 30.0,),
              Align(
                alignment: FractionalOffset(0.5, 1.0),
                child: IconButton(
                  icon: Icon(Icons.arrow_drop_down_circle),
                  color: Color(0xff16A2B8),
                  iconSize: 28.0,
                  onPressed: () {
                    setState(() {
                      showCost = !showCost;
                    });
                  },
                ),
              )
            ],
          ),
        ],
      );
  }

  GestureDetector _buildAnnualTab(int index, {ColumnTotal columnTotal, ColumnDetail columnDetail}) {
    bool active = index == currentYear;
    return GestureDetector(
      onTap: () {
        setState(() {
          currentYear = index;
        });
      },
      child: Container(
        width: 120,
        decoration: BoxDecoration(
            color: active?Color(0xffE3F2FF):Color(0xff1A4182),
            border: Border(
                right: BorderSide(
                    color: Color(0xffE3F2FF),
                    width: 1.0,
                    style: BorderStyle.solid
                )
            )
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(18.0, 3, 0, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                height: 30,
                child: Text(
                  columnTotal!=null?columnTotal.year:columnDetail.year,
                  style: TextStyle(
                      fontSize: 13.0,
                      color: active?Color.fromRGBO(0, 0, 0, 0.85):Colors.white
                  ),
                ),
              ),
              Container(
                child: Text(
                  '${CommonUtil.CurrencyForm(columnTotal!=null?columnTotal.quotation:columnDetail.total, digits: 0, isFloor: false, times: 1000)}',
                  style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400,
                      color: active?Color.fromRGBO(0, 0, 0, 0.85):Colors.white
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Container buildAnnualSlider() {
    List<Widget> _list = [];
    switch (currentTable) {
      case 1:
        _list.addAll(columnTotal.asMap().keys.map((index) {
          return _buildAnnualTab(index, columnTotal: columnTotal[index]);
        }).toList());
        break;
      case 2:
        _list.addAll(columnForecast.asMap().keys.map((index) {
          return _buildAnnualTab(index, columnDetail: columnForecast[index]);
        }).toList());
        break;
    }
    return Container(
      height: 60.0,
      color: Color(0xff1A4182),
      child: ListView(
        scrollDirection: Axis.horizontal,
        controller: ScrollController(),
        children: _list,
      ),
    );
  }

  Container buildTableDetail() {
    ColumnTotal columnData = columnTotal.isNotEmpty?columnTotal[currentYear]:new ColumnTotal();
    return Container(
      color: Color(0xffE3F2FF),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            _buildContainerRow(Colors.black, header: "成本汇总", tail: CommonUtil.CurrencyForm(columnData.total, times: 1000, digits: 0, isFloor: false)),
            _buildContainerSplit(Colors.black, headerLeft: "固定类", tailLeft: CommonUtil.CurrencyForm(columnData.fixed, times: 1000, digits: 0, isFloor: false),
              headerRight: "变动类-保养", tailRight: CommonUtil.CurrencyForm(columnData.consumable, times: 1000, digits: 0, isFloor: false)
            ),
            _buildContainerSplit(Colors.black, headerLeft: "变动类-维修", tailLeft: CommonUtil.CurrencyForm(columnData.repair, times: 1000, digits: 0, isFloor: false),
              headerRight: "", tailRight: ""
            ),
            _buildContainerRow(Colors.black, header: "导入期成本", tail: CommonUtil.CurrencyForm(columnData.importCost, times: 1000, digits: 0, isFloor: false)),
            _buildContainerRow(Colors.black, header: "总成本", tail: CommonUtil.CurrencyForm(columnData.totalCost, times: 1000, digits: 0, isFloor: false)),
            _buildContainerRow(Colors.black, header: "边际利润", tail: CommonUtil.CurrencyForm(columnData.marginProfit, times: 1000, digits: 0, isFloor: false)),
            _buildContainerSplit(Colors.black, headerLeft: "边际利润率", tailLeft: '${columnData.marginRatio?.toStringAsFixed(0)}%', headerRight: "", tailRight: ""),
            _buildContainerRow(Colors.black, header: "安全额", tail: CommonUtil.CurrencyForm(columnData.safeAmount, times: 1000, digits: 0, isFloor: false)),
          ],
        ),
      ),
    );
  }

  void initChartData() {
    chartData.clear();
    chartData.add(ChartData("固定类", columnActual.fixed/1000, Color(0xff2FC25B)));
    chartData.add(ChartData("变动类-保养", columnActual.maintain/1000, Color(0xff1890FF)));
    chartData.add(ChartData("变动类-维修", columnActual.repair/1000, Color(0xff13C2C2)));
  }

  void initLineData() {
    lineDataFixed.clear();
    lineDataMaintain.clear();
    lineDataRepair.clear();
    for(int i=0; i<columnActual.monthDetail.length; i++) {
      ColumnDetail monthDetail = columnActual.monthDetail[i];
      lineDataFixed.add(MonthData(monthDetail.month, monthDetail.fixed/1000??0));
      lineDataMaintain.add(MonthData(monthDetail.month, monthDetail.maintain/1000??0));
      lineDataRepair.add(MonthData(monthDetail.month, monthDetail.repair/1000??0));
    }
  }

  Container buildTableForecast() {
    ColumnDetail columnData = columnForecast.isNotEmpty?columnForecast[currentYear]:new ColumnDetail();
    return Container(
      color: Color(0xffE3F2FF),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            _buildContainerRow(Colors.black, header: '固定类', tail: CommonUtil.CurrencyForm(columnData.fixed, times: 1000, digits: 0, isFloor: false)),
            _buildContainerSplit(Colors.black, headerLeft: '信息系统使用费', tailLeft: CommonUtil.CurrencyForm(columnData.system, times: 1000, digits: 0, isFloor: false,),
                headerRight: '人工费', tailRight: CommonUtil.CurrencyForm(columnData.labour, times: 1000, digits: 0, isFloor: false)
            ),
            _buildContainerSplit(Colors.black, headerLeft: '维保费', tailLeft: CommonUtil.CurrencyForm(columnData.repairAndMaintain, times: 1000, digits: 0, isFloor: false),
                headerRight: '备用机成本', tailRight: CommonUtil.CurrencyForm(columnData.spare, times: 1000, digits: 0, isFloor: false)
            ),
            _buildContainerRow(Colors.black, header: '变动类-保养', tail: CommonUtil.CurrencyForm(columnData?.maintain, times: 1000, digits: 0, isFloor: false)),
            _buildContainerSplit(Colors.black, headerLeft: '耗材费', tailLeft: CommonUtil.CurrencyForm(columnData.consumable, times: 1000, digits: 0, isFloor: false),
                headerRight: '定期类', tailRight: CommonUtil.CurrencyForm(columnData.fixedPeriod, times: 1000, digits: 0, isFloor: false)
            ),
            _buildContainerSplit(Colors.black, headerLeft: '定量类', tailLeft: CommonUtil.CurrencyForm(columnData.fixedQuantity, times: 1000, digits: 0, isFloor: false),
                headerRight: '小额汇总成本', tailRight: CommonUtil.CurrencyForm(columnData.small, times: 1000, digits: 0, isFloor: false)
            ),
            _buildContainerRow(Colors.black, header: '变动类-维修', tail: CommonUtil.CurrencyForm(columnData.repair, times: 1000, digits: 0, isFloor: false)),
            _buildContainerSplit(Colors.black, headerLeft: '故障零件成本', tailLeft: CommonUtil.CurrencyForm(columnData.componentCost, times: 1000, digits: 0, isFloor: false),
              headerRight: '', tailRight: '',
            ),
            _buildContainerSplit(Colors.black, headerLeft: '重点设备', tailLeft: CommonUtil.CurrencyForm(columnData.essential, times: 1000, digits: 0, isFloor: false),
                headerRight: '一般设备', tailRight: CommonUtil.CurrencyForm(columnData.common, times: 1000, digits: 0, isFloor: false)
            ),
            _buildContainerSplit(Colors.black, headerLeft: '外来服务费', tailLeft: CommonUtil.CurrencyForm(columnData.service, times: 1000, digits: 0, isFloor: false),
              headerRight: '', tailRight: '',
            ),
            _buildContainerSplit(Colors.black, headerLeft: '重点设备', tailLeft: CommonUtil.CurrencyForm(columnData.serviceEssential, times: 1000, digits: 0, isFloor: false),
                headerRight: '一般设备', tailRight: CommonUtil.CurrencyForm(columnData.serviceCommon, times: 1000, digits: 0, isFloor: false)
            ),
          ],
        ),
      ),
    );
  }

  GestureDetector _buildMonthTab(int index, {ColumnTotal columnTotal, ColumnDetail columnDetail}) {
    bool active = index == currentMonth;
    return GestureDetector(
      onTap: () {
        setState(() {
          currentMonth = index;
        });
      },
      child: Container(
        width: 120.0,
        child: Center(
          child: Container(
            width: 100.0,
            height: 30.0,
            decoration: BoxDecoration(
              color: active?Color(0xff1A4182):Colors.white,
              borderRadius: BorderRadius.all(
                  Radius.circular(18.0)
              ),
              border: Border.all(
                color: active?Color(0xff1A4182):Color.fromRGBO(0,0,0, 0.12),
                width: 1.0,
              ),
            ),
            child: Center(
              child: Text(columnTotal!=null?columnTotal?.month:columnDetail.month??'Actual',
                style: TextStyle(
                  fontSize: 13.0,
                  color: active?Colors.white:Color.fromRGBO(0, 0, 0, 0.85)
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Container buildMonthSlider() {
    List<Widget> _list = [];
    if (showCost&&currentTable==2) {
      _list.addAll(columnActual.monthDetail.asMap().keys.map((index) {
        return _buildMonthTab(index, columnDetail: columnActual.monthDetail[index]);
      }).toList());
    } else {
      switch (currentTable) {
        case 1:
          _list.addAll(columnTotal[currentYear].monthDetail.asMap().keys.map((index) {
            return _buildMonthTab(index, columnTotal: columnTotal[currentYear].monthDetail[index]);
          }).toList());
          break;
        case 2:
          _list.addAll(columnForecast[currentYear].monthDetail.asMap().keys.map((index) {
            return _buildMonthTab(index, columnDetail: columnForecast[currentYear].monthDetail[index]);
          }).toList());
      }
    }
    return Container(
      height: 50.0,
      child: ListView(
        scrollDirection: Axis.horizontal,
        controller: ScrollController(),
        children: _list,
      ),
    );
  }

  Container buildMonthTable(ColumnTotal columnData) {
    return Container(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
        child: Column(
          children: <Widget>[
            Container(
              height: 32.0,
              decoration: BoxDecoration(
                color: Color(0xffF2F3F5),
                borderRadius: BorderRadius.all(
                    Radius.circular(18.0)
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      '${columnData.month} 报价',
                      style: TextStyle(
                          color: Color.fromRGBO(0, 0, 0, 0.75),
                          fontSize: 13.0
                      ),
                    ),
                    Text(
                      CommonUtil.CurrencyForm(columnData.quotation, times: 1000, digits: 0, isFloor: false),
                      style: TextStyle(
                          color: Color.fromRGBO(0, 0, 0, 0.75),
                          fontSize: 13.0
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildContainerRow(Colors.black54, header: "成本汇总", tail: CommonUtil.CurrencyForm(columnData.total, times: 1000, digits: 0, isFloor: false)),
            _buildContainerSplit(Colors.black54, headerLeft: "固定类", tailLeft: CommonUtil.CurrencyForm(columnData.fixed, times: 1000, digits: 0, isFloor: false),
                headerRight: "变动类-保养", tailRight: CommonUtil.CurrencyForm(columnData.consumable, times: 1000, digits: 0, isFloor: false)
            ),
            _buildContainerSplit(Colors.black54, headerLeft: "变动类-维修", tailLeft: CommonUtil.CurrencyForm(columnData.repair, times: 1000, digits: 0, isFloor: false),
                headerRight: "", tailRight: ""
            ),
            _buildContainerRow(Colors.black54, header: "导入期成本", tail: CommonUtil.CurrencyForm(columnData.importCost, times: 1000, digits: 1, isFloor: false)),
            _buildContainerRow(Colors.black54, header: "总成本", tail: CommonUtil.CurrencyForm(columnData.totalCost, times: 1000, digits: 0, isFloor: false)),
            _buildContainerRow(Colors.black54, header: "边际利润", tail: CommonUtil.CurrencyForm(columnData.marginProfit, times: 1000, digits: 0, isFloor: false)),
            _buildContainerSplit(Colors.black54, headerLeft: "边际利润率", tailLeft: '${columnData.marginRatio?.toStringAsFixed(0)}%', headerRight: "", tailRight: ""),
            _buildContainerRow(Colors.black54, header: "安全额", tail: CommonUtil.CurrencyForm(columnData.safeAmount, times: 1000, digits: 0, isFloor: false)),
          ],
        ),
      ),
    );
  }

  Container buildMonthDetail(ColumnDetail columnData) {
    return Container(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
        child: Column(
          children: <Widget>[
            Container(
              height: 32.0,
              decoration: BoxDecoration(
                color: Color(0xffF2F3F5),
                borderRadius: BorderRadius.all(
                    Radius.circular(18.0)
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      '${columnData.month} 总计',
                      style: TextStyle(
                          color: Color.fromRGBO(0, 0, 0, 0.75),
                          fontSize: 13.0
                      ),
                    ),
                    Text(
                      CommonUtil.CurrencyForm(columnData.total, times: 1000, digits: 0, isFloor: false),
                      style: TextStyle(
                          color: Color.fromRGBO(0, 0, 0, 0.75),
                          fontSize: 13.0
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildContainerRow(Colors.black54, header: '固定类', tail: CommonUtil.CurrencyForm(columnData.fixed, times: 1000, digits: 0, isFloor: false)),
            _buildContainerSplit(Colors.black54, headerLeft: '信息系统使用费', tailLeft: CommonUtil.CurrencyForm(columnData.system, times: 1000, digits: 0, isFloor: false,),
                headerRight: '人工费', tailRight: CommonUtil.CurrencyForm(columnData.labour, times: 1000, digits: 0, isFloor: false)
            ),
            _buildContainerSplit(Colors.black54, headerLeft: '维保费', tailLeft: CommonUtil.CurrencyForm(columnData.repairAndMaintain, times: 1000, digits: 0, isFloor: false),
                headerRight: '备用机成本', tailRight: CommonUtil.CurrencyForm(columnData.spare, times: 1000, digits: 0, isFloor: false)
            ),
            _buildContainerRow(Colors.black54, header: '变动类-保养', tail: CommonUtil.CurrencyForm(columnData?.maintain, times: 1000, digits: 0, isFloor: false)),
            _buildContainerSplit(Colors.black54, headerLeft: '耗材费', tailLeft: CommonUtil.CurrencyForm(columnData.consumable, times: 1000, digits: 0, isFloor: false),
                headerRight: '定期类', tailRight: CommonUtil.CurrencyForm(columnData.fixedPeriod, times: 1000, digits: 0, isFloor: false)
            ),
            _buildContainerSplit(Colors.black54, headerLeft: '定量类', tailLeft: CommonUtil.CurrencyForm(columnData.fixedQuantity, times: 1000, digits: 0, isFloor: false),
                headerRight: '小额汇总成本', tailRight: CommonUtil.CurrencyForm(columnData.small, times: 1000, digits: 0, isFloor: false)
            ),
            _buildContainerRow(Colors.black54, header: '变动类-维修', tail: CommonUtil.CurrencyForm(columnData.repair, times: 1000, digits: 0, isFloor: false)),
            _buildContainerSplit(Colors.black54, headerLeft: '故障零件成本', tailLeft: CommonUtil.CurrencyForm(columnData.componentCost, times: 1000, digits: 0, isFloor: false),
              headerRight: '', tailRight: '',
            ),
            _buildContainerSplit(Colors.black54, headerLeft: '重点设备', tailLeft: CommonUtil.CurrencyForm(columnData.essential, times: 1000, digits: 0, isFloor: false),
                headerRight: '一般设备', tailRight: CommonUtil.CurrencyForm(columnData.common, times: 1000, digits: 0, isFloor: false)
            ),
            _buildContainerSplit(Colors.black54, headerLeft: '外来服务费', tailLeft: CommonUtil.CurrencyForm(columnData.service, times: 1000, digits: 0, isFloor: false),
              headerRight: '', tailRight: '',
            ),
            _buildContainerSplit(Colors.black54, headerLeft: '重点设备', tailLeft: CommonUtil.CurrencyForm(columnData.serviceEssential, times: 1000, digits: 0, isFloor: false),
                headerRight: '一般设备', tailRight: CommonUtil.CurrencyForm(columnData.serviceCommon, times: 1000, digits: 0, isFloor: false)
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> renderTotal() {
    List<Widget> _list = [];
    _list.addAll([
      buildAnnualSlider(),
      buildTableDetail(),
      currentYear==0?Container():buildMonthSlider(),
      currentYear==0?Container():buildMonthTable(columnTotal[currentYear].monthDetail[currentMonth]),
    ]);
    return _list;
  }

  List<Widget> renderDetail() {
    List<Widget> _list = [];
    if (columnActual == null) {
      return _list;
    }
    _list.addAll([
      buildTopStack(),
      buildAnnualSlider(),
      buildTableForecast(),
    ]);
    if (currentYear == columnForecast.length-1) {
      return _list;
    } else {
      _list.add(buildMonthSlider());
      if (showCost) {
        _list.add(buildMonthDetail(columnActual.monthDetail[currentMonth]));
      } else {
        _list.add(buildMonthDetail(columnForecast[currentYear]?.monthDetail[currentMonth]));
      }
      return _list;
    }
  }
  
  Card _buildOptionTile(String title, int typeID, AnalysisType analysisType, {bool percentage}) {
    percentage = percentage??false;
    return Card(
        child: ListTile(
          title: new Center(
            child: Text(
              title,
              style: new TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16.0,
                  color: Colors.blue
              ),
            ),
          ),
          onTap: () {
            Navigator.of(context).push(new MaterialPageRoute(builder: (context) =>
            ValuationDetail(analysisType: analysisType, historyID: widget.historyID, typeID: typeID, percentage: percentage, title: title,)));
          },
        ),
      );
  }

  List<Widget> _buildOptions(AnalysisType analysisType) {
    List<Widget> _list = [];
    switch (analysisType) {
      case AnalysisType.SERVICE:
        _list.addAll([
          _buildOptionTile("外来服务成本-重点", 1, analysisType),
          _buildOptionTile("外来服务成本-次重点", 2, analysisType),
        ]);
        break;
      case AnalysisType.CONSUMABLE:
        _list.addAll([
          _buildOptionTile("耗材成本-定期", 1, analysisType),
          _buildOptionTile("耗材成本-定量", 2, analysisType),
        ]);
        break;
      case AnalysisType.COMPONENT:
        _list.addAll([
          _buildOptionTile("零件成本-重点", 1, analysisType),
          _buildOptionTile("零件成本-次重点", 2, analysisType),
          _buildOptionTile("零件成本-一般", 3, analysisType, percentage: false),
          _buildOptionTile("零件成本-一般(暂定百分比)", 3, analysisType, percentage: true),
        ]);
        break;
      case AnalysisType.CT:
        break;
      case AnalysisType.CONTRACT:
        break;
      case AnalysisType.SPARE:
        break;
    }

    return _list;
  }

  void showAnalysisOptions(AnalysisType analysisType) {
    showModalBottomSheet(context: context, builder: (context) {
      return ListView(
        shrinkWrap: true,
        children: _buildOptions(analysisType),
      );
    });
  }

  List <Widget> renderAnalysis() {
    List<Widget> _list = [];
    _list.addAll([
      SizedBox(height: 80.0,),
      Row(
        children: <Widget>[
          Expanded(
            flex: 4,
            child: Container(
              child: Center(
                child: Column(
                  children: <Widget>[
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).push(new MaterialPageRoute(builder: (_) => ValuationDetail(historyID: widget.historyID, analysisType: AnalysisType.CONTRACT,)));
                      },
                      icon: Icon(Icons.insert_drive_file, color: Color(0xff41579B), size: 36.0,),
                    ),
                    Text("合同金额")
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Container(
              child: Center(
                child: Column(
                  children: <Widget>[
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).push(new MaterialPageRoute(builder: (_) => ValuationDetail(historyID: widget.historyID, analysisType: AnalysisType.SPARE,)));
                      },
                      icon: Icon(Icons.devices, color: Color(0xff41579B), size: 36.0,),
                    ),
                    Text("备用机金额")
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Container(
              child: Center(
                child: Column(
                  children: <Widget>[
                    IconButton(
                      onPressed: () {
                        showAnalysisOptions(AnalysisType.CONSUMABLE);
                      },
                      icon: Icon(Icons.battery_charging_full, color: Color(0xff41579B), size: 36.0,),
                    ),
                    Text("耗材金额")
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      SizedBox(height: 80.0,),
      Row(
        children: <Widget>[
          Expanded(
            flex: 4,
            child: Container(
              child: Center(
                child: Column(
                  children: <Widget>[
                    IconButton(
                      onPressed: () {
                        showAnalysisOptions(AnalysisType.COMPONENT);
                      },
                      icon: Icon(Icons.settings, color: Color(0xff41579B), size: 36.0,),
                    ),
                    Text("零件金额")
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Container(
              child: Center(
                child: Column(
                  children: <Widget>[
                    IconButton(
                      onPressed: () {
                        showAnalysisOptions(AnalysisType.SERVICE);
                      },
                      icon: Icon(Icons.assignment_ind, color: Color(0xff41579B), size: 36.0,),
                    ),
                    Text("外来服务金额")
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Container(
              child: Center(
                child: Column(
                  children: <Widget>[
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).push(new MaterialPageRoute(builder: (_) => ValuationDetail(historyID: widget.historyID, analysisType: AnalysisType.CT,)));
                      },
                      icon: Icon(Icons.filter, color: Color(0xff41579B), size: 36.0,),
                    ),
                    Text("CT金额")
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ]);
    return _list;
  }

  // overview

  ScrollController _verticalController = new ScrollController();
  ScrollController _horizonController = new ScrollController();
  List<ChartData> chartData = [];

  List<Widget> renderLegendSlider() {
    List<Widget> _list = [];
    double _total = 0.0;

    for(int i=0; i<chartData.length; i++) {
      _total += chartData[i].y;
    }

    _list = chartData.map((item) {
      return renderMenuBox(item.x, item.y, item.y/_total);
    }).toList();

    return _list;
  }

  Padding renderMenuBox(String title, double total, double percentage) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
      child: Container(
        height: 80,
        width: 120,
        color: Color(0xffE3F2FF),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(title),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "${CommonUtil.CurrencyForm(total, times: 1, digits: 0)}千元"
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                    "${(percentage*100).toStringAsFixed(2)}%"
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Container renderPie() {
    return Container(
      height: 400.0,
      width: 250.0,
      child: Center(
        child: SfCircularChart(series: <CircularSeries>[
          // Render pie chart
          PieSeries<ChartData, String>(
              dataSource: chartData,
              pointColorMapper:(ChartData data,  _) => data.color,
              xValueMapper: (ChartData data, _) => data.x,
              yValueMapper: (ChartData data, _) => data.y,
              dataLabelSettings: DataLabelSettings(
                  isVisible: true,
                  labelPosition: ChartDataLabelPosition.outside,
                  labelIntersectAction: LabelIntersectAction.none
              ),
              explode: true,
              explodeIndex: 1
          )
        ],
          legend: Legend(
            isVisible: true
          ),
        ),
      ),
    );
  }

  List<MonthData> lineDataFixed = [
    MonthData("1", 123.0),
    MonthData("2", 213.0),
    MonthData("3", 143.0),
    MonthData("4", 1125.0),
    MonthData("5", 542.0),
    MonthData("6", 321.0),
    MonthData("7", 211.0),
  ];

  List<MonthData> lineDataMaintain = [
    MonthData("1", 543.0),
    MonthData("2", 453.0),
    MonthData("3", 543.0),
    MonthData("4", 234.0),
  ];

  List<MonthData> lineDataRepair = [
    MonthData("4", 1125.0),
    MonthData("5", 542.0),
    MonthData("6", 321.0),
    MonthData("7", 211.0),
  ];

  Container renderLine() {
    return Container(
      height: 400.0,
      width: 400.0,
      child: Center(
        child: SfCartesianChart(
          primaryXAxis: CategoryAxis(
              labelRotation: 90,
              majorGridLines: MajorGridLines(
                  width: 0
              ),
              majorTickLines: MajorTickLines(
                  width: 0
              )
          ),
          series: <LineSeries<MonthData, String>>[
            LineSeries<MonthData, String>(
              dataSource: lineDataFixed,
              xValueMapper: (MonthData data, _) => data.x,
              yValueMapper: (MonthData data, _) => data.y,
              color: Color(0xff2FC25B)
            ),
            LineSeries<MonthData, String>(
              dataSource: lineDataMaintain,
              xValueMapper: (MonthData data, _) => data.x,
              yValueMapper: (MonthData data, _) => data.y,
                color: Color(0xff1890FF)
            ),
            LineSeries<MonthData, String>(
                dataSource: lineDataRepair,
                xValueMapper: (MonthData data, _) => data.x,
                yValueMapper: (MonthData data, _) => data.y,
                color: Colors.greenAccent
            ),
        ],
        ),
      ),
    );
  }

  Container renderBar(String title) {
    return Container(
        child: Column(
          children: <Widget>[
            Container(
              color: Color(0xff41579B),
              height: 40.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    child: Row(
                      children: <Widget>[
                        SizedBox(width: 12.0,),
                        Icon(Icons.pie_chart, color: Colors.white,),
                        SizedBox(width: 6.0,),
                        Text(title, style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),)
                      ],
                    ),
                  ),
                  Container(
                      child: Row(
                        children: <Widget>[
                          Text(
                            "单位 : 千元",
                            style: TextStyle(
                                color: Color.fromRGBO(255, 255, 255, 0.85),
                                fontSize: 12.0,
                                fontWeight: FontWeight.w200
                            ),
                          ),
                          SizedBox(width: 12.0,)
                        ],
                      )
                  ),
                ],
              ),
            )
          ],
        ),
      );
  }

  Padding renderPaddingPie() {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Container(
        child: Column(
          children: <Widget>[
            renderBar("成本构成分析"),
            renderPie(),
            Container(
              height: 100,
              child: ListView(
                controller: _horizonController,
                scrollDirection: Axis.horizontal,
                children: renderLegendSlider(),
              ),
            ),
            SizedBox(height: 16.0,),
            Container(),
          ],
        ),
      ),
    );
  }

  Padding renderPaddingLine() {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Container(
        child: Column(
          children: <Widget>[
            renderBar("月度成本分析"),
            renderLine(),
          ],
        ),
      ),
    );
  }

  List<Widget> renderOverviewList() {
    List<Widget> _list = [];
    _list.add(renderPaddingPie());
    _list.add(SizedBox(height: 16.0,));
    _list.add(renderPaddingLine());
    return _list;
  }

  List<Widget> buildBody() {
    List _list = [];
    switch (currentTable) {
      case 0:
        _list = renderOverviewList();
        break;
      case 1:
        _list = renderTotal();
        break;
      case 2:
        _list = renderDetail();
        break;
      case 3:
        _list = renderAnalysis();
        break;
    }
    return _list;
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff41579B),
        title: Container(
          height: 55.0,
          width: 400.0,
          child: ListView(
            controller: new ScrollController(),
            scrollDirection: Axis.horizontal,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  setState(() {
                    currentTable = 0;
                  });
                  getTableData();
                },
                child: Container(
                  width: 100.0,
                  decoration: currentTable==0?BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              color: Color(0xff16A2B8),
                              width: 3.0,
                              style: BorderStyle.solid
                          )
                      )
                  ):BoxDecoration(),
                  child: Center(
                    child: Text("成本结构",
                      style: currentTable==0?TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600
                      ):TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14.0
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    currentTable = 1;
                  });
                  getTableData();
                },
                child: Container(
                  width: 100.0,
                  decoration: currentTable==1?BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              color: Color(0xff16A2B8),
                              width: 3.0,
                              style: BorderStyle.solid
                          )
                      )
                  ):BoxDecoration(),
                  child: Center(
                    child: Text("最终定价表",
                      style: currentTable==1?TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600
                      ):TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14.0
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    currentTable = 2;
                  });
                  getTableData();
                },
                child: Container(
                  width: 100.0,
                  decoration: currentTable==2?BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              color: Color(0xff16A2B8),
                              width: 3.0,
                              style: BorderStyle.solid
                          )
                      )
                  ):BoxDecoration(),
                  child: Center(
                    child: Text("成本明细",
                      style: currentTable==2?TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600
                      ):TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14.0
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    currentTable = 3;
                  });
                },
                child: Container(
                  width: 100.0,
                  decoration: currentTable==3?BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              color: Color(0xff16A2B8),
                              width: 3.0,
                              style: BorderStyle.solid
                          )
                      )
                  ):BoxDecoration(),
                  child: Center(
                    child: Text("分析",
                      style: currentTable==3?TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600
                      ):TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 14.0
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        centerTitle: false,
      ),
      body: ListView(
        controller: _verticalController,
        children: buildBody(),
      ),
    );
  }
}

class ColumnTotal {
  final String year;
  final String month;
  final double total;
  final double fixed;
  final double repair;
  final double consumable;
  final double importCost;
  final double totalCost;
  final double marginProfit;
  final double marginRatio;
  final double safeAmount;
  final double quotation;
  final List<ColumnTotal> monthDetail;

  ColumnTotal({
    this.year,
    this.month,
    this.total,
    this.fixed,
    this.repair,
    this.consumable,
    this.importCost,
    this.totalCost,
    this.marginProfit,
    this.marginRatio,
    this.safeAmount,
    this.quotation,
    this.monthDetail
  });
}

class ColumnDetail {
  final String year;
  final String month;
  final double total;
  final double fixed;
  final double system;
  final double labour;
  final double repairAndMaintain;
  final double spare;
  final double maintain;
  final double consumable;
  final double fixedPeriod;
  final double fixedQuantity;
  final double small;
  final double repair;
  final double componentCost;
  final double essential;
  final double common;
  final double service;
  final double serviceEssential;
  final double serviceCommon;
  final List<ColumnDetail> monthDetail;

  ColumnDetail({
    this.year,
    this.month,
    this.total,
    this.fixed,
    this.system,
    this.labour,
    this.repairAndMaintain,
    this.spare,
    this.maintain,
    this.consumable,
    this.fixedPeriod,
    this.fixedQuantity,
    this.small,
    this.repair,
    this.componentCost,
    this.essential,
    this.common,
    this.service,
    this.serviceEssential,
    this.serviceCommon,
    this.monthDetail
  });
}

class ChartData {
  ChartData(this.x, this.y, [this.color]);

  final String x;
  final double y;
  final Color color;
}

class MonthData {
  MonthData(this.x, this.y);

  final String x;
  final double y;
}
