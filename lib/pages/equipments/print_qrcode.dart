import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:atoi/utils/http_request.dart';
import 'package:brother_printer/brother_printer.dart';
import 'dart:convert';
import 'package:atoi/widgets/build_widget.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';


/// 打印二维码标签页面类
class PrintQrcode extends StatefulWidget{
  _PrintQrcodeState createState() => _PrintQrcodeState();
  final int equipmentId;
  final CodeType codeType;
  final List components;
  final bool inbound;
  final bool html;
  PrintQrcode({Key key, this.equipmentId, this.codeType, this.components, this.inbound, this.html}):super(key: key);
}

class _PrintQrcodeState extends State<PrintQrcode> {
  var _equipment;
  var _qrcode;
  List _image;
  List qrcodes = [];
  List qrcodesString = [];
  //String qrUrl = "http://fujifilm.esdpro.com/ATOI_ESD/app/qrcode.html";
  String qrUrl = "http://localhost:9527/static/qrcode.html";

  void initState() {
    super.initState();
    getAllCodes();
  }

  void initQrUrl() async {
  }

  void getAllCodes() async {
    if (widget.equipmentId != null) {
      String encoded = await getQrcode(widget.equipmentId);
      if (encoded != "") {
        Uint8List _decoded = base64Decode(encoded);
        qrcodes.add(_decoded);
        qrcodesString.add(encoded);
      }
    } else {
      if (widget.components != null) {
        for(int i=0; i<widget.components.length; i++) {
          String _code = await getQrcode(widget.components[i]['ID']);
          if (_code != "") {
            Uint8List _decoded = base64Decode(_code);
            qrcodes.add(_decoded);
            qrcodesString.add(_code);
          }
        }
      }
    }
    setState(() {
      qrcodes = qrcodes;
    });
  }

  Future<String> getQrcode(int id) async {
    String url;
    switch (widget.codeType) {
      case CodeType.COMPONENT:
        url = '/InvComponent/InvComponentLabel';
        break;
      case CodeType.CONSUMABLE:
        url = '/InvConsumable/InvConsumableLabel';
        break;
      case CodeType.SPARE:
        url = '/InvSpare/InvSpareLabel';
        break;
      case CodeType.MEASURE:
        url = '/MeasInstrum/MeasInstrumLabel';
        break;
      case CodeType.OTHER:
        url = '/OtherEqpt/OtherEqptLabel';
        break;
      default:
        url = '/Equipment/EquipmentLabel';
        break;
    }
    // 初始化html链接
    if (widget.html != null && widget.html) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int userID = await prefs.getInt("userID");
      String session = await prefs.getString("sessionId");
      qrUrl = qrUrl+"?url=$url&id=$id&session=$session&user=$userID";
      print(qrUrl);
      setState(() {
        qrUrl = qrUrl;
      });
    }
    var resp = await HttpRequest.request(
      url,
      method: HttpRequest.GET,
      params: {
        'id': id
      }
    );
    if (resp['ResultCode'] == '00') {
      return resp['Data'];
    }
    return "";
  }

  Row buildCardRowLeft(String tHead, String tBody) {
    var _headList = tHead.split('');
    print(_headList);
    List<Widget> _textList = [];

    for(var _head in _headList){
      _textList.add(new Text(
        _head,
        style: new TextStyle(
          fontSize: 16.0
        ),
      ));
    }

    return new Row(
        children: <Widget>[
          new Expanded(
              flex: 5,
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _textList
              )
          ),
          new Expanded(
            flex: 1,
            child: new Text(
              ':',
              style: new TextStyle(
                  fontSize: 16.0
              ),
            ),
          ),
          new Expanded(
            flex: 6,
            child: new Text(
              tBody,
              textAlign: TextAlign.start,
              style: new TextStyle(
                  fontSize: 14.0
              ),
            ),
          ),
        ],
      );
  }

  Card buildPrintCard(Uint8List image) {
    return new Card(
      child: new Container(
        width: 390,
        height: 270,
        child: new Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          child: Center(
            child: BuildWidget.buildPhotoPageList(context, image),
          ),
        ),
      ),
    );
  }

  Future<Null> printQRcode() async {
    if (widget.html !=null && widget.html) {
      if (await canLaunch(qrUrl)) {
        await launch(qrUrl);
      } else {
        throw 'Could not launch $qrUrl';
      }
    } else {
      for(String code in qrcodesString) {
        var error = await BrotherPrinter.printImage(code);
        print(error);
        showDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: new Text(error=='ok'?'打印完成':'请连接打印机'),
            )
        );
      }
    }
  }

  List<Widget> buildList() {
    List<Widget> _list = [];
    _list.addAll(
      qrcodes.map((codes) {
        return buildPrintCard(codes);
      }).toList()
    );
    _list.add(
      new SizedBox(height: 16.0,)
    );
    _list.add(
      Center(
        child: new RaisedButton(
          onPressed: () async {
            printQRcode();
          },
          child: new Text(
            '打印',
            style: new TextStyle(
                color: Colors.white
            ),
          ),
        )
      )
    );
    return _list;
  }

  Widget build(BuildContext context) {
//    return widget.html!=null?new WebviewScaffold(
//      url: qrUrl,
//      appBar: new AppBar(
//        title: new Text('二维码打印'),
//        elevation: 0.7,
//        leading: IconButton(
//          onPressed: () {
//            if (widget.inbound!=null&&widget.inbound) {
//              int count = 0;
//              Navigator.popUntil(context, (route) {
//                return count ++ == 2;
//              });
//            } else {
//              Navigator.of(context).pop();
//            }
//          },
//          icon: Icon(Icons.arrow_back_ios),
//        ),
//        flexibleSpace: Container(
//          decoration: BoxDecoration(
//            gradient: LinearGradient(
//              begin: Alignment.centerLeft,
//              end: Alignment.centerRight,
//              colors: [
//                Theme.of(context).primaryColor,
//                Theme.of(context).accentColor
//              ],
//            ),
//          ),
//        ),
//      ),
//    ):new Scaffold(
      return new Scaffold(
      appBar: new AppBar(
        title: new Text('二维码打印'),
        elevation: 0.7,
        leading: IconButton(
          onPressed: () {
            if (widget.inbound!=null&&widget.inbound) {
              int count = 0;
              Navigator.popUntil(context, (route) {
                return count ++ == 2;
              });
            } else {
              Navigator.of(context).pop();
            }
          },
          icon: Icon(Icons.arrow_back_ios),
        ),
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
      ),
      body: new ListView(
        controller: new ScrollController(),
        children: buildList(),
      )
    );
  }
}

enum CodeType {
  DEVICE,
  COMPONENT,
  CONSUMABLE,
  SPARE,
  MEASURE,
  OTHER,
}