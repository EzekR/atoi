import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:atoi/pages/equipments/equipments_list.dart';
import 'package:atoi/pages/equipments/contract_list.dart';
import 'package:atoi/pages/equipments/vendors_list.dart';
import 'package:atoi/pages/reports/report_list.dart';
import 'package:atoi/pages/superuser/super_request.dart';
import 'package:atoi/models/main_model.dart';
import 'package:atoi/models/constants_model.dart';

class SuperHome extends StatefulWidget {
  _SuperHomeState createState() => _SuperHomeState();
}

class _SuperHomeState extends State<SuperHome> with SingleTickerProviderStateMixin{

  TabController _tabController;
  ConstantsModel model;

  void initState() {
    super.initState();
    model = MainModel.of(context);
    model.getConstants();
    _tabController = new TabController(length: 3, vsync: this, initialIndex: 0);
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
              'Superuser',
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
            _TabView(context, tabType: TabType.EQUIP,),
            _TabView(context, tabType: TabType.CONTRACT,),
            _TabView(context, tabType: TabType.VENDOR,),
          ]
      ),
    );
  }
}

class _TabView extends StatelessWidget {

  final TabType tabType;
  final BuildContext context;
  _TabView(this.context, {this.tabType});

  List<Widget> _menuList = [];

  Column buildIconColumn(_MenuItem menuOption) {
    return new Column(
      mainAxisSize: MainAxisSize.values[1],
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        new IconButton(
          icon: menuOption.menuIcon,
          color: Color(0xff4e8faf),
          onPressed: () {
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

  Widget build(BuildContext context) {
    switch (tabType) {
      case TabType.EQUIP:
        _menuList.clear();
        _menuList.addAll([
          Expanded(
            flex: 4,
            child: buildIconColumn(new _MenuItem(Icon(Icons.computer), '设备', targetPage: new EquipmentsList())),
          ),
          Expanded(
            flex: 3,
            child: buildIconColumn(new _MenuItem(Icon(Icons.event_note), '合同', targetPage: new ContractList())),
          ),
          Expanded(
            flex: 4,
            child: buildIconColumn(new _MenuItem(Icon(Icons.store), '供应商', targetPage: new VendorsList())),
          )
        ]);
        break;
      case TabType.CONTRACT:
        _menuList.clear();
        _menuList.addAll([
          Expanded(
            flex: 4,
            child: buildIconColumn(new _MenuItem(Icon(Icons.assignment_late), '客户请求', targetPage: SuperRequest(pageType: PageType.REQUEST,))),
          ),
          Expanded(
            flex: 4,
            child: buildIconColumn(new _MenuItem(Icon(Icons.assignment_ind), '派工单', targetPage: SuperRequest(pageType: PageType.DISPATCH,))),
          )
        ]);
        break;
      case TabType.VENDOR:
        _menuList.clear();
        _menuList.addAll([
          Expanded(
            flex: 4,
            child: buildIconColumn(new _MenuItem(Icon(Icons.show_chart), '设备绩效报表', targetPage: new ReportList(showContent: 'equip',))),
          ),
          Expanded(
            flex: 4,
            child: buildIconColumn(new _MenuItem(Icon(Icons.show_chart), '服务绩效报表', targetPage: new ReportList(showContent: 'service',))),
          )
        ]);
        break;
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        new SizedBox(
          height: 100.0,
        ),
        new Center(
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _menuList,
          ),
        ),
      ],
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
  _MenuItem(this.menuIcon, this.menuTitle, {this.targetPage});
}