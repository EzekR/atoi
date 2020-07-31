import 'package:scoped_model/scoped_model.dart';
import 'package:atoi/utils/http_request.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 常量模型类
class ConstantsModel extends Model {
  Map<String, dynamic> _Constants = {};
  List<Map<String, dynamic>> _ReportDimensions = [];
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
  Map<String, int> _ServiceProviders = {};
  Map<String, int> _Sources = {};

  List<String> _DepartmentsList = [];
  List<String> _ContractTypeList = [];
  List<String> _ContractScopeList = [];
  List<String> _PeriodTypeList = [];
  List<String> _Remark = [
    '',
    '故障描述',
    '保养要求' ,
    '强检要求' ,
    '巡检要求' ,
    '校准要求' ,
    '备注' ,
    '不良事件描述',
    '合同档案备注' ,
    '验收安装备注' ,
    '调拨备注' ,
    '借用备注' ,
    '盘点备注' ,
    '报废备注' ,
    '备注'
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

  get Constants => _Constants;
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
  get ServiceProviders => _ServiceProviders;
  get ContractTypeList => _ContractTypeList;
  get ContractScopeList => _ContractScopeList;
  get PeriodTypeList => _PeriodTypeList;
  get ReportDimensions => _ReportDimensions;
  Map<String, int> get Sources => _Sources;

  /// 获取常量
  Future<Null> getConstants() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    int _userId  = await _prefs.getInt('userID');
    var resp = await HttpRequest.request(
      '/User/GetConstants',
      method: HttpRequest.GET,
      params: <String, dynamic> {
        'userID': _userId
      }
    );
    if (resp['ResultCode'] == '00') {
      _Constants = resp['Data'];
      for(var _item in resp['Data']['UserRole']) {
        _UserRole.putIfAbsent(_item['Name'], () => _item['ID']);
      }
      for(var _item in resp['Data']['AssetsLevel']) {
        _AssetsLevel.putIfAbsent(_item['Name'], () => _item['ID']);
      }
      for(var _item in resp['Data']['ContractScope']) {
        _ContractScope.putIfAbsent(_item['Name'], () => _item['ID']);
        if (!_ContractScopeList.contains(_item['Name'])) {
          _ContractScopeList.add(_item['Name']);
        }
      }
      //for(var _item in resp['Data']['ReportType']) {
      //  _ReportType.putIfAbsent(_item['Name'], () => _item['ID']);
      //}
      for(var _item in resp['Data']['SolutionStatus']) {
        _SolutionStatus.putIfAbsent(_item['Name'], () => _item['ID']);
      }
      for(var _item in resp['Data']['ReportStatus']) {
        _ReportStatus.putIfAbsent(_item['Name'], () => _item['ID']);
      }
      for(var _item in resp['Data']['AccessorySourceType']) {
        _AccessorySourceType.putIfAbsent(_item['Name'], () => _item['ID']);
      }
      for(var _item in resp['Data']['AccessoryFileType']) {
        _AccessoryFileType.putIfAbsent(_item['Name'], () => _item['ID']);
      }
      for(var _item in resp['Data']['RequestType']) {
        _RequestType.putIfAbsent(_item['Name'], () => _item['ID']);
      }
      for(var _item in resp['Data']['RequestStatus']) {
        _RequestStatus.putIfAbsent(_item['Name'], () => _item['ID']);
      }
      for(var _item in resp['Data']['DealType']) {
        _DealType.putIfAbsent(_item['Name'], () => _item['ID']);
      }
      for(var _item in resp['Data']['PriorityID']) {
        _PriorityID.putIfAbsent(_item['Name'], () => _item['ID']);
      }
      if (resp['Data']['FaultRepair'] == null || resp['Data']['FaultRepair'].isEmpty) {
        _FaultRepair[' '] = 1;
      } else {
        for(var _item in resp['Data']['FaultRepair']) {
          _FaultRepair.putIfAbsent(_item['Name'], () => _item['ID']);
        }
      }
      for(var _item in resp['Data']['FaultMaintain']) {
        _FaultMaintain.putIfAbsent(_item['Name'], () => _item['ID']);
      }
      for(var _item in resp['Data']['FaultCheck']) {
        _FaultCheck.putIfAbsent(_item['Name'], () => _item['ID']);
      }
      for(var _item in resp['Data']['MachineStatus']) {
        _MachineStatus.putIfAbsent(_item['Name'], () => _item['ID']);
      }
      for(var _item in resp['Data']['FaultBad']) {
        _FaultBad.putIfAbsent(_item['Name'], () => _item['ID']);
      }
      for(var _item in resp['Data']['UrgencyID']) {
        _UrgencyID.putIfAbsent(_item['Name'], () => _item['ID']);
      }
      for(var _item in resp['Data']['EquipmentStatus']) {
        _EquipmentStatus.putIfAbsent(_item['Name'], () => _item['ID']);
      }
      for(var _item in resp['Data']['DispatchStatus']) {
        _DispatchStatus.putIfAbsent(_item['Name'], () => _item['ID']);
      }
      for(var _item in resp['Data']['ResultStatusID']) {
        _ResultStatusID.putIfAbsent(_item['Name'], () => _item['ID']);
      }
      for(var _item in resp['Data']['JournalStatusID']) {
        _JournalStatusID.putIfAbsent(_item['Name'], () => _item['ID']);
      }
      for(var _item in resp['Data']['SupplierType']) {
        _SupplierType.putIfAbsent(_item['Name'], () => _item['ID']);
      }
      for(var _item in resp['Data']['UsageStatus']) {
        _UsageStatus.putIfAbsent(_item['Name'], () => _item['ID']);
      }
      for(var _item in resp['Data']['Source']) {
        _Sources.putIfAbsent(_item['Name'], () => _item['ID']);
      }
      _PeriodType['无'] = 0;
      _PeriodTypeList = [];
      _PeriodTypeList.add('无');
      for(var _item in resp['Data']['PeriodType']) {
        _PeriodType.putIfAbsent(_item['Name'], () => _item['ID']);
        if (!_PeriodTypeList.contains(_item['Name'])) {
          _PeriodTypeList.add(_item['Name']);
        }
      }
      for(var _item in resp['Data']['ContractType']) {
        _ContractType.putIfAbsent(_item['Name'], () => _item['ID']);
        if (!_ContractTypeList.contains(_item['Name'])) {
          _ContractTypeList.add(_item['Name']);
        }
      }
      //for(var _item in resp['Data']['GetDepartment']) {
      //  _Departments.putIfAbsent(_item['Name'], () => _item['ID']);
      //  if (!_DepartmentsList.contains(_item['Name'])) {
      //    _DepartmentsList.add(_item['Name']);
      //  }
      //}
      for(var _item in resp['Data']['ServiceProviders']) {
        _ServiceProviders.putIfAbsent(_item['Name'], () => _item['ID']);
      }
    }

    var _departments = await HttpRequest.request(
      '/User/GetDepartments',
      method: HttpRequest.GET,
      params: <String, dynamic> {
        'userID': _userId
      }
    );
    if (_departments['ResultCode'] == '00') {
      for(var _item in _departments['Data']) {
        _Departments.putIfAbsent(_item['Description'], () => _item['ID']);
        if (!_DepartmentsList.contains(_item['Description'])) {
          _DepartmentsList.add(_item['Description']);
        }
      }
    }
    notifyListeners();
  }

}
