import 'package:atoi/pages/equipments/equipments_list.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:convert';
import 'package:atoi/utils/http_request.dart';
import 'dart:typed_data';
import 'package:atoi/widgets/build_widget.dart';

class EquipmentCarousel extends StatefulWidget {
  final List equipmentFile;
  final EquipmentType equipmentType;
  EquipmentCarousel({Key key, this.equipmentFile, this.equipmentType}):super(key: key);
  _EquipmentCarouselState createState() => new _EquipmentCarouselState();
}

class _EquipmentCarouselState extends State<EquipmentCarousel> {

  List _images = [
    {
      'type': 4,
      'asset': 'assets/appearance.png',
      'fileName': '设备外观'
    },
    {
      'type': 5,
      'asset': 'assets/plaque.png',
      'fileName': '设备铭牌'
    },
    {
      'type': 6,
      'asset': 'assets/label.png',
      'fileName': '设备标签'
    }
  ];

  void getFile(int fileId, String fileName, int typeId) async {
    String url;
    switch (widget.equipmentType) {
      case EquipmentType.MEDICAL:
        url = '/Equipment/DownloadUploadFile';
        break;
      case EquipmentType.MEASURE:
        url = '/MeasInstrum/DownloadUploadFile';
        break;
      case EquipmentType.OTHER:
        url = '/OtherEqpt/DownloadUploadFile';
        break;
    }
    Map resp = await HttpRequest.request(
        url,
        method: HttpRequest.POST,
        data: {
          'id': fileId
        }
    );
    if (resp['ResultCode'] == '00') {
      Uint8List _data = base64Decode(resp['Data']);
      int _index = _images.indexWhere((item) => item['type']==typeId);
      setState(() {
        _images[_index]['fileName'] = fileName;
        _images[_index]['image'] = _data;
      });
    }
  }

  void initState() {
    super.initState();
    // get equipment images
    if (widget.equipmentFile != null) {
      widget.equipmentFile.forEach((item) {
        print(item.toString());
        if (item['FileType'] == 4 || item['FileType'] == 5 || item['FileType'] == 6 ) {
          getFile(item['ID'], item['FileName'], item['FileType']);
        }
      });
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '设备图片'
        ),
      ),
      body: Container(
        child: CarouselSlider(
          options: CarouselOptions(
            height: 800.0,
            enlargeCenterPage: true,
            viewportFraction: 1.0,
            autoPlay: false
          ),
          items: _images.map<Widget>((item) {
            return Column(
              children: <Widget>[
                item['image']!=null?new GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(new MaterialPageRoute(builder: (_) =>
                        FullScreenWrapper(
                          imageProvider: MemoryImage(item['image']),
                          backgroundDecoration: BoxDecoration(
                              color: Colors.white
                          ),
                        )
                    ));
                  },
                  child: Container(
                    child: Image.memory(
                        item['image']
                    ),
                  ),
                ):Container(
                  child: Opacity(
                    opacity: 0.2,
                    child: Image.asset(item['asset']),
                  ),
                ),
                Center(
                  child: Text(
                    item['fileName']
                  ),
                )
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}