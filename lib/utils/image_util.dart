import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:io';
import 'dart:async';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'dart:typed_data';

/// 图片压缩类
class ImageUtil {

  /// 压缩图片文件返回二进制数组
  Future<List<int>> CompressFileGetList(File file, {minWidth, minHeight, quality, rotate}) async {
    minWidth??480;
    minHeight??600;
    quality??100;
    rotate??0;
    var result = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      minWidth: minWidth,
      minHeight: minHeight,
      quality: quality,
      rotate: rotate,
    );
    return result;
  }

  /// 压缩二进制数组返回数组
  Future<List<int>> CompressListGetList(List<int> list, {minWidth, minHeight, quality, rotate}) async {
    minWidth??480;
    minHeight??600;
    quality??100;
    rotate??0;
    var result = await FlutterImageCompress.compressWithList(
      list,
      minWidth: minWidth,
      minHeight: minHeight,
      quality: quality,
      rotate: rotate,
    );
    return result;
  }

  Future<List<Uint8List>> getImages({int maxImages}) async {
    maxImages = maxImages ?? 3;
    List<Uint8List> _list = [];
    try {
      List<Asset> _imageList = await MultiImagePicker.pickImages(maxImages: maxImages, enableCamera: true);
      if (_imageList != null) {
        _imageList.forEach((_image) async {
          var _data = await _image.getByteData();
          var compressed = await FlutterImageCompress.compressWithList(
            _data.buffer.asUint8List(),
            minHeight: 800,
            minWidth: 600,
          );
          _list.add(Uint8List.fromList(compressed));
        });
      }
    } catch (e) {
      print(e.toString());
    }
    return _list;
  }
}