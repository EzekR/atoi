import 'package:scoped_model/scoped_model.dart';
import 'package:atoi/utils/http_request.dart';

class ConstantsModel extends Model {
  Map<String, int> _UserRole = {};
  Map<String, int> _AssetsLevel = {};
  Map<String, int> _ContractScope = {};
  Map<String, int> _ReportType = {};
  Map<String, int> _SolutionStatus = {};
  Map<String, int> _ReportStatus = {};
  Map<String, int> _AccessorySourceType = {};
  Map<String, int> _AccessoryFileType = {};
  Map<String, int> _RequestType = {};
  Map<String, int> _RequestStatus = {};
  Map<String, int> _DealType = {};
  Map<String, int> _PriorityID = {};
  Map<String, int> _FaultRepair = {};
  Map<String, int> _FaultMaintain = {};
  Map<String, int> _FaultCheck = {};
  Map<String, int> _MachineStatus = {};
  Map<String, int> _FaultBad = {};
  Map<String, int> _UrgencyID = {};
  Map<String, int> _EquipmentStatus = {};
  Map<String, int> _DispatchStatus = {};
  Map<String, int> _ResultStatusID = {};
  Map<String, int> _JournalStatusID = {};
  Map<String, int> _SupplierType = {};
  Map<String, int> _UsageStatus = {};
  Map<String, int> _PeriodType = {};
  Map<String, int> _ContractType = {};
  Map<String, int> _Departments = {};
  List<String> _DepartmentsList = [];
  List<String> _Remark = [
    '',
    '故障描述',
    '保养要求' ,
    '强检要求' ,
    '巡检要求' ,
    '校正要求' ,
    '备注' ,
    '不良事件描述',
    '合同备注' ,
    '验收安装备注' ,
    '调拨备注' ,
    '借用备注' ,
    '盘点备注' ,
    '报废备注' ,
    '其他服务备注'
  ];
  List<String> _RemarkType = [
    '',
    '故障分类',
    '保养类型' ,
    '强检原因' ,
    '' ,
    '' ,
    '' ,
    '不良来源',
    '' ,
    '' ,
    '' ,
    '' ,
    '' ,
    '' ,
    ''
  ];

  get UserRole => _UserRole;
  get AssetsLevel => _AssetsLevel;
  get ContractScope => _ContractScope;
  get ReportType => _ReportType;
  get SolutionStatus => _SolutionStatus;
  get ReportStatus => _ReportStatus;
  get AccessorySourceType => _AccessorySourceType;
  get AccessoryFileType => _AccessoryFileType;
  get RequestType => _RequestType;
  get RequestStatus => _RequestStatus;
  get DealType => _DealType;
  get PriorityID => _PriorityID;
  get FaultRepair => _FaultRepair;
  get FaultMaintain => _FaultMaintain;
  get FaultCheck => _FaultCheck;
  get MachineStatus => _MachineStatus;
  get FaultBad => _FaultBad;
  get UrgencyID => _UrgencyID;
  get EquipmentStatus => _EquipmentStatus;
  get DispatchStatus => _DispatchStatus;
  get ResultStatusID => _ResultStatusID;
  get JournalStatusID => _JournalStatusID;
  get SupplierType => _SupplierType;
  get UsageStatus => _UsageStatus;
  get PeriodType => _PeriodType;
  get ContractType => _ContractType;
  get Departments => _Departments;
  get Remark => _Remark;
  get RemarkType => _RemarkType;
  get DepartmentsList => _DepartmentsList;

