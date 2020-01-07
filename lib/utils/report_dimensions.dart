import 'dart:core';

class ReportDimensions {

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

  static const List TIME_TYPES = ['年', '月'];

  static const List YEARS = [
    2020,2019,2018,2017,2016,2015,2014,2013,2012,2011,2010,2009,2008,2007,2006,2005,2004,2003,2002,2001,2000
  ];

  static const List MONTHS = [
    12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1
  ];

  static int CURRENT_MONTH = DateTime.now().month;

}