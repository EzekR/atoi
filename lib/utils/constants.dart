import 'package:flutter/material.dart';
import 'package:date_format/date_format.dart';

class AppConstants {

  //BuildContext context;

  //AppConstants(BuildContext context) {
  //  this.context = context;
  //  initMaps();
  //}

  //Future<Null> initMaps() async {
  //  Users = {
  //    'a': 1
  //  };
  //}

  //Map<String, int> Users = {
  //  '超级管理员': 1,
  //  '管理员': 2,
  //  '超级用户': 3,
  //  '用户': 4
  //};

  //static Map<String, int> AssetsLevel = {
  //  '重要': 1,
  //  '一般': 2,
  //  '特殊': 3
  //};

  //static Map<String, int> ContractScope = {
  //  '全保': 1,
  //  '技术保': 2,
  //  '其他': 3
  //};

  //static Map<String, int> ReportType = {
  //  '通用报告类型': 1
  //};

  //static Map<String, int> SolutionStatus = {
  //  '待分配': 1,
  //  '问题升级': 2,
  //  '待第三方支持': 3,
  //  '已解决': 4
  //};

  //static Map<String, int> ReportStatus = {
  //  '新建': 1,
  //  '待审批': 2,
  //  '已审批': 3,
  //  '已终止': 99
  //};

  //static Map<String, int> AccessorySourceType = {
  //  '外部供应商': 1,
  //  '备件库': 2
  //};

  //static Map<String, int> AccessoryFileType = {
  //  '新装': 1,
  //  '拆下': 2
  //};

  //static Map<String, int> RequestType = {
  //  '维修': 1,
  //  '保养': 2,
  //  '强检': 3,
  //  '巡检': 4,
  //  '校正': 5,
  //  '设备新增': 6,
  //  '不良事件': 7,
  //  '合同档案': 8,
  //  '验收安装': 9,
  //  '调拨': 10,
  //  '借用': 11,
  //  '盘点': 12,
  //  '报废': 13,
  //  '其他服务': 14
  //};

  //static Map<String, int> RequestStatus = {
  //  '终止': -1,
  //  '新建': 1,
  //  '已分配': 2,
  //  '已响应': 3,
  //  '待审批': 4,
  //  '待分配': 5,
  //  '问题升级': 6,
  //  '待第三方支持': 7,
  //  '关闭': 99,
  //  '未完成': 98,
  //  '超时': 97
  //};

  //static Map<String, int> DealType = {
  //  '现场服务': 1,
  //  '电话解决': 2,
  //  '远程解决': 3,
  //  '待第三方支持': 4
  //};

  //static Map<String, int> PriorityID = {
  //  '普通': 1,
  //  '紧急': 2
  //};

  //static Map<String, int> FaultRepair = {
  //  '未知': 1,
  //  '已知': 2
  //};

  //static Map<String, int> FaultMaintain = {
  //  '原厂保养': 1,
  //  '第三方保养': 2,
  //  'FMTS保养': 3
  //};

  //static Map<String, int> FaultCheck = {
  //  '政府要求': 1,
  //  '医院要求': 2,
  //  '自主强检': 3
  //};

  //static Map<String, int> MachineStatus = {
  //  '正常': 1,
  //  '勉强使用': 2,
  //  '停机': 3
  //};

  //static Map<String, int> FaultBad = {
  //  '政府通报': 1,
  //  '医院自检': 2,
  //  '召回事件': 3
  //};

  //static Map<String, int> UrgencyID = {
  //  '普通': 1,
  //  '紧急': 2
  //};

  //static Map<String, int> EquipmentStatus = {
  //  '正常': 1,
  //  '故障': 2
  //};

  //static Map<String, int> DispatchStatus = {
  //  '终止': -1,
  //  '新建': 1,
  //  '已响应': 2,
  //  '待审批': 3,
  //  '已审批': 4
  //};

  //static Map<String, int> ResultStatusID = {
  //  '待跟进': 1,
  //  '完成': 2
  //};

  //static Map<String, int> JournalStatusID = {
  //  '新建': 1,
  //  '待审批': 2,
  //  '已审批': 3,
  //  '已终止': 99
  //};

  //static List<String> Remark = [
  //  '',
  //  '故障描述',
  //  '保养要求' ,
  //  '强检要求' ,
  //  '巡检要求' ,
  //  '校正要求' ,
  //  '备注' ,
  //  '不良事件描述',
  //  '合同备注' ,
  //  '验收安装备注' ,
  //  '调拨备注' ,
  //  '借用备注' ,
  //  '盘点备注' ,
  //  '报废备注' ,
  //  '其他服务备注'
  //];

  //static List<String> RemarkType = [
  //  '',
  //  '故障分类',
  //  '保养类型' ,
  //  '强检原因' ,
  //  '' ,
  //  '' ,
  //  '' ,
  //  '不良来源',
  //  '' ,
  //  '' ,
  //  '' ,
  //  '' ,
  //  '' ,
  //  '' ,
  //  ''
  //];

  static String TimeForm(String time, String format) {
    var _date = DateTime.tryParse(time);
    if (_date != null) {
      if (format == 'yyyy-mm-dd') {
        return formatDate(_date, [yyyy,'-',mm,'-',dd]);
      } else {
        return formatDate(_date, [yyyy,'-',mm,'-',dd,' ',HH,':',nn]);
      }
    } else {
      return '';
    }
  }

  static Map<String, Color> AppColors = {
    'appbar_prime_m': Color(0xff2c5c85),
    'appbar_accent_m': Color(0xff4e8fa),
    'appbar_prime_e': Color(0xff3b4674),
    'appbar_accent_e': Color(0xff2c5c85),
    'btn_invalid': Colors.grey,
    'btn_main': Color(0xff2E94B9),
    'btn_success': Color(0xffF0B775),
    'btn_cancel': Color(0xffD25565)
  };
}
