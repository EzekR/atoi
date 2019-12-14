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

  static const List YEARS = [
    2019,2018,2017,2016,2015,2014,2013,2012,2011,2010,2009,2008,2007,2006,2005,2004,2003,2002,2001,2000
  ];

  static const List MONTHS = [
    1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12
  ];

  static List<Map> buildPickers(int typeStart, int typeEnd, bool years, bool months) {
    List typeSlice = DIMS.sublist(typeStart, typeEnd);
    if (years && months) {
      var _list = [];
      typeSlice.map((item) => {
        item['Name']:
      })
    }
  }
}