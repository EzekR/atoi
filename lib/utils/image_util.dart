import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:io';
import 'dart:async';

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
}