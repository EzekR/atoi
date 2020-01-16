import 'dart:core';

/// 报告维度类
class ReportDimensions {

  /// 报告基本维度
  static const List DIMS = [
    {
      "ID": 1,
      "Name": "时间类型-年"
    },
    {
      "ID": 2,
      "Name": "时间类型-月"
    },
    {
      "ID": 3,
      "Name": "设备类型"
    },
    {
      "ID": 4,
      "Name": "资产类型"
    },
    {
      "ID": 5,
      "Name": "设备年限"
    },
    {
      "ID": 6,
      "Name": "设备产地"
    },
    {
      "ID": 7,
      "Name": "设备科室"
    },
    {
      "ID": 8,
      "Name": "厂商分布"
    }
  ];

  /// 时间类型
  static const List TIME_TYPES = ['年', '月'];

  static const List _YEARS = [
    2020,2019,2018,2017,2016,2015,2014,2013,2012,2011,2010,2009,2008,2007,2006,2005,2004,2003,2002,2001,2000
  ];

  /// 月份
  static const List MONTHS = [
    12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1
  ];

  /// 当前月份
  static int CURRENT_MONTH = DateTime.now().month;

  /// 当前年份
  static int CURRENT_YEAR = DateTime.now().year;

  /// 生成从当前年份开始，长度为20的年份数组
  static List get YEARS {
    List _list = [];
    for(int i=0; i<20; i++) {
      _list.add(CURRENT_YEAR-i);
    }
    return _list;
  }

}