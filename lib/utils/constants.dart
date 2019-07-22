import 'package:flutter/material.dart';

class AppConstants {

  Map<String, int> Users = {
    '超级管理员': 1,
    '管理员': 2,
    '超级用户': 3,
    '用户': 4
  };

  Map<String, int> AssetsLevel = {
    '重要': 1,
    '一般': 2,
    '特殊': 3
  };

  Map<String, int> ContractScope = {
    '全保': 1,
    '技术保': 2,
    '其他': 3
  };

  Map<String, int> ReportType = {
    '通用报告类型': 1
  };

  Map<String, int> SolutionStatus = {
    '待分配': 1,
    '问题升级': 2,
    '待第三方支持': 3,
    '已解决': 4
  };

  Map<String, int> ReportStatus = {
    '新建': 1,
    '待审批': 2,
    '已审批': 3,
    '已终止': 99
  };

  Map<String, int> AccessorySourceType = {
    '外部供应商': 1,
    '备件库': 2
  };

  Map<String, int> AccessoryFileType = {
    '新装': 1,
    '拆下': 2
  };

  Map<String, int> RequestType = {
    '维修': 1,
    '保养': 2,
    '强检': 3,
    '巡检': 4,
    '校正': 5,
    '设备新增': 6,
    '不良事件': 7,
    '合同档案': 8,
    '验收安装': 9,
    '调拨': 10,
    '借用': 11,
    '盘点': 12,
    '报废': 13,
    '其他服务': 14
  };

  Map<String, int> RequestStatus = {
    '终止': -1,
    '新建': 1,
    '已分配': 2,
    '已响应': 3,
    '待审批': 4,
    '待分配': 5,
    '问题升级': 6,
    '待第三方支持': 7,
    '关闭': 99,
    '未完成': 98,
    '超时': 97
  };

  Map<String, int> DealType = {
    '现场服务': 1,
    '电话解决': 2,
    '远程解决': 3,
    '第三方支持': 4
  };

  Map<String, int> PriorityID = {
    '普通': 1,
    '紧急': 2
  };

  Map<String, int> FaultRepair = {
    '未知': 1
  };

  Map<String, int> FaultMaintain = {
    '原厂保养': 1,
    '第三方保养': 2,
    'FMTS保养': 3
  };

  Map<String, int> FaultCheck = {
    '政府要求': 1,
    '医院要求': 2,
    '自主强检': 3
  };

  Map<String, int> FaultBad = {
    '政府通报': 1,
    '医院自检': 2,
    '召回事件': 3
  };

  Map<String, int> UrgencyID = {
    '普通': 1,
    '紧急': 2
  };

  Map<String, int> EquipmentStatus = {
    '正常': 1,
    '故障': 2
  };

  Map<String, int> DispatchStatus = {
    '终止': -1,
    '新建': 1,
    '已响应': 2,
    '待审批': 3,
    '已审批': 4
  };

  Map<String, int> ResultStatusID = {
    '待跟进': 1,
    '完成': 2
  };

  Map<String, int> JournalStatusID = {
    '新建': 1,
    '待审批': 2,
    '已审批': 3,
    '已终止': 99
  };
}
