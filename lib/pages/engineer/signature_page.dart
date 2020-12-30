import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_signature_pad/flutter_signature_pad.dart';
import 'package:flutter/cupertino.dart';

/// 签名页面类
class SignaturePage extends StatefulWidget {
  static String tag = 'signature-page';
  SignaturePage({Key key}) : super(key: key);

  @override
  _SignaturePageState createState() => _SignaturePageState();
}

class _WatermarkPaint extends CustomPainter {
  final String price;
  final String watermark;

  _WatermarkPaint(this.price, this.watermark);

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
   // canvas.drawCircle(Offset(size.width / 2, size.height / 2), 10.8, Paint()..color = Colors.blue);
  }

  @override
  bool shouldRepaint(_WatermarkPaint oldDelegate) {
    return oldDelegate != this;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is _WatermarkPaint && runtimeType == other.runtimeType && price == other.price && watermark == other.watermark;

  @override
  int get hashCode => price.hashCode ^ watermark.hashCode;
}

class _SignaturePageState extends State<SignaturePage> {
  ByteData _img = ByteData(0);
  var color = Colors.black;
  var strokeWidth = 5.0;
  GlobalKey<SignatureState> _sign = GlobalKey<SignatureState>();

  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Transform.rotate(
                angle: pi / 2,
                child: MaterialButton(
                    color: Colors.indigo,
                    onPressed: () async {
                      final sign = _sign.currentState;
                      //retrieve image data, do whatever you want with it (send to server, save locally...)
                      final image = await sign.getData();
                      var data = await image.toByteData(format: ui.ImageByteFormat.png);
                      setState(() {
                        _img = data;
                      });
                      if (sign.points.length==0) {
                        showDialog(context: context,
                            builder: (context) => CupertinoAlertDialog(
                              title: new Text('签名不可为空'),
                            )
                        );
                        return;
                      }
                      sign.clear();
                      Navigator.pop(context, _img);
                    },
                    child: Text("保存",
                      style: new TextStyle(
                          color: Colors.white
                      ),
                    )),
              ),
              new SizedBox(height: 50.0,),
              Transform.rotate(
                angle: pi / 2,
                child: MaterialButton(
                    color: Colors.grey,
                    onPressed: () {
                      final sign = _sign.currentState;
                      sign.clear();
                      setState(() {
                        _img = ByteData(0);
                      });
                      debugPrint("cleared");
                    },
                    child: Text("清除")),
              ),
            ],
          ),
          Expanded(
            child: Container(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Signature(
                  color: color,
                  key: _sign,
                  onSign: () {
                    final sign = _sign.currentState;
                    debugPrint('${sign.points.length} points in the signature');
                  },
                  backgroundPainter: _WatermarkPaint("1.0", "1.0"),
                  strokeWidth: strokeWidth,
                ),
              ),
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
