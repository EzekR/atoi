import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:atoi/utils/http_request.dart';
import 'package:brother_printer/brother_printer.dart';
import 'dart:convert';
import 'package:atoi/widgets/build_widget.dart';

/// 打印二维码标签页面类
class PrintQrcode extends StatefulWidget{
  _PrintQrcodeState createState() => _PrintQrcodeState();
  final int equipmentId;
  PrintQrcode({Key key, this.equipmentId}):super(key: key);
}

class _PrintQrcodeState extends State<PrintQrcode> {
  var _equipment;
  var _qrcode;
  List _image;

  void initState() {
    super.initState();
    getQrcode();
  }

  Future<Null> getEquipment() async {
    var resp = await HttpRequest.request(
      '/Equipment/Getdevices',
      method: HttpRequest.GET,
      params: {
        'filterText': widget.equipmentId
      }
    );
    if (resp['ResultCode'] == '00') {
      setState(() {
        _equipment = resp['Data'][0];
      });
      getQrcode();
    }
  }

  Future<Null> getQrcode() async {
    var resp = await HttpRequest.request(
      '/Equipment/EquipmentLabel',
      method: HttpRequest.GET,
      params: {
        'id': widget.equipmentId
      }
    );
    if (resp['ResultCode'] == '00') {
      setState(() {
        _qrcode = resp['Data'];
        _image = base64Decode(resp['Data']);
      });
    }
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

  Card buildPrintCard() {
    return new Card(
      child: new Container(
        width: 390,
        height: 270,
        child: new Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          child: Center(
            child: BuildWidget.buildPhotoPageList(context, _image),
          ),
        ),
//        child: new Padding(
//          padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
//          child: new Row(
//            children: <Widget>[
//              new Expanded(
//                flex: 6,
//                child: new Column(
//                  children: <Widget>[
//                    buildCardRowLeft('医院', '龙山县人民医院'),
//                    new SizedBox(height: 5.0,),
//                    buildCardRowLeft('科室', _equipment['Department']['Name']),
//                    new SizedBox(height: 5.0,),
//                    buildCardRowLeft('放置地点', _equipment['InstalSite']),
//                    new SizedBox(height: 5.0,),
//                    buildCardRowLeft('名称', _equipment['Name']),
//                    new SizedBox(height: 5.0,),
//                    buildCardRowLeft('型号', _equipment['EquipmentCode']),
//                    new SizedBox(height: 5.0,),
//                    buildCardRowLeft('序列号', _equipment['SerialCode']),
//                    new SizedBox(height: 5.0,),
//                    buildCardRowLeft('资产编号', _equipment['OID']),
//                    new SizedBox(height: 5.0,),
//                  ],
//                ),
//              ),
//              new Expanded(
//                flex: 4,
//                child: new Column(
//                  crossAxisAlignment: CrossAxisAlignment.end,
//                  children: <Widget>[
//                    new Container(
//                      child: Image.asset('assets/atoi.png'),
//                    ),
//                    new SizedBox(height: 16.0,),
//                    new QrImage(
//                      data: "www.baidu.com",
//                      version: QrVersions.auto,
//                      size: 150.0,
//                    ),
//                    new Padding(
//                      padding: EdgeInsets.symmetric(horizontal: 16.0),
//                      child: new Text('微信扫一扫报修'),
//                    )
//                  ],
//                ),
//              )
//            ],
//          ),
//        )
      ),
    );
  }

  Future<Null> printQRcode() async {
    var error = await BrotherPrinter.printImage(_qrcode);
    print(error);
    showDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: new Text(error=='ok'?'打印完成':'请连接打印机'),
      )
    );
  }

  //void printQrcode() async {
  //  final doc  = pdf.Document();
  //  var _image = base64Decode(_qrcode);
  //  var imageProvider = MemoryImage(_image);
  //  final PdfImage image = await pdfImageFromImageProvider(pdf: doc.document, image: imageProvider);

  //  doc.addPage(
  //    pdf.Page(
  //      //pageFormat: PdfPageFormat.a9,
  //      build: (context) {
  //        return pdf.Center(
  //          child: pdf.Image(image)
  //        );
  //      }
  //    )
  //  );

  //  await Printing.layoutPdf(
  //    onLayout: (PdfPageFormat format) async {
  //      return doc.save();
  //    }
  //  );
  //}

  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('设备二维码打印'),
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
      ),
      body: new Column(
        children: <Widget>[
          _image==null?new Container():buildPrintCard(),
          new SizedBox(height: 16.0,),
          new RaisedButton(
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
        ],
      )
    );
  }
}