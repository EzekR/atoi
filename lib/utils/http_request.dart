import 'package:dio/dio.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:atoi/utils/event_bus.dart';

/*
 * 封装 restful 请求
 *
 * GET、POST、DELETE、PATCH
 * 主要作用为统一处理相关事务：
 *  - 统一处理请求前缀；
 *  - 统一打印请求信息；
 *  - 统一打印响应信息；
 *  - 统一打印报错信息；
 */

/// 封装http请求类
class HttpRequest {

  ///添加构建方法
  //HttpRequest({this.apiUrl}):super();
  //final String apiUrl;
  /// global dio object
  static Dio dio;

  /// default options
  //static const String API_PREFIX = 'http://159.226.128.250/MEMS_FUJI/APP';
  static const String APP_VERSION = '1.1.12';
  // default server
  static const String API_PREFIX = 'http://27.115.59.42:81/MEMS';
  static const int CONNECT_TIMEOUT = 10000;
  static const int RECEIVE_TIMEOUT = 10000;

  /// http request methods
  static const String GET = 'get';
  static const String POST = 'post';
  static const String PUT = 'put';
  static const String PATCH = 'patch';
  static const String DELETE = 'delete';


  /// request method
  static Future<Map> request (
      String url,
      { params, data, method }) async {

    data ?? {};
    params ?? {};
    method = method ?? 'GET';

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var _url = await prefs.getString('serverUrl');
    var serverUrl = _url ?? API_PREFIX;
    EventBus bus = new EventBus();
    /// 打印请求相关信息：请求地址、请求方式、请求参数
    print('请求地址：【' + method + '  ' + url + '】');
    print('请求body：' + data.toString());
    print('请求params：'+params.toString());
    print('服务器地址：'+serverUrl);

    Dio dio = createInstance(serverUrl+'/APP');
    var result;

    try {
      Response response = await dio.request(url, queryParameters: params, data: data, options: new Options(method: method));

      result = response.data;

      /// 打印响应相关信息
      print('响应数据：' + response.toString());
    } on DioError catch (e) {
      /// 打印请求失败相关信息
      print('请求出错：' + e.toString());
      // 网络超时且请求地址非轮询接口时，emit超时事件
      if (url != '/User/GetEngineerCount' && url !='/User/GetAdminCount') {
        bus.emit('timeout', url);
      }
    }

    return result;
  }

  /// 创建 dio 实例对象
  static Dio createInstance (String serverUrl) {
    if (dio == null) {
      /// 全局属性：请求前缀、连接超时时间、响应超时时间
      dio = new Dio();
      dio.options.baseUrl = serverUrl;
      dio.options.connectTimeout = CONNECT_TIMEOUT;
      dio.options.receiveTimeout = RECEIVE_TIMEOUT;
    }

    return dio;
  }

  /// 清空 dio 对象
  static clear () {
    dio = null;
  }

}