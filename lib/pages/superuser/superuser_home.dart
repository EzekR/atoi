import 'package:atoi/pages/inventory/service_list.dart';
import 'package:atoi/pages/inventory/spare_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:atoi/pages/equipments/equipments_list.dart';
import 'package:atoi/pages/equipments/contract_list.dart';
import 'package:atoi/pages/equipments/vendors_list.dart';
import 'package:atoi/pages/reports/report_list.dart';
import 'package:atoi/pages/superuser/super_request.dart';
import 'package:atoi/models/main_model.dart';
import 'package:atoi/models/constants_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:atoi/pages/inventory/component_list.dart';
import 'package:atoi/pages/inventory/consumable_list.dart';
import 'package:atoi/pages/valuation/valuation_history.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:atoi/permissions.dart';

class SuperHome extends StatefulWidget {
  _SuperHomeState createState() => _SuperHomeState();
}

class _SuperHomeState extends State<SuperHome> with SingleTickerProviderStateMixin{

  TabController _tabController;
  ConstantsModel model;
  Future<SharedPreferences> prefs = SharedPreferences.getInstance();
  String userName;
  Map requestTechPermission;
  Map dispatchTechPermission;
  Map medicalPermission;
  Map measurePermission;
  Map otherPermission;
  Map contractPermission;
  Map supplierPermission;

  void getUserName() async {
    SharedPreferences _prefs = await prefs;
    setState(() {
      userName = _prefs.getString('userName');
    });
  }

  void initState() {
    super.initState();
    getPermission();
    getUserName();
    model = MainModel.of(context);
    model.getConstants();
    _tabController = new TabController(length: 3, vsync: this, initialIndex: 0);
  }

  Future<Null> getPermission() async {
    SharedPreferences _prefs = await prefs;
    Permission permissionInstance = new Permission();
    permissionInstance.prefs = _prefs;
    permissionInstance.initPermissions();
    requestTechPermission = permissionInstance.getTechPermissions('Operations', 'Request');
    dispatchTechPermission = permissionInstance.getTechPermissions('Operations', 'Dispatch');
    medicalPermission = permissionInstance.getTechPermissions("Asset", "Equipment");
    measurePermission = permissionInstance.getTechPermissions("Asset", "MeasInstrum");
    otherPermission = permissionInstance.getTechPermissions("Asset", "OtherEqpt");
    contractPermission = permissionInstance.getTechPermissions("Asset", "Contract");
    supplierPermission = permissionInstance.getTechPermissions("Asset", "Supplier");
  }

  Widget build (BuildContext context) {
    return Scaffold(
      backgroundColor: new Color(0xfffafafa),
      appBar: AppBar(
        title: new Align(
          alignment: Alignment(-1.0, 0),
          child: new Text('ATOI医疗设备管理系统',
            textAlign: TextAlign.left,
          ),
        ),
        automaticallyImplyLeading: false,
        centerTitle: false,
        elevation: 0.7,
        actions: <Widget>[
          new Center(
            child: new Text(
              userName??'Superuser',
              style: new TextStyle(fontSize: 16.0),
            ),
          ),
          new SizedBox(width: 10.0,)
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Theme.of(context).accentColor,
                new Color(0xff4e8faf)
              ],
            ),
          ),
        ),
        bottom: TabBar(
            indicatorColor: Colors.white,
            controller: _tabController,
            tabs: [
              new Tab(icon: new Icon(Icons.list), text: '资产管理'),
              new Tab(icon: new Icon(Icons.assignment), text: '运维管理'),
              new Tab(icon: new Icon(Icons.insert_chart), text: '报表管理'),
            ]
        ),
      ),
      body: new TabBarView(
          controller: _tabController,
          children: [
            _TabView(context, tabType: TabType.EQUIP, contract: contractPermission,
            supplier: supplierPermission,),
            _TabView(context, tabType: TabType.CONTRACT, dispatch: dispatchTechPermission,
            request: requestTechPermission,),
            _TabView(context, tabType: TabType.VENDOR,),
          ]
      ),
    );
  }
}

class _TabView extends StatelessWidget {

  final TabType tabType;
  final BuildContext context;
  final Map contract;
  final Map supplier;
  final Map request;
  final Map dispatch;

  _TabView(this.context, {this.tabType, this.contract, this.supplier, this.request,
  this.dispatch});

  List<Widget> _menuList = [];

