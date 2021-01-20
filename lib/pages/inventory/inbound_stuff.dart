import 'dart:developer';

import 'package:atoi/pages/equipments/print_qrcode.dart';
import 'package:atoi/pages/inventory/po_attachment.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:atoi/widgets/build_widget.dart';
import 'package:atoi/utils/http_request.dart';

class InboundStuff extends StatefulWidget{
  final AttachmentType type;
  final Map stuff;
  final Map purchaseOrder;
  InboundStuff({Key key, this.type, this.stuff, this.purchaseOrder}):super(key: key);

  _InboundStuffState createState() => new _InboundStuffState();
}

class _InboundStuffState extends State<InboundStuff> {

  String pageTitle;
  List<Widget> stuffList = [];

  // components
  List inboundComponents = [];
  List<TextEditingController> serialList = [];
  List<TextEditingController> specList = [];
  List<TextEditingController> modelList = [];

  // consumable
  List inboundConsumable = [];
  List<TextEditingController> lotNumList = [];
  List<TextEditingController> quantityList = [];

  void addOneComponent() {
    Map _component = widget.stuff;
    log("$_component");
    if (inboundComponents.length > (_component['Qty'] - _component['InboundQty'])) {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('入库数量不能超过采购数量'),
      ));
      return;
    }
    Map item = widget.stuff;
    inboundComponents.add({
      'ID': item['ID'],
      'Component': {
        'ID': item['Component']['ID']
      },
      'Equipment': {
        'ID': item['Equipment']['ID']
      },
      'SerialCode': '',
      'Model': item['Model'],
      'Specification': item['Specification'],
      'Price': item['Price']
    });
    serialList.add(new TextEditingController());
    TextEditingController _specTmp = new TextEditingController();
    _specTmp.text = item['Specification'];
    specList.add(_specTmp);
    TextEditingController _modelTmp = new TextEditingController();
    _modelTmp.text = item['Model'];
    modelList.add(_modelTmp);
    setState(() {
      inboundComponents = inboundComponents;
    });
  }


  void addOneConsumable() {
    Map item = widget.stuff;
    inboundConsumable.add({
      'ID': item['ID'],
      'Consumable': {
        'ID': item['Consumable']['ID']
      },
      'LotNum': '',
      'Model': item['Model'],
      'Specification': item['Specification'],
      'Price': item['Price'],
      'Qty': item['Qty']
    });
    lotNumList.add(new TextEditingController());
    TextEditingController _specTmp = new TextEditingController();
    _specTmp.text = item['Specification'];
    specList.add(_specTmp);
    TextEditingController _modelTmp = new TextEditingController();
    _modelTmp.text = item['Model'];
    modelList.add(_modelTmp);
    TextEditingController _qtyTmp = new TextEditingController();
    _qtyTmp.text = item['Qty'].toString();
    quantityList.add(_qtyTmp);
    setState(() {
      inboundConsumable = inboundConsumable;
    });
  }

  void inboundComponent() async {
    Map _component = widget.stuff;
    Map _po = widget.purchaseOrder;
    print(_po.toString());
    if (widget.type == AttachmentType.COMPONENT) {
      if (serialList.any((item) => item.text.isEmpty)) {
        showDialog(context: context, builder: (context) => CupertinoAlertDialog(
          title: new Text('序列号不可为空'),
        ));
        return;
      }
      if (inboundComponents.length > (_component['Qty']-_component['InboundQty'])) {
        showDialog(context: context, builder: (context) => CupertinoAlertDialog(
          title: new Text('入库数量不可超过零件数量'),
        ));
        return;
      }
    }
    if (widget.type == AttachmentType.CONSUMABLE) {
      if (lotNumList.any((item) => item.text.isEmpty)) {
        showDialog(context: context, builder: (context) => CupertinoAlertDialog(
          title: new Text('批次号不可为空'),
        ));
        return;
      }
    }
    List _list = [];
    Map _info = {
      'User': {
        'ID': _po['User']['ID']
      },
      'ID': _po['ID'],
      'Supplier': {
        'ID': _po['Supplier']['ID']
      },
      'OrderDate': _po['OrderDate'],
      'DueDate': _po['DueDate'],
      'Comments': _po['Comments'],
      'Status': {
        'ID': _po['Status']['ID']
      }
    };
    if (widget.type == AttachmentType.COMPONENT) {
      _list = inboundComponents.asMap().keys.map((key) {
        return {
          'ID': _component['ID'],
          'Component': {
            'ID': _component['Component']['ID']
          },
          'Equipment': {
            'ID': _component['Equipment']['ID']
          },
          'SerialCode': serialList[key].text,
          'Specification': specList[key].text,
          'Model': modelList[key].text,
          'Price': _component['Price']
        };
      }).toList();
      _info['Components'] = _list;
    }
    if (widget.type == AttachmentType.CONSUMABLE) {
      _list = inboundConsumable.asMap().keys.map((key) {
        return {
          'ID': _component['ID'],
          'Consumable': {
            'ID': _component['Consumable']['ID']
          },
          'LotNum': lotNumList[key].text,
          'Specification': specList[key].text,
          'Model': modelList[key].text,
          'Price': _component['Price'],
          'Qty': quantityList[key].text
        };
      }).toList();
      _info['Consumables'] = _list;
    }
    Map resp = await HttpRequest.request(
      '/PurchaseOrder/InboundPurchaseOrder',
      method: HttpRequest.POST,
      data: {
        'info': _info
      }
    );
    if (resp['ResultCode'] == '00') {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text('入库成功'),
      )).then((result) {
        switch (widget.type) {
          case AttachmentType.COMPONENT:
            Navigator.of(context).push(new MaterialPageRoute(builder: (_) => PrintQrcode(components: resp['Data']['Components'], codeType: CodeType.COMPONENT,)));
            break;
          case AttachmentType.CONSUMABLE:
            Navigator.of(context).push(new MaterialPageRoute(builder: (_) => PrintQrcode(equipmentId: resp['Data']['Consumables'][0]['ID'], codeType: CodeType.CONSUMABLE,)));
            break;
          case AttachmentType.SERVICE:
            break;
        }
      });
    } else {
      showDialog(context: context, builder: (context) => CupertinoAlertDialog(
        title: new Text(resp['ResultMessage']),
      ));
    }
  }

  List<Widget> buildStuffList() {
    List<Widget> _list = [];
    switch (widget.type) {
      case AttachmentType.COMPONENT:
        for(int i=0; i<inboundComponents.length; i++) {
          _list.add(
            Card(
              child: Column(
                children: <Widget>[
                  BuildWidget.buildCardInput('序列号', serialList[i]),
                  BuildWidget.buildCardInput('规格', specList[i]),
                  BuildWidget.buildCardInput('型号', modelList[i]),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      inboundComponents.length>1?IconButton(
                        color: Colors.redAccent,
                        icon: Icon(Icons.delete_forever),
                        onPressed: () {
                          setState(() {
                            inboundComponents.removeAt(i);
                            serialList.removeAt(i);
                            specList.removeAt(i);
                            modelList.removeAt(i);
                          });
                        },
                      ):Container(),
                    ],
                  )
                ],
              ),
            )
          );
        }
        break;
      case AttachmentType.CONSUMABLE:
        for(int i=0; i<inboundConsumable.length; i++) {
          _list.add(
              Card(
                child: Column(
                  children: <Widget>[
                    BuildWidget.buildCardInput('批次号', lotNumList[i]),
                    BuildWidget.buildCardInput('规格', specList[i]),
                    BuildWidget.buildCardInput('型号', modelList[i]),
                    BuildWidget.buildCardRow('数量', quantityList[i].text),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        inboundConsumable.length>1?IconButton(
                          color: Colors.redAccent,
                          icon: Icon(Icons.delete_forever),
                          onPressed: () {
                            setState(() {
                              inboundConsumable.removeAt(i);
                              lotNumList.removeAt(i);
                              specList.removeAt(i);
                              modelList.removeAt(i);
                              quantityList.removeAt(i);
                            });
                          },
                        ):Container(),
                      ],
                    )
                  ],
                ),
              )
          );
        }
        break;
      case AttachmentType.SERVICE:
        break;
    }
    _list.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RaisedButton(
            onPressed: () {
              inboundComponent();
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            padding: EdgeInsets.all(12.0),
            color: new Color(0xff2E94B9),
            child: Center(
              child: Text('入库',
                style: TextStyle(
                    color: Colors.white
                ),
              ),
            ),
          ),
        ],
      )
    );
    return _list;
  }

  void initType() {
    switch (widget.type) {
      case AttachmentType.COMPONENT:
        pageTitle = '零件';
        addOneComponent();
        break;
      case AttachmentType.CONSUMABLE:
        pageTitle = '耗材';
        addOneConsumable();
        break;
      case AttachmentType.SERVICE:
        pageTitle = '服务';
        break;
    }
  }

  void initState() {
    super.initState();
    initType();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
         '入库$pageTitle'
        ),
      ),
      body: ListView(
        children: buildStuffList(),
      ),
      floatingActionButton: widget.type != AttachmentType.CONSUMABLE?FloatingActionButton(
        onPressed: () {
          switch (widget.type) {
            case AttachmentType.COMPONENT:
              addOneComponent();
              break;
            case AttachmentType.CONSUMABLE:
              addOneConsumable();
              break;
            case AttachmentType.SERVICE:
              break;
          }
        },
        backgroundColor: Colors.blueAccent,
        child: Icon(Icons.add_circle, color: Colors.white,),
      ):Container(),
    );
  }
}