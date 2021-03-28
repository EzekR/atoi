import 'dart:math';

import 'package:atoi/utils/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:atoi/models/models.dart';
import 'package:scoped_model/scoped_model.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:atoi/utils/http_request.dart';
import 'package:atoi/widgets/build_widget.dart';
import 'package:atoi/widgets/search_lazy.dart';
import 'package:atoi/utils/event_bus.dart';
import 'dart:convert';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:atoi/utils/constants.dart';
import 'package:date_format/date_format.dart';
import 'package:atoi/pages/inventory/po_attachment.dart';
import 'package:atoi/pages/inventory/inbound_stuff.dart';

/// 耗材详情页
class PODetail extends StatefulWidget {
  PODetail({Key key, this.purchaseOrder, this.editable, this.operation}) : super(key: key);
  final Map purchaseOrder;
  final bool editable;

  final PurchaseOrderOperation operation;
  _PODetailState createState() => new _PODetailState();
}

class _PODetailState extends State<PODetail> {
  String oid = '系统自动生成';
  String userName = '系统管理员';
  EventBus bus = new EventBus();
  Map manufacturer;
  Map po;
  Map supplier;
  String startDate = 'YYYY-MM-DD';
  String endDate = 'YYYY-MM-DD';
  ConstantsModel cModel;
  ScrollController controller = new ScrollController();
  FocusNode focusApprove = new FocusNode();
  String pageTitle = "新增采购单";
  String fujiComments;

  List _accs = [];
  List _consumable = [];
  List _services = [];
  List _componentsList = [];
  List _consumableList = [];
  List _servicesList = [];

  // inbound variables
  List _inboundComponents = [];
  List _inboundConsumable = [];
  List _inboundServices = [];
  TextEditingController serialCode = new TextEditingController(),
  model = new TextEditingController(),
  spec = new TextEditingController();
  List<TextEditingController> serviceTimes = [];

  List expansionList = new List(5).map((item) {
    return true;
  }).toList();

