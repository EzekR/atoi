import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:atoi_charts/charts.dart';
import 'package:badges/badges.dart';
import 'package:atoi_gauge/gauges.dart';
import 'package:spider_chart/spider_chart.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:atoi/pages/superuser/superuser_home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:atoi/utils/http_request.dart';
import 'package:atoi/pages/manager/manager_complete_page.dart';
import 'package:atoi/utils/common.dart';
import 'package:atoi/pages/superuser/equipment_carousel.dart';
import 'package:atoi/utils/constants.dart';
import 'package:atoi/pages/superuser/super_request.dart';

class Dashboard extends StatefulWidget {
  final int equipmentId;
  Dashboard({Key key, this.equipmentId}):super(key: key);
  _DashboardState createState() => new _DashboardState();
}

class _DashboardState extends State<Dashboard> {

  int currentTab = 0;
  int currentEvent = 0;
  bool isDetailPage = false;
  Future<SharedPreferences> prefs = SharedPreferences.getInstance();
  String userName;
  int role;
  String barTip;
  String equipmentName;
  String equipmentTimelineName;
  String equipmentStatus;
  List equipmentFiles;
  String installDate;
  String installSite;
  String warrantyStatus;
  Map incomeAll = {
    'income': 0.0,
    'income_rate': 0.0,
    'expense': 0.0,
    'expense_rate': 0.0
  };
  // dashboard data
  Map overview;
  Map departmentAll = {
    'income': 0.0,
    'income_rate': 0.0,
    'expense': 0.0,
    'expense_rate': 0.0
  };
  List departmentData;
  List equipmentData;
  int sortBy = 0;
  String sortName = '科室';
  int filter = 0;
  String filterName = '所有科室';
  List requestList;
  int totalRequest;
  List repairEvents;
  List recallEvents;
  List mandatoryEvents;
  List overdueEvents;
  Map kpi;

  List<IncomeData> incomeData = [
    IncomeData(1, 100.0, -80.0, 0),
    IncomeData(2, 100.0, -80.0, 0),
    IncomeData(3, 80.0, -80.0, -20),
    IncomeData(4, 50, -50.0, -10),
    IncomeData(5, 100.0, -80.0, 0),
    IncomeData(6, 80.0, -80.0, -20),
    IncomeData(7, 50, -50.0, -10),
    IncomeData(8, 100.0, -80.0, 0),
    IncomeData(9, 80.0, -80.0, -20),
    IncomeData(10, 50, -50.0, -10),
    IncomeData(11, 40, -40.0, -40),
    IncomeData(12, 100.0, -80.0, 0),
    IncomeData(13, 40, -40.0, -40),
    IncomeData(14, 100.0, -80.0, 0),
    IncomeData(15, 40, -40.0, -40),
    IncomeData(16, 100.0, -80.0, 0),
    IncomeData(17, 80.0, -80.0, -20),
    IncomeData(18, 50, -50.0, -10),
    IncomeData(19, 40, -40.0, -40),
    IncomeData(20, 100.0, -80.0, 0),
  ];

  List<RequestData> requestData = [
    RequestData('1', 23, Color(0xff385A95)),
    RequestData('2', 20, Color(0xffCD6750)),
    RequestData('3', 12, Color(0xffD8A92E)),
    RequestData('4', 10, Color(0xff21C4BF)),
    RequestData('5', 3, Color(0xff3aab64)),
  ];

  Map equipmentTimeline = {};
  Map equipmentCount = {};
  Map equipmentIncome = {};

  void getUserName() async {
    SharedPreferences _prefs = await prefs;
    setState(() {
      userName = _prefs.getString('userName');
      role = _prefs.getInt('role');
    });
  }

  // get dashboard data
  void getOverview() async {
    Map resp = await HttpRequest.request(
      '/Equipment/QueryOverview',
      method: HttpRequest.GET,
      isBoard: true
    );
    if (resp['ResultCode'] == '00') {
      setState(() {
        overview = resp['Data'];
      });
    }
  }

  void sortIncome(int sortId) {
    List _data = List.from(departmentData);
    switch (sortId) {
      case 0:
        _data.sort((prev, next) => prev['Department']['ID'].compareTo(next['Department']['ID']));
        break;
      case 1:
        _data.sort((prev, next) => next['Incomes'].compareTo(prev['Incomes']));
        break;
      case 2:
        _data.sort((prev, next) => next['Expenses'].compareTo(prev['Expenses']));
        break;
    }
    incomeData = _data.asMap().keys.map((index) {
      double _income = _data[index]['Incomes'];
      double _expense = _data[index]['Expenses'];
      double _net = _income-_expense>=0?0:(_income-_expense);
      if (_income == 0.0) {
        _net = 0.0;
      }
      return new IncomeData(index/1.0, _income, _net==0.0?(0.0-_expense):(0.0-_income), _net);
    }).toList();
    setState(() {
      incomeData = incomeData;
    });
  }

  void filterIncome(int filter) {
    List _data = List.from(departmentData);
    switch (filter) {
      case 1:
        _data.retainWhere((item) => item['Department']['DepartmentType']['ID'] == 1);
        break;
      case 2:
        _data.retainWhere((item) => item['Department']['DepartmentType']['ID'] == 2);
        break;
      case 3:
        _data.retainWhere((item) => item['Department']['DepartmentType']['ID'] == 9);
        break;
    }
    incomeData = _data.asMap().keys.map((index) {
      double _income = _data[index]['Incomes'];
      double _expense = _data[index]['Expenses'];
      double _net = _income-_expense>=0?0:(_income-_expense);
      if (_income == 0.0) {
        _net = 0.0;
      }
      return new IncomeData(index/1.0, _income, _net==0.0?(0.0-_expense):(0.0-_income), _net);
    }).toList();
    setState(() {
      incomeData = incomeData;
    });
  }

  void getDepartmentIncome() async {
    Map resp = await HttpRequest.request(
      '/Equipment/IncomeExpenseByDepartment',
      method: HttpRequest.GET,
      isBoard: true
    );
    if (resp['ResultCode'] == '00') {
      List _data = resp['Data'];
      departmentData = resp['Data'];
      incomeData = _data.asMap().keys.map((index) {
        double _income = _data[index]['Incomes'];
        double _expense = _data[index]['Expenses'];
        double _net = _income-_expense>=0?0:(_income-_expense);
        if (_income == 0.0) {
          _net = 0.0;
        }
        return new IncomeData(index/1.0, _income, _net==0.0?(0.0-_expense):(0.0-_income), _net);
      }).toList();
      double income_last = 0.0;
      double expense_last = 0.0;
      departmentAll.forEach((key, val) {
        departmentAll[key] = 0.0;
      });
      _data.forEach((item) {
        departmentAll['income'] += item['Incomes'];
        income_last += item['LastIncomes'];
        departmentAll['expense'] += item['Expenses'];
        expense_last += item['LastExpenses'];
      });
      departmentAll['income_rate'] = (departmentAll['income']-income_last)/income_last*100;
      departmentAll['expense_rate'] = (departmentAll['expense']-expense_last)/expense_last*100;
      setState(() {
        incomeData = incomeData;
        incomeAll = departmentAll;
      });
    }
  }

