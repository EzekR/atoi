import 'package:atoi/utils/http_request.dart';
import 'package:flutter/material.dart';
import 'package:atoi/utils/common.dart';

class ValuationDetail extends StatefulWidget {
  final int historyID;
  final AnalysisType analysisType;
  ValuationDetail({this.historyID, this.analysisType});
  _ValuationDetailState createState() => new _ValuationDetailState();
}

class _ValuationDetailState extends State<ValuationDetail> {

  int currentFuji = 0;
  int currentMonth = 0;
  List<FujiItem> fujiItems = [];

  void initState() {
    super.initState();
    getContractAmount();
  }

  Future<Null> getContractAmount() async {
    String url;
    String key;
    switch (widget.analysisType) {
      case AnalysisType.CONTRACT:
        url = "/Valuation/GetContractAmount";
        key = "AmountList";
        break;
      case AnalysisType.SPARE:
        url = "/Valuation/GetSpareAmount";
        key = "AmountList";
        break;
      case AnalysisType.COMPONENT:
        url = "/Valuation/GetComponentAmount";
        key = "ForecastAmountList";
        break;
      case AnalysisType.CONSUMABLE:
        url = "/Valuation/GetConsumableAmount";
        key = "AmountList";
        break;
      case AnalysisType.SERVICE:
        url = "/Valuation/GetServiceAmount";
        key = "ForecastAmountList";
        break;
      case AnalysisType.CT:
        url = "/Valuation/GetCTAmount";
        key = "ForecastAmountList";
        break;
    }
    Map resp = await HttpRequest.request(
      url,
      method: HttpRequest.GET,
      params: {
        'valHisID': widget.historyID
      }
    );
    if (resp['ResultCode'] == '00') {
      List items;
      switch (widget.analysisType) {
        case AnalysisType.CONTRACT:
          items = resp['Data']['Equipments'];
          break;
        case AnalysisType.SPARE:
          items = resp['Data']['Equipments'];
          break;
        case AnalysisType.CONSUMABLE:
          items = resp['Data']['Equipments'];
          break;
        case AnalysisType.COMPONENT:
          items = resp['Data']['Components'];
          break;
        case AnalysisType.SERVICE:
          items = resp['Data']['Services'];
          break;
        case AnalysisType.CT:
          items = resp['Data']['Components'];
          break;
      }
      List dates = resp['Data']['ForecastDate'];
      List<FujiItem> _list = [];
      for(int i=0; i<items.length; i++) {
        List<MonthData> _ml = [];
        for(int j=0; j<items[i][key].length; j++) {
          MonthData _md = new MonthData(id: j, date: dates[j]['Name'], amount: items[i][key][j]);
          _ml.add(_md);
        }
        FujiItem _fi;
        switch (widget.analysisType) {
          case AnalysisType.CONTRACT:
            _fi = new FujiItem(i, fujiName: items[i]['FujiClass2Name'], totalAmount: items[i]['ContractAmountTotal'], monthlyData: _ml);
            break;
          case AnalysisType.SPARE:
            _fi = new FujiItem(i, fujiName: items[i]['FujiClass2Name'], totalAmount: items[i]['SpareAmountTotal'],
                rent: items[i]['Rent'], quantity: items[i]['Qty'], subTotal: items[i]['SubTotal'],
                price: items[i]['Price'], monthlyData: _ml);
            break;
          case AnalysisType.CONSUMABLE:
            _fi = new FujiItem(i, fujiName: items[i]['FujiClass2Name'], totalAmount: items[i]['ContractAmountTotal'], monthlyData: _ml);
            break;
          case AnalysisType.COMPONENT:
            _fi = new FujiItem(i, fujiName: items[i]['FujiClass2Name'], totalAmount: items[i]['ForecastAmountTotal'], monthlyData: _ml);
            break;
          case AnalysisType.SERVICE:
            _fi = new FujiItem(i, fujiName: items[i]['FujiClass2Name'], totalAmount: items[i]['ForecastAmountTotal'], monthlyData: _ml);
            break;
          case AnalysisType.CT:
            _fi = new FujiItem(i, fujiName: items[i]['FujiClass2Name'], totalAmount: items[i]['ForecastAmountTotal'], monthlyData: _ml);
            break;
        }
        _list.add(_fi);
      }
      setState(() {
        fujiItems = _list;
      });
    }
  }