  void getName() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = _prefs.getString('userName');
    });
  }

  void initServiceInput() {
    serviceTimes = _servicesList.map<TextEditingController>((item) =>
    new TextEditingController(text: item['TotalTimes'].toString())).toList();
  }

  TextEditingController comments = new TextEditingController(),
                        approveComments = new TextEditingController();

  void initState() {
    super.initState();
    cModel = MainModel.of(context);
    if (widget.purchaseOrder != null) {
      getPurchaseOrder().then((_) {
        initServiceInput();
      });
    }
    getName();
    switch (widget.operation) {
      case PurchaseOrderOperation.APPROVE:
        pageTitle = "审核采购单";
        break;
      case PurchaseOrderOperation.EDIT:
        pageTitle = "编辑采购单";
        break;
      case PurchaseOrderOperation.INBOUND:
        pageTitle = "采购单入库";
        break;
    }
    if (!widget.editable&&widget.operation==null) {
      pageTitle = "查看采购单";
    }
  }

  Future<Null> getPurchaseOrder() async {
    var resp = await HttpRequest.request('/PurchaseOrder/GetPurchaseOrderByID',
        method: HttpRequest.GET, params: {'purchaseOrderID': widget.purchaseOrder['ID']});
    if (resp['ResultCode'] == '00') {
      var _data = resp['Data'];
      po = _data;
      setState(() {
        oid = _data['OID'];
        startDate = _data['OrderDate'].toString().split('T')[0];
        endDate = _data['DueDate'].toString().split('T')[0];
        supplier = _data['Supplier'];
        comments.text = _data['Comments'];
        fujiComments = _data['FujiComments'];
        userName = _data['User']['Name'];
        _componentsList = _data['Components'];
        _accs = _componentsList.map((_data) {
          Map _info = {
            '简称': _data['Component']['Name'],
            '描述': _data['Component']['Description'],
            '规格': _data['Specification'],
            '型号': _data['Model'],
            '类型': _data['Component']['Type']['Name'],
            '关联设备': _data['Equipment']['Name'],
            '单价': CommonUtil.CurrencyForm(_data['Price'], times: 1, digits: 0),
            '数量': _data['Qty'].toString()
          };
          if (widget.operation == PurchaseOrderOperation.INBOUND) {
            _info['已入库数量'] = _data['InboundQty'].toString();
          }
          return _info;
        }).toList();
        _consumableList = _data['Consumables'];
        _consumable = _consumableList.map((_data) {
          Map _info = {
            '简称': _data['Consumable']['Name'],
            '描述': _data['Consumable']['Description'],
            '规格': _data['Specification'],
            '型号': _data['Model'],
            '关联富士II类': _data['Consumable']['FujiClass2']['Name'],
            '单价': CommonUtil.CurrencyForm(_data['Price'], times: 1, digits: 0),
            '单位': _data['Unit'],
            '数量': _data['Qty'].toString()
          };
          if (widget.operation == PurchaseOrderOperation.INBOUND) {
            _info['已入库数量'] = _data['InboundQty'].toString();
          }
          return _info;
        }).toList();
        _servicesList = _data['Services'];
        _services = _servicesList.map((_data) {
          return {
            '服务名称': _data['Name'],
            '关联设备': _data['Equipments'].map((equip) => equip['Name']).join(";"),
            '金额': CommonUtil.CurrencyForm(_data['Price'], times: 1, digits: 0),
            '服务开始日期': _data['StartDate'].toString().split('T')[0],
            '服务结束日期': _data['EndDate'].toString().split('T')[0],
            '服务次数': _data['TotalTimes'].toString()
          };
        }).toList();
      });
    }
  }

  List<FocusNode> _focusComponent = new List(10).map((item) {
    return new FocusNode();
  }).toList();

  Future<Null> savePurchaseOrder({int statusId}) async {
    statusId = statusId ?? 1;
    setState(() {
      expansionList = expansionList.map((item) {
        return true;
      }).toList();
    });
    if (supplier == null) {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('供应商不可为空'),
      )).then((result) => controller.jumpTo(0.0));
      return;
    }
    if (startDate == 'YYYY-MM-DD') {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('采购日期不可为空'),
      )).then((result) => controller.jumpTo(0.0));
      return;
    }
    if (endDate == 'YYYY-MM-DD') {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('到货日期不可为空'),
      )).then((result) => controller.jumpTo(0.0));
      return;
    }
    if (DateTime.parse(startDate).isAfter(DateTime.parse(endDate))) {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('采购日期不可在到货日期之后'),
      )).then((result) => controller.jumpTo(0.0));
      return;
    }
    if (statusId == 2 && _consumableList.isEmpty && _componentsList.isEmpty && _servicesList.isEmpty) {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('请添加采购内容'),
      )).then((result) => controller.jumpTo(100.0));
      return;
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _info = {
      'User': {
        'ID': prefs.getInt('userID')
      },
      'Supplier': {
        'ID': supplier['ID']
      },
      'OrderDate': startDate,
      'DueDate': endDate,
      'Comments': comments.text,
      'Status': {
        'ID': statusId
      },
      'Components': _componentsList,
      'Consumables': _consumableList,
      'Services': _servicesList,
      'ID': 0
    };
    if (widget.purchaseOrder != null) {
      _info['ID'] = widget.purchaseOrder['ID'];
    }
    var _data = {
      "userID": prefs.getInt('userID'),
      "info": _info
    };
    var resp = await HttpRequest.request(
        '/PurchaseOrder/SavePurchaseOrder',
        method: HttpRequest.POST,
        data: _data
    );
    if (resp['ResultCode'] == '00') {
      showDialog(context: context, builder: (context) {
        return CupertinoAlertDialog(
          title: new Text(statusId==1?'保存成功':'提交成功'),
        );
      }).then((result) => Navigator.of(context).pop());
    } else {
      showDialog(context: context, builder: (context) {
        return CupertinoAlertDialog(
          title: new Text(resp['ResultMessage']),
        );
      });
    }
  }

  void handlePO(int operationId) async {
    String url;
    switch (operationId) {
      case 0:
        url = '/PurchaseOrder/CancelPurchaseOrder';
        break;
      case 1:
        url = '/PurchaseOrder/PassPurchaseOrder';
        break;
      case 2:
        url = '/PurchaseOrder/RejectPurchaseOrder';
        break;
      case 3:
        url = '/PurchaseOrder/EndPurchaseOrder';
        break;
    }
    if (operationId == 2 && approveComments.text.isEmpty){
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('审批备注不可为空'),
      )).then((result) => FocusScope.of(context).requestFocus(focusApprove));
      return;
    }
    Map resp = await HttpRequest.request(
      url,
      method: HttpRequest.POST,
      data: {
        'purchaseOrderID': widget.purchaseOrder['ID'],
        'comments': approveComments.text
      }
    );
    if (resp['ResultCode'] == '00') {
      showDialog(context: context, builder: (context) {
        return CupertinoAlertDialog(
          title: new Text('操作成功'),
        );
      }).then((result) => Navigator.of(context).pop());
    } else {
      showDialog(context: context, builder: (context) {
        return CupertinoAlertDialog(
          title: new Text(resp['ResultMessage']),
        );
      });
    }
  }


  Row buildDropdown(String title, int currentItem, List dropdownItems, Function changeDropdown, {bool required}) {
    return new Row(
      children: <Widget>[
        new Expanded(
          flex: 4,
          child: new Wrap(
            alignment: WrapAlignment.end,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              required?new Text(
                '*',
                style: new TextStyle(
                    color: Colors.red
                ),
              ):Container(),
              new Text(
                title,
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
          flex: 6,
          child: new DropdownButton(
            value: currentItem,
            items: dropdownItems.map<DropdownMenuItem>((item) {
              return DropdownMenuItem(
                value: item['value'],
                child: Text(
                  item['text'],
                  style: TextStyle(
                      fontSize: 12.0
                  ),
                ),
              );
            }).toList(),
            onChanged: changeDropdown,
            style: new TextStyle(
              color: Colors.black54,
              fontSize: 12.0,
            ),
          ),
        )
      ],
    );
  }

  Padding buildRow(String labelText, String defaultText) {
    return new Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: new Row(
        children: <Widget>[
          new Expanded(
            flex: 4,
            child: new Text(
              labelText,
              style: new TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
            ),
          ),
          new Expanded(
            flex: 6,
            child: new Text(
              defaultText,
              style: new TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w400,
                  color: Colors.black54),
            ),
          )
        ],
      ),
    );
  }

  void inboundService(List service) async {
    Map _info = {
      'User': {
        'ID': po['User']['ID']
      },
      'ID': po['ID'],
      'Supplier': {
        'ID': po['Supplier']['ID']
      },
      'OrderDate': po['OrderDate'],
      'DueDate': po['DueDate'],
      'Comments': po['Comments'],
      'Status': {
        'ID': po['Status']['ID']
      }
    };
    _info['Services'] = service;
    Map resp = await HttpRequest.request(
      '/PurchaseOrder/InboundPurchaseOrder',
      method: HttpRequest.POST,
      data: {
        'info': _info
      }
    );
    if (resp['ResultCode'] == '00') {
      showDialog(context: context, builder: (context) {
        return CupertinoAlertDialog(
          title: new Text('入库成功'),
        );
      }).then((result) => getPurchaseOrder());
    }
  }

  Card buildCard(Map item, Map fullItem, AttachmentType pageType, int key) {
    List _list = item.keys.map<Widget>((key) {
      return BuildWidget.buildRow(key, item[key]);
    }).toList();
    if (widget.operation == PurchaseOrderOperation.INBOUND) {
      //if (pageType == AttachmentType.SERVICE && !fullItem['Inbounded']) {
      //  _list.removeLast();
      //  _list.add(
      //      BuildWidget.buildCardInput('服务次数', serviceTimes[key])
      //  );
      //}
      _list.add(
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: pageType==AttachmentType.SERVICE?[
              !fullItem['Inbounded']?RaisedButton(
                onPressed: () {
                  List _service = [
                    {
                      'ID': fullItem['ID'],
                      'Equipments': fullItem['Equipments'],
                      'Name': fullItem['Name'],
                      'TotalTimes': serviceTimes[key].text,
                      'Price': fullItem['Price'],
                      'StartDate': fullItem['StartDate'],
                      'EndDate': fullItem['EndDate'],
                      'Purchase': {
                        'ID': fullItem['Purchase']['ID']
                      }
                    }
                  ];
                  inboundService(_service);
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: EdgeInsets.all(12.0),
                color: new Color(0xff2E94B9),
                child: Center(
                  child: Text(
                    '入库',
                    style: TextStyle(
                        color: Colors.white
                    ),
                  ),
                ),
              ):Text('已入库'),
            ]:[
              fullItem['Qty']!=fullItem['InboundQty']?RaisedButton(
                onPressed: () {
                  Navigator.of(context).push(new MaterialPageRoute(builder: (context) => new InboundStuff(stuff: fullItem, type: pageType, purchaseOrder: po,))).then((result) {
                    getPurchaseOrder();
                  });
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: EdgeInsets.all(12.0),
                color: new Color(0xff2E94B9),
                child: Center(
                  child: Text(
                    '入库',
                    style: TextStyle(
                        color: Colors.white
                    ),
                  ),
                ),
              ):Text('已入库'),
            ],
          )
      );
    }
    if (widget.editable) {
      _list.add(
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              RaisedButton(
                onPressed: () {
                  print(fullItem);
                  // todo: 富士二类改成关联设备
                  Navigator.of(context).push(new MaterialPageRoute(builder: (context) => POAttachment(po: fullItem, editable: true, attachType: pageType,))).then((result) {
                    if (result !=null) {
                      Map _data = result;
                      switch (pageType) {
                        case AttachmentType.COMPONENT:
                          setState(() {
                            _componentsList[key] = _data;
                          });
                          _accs[key] = {
                            '简称': _data['Component']['Name'],
                            '描述': _data['Component']['Description'],
                            '规格': _data['Specification'],
                            '型号': _data['Model'],
                            '类型': _data['Component']['Type']['Name'],
                            '关联设备': _data['Equipment']['Name'],
                            '单价': CommonUtil.CurrencyForm(double.tryParse(_data['Price']), times: 1, digits: 0),
                            '数量': _data['Qty']
                          };
                          break;
                        case AttachmentType.CONSUMABLE:
                          setState(() {
                            _consumableList[key] = _data;
                          });
                          _consumable[key] = {
                            '简称': _data['Consumable']['Name'],
                            '描述': _data['Consumable']['Description'],
                            '规格': _data['Specification'],
                            '型号': _data['Model'],
                            '关联富士II类': _data['Consumable']['FujiClass2']['Name'],
                            '单价': CommonUtil.CurrencyForm(double.tryParse(_data['Price']), times: 1, digits: 0),
                            '单位': _data['Unit'],
                            '数量': _data['Qty']
                          };
                          break;
                        case AttachmentType.SERVICE:
                          setState(() {
                            _servicesList[key] = _data;
                            //serviceTimes[key].text = _data['TotalTimes'];
                          });
                          _services[key] = {
                            '服务名称': _data['Name'],
                            '关联设备': _data['Equipments'].map((equip) => equip['Name']).join(";"),
                            '金额': CommonUtil.CurrencyForm(double.tryParse(_data['Price']), times: 1, digits: 0),
                            '服务开始日期': _data['StartDate'].toString().split("T")[0],
                            '服务结束日期': _data['EndDate'].toString().split("T")[0],
                            '服务次数': _data['TotalTimes']
                          };
                          break;
                      }
                    }
                  });
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: EdgeInsets.all(12.0),
                color: new Color(0xff2E94B9),
                child: Center(
                  child: Text(
                    '编辑',
                    style: TextStyle(
                        color: Colors.white
                    ),
                  ),
                ),
              ),
              RaisedButton(
                onPressed: () {
                  switch (pageType) {
                    case AttachmentType.COMPONENT:
                      setState(() {
                        _componentsList.removeAt(key);
                        _accs.removeAt(key);
                      });
                      break;
                    case AttachmentType.CONSUMABLE:
                      setState(() {
                        _consumableList.removeAt(key);
                        _consumable.removeAt(key);
                      });
                      break;
                    case AttachmentType.SERVICE:
                      setState(() {
                        _servicesList.removeAt(key);
                        _services.removeAt(key);
                      });
                      break;
                  }
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: EdgeInsets.all(12.0),
                color: new Color(0xffD25565),
                child: Center(
                  child: Text(
                    '删除',
                    style: TextStyle(
                        color: Colors.white
                    ),
                  ),
                ),
              ),
            ],
          )
      );
    }
    return Card(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: _list,
        ),
      ),
    );
  }

  List<Widget> buildList(List targetList, List originList, AttachmentType pageType) {
    List<Widget> _list = [];
    if (targetList.length == 0) {
      _list.add(Center(child: Text('暂无数据'),));
    } else {
      _list.addAll(
        targetList.asMap().keys.map((key) => buildCard(targetList[key], originList[key], pageType, key)).toList()
      );
    }
    if (widget.editable) {
      _list.add(
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.add_circle),
                onPressed: () {
                  Navigator.of(context).push(new MaterialPageRoute(builder: (context) => new POAttachment(editable: true, attachType: pageType,))).then((result) {
                    print(result);
                    if (result != null) {
                      Map _data = result;
                      switch (pageType) {
                        case AttachmentType.COMPONENT:
                          _componentsList.add(_data);
                          _accs.add({
                            '简称': _data['Component']['Name'],
                            '描述': _data['Component']['Description'],
                            '规格': _data['Specification'],
                            '型号': _data['Model'],
                            '类型': _data['Component']['Type']['Name'],
                            '关联设备': _data['Equipment']['Name'],
                            '单价': CommonUtil.CurrencyForm(double.tryParse(_data['Price']), times: 1, digits: 0),
                            '数量': _data['Qty']
                          });
                          break;
                        case AttachmentType.CONSUMABLE:
                          _consumableList.add(_data);
                          _consumable.add({
                            '简称': _data['Consumable']['Name'],
                            '描述': _data['Consumable']['Description'],
                            '规格': _data['Specification'],
                            '型号': _data['Model'],
                            '关联富士II类': _data['Consumable']['FujiClass2']['Name'],
                            '单价': CommonUtil.CurrencyForm(double.tryParse(_data['Price']), times: 1, digits: 0),
                            '单位': _data['Unit'],
                            '数量': _data['Qty']
                          });
                          break;
                        case AttachmentType.SERVICE:
                          _servicesList.add(_data);
                          _services.add({
                            '服务名称': _data['Name'],
                            '关联设备': _data['Equipments'].map((equip) => equip['Name']).join(";"),
                            '金额': CommonUtil.CurrencyForm(double.tryParse(_data['Price']), times: 1, digits: 0),
                            '服务开始日期': _data['StartDate'].toString().split('T')[0],
                            '服务结束日期': _data['EndDate'].toString().split('T')[0],
                            '服务次数': _data['TotalTimes']
                          });
                          break;
                      }
                    }
                  });
                },
              )
            ],
          )
      );
    }
    return _list;
  }

  bool checkInboundComponent() {
    bool allInbound = true;
    _componentsList.forEach((_comp) {
      if (_comp['InboundQty'] != _comp['Qty']) {
        allInbound = false;
      }
    });
    return allInbound;
  }

  bool checkInboundConsumable() {
    bool allInbound = true;
    _consumableList.forEach((_con) {
      if (_con['InboundQty'] != _con['Qty']) {
        allInbound = false;
      }
    });
    return allInbound;
  }

  // todo: 服务未完全入库判断
  bool checkInboundService() {
    bool allInbound = true;
    _servicesList.forEach((_con) {
      if (!_con['Inbounded']) {
        allInbound = false;
      }
    });
    return allInbound;
  }

  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (context, child, mainModel) {
        return new Scaffold(
            appBar: new AppBar(
              // todo : 判断title
              title: Text(pageTitle),
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
              actions: <Widget>[],
            ),
            body: new Padding(
              padding: EdgeInsets.symmetric(vertical: 5.0),
              child: new Card(
                child: new ListView(
                  controller: controller,
                  children: <Widget>[
                    new ExpansionPanelList(
                      animationDuration: Duration(milliseconds: 200),
                      expansionCallback: (index, isExpanded) {
                        setState(() {
                          expansionList[index] = !expansionList[index];
                        });
                      },
                      children: [
                        new ExpansionPanel(
                          canTapOnHeader: true,
                          headerBuilder: (context, isExpanded) {
                            return ListTile(
                              leading: new Icon(
                                Icons.description,
                                size: 24.0,
                                color: Colors.blue,
                              ),
                              title: Text(
                                '采购单基本信息',
                                style: new TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w400),
                              ),
                            );
                          },
                          body: new Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.0),
                            child: new Column(
                              children: <Widget>[
                                BuildWidget.buildRow('系统编号', oid),
                                BuildWidget.buildRow('请求人', userName),
                                widget.editable?new Padding(
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
                                              '采购日期',
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
                                                dateFormat: 'yyyy-MM-dd',
                                                locale: DateTimePickerLocale.en_us,
                                                onClose: () => print(""),
                                                onCancel: () => print('onCancel'),
                                                onChange: (dateTime, List<int> index) {
                                                },
                                                onConfirm: (dateTime, List<int> index) {
                                                  var _date = formatDate(dateTime, [yyyy, '-', mm, '-', dd]);
                                                  setState(() {
                                                    startDate = _date;
                                                  });
                                                },
                                              );
                                            }),
                                      ),
                                    ],
                                  ),
                                ):BuildWidget.buildRow('采购日期', startDate),
                                widget.editable?new Padding(
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
                                              '到货日期',
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
                                          endDate,
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
                                              var _time = DateTime.tryParse(endDate)??DateTime.now();
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
                                                dateFormat: 'yyyy-MM-dd',
                                                locale: DateTimePickerLocale.en_us,
                                                onClose: () => print(""),
                                                onCancel: () => print('onCancel'),
                                                onChange: (dateTime, List<int> index) {
                                                },
                                                onConfirm: (dateTime, List<int> index) {
                                                  var _date = formatDate(dateTime, [yyyy, '-', mm, '-', dd]);
                                                  setState(() {
                                                    endDate = _date;
                                                  });
                                                },
                                              );
                                            }),
                                      ),
                                    ],
                                  ),
                                ):BuildWidget.buildRow('到货日期', endDate),
                                widget.editable?new Padding(
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
                                              '供应商',
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
                                          supplier == null ? '' : supplier['Name'],
                                          style: new TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.w400,
                                              color: Colors.black54),
                                        ),
                                      ),
                                      new Expanded(
                                          flex: 2,
                                          child: new IconButton(
                                              focusNode: _focusComponent[3],
                                              icon: Icon(Icons.search),
                                              onPressed: () async {
                                                FocusScope.of(context).requestFocus(new FocusNode());
                                                final _searchResult = await Navigator.of(context).push(new MaterialPageRoute(builder: (_) => SearchLazy(searchType: SearchType.VENDOR,)));
                                                print(_searchResult);
                                                if (_searchResult != null &&
                                                    _searchResult != 'null') {
                                                  setState(() {
                                                    supplier = jsonDecode(_searchResult);
                                                  });
                                                }
                                              })),
                                    ],
                                  ),
                                ):BuildWidget.buildRow('供应商', supplier==null?'':supplier['Name']),
                                widget.editable?BuildWidget.buildInput('备注', comments, maxLength: 500, focusNode: _focusComponent[5]):BuildWidget.buildRow('备注', comments.text),
                                fujiComments!=null?BuildWidget.buildRow("审批备注", fujiComments):Container(),
                                new Divider(),
                                new Padding(
                                    padding:
                                    EdgeInsets.symmetric(vertical: 8.0))
                              ],
                            ),
                          ),
                          isExpanded: expansionList[0],
                        ),
                        new ExpansionPanel(
                          canTapOnHeader: true,
                          isExpanded: expansionList[1],
                          headerBuilder: (context, isExpanded) {
                            return ListTile(
                              leading: new Icon(
                                Icons.settings,
                                size: 24.0,
                                color: Colors.blue,
                              ),
                              title: Text(
                                '零件',
                                style: new TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w400),
                              ),
                            );
                          },
                          body: new Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.0),
                            child: new Padding(
                              padding: EdgeInsets.symmetric(vertical: 5.0),
                              child: Column(
                                children: buildList(_accs, _componentsList, AttachmentType.COMPONENT),
                              ),
                            ),
                          )
                        ),
                        new ExpansionPanel(
                            canTapOnHeader: true,
                            isExpanded: expansionList[2],
                            headerBuilder: (context, isExpanded) {
                              return ListTile(
                                leading: new Icon(
                                  Icons.restore_from_trash,
                                  size: 24.0,
                                  color: Colors.blue,
                                ),
                                title: Text(
                                  '耗材',
                                  style: new TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.w400),
                                ),
                              );
                            },
                            body: new Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12.0),
                              child: new Padding(
                                padding: EdgeInsets.symmetric(vertical: 5.0),
                                child: Column(
                                  children: buildList(_consumable, _consumableList, AttachmentType.CONSUMABLE),
                                ),
                              ),
                            )
                        ),
                        new ExpansionPanel(
                            canTapOnHeader: true,
                            isExpanded: expansionList[3],
                            headerBuilder: (context, isExpanded) {
                              return ListTile(
                                leading: new Icon(
                                  Icons.assignment_ind,
                                  size: 24.0,
                                  color: Colors.blue,
                                ),
                                title: Text(
                                  '服务',
                                  style: new TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.w400),
                                ),
                              );
                            },
                            body: new Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12.0),
                              child: new Padding(
                                padding: EdgeInsets.symmetric(vertical: 5.0),
                                child: Column(
                                  children: buildList(_services, _servicesList, AttachmentType.SERVICE),
                                ),
                              ),
                            )
                        ),
                      ],
                    ),
                    SizedBox(height: 24.0),
                    widget.operation==PurchaseOrderOperation.APPROVE?BuildWidget.buildInput('审批备注', approveComments, focusNode: focusApprove):Container(),
                    new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: widget.operation==PurchaseOrderOperation.APPROVE?[
                        new RaisedButton(
                          onPressed: () {
                            handlePO(2);
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: EdgeInsets.all(12.0),
                          color: new Color(0xffD25565),
                          child:
                          Text('退回', style: TextStyle(color: Colors.white)),
                        ),
                        new RaisedButton(
                          onPressed: () {
                            handlePO(1);
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: EdgeInsets.all(12.0),
                          color: new Color(0xff2E94B9),
                          child:
                          Text('通过', style: TextStyle(color: Colors.white)),
                        ),
                        new RaisedButton(
                          onPressed: () {
                            handlePO(0);
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: EdgeInsets.all(12.0),
                          color: new Color(0xff2E94B9),
                          child:
                          Text('终止', style: TextStyle(color: Colors.white)),
                        ),
                      ]:[
                        Container(),
                        widget.editable?new RaisedButton(
                          onPressed: () {
                            FocusScope.of(context).requestFocus(new FocusNode());
                            savePurchaseOrder(statusId: 1);
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: EdgeInsets.all(12.0),
                          color: new Color(0xff2E94B9),
                          child:
                          Text('保存', style: TextStyle(color: Colors.white)),
                        ):new Container(),
                        widget.editable?new RaisedButton(
                          onPressed: () {
                            FocusScope.of(context).requestFocus(new FocusNode());
                            savePurchaseOrder(statusId: 2);
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: EdgeInsets.all(12.0),
                          color: new Color(0xffD25565),
                          child:
                          Text('提交', style: TextStyle(color: Colors.white)),
                        ):Container(),
                        widget.operation==PurchaseOrderOperation.INBOUND?new RaisedButton(
                          onPressed: () {
                            if (!checkInboundComponent()) {
                              showDialog(context: context, builder: (context) => CupertinoAlertDialog(
                                title: new Text('零件未完全入库，请联系管理员'),
                              ));
                              return;
                            }
                            if (!checkInboundConsumable()) {
                              showDialog(context: context, builder: (context) => CupertinoAlertDialog(
                                title: new Text('耗材未完全入库，请联系管理员'),
                              ));
                              return;
                            }
                            if (!checkInboundService()) {
                              showDialog(context: context, builder: (context) => CupertinoAlertDialog(
                                title: new Text('服务未完全入库，请联系管理员'),
                              ));
                              return;
                            }
                            handlePO(3);
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: EdgeInsets.all(12.0),
                          color: new Color(0xffD25565),
                          child:
                          Text('完成', style: TextStyle(color: Colors.white)),
                        ):Container(),
                      ],
                    )
                  ],
                ),
              ),
            ));
      },
    );
  }
}

enum PurchaseOrderOperation {
  EDIT,
  APPROVE,
  INBOUND
}