import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:io';
import 'dart:async';

class ImageUtil {
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
}