  void getEquipmentsIncome(int departmentId) async {
    Map resp = await HttpRequest.request(
      '/Equipment/EquipmentsDetailsByDepartment',
      method: HttpRequest.GET,
      params: {
        'id': departmentId
      },
      isBoard: true
    );
    if (resp['ResultCode'] == '00') {
      List _data = resp['Data'];
      getTimeline(equipmentId: _data[0]['ID']);
      getCount(equipmentId: _data[0]['ID']);
      equipmentData = resp['Data'];
      incomeData.clear();
      incomeData = _data.asMap().keys.map((index) {
        double _income = _data[index]['Incomes'];
        double _expense = _data[index]['Expenses'];
        double _net = _income-_expense>=0?0:(_income-_expense);
        if (_income == 0.0) {
          _net = 0.0;
        }
        return new IncomeData(index/1.0, _income, _net==0.0?(0.0-_expense):(0.0-_income), _net);
      }).toList();
      print(incomeData.length);
      double income_last = 0.0;
      double expense_last = 0.0;
      departmentAll.forEach((key, val) {
        departmentAll[key] = 0.0;
      });
      _data.forEach((item) {
        departmentAll['income'] += item['Incomes'];
        income_last += item['LastIncomes'];
        departmentAll['expense'] += item['Expenses'];
        expense_last += item['LastExpenses'];
      });
      departmentAll['income_rate'] = income_last==0.0?100:(departmentAll['income']-income_last)/income_last*100;
      departmentAll['expense_rate'] = expense_last==0.0?100:(departmentAll['expense']-expense_last)/expense_last*100;
      setState(() {
        incomeData = incomeData;
        incomeAll = departmentAll;
      });
    }
  }

  void getRequestToday() async {
    Map resp = await HttpRequest.request(
      '/Request/Todays',
      method: HttpRequest.GET,
      isBoard: true
    );
    if (resp['ResultCode'] == '00') {
      requestList = resp['Data'];
      totalRequest = requestList.length;
      if (requestList.length == 0) {
        requestData.clear();
        requestData.add(RequestData('1', 1, Color(0xff385A95)));
      } else {
        Map _departs = {};
        requestList.forEach((item) {
          if (!_departs.containsKey(item['DepartmentName'])) {
            _departs[item['DepartmentName']] = 1;
          } else {
            _departs[item['DepartmentName']] += _departs[item['DepartmentName']];
          }
        });
        print(_departs.toString());
        requestData = _departs.keys.map((key) => RequestData(key.toString(), _departs[key])).toList();
      }
      setState(() {
        requestData = requestData;
      });
    }
  }

  void getKeyEvents() async {
    Map resp = await HttpRequest.request(
      '/Request/QueryOverview',
      method: HttpRequest.GET,
      isBoard: true
    );
    if (resp['ResultCode'] == '00') {
      setState(() {
        repairEvents = resp['Data']['Repair'];
        recallEvents = resp['Data']['Recall'];
        mandatoryEvents = resp['Data']['MandatoryTest'];
        overdueEvents = resp['Data']['OverDue'];
      });
    }
  }

  void getKpi() async {
    Map resp = await HttpRequest.request(
      '/Request/KPI',
      method: HttpRequest.GET,
      isBoard: true
    );
    if (resp['ResultCode'] == '00') {
      setState(() {
        kpi = resp['Data'];
      });
    }
  }

  void getTimeline({int equipmentId}) async {
    equipmentId = equipmentId??widget.equipmentId;
    Map resp = await HttpRequest.request(
      '/Equipment/GetTimeline4APP',
      method: HttpRequest.POST,
      data: {
        'id': equipmentId
      }
    );
    if (resp['ResultCode'] == '00') {
      setState(() {
        equipmentTimeline = resp['Data'];
        equipmentName = resp['Data']['Name']+'-'+resp['Data']['Manufacturer']['Name']+'-'+resp['Data']['EquipmentCode']+'-'+resp['Data']['AssetCode'];
        equipmentTimelineName = resp['Data']['Name']+'-'+resp['Data']['EquipmentCode'];
        equipmentStatus = resp['Data']['EquipmentStatus']['Name'];
        warrantyStatus = resp['Data']['WarrantyStatus'];
        equipmentFiles = resp['Data']['EquipmentFile'];
        installDate = AppConstants.TimeForm(resp['Data']['InstalDate'], 'yyyy-mm-dd');
        installSite = resp['Data']['Department']['Name'];
      });
    }
  }

  void getCount({int equipmentId}) async {
    equipmentId = equipmentId??widget.equipmentId;
    Map resp = await HttpRequest.request(
      '/Equipment/GetRequestCountByID',
      method: HttpRequest.GET,
      params: {
        'id': equipmentId
      }
    );
    if (resp['ResultCode'] == '00') {
      setState(() {
        equipmentCount = resp['Data'];
      });
    }
  }

  void getIncome({int equipmentId}) async {
    equipmentId = equipmentId??widget.equipmentId;
    Map resp = await HttpRequest.request(
      '/Equipment/IncomeExpenseByID',
      method: HttpRequest.GET,
      params: {
        'id': equipmentId
      }
    );
    if (resp['ResultCode'] == '00') {
      incomeAll['income'] = resp['Data']['overall'][0]['Item2'];
      incomeAll['income_rate'] = resp['Data']['overall'][2]['Item2'];
      incomeAll['expense'] = resp['Data']['overall'][0]['Item3'];
      incomeAll['expense_rate'] = resp['Data']['overall'][2]['Item3'];
      setState(() {
        equipmentIncome = resp['Data'];
        incomeAll = incomeAll;
        incomeData = resp['Data']['detail'].asMap().keys.map<IncomeData>((index) {
          double _income = resp['Data']['detail'][index]['Item2'];
          double _expense = resp['Data']['detail'][index]['Item3'];
          double _net = _income-_expense>=0?0:(_income-_expense);
          if (_income == 0.0) {
            _net = 0.0;
          }
          return new IncomeData(index/1.0, _income, _net==0.0?(0.0-_expense):(0.0-_income), _net);
        }).toList();
      });
    }
  }

  void getEquipmentInfo() async {
    await getTimeline();
    await getCount();
    await getIncome();
  }

  void initState() {
    super.initState();
    if (widget.equipmentId != null) {
      getEquipmentInfo();
    } else {
      getUserName();
      getOverview();
      getDepartmentIncome();
      getRequestToday();
      getKeyEvents();
      getKpi();
    }
  }