  Container buildAnnualSlider() {
    List<Widget> _list = [];
    _list.addAll(fujiItems.asMap().keys.map((index) {
      return _buildFujiTab(index, fujiItems[index]);
    }).toList());
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

  GestureDetector _buildFujiTab(int index, FujiItem fujiItem) {
    bool active = index == currentFuji;
    return GestureDetector(
      onTap: () {
        setState(() {
          currentFuji = index;
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
                  fujiItem.fujiName,
                  style: TextStyle(
                      fontSize: 13.0,
                      color: active?Color.fromRGBO(0, 0, 0, 0.85):Colors.white
                  ),
                ),
              ),
              Container(
                child: Text(
                  '${CommonUtil.CurrencyForm(fujiItem.totalAmount, digits: 0, times: 1000)}',
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

  Container buildMonthSlider() {
    FujiItem fujiItem = fujiItems.isNotEmpty?fujiItems[currentFuji]:FujiItem(0, monthlyData: [MonthData(id: 0)]);
    List<Widget> _list = [];
    _list.addAll(fujiItem.monthlyData.asMap().keys.map((index) {
      return _buildMonthTab(fujiItem.monthlyData[index]);
    }).toList());
    return Container(
      height: 50.0,
      child: ListView(
        scrollDirection: Axis.horizontal,
        controller: ScrollController(),
        children: _list,
      ),
    );
  }

  GestureDetector _buildMonthTab(MonthData monthData) {
    bool active = monthData.id == currentMonth;
    return GestureDetector(
      onTap: () {
        setState(() {
          currentMonth = monthData.id;
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
              child: Text(monthData.date??'',
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

  List<Widget> _buildForecastRow(FujiItem fujiItem) {
    List<Widget> _list = [];
    switch (widget.analysisType) {
      case AnalysisType.CONTRACT:
        _list.addAll([
          _buildContainerRow(Colors.black, header: '合同总价', tail: CommonUtil.CurrencyForm(fujiItem.totalAmount, times: 1000, digits: 0)),
        ]);
        break;
      case AnalysisType.SPARE:
        _list.addAll([
          _buildContainerRow(Colors.black, header: '备用机成本', tail: CommonUtil.CurrencyForm(fujiItem.totalAmount, times: 1000, digits: 0)),
          _buildContainerRow(Colors.black, header: '月租租金', tail: CommonUtil.CurrencyForm(fujiItem.rent, times: 1000, digits: 0)),
          _buildContainerRow(Colors.black, header: '台数', tail: fujiItem.quantity.toString()),
          _buildContainerRow(Colors.black, header: 'SubTotal', tail: fujiItem.subTotal),
          _buildContainerRow(Colors.black, header: '成本', tail: CommonUtil.CurrencyForm(fujiItem.price, times: 1000, digits: 0)),
        ]);
        break;
      case AnalysisType.COMPONENT:
        _list.addAll([
          _buildContainerRow(Colors.black, header: '零件成本', tail: CommonUtil.CurrencyForm(fujiItem.totalAmount, times: 1000, digits: 0)),
        ]);
        break;
      case AnalysisType.CONSUMABLE:
        _list.addAll([
          _buildContainerRow(Colors.black, header: '耗材成本', tail: CommonUtil.CurrencyForm(fujiItem.totalAmount, times: 1000, digits: 0)),
        ]);
        break;
      case AnalysisType.SERVICE:
        _list.addAll([
          _buildContainerRow(Colors.black, header: '服务成本', tail: CommonUtil.CurrencyForm(fujiItem.totalAmount, times: 1000, digits: 0)),
        ]);
        break;
      case AnalysisType.CT:
        _list.addAll([
          _buildContainerRow(Colors.black, header: 'CT球馆成本', tail: CommonUtil.CurrencyForm(fujiItem.totalAmount, times: 1000, digits: 0)),
        ]);
        break;
    }

    return _list;
  }

  Container buildTableForecast() {
    FujiItem fujiItem = fujiItems.isNotEmpty?fujiItems[currentFuji]:new FujiItem(0);
    return Container(
      color: Color(0xffE3F2FF),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: _buildForecastRow(fujiItem),
        ),
      ),
    );
  }

  Container buildMonthTable() {
    MonthData monthData = fujiItems.isNotEmpty?fujiItems[currentFuji].monthlyData[currentMonth]:new MonthData();
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
                      '${monthData?.date} 总计',
                      style: TextStyle(
                          color: Color.fromRGBO(0, 0, 0, 0.75),
                          fontSize: 13.0
                      ),
                    ),
                    Text(
                      CommonUtil.CurrencyForm(monthData?.amount, times: 1000, digits: 0),
                      style: TextStyle(
                          color: Color.fromRGBO(0, 0, 0, 0.75),
                          fontSize: 13.0
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> buildAnalysisList() {
    List<Widget> _list = [];
    _list.addAll([
      buildAnnualSlider(),
      buildTableForecast(),
      buildMonthSlider(),
      buildMonthTable()
    ]);
    return _list;
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("分析"),
        backgroundColor: Color(0xff41579B),
      ),
      body: ListView(
        controller: ScrollController(),
        children: buildAnalysisList(),
      ),
    );
  }
}

class FujiItem {
  final int id;
  final String fujiName;
  final double totalAmount;
  final double rent;
  final int quantity;
  final String subTotal;
  final double price;

  final List<MonthData> monthlyData;

  FujiItem(this.id, {this.fujiName, this.totalAmount, this.rent, this.quantity,
    this.subTotal, this.price, this.monthlyData});
}

class MonthData {
  final int id;
  final String date;
  final double amount;

  MonthData({this.id, this.date, this.amount});
}

enum AnalysisType {
  CONTRACT,
  SPARE,
  CONSUMABLE,
  COMPONENT,
  SERVICE,
  CT
}