  Future<Null> getConstants() async {
    var resp = await HttpRequest.request(
      '/User/GetConstants',
      method: HttpRequest.GET
    );
    if (resp['ResultCode'] == '00') {
      for(var item in resp['Data']['UserRole']) {
        _UserRole.putIfAbsent(item['Name'], () => item['ID']);
      }
      for(var item in resp['Data']['AssetsLevel']) {
        _AssetsLevel.putIfAbsent(item['Name'], () => item['ID']);
      }
      for(var item in resp['Data']['ContractScope']) {
        _ContractScope.putIfAbsent(item['Name'], () => item['ID']);
      }
      for(var item in resp['Data']['ReportType']) {
        _ReportType.putIfAbsent(item['Name'], () => item['ID']);
      }
      for(var item in resp['Data']['SolutionStatus']) {
        _SolutionStatus.putIfAbsent(item['Name'], () => item['ID']);
      }
      for(var item in resp['Data']['ReportStatus']) {
        _ReportStatus.putIfAbsent(item['Name'], () => item['ID']);
      }
      for(var item in resp['Data']['AccessorySourceType']) {
        _AccessorySourceType.putIfAbsent(item['Name'], () => item['ID']);
      }
      for(var item in resp['Data']['AccessoryFileType']) {
        _AccessoryFileType.putIfAbsent(item['Name'], () => item['ID']);
      }
      for(var item in resp['Data']['RequestType']) {
        _RequestType.putIfAbsent(item['Name'], () => item['ID']);
      }
      for(var item in resp['Data']['RequestStatus']) {
        _RequestStatus.putIfAbsent(item['Name'], () => item['ID']);
      }
      for(var item in resp['Data']['DealType']) {
        _DealType.putIfAbsent(item['Name'], () => item['ID']);
      }
      for(var item in resp['Data']['PriorityID']) {
        _PriorityID.putIfAbsent(item['Name'], () => item['ID']);
      }
      if (resp['Data']['FaultRepair'] == null || resp['Data']['FaultRepair'].isEmpty) {
        _FaultRepair[' '] = 1;
      } else {
        for(var item in resp['Data']['FaultRepair']) {
          _FaultRepair.putIfAbsent(item['Name'], () => item['ID']);
        }
      }
      for(var item in resp['Data']['FaultMaintain']) {
        _FaultMaintain.putIfAbsent(item['Name'], () => item['ID']);
      }
      for(var item in resp['Data']['FaultCheck']) {
        _FaultCheck.putIfAbsent(item['Name'], () => item['ID']);
      }
      for(var item in resp['Data']['MachineStatus']) {
        _MachineStatus.putIfAbsent(item['Name'], () => item['ID']);
      }
      for(var item in resp['Data']['FaultBad']) {
        _FaultBad.putIfAbsent(item['Name'], () => item['ID']);
      }
      for(var item in resp['Data']['UrgencyID']) {
        _UrgencyID.putIfAbsent(item['Name'], () => item['ID']);
      }
      for(var item in resp['Data']['EquipmentStatus']) {
        _EquipmentStatus.putIfAbsent(item['Name'], () => item['ID']);
      }
      for(var item in resp['Data']['DispatchStatus']) {
        _DispatchStatus.putIfAbsent(item['Name'], () => item['ID']);
      }
      for(var item in resp['Data']['ResultStatusID']) {
        _ResultStatusID.putIfAbsent(item['Name'], () => item['ID']);
      }
      for(var item in resp['Data']['JournalStatusID']) {
        _JournalStatusID.putIfAbsent(item['Name'], () => item['ID']);
      }
      for(var item in resp['Data']['SupplierType']) {
        _SupplierType.putIfAbsent(item['Name'], () => item['ID']);
      }
      for(var item in resp['Data']['UsageStatus']) {
        _UsageStatus.putIfAbsent(item['Name'], () => item['ID']);
      }
      for(var item in resp['Data']['PeriodType']) {
        _PeriodType.putIfAbsent(item['Name'], () => item['ID']);
      }
      for(var item in resp['Data']['ContractType']) {
        _ContractType.putIfAbsent(item['Name'], () => item['ID']);
      }
      for(var item in resp['Data']['GetDepartment']) {
        _Departments.putIfAbsent(item['Name'], () => item['ID']);
        _DepartmentsList.add(item['Name']);
      }
    }
    notifyListeners();
  }

}