  Column buildIconColumn(_MenuItem menuOption) {
    return new Column(
      mainAxisSize: MainAxisSize.values[1],
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        new IconButton(
          icon: menuOption.menuIcon,
          color: Color(0xff4e8faf),
          onPressed: menuOption.onPress!=null?menuOption.onPress:() {
            return menuOption.targetPage != null?Navigator.of(context).push(new MaterialPageRoute(builder: (_) => menuOption.targetPage)):null;
          },
          iconSize: 50.0,
        ),
        new Container(
          margin: const EdgeInsets.only(top: 8.0),
          child: new Text(
            menuOption.menuTitle,
            style: new TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w400,
              color: new Color(0xff000000),
            ),
          ),
        ),
      ],
    );
  }

  void showInventory() {
    print("tab tab");
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return ListView(
            shrinkWrap: true,
            children:<Widget>[
              Card(
                child: ListTile(
                  title: new Center(
                    child: Text(
                      '服务库',
                      style: new TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16.0,
                          color: Colors.blue
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).push(new MaterialPageRoute(builder: (_) => new ServiceList()));
                  },
                ),
              ),
              Card(
                child: ListTile(
                  title: new Center(
                    child: Text('备用机库',
                      style: new TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16.0,
                          color: Colors.blue
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).push(new MaterialPageRoute(builder: (_) => new SpareList()));
                  },
                ),
              ),
            ],
          );
        }
    );
  }

  Widget build(BuildContext context) {
    switch (tabType) {
      case TabType.EQUIP:
        _menuList.clear();
        _menuList.addAll([
          SizedBox(height: 50.0,),
          Row(
            children: <Widget>[
              Expanded(
                flex: 4,
                child: buildIconColumn(new _MenuItem(Icon(Icons.computer), '医疗设备', targetPage: new EquipmentsList(equipmentType: EquipmentType.MEDICAL,))),
              ),
              Expanded(
                flex: 3,
                child: buildIconColumn(new _MenuItem(Icon(Icons.straighten), '计量器具', targetPage: new EquipmentsList(equipmentType: EquipmentType.MEASURE,))),
              ),
              Expanded(
                flex: 4,
                child: buildIconColumn(new _MenuItem(Icon(Icons.devices_other), '其他设备', targetPage: new EquipmentsList(equipmentType: EquipmentType.OTHER,))),
              )
            ],
          ),
          SizedBox(height: 50.0,),
          Row(
            children: <Widget>[
              Expanded(
                flex: 4,
                child: buildIconColumn(new _MenuItem(Icon(Icons.store), '库存', onPress: showInventory)),
              ),
              Expanded(
                flex: 3,
                child: buildIconColumn(new _MenuItem(Icon(Icons.event_note), '合同', targetPage: contract['View']!=null&&contract['View']?new ContractList():null)),
              ),
              Expanded(
                flex: 4,
                child: buildIconColumn(new _MenuItem(Icon(Icons.store), '供应商', targetPage: supplier['View']!=null&&supplier['View']?new VendorsList():null)),
              )
            ],
          ),
        ]);
        break;
      case TabType.CONTRACT:
        _menuList.clear();
        _menuList.addAll([
          SizedBox(height: 50.0,),
          Row(
            children: <Widget>[
              Expanded(
                flex: 4,
                child: buildIconColumn(new _MenuItem(Icon(Icons.assignment_late), '客户请求', targetPage: request['View']!=null&&request['View']?SuperRequest(pageType: PageType.REQUEST, type: 0,):null)),
              ),
              Expanded(
                flex: 3,
                child: buildIconColumn(new _MenuItem(Icon(Icons.assignment_ind), '派工单', targetPage: dispatch['View']!=null&&dispatch['View']?SuperRequest(pageType: PageType.DISPATCH, type: 0, field: "d.RequestID",):null)),
              ),
              Expanded(
                flex: 4,
                child: buildIconColumn(new _MenuItem(Icon(Icons.settings), '零配件管理', targetPage: ComponentList())),
              ),
            ],
          ),
          SizedBox(height: 50.0,),
          Row(
            children: <Widget>[
              Expanded(
                flex: 4,
                child: buildIconColumn(new _MenuItem(Icon(Icons.battery_charging_full), '耗材管理', targetPage: ConsumableList())),
              ),
              Expanded(
                flex: 3,
                child: Container(),
              ),
              Expanded(
                flex: 4,
                child: Container(),
              ),
            ],
          ),
        ]);
        break;
      case TabType.VENDOR:
        _menuList.clear();
        _menuList.addAll([
          SizedBox(height: 50.0,),
          Row(
            children: <Widget>[
              Expanded(
                flex: 4,
                child: buildIconColumn(new _MenuItem(Icon(Icons.show_chart), '设备绩效报表', targetPage: new ReportList(showContent: 'equip',))),
              ),
              Expanded(
                flex: 3,
                child: buildIconColumn(new _MenuItem(Icon(Icons.show_chart), '服务绩效报表', targetPage: new ReportList(showContent: 'service',))),
              ),
              Expanded(
                flex: 4,
                child: buildIconColumn(new _MenuItem(Icon(Icons.pie_chart), '运营实绩', targetPage: new ValuationHistory())),
              ),
            ],
          ),
        ]);
        break;
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: _menuList,
    );
  }
}

enum TabType {
  EQUIP,
  CONTRACT,
  VENDOR
}

class _MenuItem {
  final Icon menuIcon;
  final String menuTitle;
  final Widget targetPage;
  final Function onPress;
  _MenuItem(this.menuIcon, this.menuTitle, {this.targetPage, this.onPress});
}