  void showBottomSheet() {
    showModalBottomSheet(context: context, builder: (context) {
      return StatefulBuilder(builder: (context, setState) {
        return Container(
          height: 400,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(12.0)),
              color: Colors.white
          ),
          child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 22.0),
              child: Column(
                children: <Widget>[
                  Container(
                    height: 300,
                    child: ListView(
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              sortBy = 0;
                              sortName = '科室';
                            });
                          },
                          child: Container(
                            height: 64.0,
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: Color.fromRGBO(0, 0, 0, 0.1),
                                        width: 1.0
                                    )
                                )
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  '科室',
                                  style: TextStyle(
                                      fontSize: 17.0,
                                      color: Colors.black
                                  ),
                                ),
                                sortBy==0?Icon(
                                  Icons.check,
                                  color: Color(0xff39649C),
                                  size: 18.0,
                                ):Container()
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              sortBy = 1;
                              sortName = '收入';
                            });
                          },
                          child: Container(
                            height: 64.0,
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: Color.fromRGBO(0, 0, 0, 0.1),
                                        width: 1.0
                                    )
                                )
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  '收入',
                                  style: TextStyle(
                                      fontSize: 17.0,
                                      color: Colors.black
                                  ),
                                ),
                                sortBy==1?Icon(
                                  Icons.check,
                                  color: Color(0xff39649C),
                                  size: 18.0,
                                ):Container()
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              sortBy = 2;
                              sortName = '支出';
                            });
                          },
                          child: Container(
                            height: 64.0,
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: Color.fromRGBO(0, 0, 0, 0.1),
                                        width: 1.0
                                    )
                                )
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  '支出',
                                  style: TextStyle(
                                      fontSize: 17.0,
                                      color: Colors.black
                                  ),
                                ),
                                sortBy==2?Icon(
                                  Icons.check,
                                  color: Color(0xff39649C),
                                  size: 18.0,
                                ):Container()
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      sortIncome(sortBy);
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      height: 50.0,
                      child: Container(
                        width: 322.0,
                        height: 40.0,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(4.0)),
                            color: Color(0xff39649C)
                        ),
                        child: Center(
                          child: Text(
                            '确定',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16.0
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 24,
                  )
                ],
              )
          ),
        );
      });
    });
  }

  void showFilter() {
    showModalBottomSheet(context: context, builder: (context) {
      return StatefulBuilder(builder: (context, setState) {
        return Container(
          height: 400,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(12.0)),
              color: Colors.white
          ),
          child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 22.0),
              child: Column(
                children: <Widget>[
                  Container(
                    height: 300,
                    child: ListView(
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              filter = 0;
                              filterName = '所有科室';
                            });
                          },
                          child: Container(
                            height: 64.0,
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: Color.fromRGBO(0, 0, 0, 0.1),
                                        width: 1.0
                                    )
                                )
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  '所有科室',
                                  style: TextStyle(
                                      fontSize: 17.0,
                                      color: Colors.black
                                  ),
                                ),
                                filter==0?Icon(
                                  Icons.check,
                                  color: Color(0xff39649C),
                                  size: 18.0,
                                ):Container()
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              filter = 1;
                              filterName = '医技科室';
                            });
                          },
                          child: Container(
                            height: 64.0,
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: Color.fromRGBO(0, 0, 0, 0.1),
                                        width: 1.0
                                    )
                                )
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  '医技科室',
                                  style: TextStyle(
                                      fontSize: 17.0,
                                      color: Colors.black
                                  ),
                                ),
                                filter==1?Icon(
                                  Icons.check,
                                  color: Color(0xff39649C),
                                  size: 18.0,
                                ):Container()
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              filter = 2;
                              filterName = '临床科室';
                            });
                          },
                          child: Container(
                            height: 64.0,
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: Color.fromRGBO(0, 0, 0, 0.1),
                                        width: 1.0
                                    )
                                )
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  '临床科室',
                                  style: TextStyle(
                                      fontSize: 17.0,
                                      color: Colors.black
                                  ),
                                ),
                                filter==2?Icon(
                                  Icons.check,
                                  color: Color(0xff39649C),
                                  size: 18.0,
                                ):Container()
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              filter = 3;
                              filterName = '其他科室';
                            });
                          },
                          child: Container(
                            height: 64.0,
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                        color: Color.fromRGBO(0, 0, 0, 0.1),
                                        width: 1.0
                                    )
                                )
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  '其他科室',
                                  style: TextStyle(
                                      fontSize: 17.0,
                                      color: Colors.black
                                  ),
                                ),
                                filter==3?Icon(
                                  Icons.check,
                                  color: Color(0xff39649C),
                                  size: 18.0,
                                ):Container()
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      filterIncome(filter);
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      height: 50.0,
                      child: Container(
                        width: 322.0,
                        height: 40.0,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(4.0)),
                            color: Color(0xff39649C)
                        ),
                        child: Center(
                          child: Text(
                            '确定',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16.0
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 24,
                  )
                ],
              )
          ),
        );
      });
    });
  }

  // top tab
  GestureDetector buildTab(String tabTitle, int index) {
    bool isActive = (index==currentTab);
    BoxDecoration _dec = new BoxDecoration(
      color: isActive?Colors.white:Color(0xff385A95),
      borderRadius: BorderRadius.circular(16.0),
      border: Border.all(
        color: Colors.white
      )
    );
    return new GestureDetector(
      onTap: () {
        setState(() {
          currentTab = index;
        });
      },
      child: new Container(
        height: 32.0,
        width: 75.0,
        decoration: _dec,
        child: Center(
          child: Text(
            tabTitle,
            style: TextStyle(
                color: isActive?Color(0xff385A95):Colors.white,
                fontSize: 12.0
            ),
          ),
        ),
      ),
    );
  }

  // info card
  Padding buildCard(Widget child) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 7.0),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Color.fromRGBO(3, 17, 62, 0.23),
                  blurRadius: 7
              ),
            ]
        ),
        child: child,
      ),
    );
  }

  // asset overview
  Padding buildAsset() {
    return new Padding(
      padding: EdgeInsets.all(23.0),
      child: Container(
        child: Column(
          children: <Widget>[
            Container(
              height: 66.0,
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 6,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(right: BorderSide(color: Color(0xffebebeb),))
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '设备数量(台)',
                            style: TextStyle(
                              color: Color(0xff666666),
                              fontSize: 11.0
                            ),
                          ),
                          SizedBox(
                            height: 8.0,
                          ),
                          Text(
                            overview!=null?overview['EquipmentCount'].toString():'0',
                            style: TextStyle(
                              color: Color(0xff385A95),
                              fontSize: 24.0,
                              fontWeight: FontWeight.w600
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: Container(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(23.0, 0, 0, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              '设备金额(万元)',
                              style: TextStyle(
                                  color: Color(0xff666666),
                                  fontSize: 11.0
                              ),
                            ),
                            SizedBox(
                              height: 8.0,
                            ),
                            Text(
                              overview!=null?CommonUtil.CurrencyForm(overview['EquipmentAmount']):'0',
                              style: TextStyle(
                                  color: Color(0xff385A95),
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.w600
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Container(
              height: 23.0,
              decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xffebebeb),))
              ),
            ),
            SizedBox(
              height: 23.0,
            ),
            Container(
              height: 66.0,
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 6,
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border(right: BorderSide(color: Color(0xffebebeb),))
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '折旧率',
                            style: TextStyle(
                                color: Color(0xff666666),
                                fontSize: 11.0
                            ),
                          ),
                          SizedBox(
                            height: 8.0,
                          ),
                          Text(
                            overview!=null?'${overview['DepreciationRate']*100}%':'0.00%',
                            style: TextStyle(
                                color: Color(0xff385A95),
                                fontSize: 24.0,
                                fontWeight: FontWeight.w600
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: Container(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(23.0, 0, 0, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              '当年服务人次(人)',
                              style: TextStyle(
                                  color: Color(0xff666666),
                                  fontSize: 11.0
                              ),
                            ),
                            SizedBox(
                              height: 8.0,
                            ),
                            Text(
                              overview!=null?'${overview['ServiceCount']}':'',
                              style: TextStyle(
                                  color: Color(0xff385A95),
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.w600
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // department income overview
  Padding buildIncome() {
    return new Padding(
      padding: EdgeInsets.all(23.0),
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              child: Text(
                '科室收支概览',
                style: TextStyle(
                  color: Color(0xff1e1e1e),
                  fontSize: 17.0,
                  fontWeight: FontWeight.w600
                ),
              ),
            ),
            SizedBox(
              height: 9.0,
            ),
            Container(
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 6,
                    child: Row(
                      children: <Widget>[
                        Text(
                          '排序：',
                          style: TextStyle(
                            color: Color(0xff666666),
                            fontSize: 11.0
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            showBottomSheet();
                          },
                          child: Container(
                              height: 24.0,
                              width: 90.0,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Color(0xff7597D3)
                                  ),
                                  borderRadius: BorderRadius.all(Radius.circular(2.0))
                              ),
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      sortName,
                                      style: TextStyle(
                                          color: Color(0xff666666),
                                          fontSize: 11.0
                                      ),
                                    ),
                                    Icon(
                                      Icons.keyboard_arrow_down,
                                      color: Color(0xff666666),
                                      size: 14.0,
                                    )
                                  ],
                                ),
                              )
                          ),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Row(
                      children: <Widget>[
                        Text(
                          '筛选：',
                          style: TextStyle(
                              color: Color(0xff666666),
                              fontSize: 11.0
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            showFilter();
                          },
                          child: Container(
                              height: 24.0,
                              width: 90.0,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Color(0xff7597D3)
                                  ),
                                  borderRadius: BorderRadius.all(Radius.circular(2.0))
                              ),
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      filterName,
                                      style: TextStyle(
                                          color: Color(0xff666666),
                                          fontSize: 11.0
                                      ),
                                    ),
                                    Icon(
                                      Icons.keyboard_arrow_down,
                                      color: Color(0xff666666),
                                      size: 14.0,
                                    )
                                  ],
                                ),
                              )
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 9.0,
            ),
            Container(
              child: Row(
                children: <Widget>[
                  Container(
                    height: 9.0,
                    width: 9.0,
                    color: Color(0xff86C7E6),
                  ),
                  SizedBox(
                    width: 4.0,
                  ),
                  Text(
                    '收入',
                    style: TextStyle(
                      color: Color(0xff666666),
                      fontSize: 10.0
                    ),
                  ),
                  SizedBox(
                    width: 15.0,
                  ),
                  Container(
                    height: 9.0,
                    width: 9.0,
                    color: Color(0xff39649C),
                  ),
                  SizedBox(
                    width: 4.0,
                  ),
                  Text(
                    '支出',
                    style: TextStyle(
                        color: Color(0xff666666),
                        fontSize: 10.0
                    ),
                  ),
                  SizedBox(
                    width: 15.0,
                  ),
                  Container(
                    height: 9.0,
                    width: 9.0,
                    color: Color(0xffD64040),
                  ),
                  SizedBox(
                    width: 4.0,
                  ),
                  Text(
                    '亏损',
                    style: TextStyle(
                        color: Color(0xff666666),
                        fontSize: 10.0
                    ),
                  ),
                  SizedBox(
                    width: 15.0,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 9.0,
            ),
            Container(
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            CommonUtil.CurrencyForm(incomeAll['income']),
                            style: TextStyle(
                              color: Color(0xff1e1e1e),
                              fontSize: 15.0,
                              fontWeight: FontWeight.w600
                            ),
                          ),
                          SizedBox(
                            height: 4.0,
                          ),
                          Text(
                            '总收入(万元)',
                            style: TextStyle(
                              color: Color(0xff666666),
                              fontSize: 10.0
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '${incomeAll['income_rate']>=0?'+':''} ${(incomeAll['income_rate']).toStringAsFixed(2)}%',
                            style: TextStyle(
                                color: incomeAll['income_rate']>=0?Color(0xffD64040):Color(0xff33B850),
                                fontSize: 15.0,
                                fontWeight: FontWeight.w600
                            ),
                          ),
                          SizedBox(
                            height: 4.0,
                          ),
                          Text(
                            '同比',
                            style: TextStyle(
                                color: Color(0xff666666),
                                fontSize: 10.0
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            CommonUtil.CurrencyForm(incomeAll['expense']),
                            style: TextStyle(
                                color: Color(0xff1e1e1e),
                                fontSize: 15.0,
                                fontWeight: FontWeight.w600
                            ),
                          ),
                          SizedBox(
                            height: 4.0,
                          ),
                          Text(
                            '总支出(万元)',
                            style: TextStyle(
                                color: Color(0xff666666),
                                fontSize: 10.0
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '${incomeAll['expense_rate']>=0?'+':''} ${(incomeAll['expense_rate']).toStringAsFixed(2)}%',
                            style: TextStyle(
                                color: incomeAll['expense_rate']>=0?Color(0xffD64040):Color(0xff33B850),
                                fontSize: 15.0,
                                fontWeight: FontWeight.w600
                            ),
                          ),
                          SizedBox(
                            height: 4.0,
                          ),
                          Text(
                            '同比',
                            style: TextStyle(
                                color: Color(0xff666666),
                                fontSize: 10.0
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 9.0,
            ),
            Container(
              height: 200.0,
              child: ListView(
                scrollDirection: Axis.horizontal,
                controller: new ScrollController(),
                children: <Widget>[
                  buildIncomeChart()
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // income chart
  Container buildIncomeChart() {
    return Container(
      width: incomeData.length<20?400.0:incomeData.length*20.0,
      child: SfCartesianChart(
          borderWidth: 0,
          plotAreaBorderWidth: 0.0,
          borderColor: Colors.white,
          primaryXAxis: NumericAxis(
            isVisible: false,
            majorGridLines: MajorGridLines(width: 0.0),
            majorTickLines: MajorTickLines(width: 0.0),
          ),
          primaryYAxis: NumericAxis(
            isVisible: false,
            majorGridLines: MajorGridLines(width: 0.0),
            majorTickLines: MajorTickLines(width: 0.0),
          ),
          palette: <Color>[
            Color(0xff86C7E6),
            Color(0xff39649C),
            Color(0xffD64040)
          ],
          tooltipBehavior: TooltipBehavior(
              enable: true,
              activationMode: ActivationMode.singleTap,
              elevation: 100.0,
              shouldAlwaysShow: true,
              builder: (dynamic data, dynamic point, dynamic series,
                  int pointIndex, int seriesIndex) {
                return GestureDetector(
                  onTap: () {
                    if (widget.equipmentId == null && !isDetailPage) {
                      getEquipmentsIncome(departmentData[pointIndex]['Department']['ID']);
                      setState(() {
                        isDetailPage = !isDetailPage;
                      });
                    } else {
                      if (widget.equipmentId == null && isDetailPage) {
                        getTimeline(equipmentId: equipmentData[pointIndex]['ID']);
                        getCount(equipmentId: equipmentData[pointIndex]['ID']);
                      }
                    }
                  },
                  child: Container(
                    height: widget.equipmentId!=null?120:250,
                    width: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      color: Color.fromRGBO(0, 0, 0, 0.83),
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(12, 5, 5, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: widget.equipmentId!=null?<Widget>[
                          Text(
                            equipmentName??'',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.0
                            ),
                          ),
                          SizedBox(
                            height: 8.0,
                          ),
                          Row(
                            children: <Widget>[
                              Expanded(
                                flex: 4,
                                child: Text(
                                  '月份：${equipmentIncome['detail'][pointIndex]['Item1']}月',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11.0
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 6,
                                child: Text(
                                  '',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11.0
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 8.0,
                          ),
                          Row(
                            children: <Widget>[
                              Expanded(
                                flex: 4,
                                child: Text(
                                  '收入：${CommonUtil.CurrencyForm(equipmentIncome['detail'][pointIndex]['Item2'])}万元',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11.0
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 6,
                                child: Text(
                                  '支出：${CommonUtil.CurrencyForm(equipmentIncome['detail'][pointIndex]['Item3'])}万元',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11.0
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ]:<Widget>[
                          Text(
                            !isDetailPage?departmentData[pointIndex]['Department']['Description']??'':'${equipmentData[pointIndex]['Name']}-${equipmentData[pointIndex]['Manufacturer']['Name']}-${equipmentData[pointIndex]['EquipmentCode']}',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.0
                            ),
                          ),
                          SizedBox(
                            height: 8.0,
                          ),
                          Row(
                            children: <Widget>[
                              Expanded(
                                flex: 4,
                                child: Text(
                                  isDetailPage?'设备价值：${CommonUtil.CurrencyForm(equipmentData[pointIndex]['PurchaseAmount'])}':'设备数量：${departmentData[pointIndex]['EquipmentCount']}台',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11.0
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 6,
                                child: Text(
                                  '',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11.0
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 8.0,
                          ),
                          Row(
                            children: <Widget>[
                              Expanded(
                                flex: 10,
                                child: Text(
                                  isDetailPage?'型号：${equipmentData[pointIndex]['EquipmentCode']}':'设备价值：${CommonUtil.CurrencyForm(departmentData[pointIndex]['EquipmentAmount'])}万元',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11.0
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  '',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11.0
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 8.0,
                          ),
                          Row(
                            children: <Widget>[
                              Expanded(
                                flex: 10,
                                child: Text(
                                  isDetailPage?'品牌：${equipmentData[pointIndex]['Manufacturer']['Name']}':'服务人次：${departmentData[pointIndex]['ServiceCount']}',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11.0
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  '',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11.0
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 8.0,
                          ),
                          Row(
                            children: <Widget>[
                              Expanded(
                                flex: 10,
                                child: Text(
                                  '收入：${CommonUtil.CurrencyForm(isDetailPage?equipmentData[pointIndex]['Incomes']:departmentData[pointIndex]['Incomes'])}万元',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11.0
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  '',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11.0
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 8.0,
                          ),
                          Row(
                            children: <Widget>[
                              Expanded(
                                flex: 10,
                                child: Text(
                                  '支出：${CommonUtil.CurrencyForm(isDetailPage?equipmentData[pointIndex]['Expenses']:departmentData[pointIndex]['Expenses'])}万元',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11.0
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  '',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11.0
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 8.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
          ),
          series: <ChartSeries<IncomeData, double>>[
            StackedColumnSeries<IncomeData, double>(
                selectionSettings: SelectionSettings(
                  enable: true
                ),
                dataSource: incomeData,
                xValueMapper: (IncomeData sales, _) => sales.x,
                yValueMapper: (IncomeData sales, _) => sales.income
            ),
            StackedColumnSeries<IncomeData, double>(
                selectionSettings: SelectionSettings(
                    enable: true
                ),
                dataSource: incomeData,
                xValueMapper: (IncomeData sales, _) => sales.x,
                yValueMapper: (IncomeData sales, _) => sales.expense
            ),
            StackedColumnSeries<IncomeData, double>(
                selectionSettings: SelectionSettings(
                    enable: true
                ),
                dataSource: incomeData,
                xValueMapper: (IncomeData sales, _) => sales.x,
                yValueMapper: (IncomeData sales, _) => sales.net
            ),
          ]
      ),
    );
  }

  //request chart
  Container buildRequestChart() {
    return Container(
      child: SfCircularChart(
          tooltipBehavior: TooltipBehavior(
            enable: true,
            format: 'point.x\n参报数量: point.y件'
          ),
          annotations: <CircularChartAnnotation>[
            CircularChartAnnotation(
              widget: Container(
                  height: 100,
                  width: 100,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        height: 15.0,
                      ),
                      Row(
                        children: <Widget>[
                          SizedBox(
                            width: 30.0,
                          ),
                          Text(
                            totalRequest.toString(),
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 39.0,
                              fontWeight: FontWeight.w600
                            ),
                          ),
                          Text(
                            '件',
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Color(0xff666666)
                            ),
                          )
                        ],
                      ),
                      Text(
                        '今日总报修',
                        style: TextStyle(
                            fontSize: 14.0,
                            color: Color(0xff666666)
                        ),
                      )
                    ],
                  )
              ),
            )
          ],
          series: <CircularSeries>[
            DoughnutSeries<RequestData, String>(
                explode: true,
                explodeIndex: 0,
                dataSource: requestData,
                pointColorMapper:(RequestData data,  _) => data.color,
                xValueMapper: (RequestData data, _) => data.x,
                yValueMapper: (RequestData data, _) => data.count,
                innerRadius: '75%',
            ),
          ],
      ),
    );
  }

  //current request
  Padding buildRequest() {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.0, 14.0, 24.0, 30),
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              child: Text(
                '当日报修',
                style: TextStyle(
                  fontSize: 17.0,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff1e1e1e)
                ),
              ),
            ),
            Container(
              height: 250.0,
              child: buildRequestChart(),
            ),
            Container(
              child: Center(
                child: Text(
                  '',
                  style: TextStyle(
                    color: Color(0xff1e1e1e),
                    fontSize: 13.0
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              height: 300.0,
              child: requestList.length==0?Center(
                child: Text(
                  '暂无报修',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600
                  ),
                ),
              ):ListView(
                children: requestList.map<Widget>((item) {
                  return Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            flex: 1,
                            child: Text(
                              '1',
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Color(0xff1B85E7),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 8,
                            child: Text(
                              '${item['EquipmentName']} 【${item['EquipmentOID']}】${item['FaultDesc']}',
                              style: TextStyle(
                                  color: Color(0xff1e1e1e),
                                  fontSize: 14.0
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Container(
                              height: 20,
                              width: 35,
                              decoration: BoxDecoration(
                                  color: Color(0xffD64040),
                                  borderRadius: BorderRadius.all(Radius.circular(4.0))
                              ),
                              child: Center(
                                child: Text(
                                  '${item['Status']['Name']}',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10.0
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 11.0,
                      ),
                    ],
                  );
                }).toList(),
              ),
            )
          ],
        ),
      ),
    );
  }

  Expanded buildEventIcon(IconData eventIcon, String count, int index, String eventTitle) {
    bool isActive = index==currentEvent;
    return Expanded(
      flex: 3,
      child: GestureDetector(
        onTap: () {
          setState(() {
            currentEvent = index;
          });
        },
        child: Column(
          children: <Widget>[
            Container(
              child: Badge(
                position: BadgePosition(
                    right: -14,
                    top: -14
                ),
                badgeContent: Text(
                  count,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 11
                  ),
                ),
                badgeColor: Color(0xffD64040),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                      color: isActive?Color(0xff385A95):Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(100)),
                      border: Border.all(
                        color: Color(0xff385A95)
                      )
                  ),
                  child: Center(
                    child: Icon(
                      eventIcon,
                      color: isActive?Colors.white:Color(0xff385A95),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 6.0,
            ),
            Container(
              child: Center(
                child: Text(
                  eventTitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: isActive?Color(0xff385A95):Color(0xff333333)
                  ),
                ),
              ),
            )
          ],
        )
      )
    );
  }

  // events
  Padding buildEventType() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      child: Container(
        child: Row(
          children: <Widget>[
            buildEventIcon(Icons.build, recallEvents?.length.toString(), 0, '紧急维修'),
            buildEventIcon(Icons.local_car_wash, recallEvents?.length.toString(), 1, '召回事件'),
            buildEventIcon(Icons.speaker_phone, mandatoryEvents?.length.toString(), 2, '强检事件'),
            buildEventIcon(Icons.calendar_today, overdueEvents?.length.toString(), 3, '超期事件'),
          ],
        ),
      ),
    );
  }

  //event list item
  Column buildEventListItem(IconData icon, String title, String date) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
              height: 32,
              width: 32,
              decoration: BoxDecoration(
                  color: Color(0xff385A95),
                  borderRadius: BorderRadius.all(Radius.circular(80))
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
            SizedBox(
              width: 19,
            ),
            Expanded(
              flex: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: TextStyle(
                        color: Color(0xff1e1e1e),
                        fontSize: 14.0
                    ),
                  ),
                  Text(
                    date,
                    style: TextStyle(
                        color: Color(0xff333333),
                        fontSize: 11
                    ),
                  )
                ],
              ),
            )
          ],
        ),
        SizedBox(
          height: 24,
        ),
      ],
    );
  }

  Padding buildEventList() {
    List _data;
    IconData _icon;
    String _type;
    switch (currentEvent) {
      case 0:
        _data = List.from(repairEvents);
        _icon = Icons.build;
        _type = '维修';
        break;
      case 1:
        _data = List.from(recallEvents);
        _icon = Icons.local_car_wash;
        _type = '召回';
        break;
      case 2:
        _data = List.from(mandatoryEvents);
        _icon = Icons.speaker_phone;
        _type = '强检';
        break;
      case 3:
        _data = List.from(overdueEvents);
        _icon = Icons.calendar_today;
        _type = '超期';
        break;
    }
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 19, 24, 19),
      child: Container(
        height: 400.0,
        child: ListView(
          children: _data.map<Widget>((item) {
            return buildEventListItem(_icon, '${item['DepartmentName']}: ${item['EquipmentName']} [${item['EquipmentOID']}] 正在等待${_type}，请优先处理', CommonUtil.TimeForm(item['RequestDate'], 'yyyy'));
          }).toList(),
        ),
      ),
    );
  }

  //key index
  Container buildProgressBar(String title, double planned, double finished) {
    double _plan;
    if (planned == 0.0) {
      _plan = 1.0;
    } else {
      _plan = planned;
    }
    return Container(
        height: 90,
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 60,
                  child: Text(
                    title,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff1e1e1e)
                    ),
                  ),
                ),
                SizedBox(
                  width: 27,
                ),
                Container(
                  height: 18,
                  width: 220,
                  color: Color(0xffE7EDF6),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: (finished/_plan)*220,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [
                                  Color(0xff3FA6CC),
                                  Color(0xff39629B)
                                ]
                            )
                        ),
                      ),
                      Container(
                        width: (1-finished/_plan)*220,
                        decoration: BoxDecoration(
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
            Row(
              children: <Widget>[
                Container(
                  width: 60,
                  child: Row(
                    children: <Widget>[
                      Text(
                        (finished/_plan*100).toStringAsFixed(0),
                        style: TextStyle(
                            color: Color(0xffD64040),
                            fontWeight: FontWeight.w600,
                            fontSize: 25
                        ),
                      ),
                      Text(
                        '%',
                        style: TextStyle(
                            color: Color(0xffD64040),
                            fontWeight: FontWeight.w600,
                            fontSize: 15
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 27,
                ),
                Text(
                  '已完成',
                  style: TextStyle(
                      color: Color(0xff333333),
                      fontSize: 13
                  ),
                ),
                Text(
                  finished.toStringAsFixed(0),
                  style: TextStyle(
                      color: Color(0xff1e1e1e),
                      fontSize: 16
                  ),
                ),
                Text(
                  '件',
                  style: TextStyle(
                      color: Color(0xff333333),
                      fontSize: 13
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  '本月计划',
                  style: TextStyle(
                      color: Color(0xff333333),
                      fontSize: 13
                  ),
                ),
                Text(
                  planned.toStringAsFixed(0),
                  style: TextStyle(
                      color: Color(0xff1e1e1e),
                      fontSize: 16
                  ),
                ),
                Text(
                  '件',
                  style: TextStyle(
                      color: Color(0xff333333),
                      fontSize: 13
                  ),
                ),
              ],
            )
          ],
        ),
      );
  }

  Padding buildKeyIndex() {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 19, 24, 19),
      child: Container(
        child: Column(
          children: <Widget>[
            Container(
              height: 300.0,
              child: buildGauge(),
            ),
            Container(
              height: 300.0,
              child: Column(
                children: kpi!=null?<Widget>[
                  buildProgressBar('校准率', kpi['Correcting']['Plans'], kpi['Correcting']['Done']),
                  buildProgressBar('保养率', kpi['Maintain']['Plans'], kpi['Maintain']['Done']),
                  buildProgressBar('巡检率', kpi['OnSiteInspection']['Plans'], kpi['OnSiteInspection']['Done']),
                ]:[],
              ),
            )
          ],
        ),
      ),
    );
  }

  Container buildGauge() {
    return Container(
      child: SfRadialGauge(
          animationDuration: 1000,
          enableLoadingAnimation: true,
          axes:<RadialAxis>[
            RadialAxis(
              showLabels: false,
              pointers: [
                NeedlePointer(
                  value: kpi==null?95:kpi['BootRate']['Present']*100,
                  needleColor: Color(0xffD64040),
                  knobStyle: KnobStyle(
                    color: Color(0xffD64040)
                  )
                ),
                MarkerPointer(value: kpi==null?90:kpi['BootRate']['Default']*100),
              ],
              annotations: [
                GaugeAnnotation(
                  angle: 90,
                  positionFactor: 0.5,
                  widget: Container(
                    height: 80,
                    width: 60,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text(
                              kpi==null?'':(kpi['BootRate']['Present']*100).toStringAsFixed(0),
                              style: TextStyle(
                                  color: Color(0xffD64040),
                                  fontSize: 30,
                                  fontWeight: FontWeight.w600
                              ),
                            ),
                            Text(
                              '%',
                              style: TextStyle(
                                  color: Color(0xffD64040),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600
                              ),
                            )
                          ],
                        ),
                        Text(
                          '开机率',
                          style: TextStyle(
                            color: Color(0xff1e1e1e),
                            fontWeight: FontWeight.w600,
                            fontSize: 14
                          ),
                        )
                      ],
                    ),
                  )
                )
              ],
              axisLineStyle: AxisLineStyle(thickness: 0.1,
                thicknessUnit: GaugeSizeUnit.factor,
                gradient: const SweepGradient(
                    colors: <Color>[Color(0xFF3FA5CC), Color(0xFF385A95)],
                    stops: <double>[0.25, 0.75]
                ),
              )
          ),
          ]
      ),
    );
  }

  void slideToMain(DragEndDetails detail) {
    setState(() {
      isDetailPage = false;
    });
  }
  
  // department detail
  GestureDetector buildDetail() {
    return GestureDetector(
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, 14, 24, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                if (widget.equipmentId == null) {
                  getDepartmentIncome();
                  setState(() {
                    isDetailPage = false;
                  });
                } else {
                  Navigator.of(context).pop();
                }
              },
              child: Container(
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.arrow_back_ios,
                      size: 13,
                      color: Colors.grey,
                    ),
                    Text(
                      '设备收支概览',
                      style: TextStyle(
                          color: Color(0xff1e1e1e),
                          fontSize: 17.0,
                          fontWeight: FontWeight.w600
                      ),
                    ),
                  ],
                )
              ),
            ),
            SizedBox(
              height: 9.0,
            ),
            Container(
              child: Row(
                children: <Widget>[
                  Container(
                    height: 9.0,
                    width: 9.0,
                    color: Color(0xff86C7E6),
                  ),
                  SizedBox(
                    width: 4.0,
                  ),
                  Text(
                    '收入',
                    style: TextStyle(
                        color: Color(0xff666666),
                        fontSize: 10.0
                    ),
                  ),
                  SizedBox(
                    width: 15.0,
                  ),
                  Container(
                    height: 9.0,
                    width: 9.0,
                    color: Color(0xff39649C),
                  ),
                  SizedBox(
                    width: 4.0,
                  ),
                  Text(
                    '支出',
                    style: TextStyle(
                        color: Color(0xff666666),
                        fontSize: 10.0
                    ),
                  ),
                  SizedBox(
                    width: 15.0,
                  ),
                  Container(
                    height: 9.0,
                    width: 9.0,
                    color: Color(0xffD64040),
                  ),
                  SizedBox(
                    width: 4.0,
                  ),
                  Text(
                    '亏损',
                    style: TextStyle(
                        color: Color(0xff666666),
                        fontSize: 10.0
                    ),
                  ),
                  SizedBox(
                    width: 15.0,
                  ),
                ],
              ),
            ),
            Container(
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 3,
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            CommonUtil.CurrencyForm(incomeAll['income']),
                            style: TextStyle(
                                color: Color(0xff1e1e1e),
                                fontSize: 15.0,
                                fontWeight: FontWeight.w600
                            ),
                          ),
                          SizedBox(
                            height: 4.0,
                          ),
                          Text(
                            '总收入(万元)',
                            style: TextStyle(
                                color: Color(0xff666666),
                                fontSize: 10.0
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '${incomeAll['income_rate']>=0?'+':''} ${incomeAll['income_rate'].toStringAsFixed(2)}%',
                            style: TextStyle(
                                color: incomeAll['income_rate']>=0?Color(0xffD64040):Color(0xff33B850),
                                fontSize: 15.0,
                                fontWeight: FontWeight.w600
                            ),
                          ),
                          SizedBox(
                            height: 4.0,
                          ),
                          Text(
                            '同比',
                            style: TextStyle(
                                color: Color(0xff666666),
                                fontSize: 10.0
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            CommonUtil.CurrencyForm(incomeAll['expense']),
                            style: TextStyle(
                                color: Color(0xff1e1e1e),
                                fontSize: 15.0,
                                fontWeight: FontWeight.w600
                            ),
                          ),
                          SizedBox(
                            height: 4.0,
                          ),
                          Text(
                            '总支出(万元)',
                            style: TextStyle(
                                color: Color(0xff666666),
                                fontSize: 10.0
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '${incomeAll['expense_rate']>=0?'+':''} ${incomeAll['expense_rate'].toStringAsFixed(2)}%',
                            style: TextStyle(
                                color: incomeAll['expense_rate']>=0?Color(0xffD64040):Color(0xff33B850),
                                fontSize: 15.0,
                                fontWeight: FontWeight.w600
                            ),
                          ),
                          SizedBox(
                            height: 4.0,
                          ),
                          Text(
                            '同比',
                            style: TextStyle(
                                color: Color(0xff666666),
                                fontSize: 10.0
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 200,
              width: incomeData.length<=20?400.0:incomeData.length*20.0,
              child: ListView(
                scrollDirection: Axis.horizontal,
                controller: new ScrollController(),
                children: <Widget>[
                  buildIncomeChart()
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // equipment radar
  Padding buildRadar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 13, 24, 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                height: 18,
                width: 30,
                color: Color(0xff33B850),
                child: Center(
                  child: Text(
                    equipmentStatus??'正常',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                )
              ),
              Container(
                height: 80,
                width: 280,
                child: Text(
                  equipmentName??'',
                  softWrap: true,
                  style: TextStyle(
                      fontSize: 17,
                      color: Color(0xff1e1e1e),
                      fontWeight: FontWeight.w600
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 14.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                '当前位置：$installSite',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 17
                ),
              ),
              Text(
                '安装日期: $installDate',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xff666666)
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text(
                '维保状态：$warrantyStatus',
                style: TextStyle(
                    fontSize: 13,
                    color: Color(0xff666666)
                ),
              ),
            ],
          ),
          SizedBox(
            height: 50,
          ),
          Container(
            height: 200,
            child: buildSpiderChart(),
          ),
          Container(
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.photo_library, color: Color.fromRGBO(1, 1, 1, 0.2),),
                  onPressed: () {
                    Navigator.of(context).push(new MaterialPageRoute(builder: (_) => EquipmentCarousel(equipmentFile: equipmentFiles,)));
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Stack buildSpiderChart() {
    List<double> _data = new List();
    equipmentCount?.forEach((key, val) {
      _data.add(val/1.0);
    });
    return Stack(
      children: <Widget>[
        Container(
          child: SpiderChart(
            data: _data.isNotEmpty?_data:[
              1,2,3,4,5
            ],
            labels: [
              '维修','保养','强检','巡检','校准'
            ],
            maxValue: _data.isEmpty||_data.every((elem) => elem == 0)?10:_data.reduce((prev,next) => prev>=next?prev:next),
            colors: <Color>[
              Colors.red,
              Colors.green,
              Colors.blue,
              Colors.yellow,
              Colors.indigo,
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(140, 0, 0, 0),
          child: GestureDetector(
            onTap: () {
              print('1 tab');
              Navigator.of(context).push(new MaterialPageRoute(builder: (_) => new SuperRequest(type: 1, field: 'e.ID', filter: equipmentTimeline['ID'].toString(), pageType: PageType.REQUEST,)));
            },
            child: Container(
              width: 80,
              height: 80,
              child: Text(' '),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(50, 60, 0, 0),
          child: GestureDetector(
            onTap: () {
              print('1 tab');
              Navigator.of(context).push(new MaterialPageRoute(builder: (_) => new SuperRequest(type: 5, field: 'e.ID', filter: equipmentTimeline['ID'].toString(), pageType: PageType.REQUEST,)));
            },
            child: Container(
              width: 80,
              height: 80,
              child: Text(' '),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(230, 60, 0, 0),
          child: GestureDetector(
            onTap: () {
              print('1 tab');
              Navigator.of(context).push(new MaterialPageRoute(builder: (_) => new SuperRequest(type: 2, field: 'e.ID', filter: equipmentTimeline['ID'].toString(), pageType: PageType.REQUEST,)));
            },
            child: Container(
              width: 80,
              height: 80,
              child: Text(' '),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(80, 160, 0, 0),
          child: GestureDetector(
            onTap: () {
              print('1 tab');
              Navigator.of(context).push(new MaterialPageRoute(builder: (_) => new SuperRequest(type: 4, field: 'e.ID', filter: equipmentTimeline['ID'].toString(), pageType: PageType.REQUEST,)));
            },
            child: Container(
              width: 80,
              height: 80,
              child: Text(' '),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(190, 160, 0, 0),
          child: GestureDetector(
            onTap: () {
              print('1 tab');
              Navigator.of(context).push(new MaterialPageRoute(builder: (_) => new SuperRequest(type: 3, field: 'e.ID', filter: equipmentTimeline['ID'].toString(), pageType: PageType.REQUEST,)));
            },
            child: Container(
              width: 80,
              height: 80,
              child: Text(' '),
            ),
          ),
        ),
      ],
    );
  }

  Color timelineColor(int requestType) {
    Color _color = Colors.grey;
    if (requestType == 1 || requestType == 3) {
      _color = Color(0xffD64040);
    }
    if (requestType == 2 || requestType == 4 || requestType ==5) {
      _color = Colors.green;
    }
    return _color;
  }

  Padding buildTimeline() {
    List _timeline = equipmentTimeline!=null?equipmentTimeline['Dispatches']:null;
    return Padding(
      padding: EdgeInsets.fromLTRB(23, 25, 23, 25),
      child: equipmentTimeline!=null?Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            equipmentTimelineName??'',
            style: TextStyle(
                fontSize: 17,
                color: Color(0xff1e1e1e),
                fontWeight: FontWeight.w600
            ),
            softWrap: true,
          ),
          SizedBox(
            height: 14,
          ),
          Container(
            height: 300,
            child: _timeline!=null?ListView(
              children: _timeline.asMap().keys.map<Widget>((index) {
                return GestureDetector(
                  onTap: () {
                    if (_timeline[index]['RequestType']['ID'] != 0) {
                      Navigator.of(context).push(new MaterialPageRoute(builder: (_) => new ManagerCompletePage(requestId: _timeline[index]['RequestID'],)));
                    }
                  },
                  child: TimelineTile(
                      alignment: TimelineAlign.left,
                      isFirst: index==0?true:false,
                      isLast: index==_timeline.length-1?true:false,
                      indicatorStyle: IndicatorStyle(
                        width: 9,
                        color: timelineColor(_timeline[index]['RequestType']['ID']),
                        indicatorY: 0.3,
                      ),
                      bottomLineStyle: const LineStyle(
                        color: Color(0xffebebeb),
                        width: 4,
                      ),
                      topLineStyle: const LineStyle(
                        color: Color(0xffebebeb),
                        width: 4,
                      ),
                      rightChild: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 13, vertical: 5),
                        child: Container(
                          constraints: const BoxConstraints(
                            minHeight: 40,
                          ),
                          child: Text(
                            '${_timeline[index]['EndDate'].split('T')[0]} ${_timeline[index]['TimelineDesc']}',
                            style: TextStyle(
                                color: Color(0xff1e1e1e),
                                fontSize: 14
                            ),
                          ),
                        ),
                      )
                  ),
                );
              }).toList(),
            ):Container(),
          )
        ],
      ):Container(),
    );
  }

  List<Widget> listBuilder() {
    List<Widget> _list = [];
    // department detail
    if (widget.equipmentId == null) {
      if (!isDetailPage) {
        _list.add(
          SizedBox(
            height: 10.0,
          ),
        );
        switch (currentTab) {
          case 0:
            _list.addAll([
              buildCard(buildAsset()),
              buildCard(buildIncome()),
            ]);
            break;
          case 1:
            _list.add(
                buildCard(buildRequest())
            );
            break;
          case 2:
            _list.add(
                buildCard(buildEventType())
            );
            _list.add(
                buildCard(buildEventList())
            );
            break;
          case 3:
            _list.add(buildCard(buildKeyIndex()));
            break;
        }
      } else {
        _list.add(buildCard(buildDetail()));
        _list.add(buildCard(buildRadar()));
        _list.add(buildCard(buildTimeline()));
      }
    } else {
      _list.add(buildCard(buildDetail()));
      _list.add(buildCard(buildRadar()));
      _list.add(buildCard(buildTimeline()));
    }
    _list.add(
      Center(
        child: Text(
          '- 没有更多了 -',
          style: TextStyle(
              color: Color(0xff666666),
              fontSize: 12.0
          ),
        ),
      )
    );
    return _list;
  }

  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Align(
          alignment: Alignment(-1.0, 0),
          child: new Text('ATOI医疗设备管理系统',
            textAlign: TextAlign.left,
          ),
        ),
        automaticallyImplyLeading: false,
        centerTitle: false,
        elevation: 0.0,
        bottomOpacity: 0,
        backgroundColor: Color(0xff385A95),
        // linear gradient decoration
        //flexibleSpace: Container(
        //  decoration: BoxDecoration(
        //    gradient: LinearGradient(
        //      begin: Alignment.centerLeft,
        //      end: Alignment.centerRight,
        //      colors: [
        //        const Color(0xFF385A95),
        //        const Color(0xFF3FA5CC)
        //      ],
        //    ),
        //  ),
        //),
        actions: <Widget>[
          GestureDetector(
            onTap: () {
              role==3?Navigator.of(context).push(new MaterialPageRoute(builder: (_) => SuperHome())):null;
            },
            child: Center(
              child: Text(
                userName??'superuser',
              ),
            ),
          ),
          SizedBox(
            width:10
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          Container(
            color: Color(0xFF385A95),
            child: !isDetailPage&&widget.equipmentId==null?Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  buildTab('资产概览', 0),
                  buildTab('当日报修', 1),
                  buildTab('关键事件', 2),
                  buildTab('关键指标', 3),
                ],
              ):Container(
              height: 32.0,
              color: Color(0xFF385A95),
            ),
          ),
          Container(
            height: 559.0,
            color: Color(0xffd8e0ee),
            child: Stack(
              children: <Widget>[
                Container(
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: CurvePainter(),
                  ),
                ),
                ListView(
                    children: listBuilder()
                ),
              ],
            ),
          ),
        ],
      )
    );
  }
}

class CurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var gradient = LinearGradient(
      colors: [
        const Color(0xFF385A95),
        const Color(0xFF3FA5CC)
      ],
    );
    var rect = Offset.zero & size;
    var paint = Paint();
    paint.color = Color(0xff385A95);
    paint.style = PaintingStyle.fill;
    //paint.shader = gradient.createShader(rect);

    var path = Path();

    path.moveTo(0, size.height * 0.05);
    path.quadraticBezierTo(size.width / 2, size.height / 12, size.width, size.height * 0.05);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class IncomeData {
  final double x;
  final double income;
  final double expense;
  final double net;

  IncomeData(this.x, this.income, this.expense, this.net);
}

class RequestData {
  final String x;
  final int count;
  final Color color;

  RequestData(this.x, this.count, [this.color]);
}
