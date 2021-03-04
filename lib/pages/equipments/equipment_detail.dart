import 'dart:developer';

import 'package:atoi/pages/equipments/equipments_list.dart';
import 'package:atoi/utils/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:atoi/widgets/build_widget.dart';
import 'package:atoi/widgets/search_bar_vendor.dart';
import 'dart:convert';
import 'package:scoped_model/scoped_model.dart';
import 'package:atoi/models/models.dart';
import 'package:atoi/utils/http_request.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:typed_data';
import 'package:atoi/utils/constants.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:date_format/date_format.dart';
import 'package:atoi/utils/event_bus.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:atoi/widgets/search_department.dart';
import 'package:atoi/widgets/search_lazy.dart';
import 'package:atoi/utils/image_util.dart';
import 'package:timeline_tile/timeline_tile.dart';


/// 设备详情页面类
class EquipmentDetail extends StatefulWidget {
  EquipmentDetail({Key key, this.equipment, this.editable, this.equipmentType}) : super(key: key);
  final Map equipment;
  final bool editable;
  final EquipmentType equipmentType;
  _EquipmentDetailState createState() => _EquipmentDetailState();
}

class _EquipmentDetailState extends State<EquipmentDetail> {
  List assetLevel = ['重要', '一般', '特殊'];
  List<DropdownMenuItem<String>> dropdownLevel;
  String currentLevel;
  String oid = '系统自动生成';
  String manufacturingDate = 'YY-MM-DD';
  String validationStartDate = 'YY-MM-DD';
  String validationEndDate = 'YY-MM-DD';
  String installStartDate = 'YY-MM-DD';
  String installEndDate = 'YY-MM-DD';
  String installDate = 'YY-MM-DD';
  String usageDate = 'YY-MM-DD';
  String purchaseDate = 'YY-MM-DD';
  String checkDate = 'YY-MM-DD';
  String mandatoryDate = 'YY-MM-DD';
  String recallDate = 'YY-MM-DD';
  String scrapDate = 'YY-MM-DD';
  String equipmentClassCode = '';
  String classCode1 = '';
  String classCode2 = '';
  String classCode3 = '';
  String warrantyStatus = '保外';
  ConstantsModel model;
  Map equipmentLevel = {'1类': 1, '2类': 2, '3类': 3};
  Map periodType = {'无': 1, '天/次': 2, '月/次': 3, '年/次': 4};
  Map mandatoryFlagType = {'无': 0, '待强检': 1, '已强检': 2};
  Map mandatoryType = {'无': 0, '固定日期':1, '周期': 2};
  List<dynamic> periodList = [];
  List<bool> expansionList = [
    true, false, false, false, false, false, false, false
  ];
  ScrollController _scrollController = new ScrollController();
  int fujiClass2;
  String fujiClass2Name;
  String fujiClass1 = "其它";
  List fujiClass2List = [];
  List fujiClass2Components = [];
  TextEditingController componentCodes = new TextEditingController();
  TextEditingController componentSeconds = new TextEditingController(text: '0');
  String title;

  bool isSearchState = false;
  bool isAdmin = true;
  bool netstat = false;
  // 自动资产编号
  bool autoAssetCode = true;
  EventBus bus = new EventBus();
  List historyComponent = [];
  List historyConsumable = [];

  var name = new TextEditingController(),
      equipmentCode = new TextEditingController(),
      serialCode = new TextEditingController(),
      responseTime = new TextEditingController(),
      assetCode = new TextEditingController(),
      depreciationYears = new TextEditingController(),
      contractName = new TextEditingController(),
      purchaseWay = new TextEditingController(),
      purchaseAmount = new TextEditingController(),
      installSite = new TextEditingController(),
      mandatoryInterval = new TextEditingController(),
      maintainPeriod = new TextEditingController(),
      patrolPeriod = new TextEditingController(),
      correctionPeriod = new TextEditingController(),
      brand = new TextEditingController(),
      comments = new TextEditingController();

  List departments = [];
  List<DropdownMenuItem<String>> dropdownDepartments;
  String currentDepartment;

  List runningStatus = ['使用', '停用'];
  List<DropdownMenuItem<String>> dropdownStatus;
  String currentStatus;

  List machineStatus = ['正常', '故障', '已报废'];
  List<DropdownMenuItem<String>> dropdownMachine;
  String currentMachine;

  List mandatoryFlag = ['无', '待强检', '已强检'];
  List<DropdownMenuItem<String>> dropdownMandatory;
  String currentMandatory;

  List mandatoryPeriod = ['无', '固定日期', '周期'];
  List<DropdownMenuItem<String>> mandatoryTypes;
  String currentMandatoryType = '无';

  List<Map> periodTypeList = [
    {
      'ID': 0,
      'Name': '无'
    },
    {
      'ID': 1,
      'Name': '天/次'
    },
    {
      'ID': 3,
      'Name': '月/次'
    },
    {
      'ID': 4,
      'Name': '年/次'
    },
  ];



  List patrolPeriodList = ['无', '天/次', '月/次', '年/次'];
  List<DropdownMenuItem<String>> dropdownPatrolPeriod;
  int currentPatrolPeriod;

  List mandatoryPeriodList = ['无', '天/次', '月/次', '年/次'];
  List<DropdownMenuItem<String>> dropdownMandatoryPeriod;
  int currentMaintainPeriod;
  int currentMandatoryPeriod;

  List correctionPeriodList = ['无', '天/次', '月/次', '年/次'];
  List<DropdownMenuItem<String>> dropdownCorrectionPeriod;
  int currentCorrectionPeriod;

  List equipmentClass = ['1类', '2类', '3类'];
  List<DropdownMenuItem<String>> dropdownClass;
  String currentClass;

  List class1 = [];
  List class1Item = [];
  List<DropdownMenuItem<String>> dropdownClass1;
  String currentClass1;

  List class2 = [];
  List class2Item = [];
  List<DropdownMenuItem<String>> dropdownClass2;
  String currentClass2;

  List class3 = [];
  List class3Item = [];
  List<DropdownMenuItem<String>> dropdownClass3;
  String currentClass3;

  List catI = [];

  List catII = [];

  List catIII = [];

  List isFixed = ['是', '否'];
  String currentFixed = '是';

  List origin = ['国产', '进口'];
  String currentOrigin = '国产';

  List checkStatus = ['已验收', '未验收'];
  String currentCheck = '未验收';

  List recall = ['是', '否'];
  String currentRecall = '否';

  List serviceScope = ['是', '否'];
  String currentServiceScope = '是';

  Map<String, dynamic> manufacturer;
  Map<String, dynamic> supplier;
  Map relatedEquipment;

  List equipmentPlaques = [];
  List equipmentLabel = [];
  List equipmentAppearance = [];

  Future<SharedPreferences> prefs = SharedPreferences.getInstance();

  Future<Null> getRole() async {
    var _prefs = await prefs;
    var _role = _prefs.getInt('role');
    isAdmin = _role == 1;
  }

  void changeValue(value) {
    FocusScope.of(context).requestFocus(new FocusNode());
    setState(() {
      currentFixed = value;
    });
  }

  void changeServiceScope(value) {
    FocusScope.of(context).requestFocus(new FocusNode());
    setState(() {
      currentServiceScope = value;
    });
  }

  void changeOrigin(value) {
    FocusScope.of(context).requestFocus(new FocusNode());
    setState(() {
      currentOrigin = value;
    });
  }

  void changeCheck(value) {
    FocusScope.of(context).requestFocus(new FocusNode());
    setState(() {
      currentCheck = value;
    });
  }

  void changeRecall(value) {
    FocusScope.of(context).requestFocus(new FocusNode());
    setState(() {
      currentRecall = value;
    });
  }

  void initDepart() {
    print(model.DepartmentsList);
    departments = model.DepartmentsList;
    dropdownDepartments = getDropDownMenuItems(departments);
    currentDepartment = '其它';
    print(currentDepartment);
  }

  List<DropdownMenuItem<String>> getDropDownMenuItems(List list) {
    List<DropdownMenuItem<String>> items = new List();
    for (String method in list) {
      items.add(new DropdownMenuItem(
          value: method,
          child: Container(
            width: 120.0,
            child: Text(
              method,
              style: TextStyle(
                fontSize: 14.0
              ),
            ),
          )
        )
      );
    }
    return items;
  }

  void changeLevel(String selectedMethod) {
    FocusScope.of(context).requestFocus(new FocusNode());
    setState(() {
      currentLevel = selectedMethod;
    });
  }

  void changeDepartment(String selectedMethod) {
    FocusScope.of(context).requestFocus(new FocusNode());
    setState(() {
      currentDepartment = selectedMethod;
    });
  }

  void searchDepartment() {
    showSearch(context: context, delegate: SearchBarDepartment(), hintText: '请输入科室名称/拼音/ID').then((result) {
      print(result);
      if (result != null) {
        var _result = jsonDecode(result);
        setState(() {
          currentDepartment = _result['Description'];
        });
      }
    });
  }

  void changeStatus(String selectedMethod) {
    FocusScope.of(context).requestFocus(new FocusNode());
    setState(() {
      currentStatus = selectedMethod;
    });
  }

  void changeMachine(String selectedMethod) {
    FocusScope.of(context).requestFocus(new FocusNode());
    setState(() {
      currentMachine = selectedMethod;
    });
  }

  void changeMandatory(String selectedMethod) {
    FocusScope.of(context).requestFocus(new FocusNode());
    setState(() {
      currentMandatory = selectedMethod;
    });
  }

  void changeMandatoryType(String selectedMethod) {
    FocusScope.of(context).requestFocus(new FocusNode());
    if (selectedMethod == '周期') {
      currentMandatoryPeriod = 0;
    }
    setState(() {
      currentMandatoryType = selectedMethod;
    });
  }

  void changePatrolPeriod(selectedMethod) {
    FocusScope.of(context).requestFocus(new FocusNode());
    if (selectedMethod == 1) {
    }
    patrolPeriod.clear();
    setState(() {
      currentPatrolPeriod = selectedMethod;
    });
  }

  void changeMandatoryPeriod(selectedMethod) {
    FocusScope.of(context).requestFocus(new FocusNode());
    setState(() {
      currentMandatoryPeriod = selectedMethod;
    });
  }

  void changeMaintainPeriod(selectedMethod) {
    FocusScope.of(context).requestFocus(new FocusNode());
    if (selectedMethod == 1) {
    }
    maintainPeriod.clear();
    setState(() {
      currentMaintainPeriod = selectedMethod;
    });
  }

  void changeCorrectionPeriod(selectedMethod) {
    FocusScope.of(context).requestFocus(new FocusNode());
    if (selectedMethod == 1) {
    }
    correctionPeriod.clear();
    setState(() {
      currentCorrectionPeriod = selectedMethod;
    });
  }

  void changeClass(String selectedMethod) {
    FocusScope.of(context).requestFocus(new FocusNode());
    setState(() {
      currentClass = selectedMethod;
    });
  }

  Future<Null> initClass1() async {
    var resp = await HttpRequest.request('/Equipment/GetEquipmentClass',
        method: HttpRequest.GET, params: {'level': 1});
    if (resp['ResultCode'] == '00') {
      List _list = [];
      _list.add("");
      _list.addAll(resp['Data'].map((item) {
        return item['Description'];
      }).toList());
      setState(() {
        class1 = _list;
        class1Item = resp['Data'];
      });
      dropdownClass1 = getDropDownMenuItems(class1);
    }
  }

  Future<Null> initClass(String code, int level) async {
    var resp = await HttpRequest.request('/Equipment/GetEquipmentClass',
        method: HttpRequest.GET, params: {'level': level, 'parentCode': code});
    if (resp['ResultCode'] == '00') {
      List _list = resp['Data'].map((item) {
        return item['Description'];
      }).toList();
      switch (level) {
        case 2:
          class2 = _list;
          class2Item = resp['Data'];
          setState(() {
            dropdownClass2 = getDropDownMenuItems(class2);
            if (dropdownClass2.length>0) {
              currentClass2 = dropdownClass2[0].value;
            }
          });
          break;
        case 3:
          class3 = _list;
          class3Item = resp['Data'];
          setState(() {
            dropdownClass3 = getDropDownMenuItems(class3);
            if (dropdownClass3.length>0) {
              currentClass3 = dropdownClass3[0].value;
            }
          });
          break;
      }
    }
  }

  void changeClass1(String selectedClass) {
    if (selectedClass == "") {
      setState(() {
        classCode1 = "00";
        classCode2 = "00";
        classCode3 = "00";
        currentClass1 = "";
        currentClass2 = null;
        currentClass3 = null;
      });
      return;
    }
    FocusScope.of(context).requestFocus(new FocusNode());
    var _selectedItem = class1Item.firstWhere((item) {
      return item['Description'] == selectedClass;
    });
    print(_selectedItem);
    initClass(_selectedItem['Code'], 2);
    setState(() {
      currentClass1 = selectedClass;
      classCode1 = _selectedItem['Code'];
    });
    getFujiClass1();
    getFujiClass2();
  }

  void changeClass2(String selectedMethod) {
    FocusScope.of(context).requestFocus(new FocusNode());
    var _selectedItem = class2Item.firstWhere((item) {
      return item['Description'] == selectedMethod;
    });
    print(_selectedItem);
    var _code = '${_selectedItem['ParentCode']}${_selectedItem['Code']}';
    initClass(_code, 3);
    setState(() {
      currentClass2 = selectedMethod;
      classCode2 = _selectedItem['Code'];
    });
    getFujiClass1();
    getFujiClass2();
  }

  void changeClass3(String selectedMethod) {
    FocusScope.of(context).requestFocus(new FocusNode());
    setState(() {
      currentClass3 = selectedMethod;
    });
    var _item = class3Item.firstWhere((item) {
      return item['Description'] == selectedMethod;
    });
    setState(() {
      classCode3 = _item['Code'];
    });
  }

  void initState() {
    super.initState();
    model = MainModel.of(context);
    dropdownLevel = getDropDownMenuItems(assetLevel);
    currentLevel = dropdownLevel[1].value;
    dropdownStatus = getDropDownMenuItems(runningStatus);
    currentStatus = dropdownStatus[0].value;
    dropdownMachine = getDropDownMenuItems(machineStatus);
    currentMachine = dropdownMachine[0].value;
    dropdownMandatory = getDropDownMenuItems(mandatoryFlag);
    currentMandatory = dropdownMandatory[0].value;
    mandatoryTypes = getDropDownMenuItems(mandatoryPeriod);
    dropdownPatrolPeriod = getDropDownMenuItems(model.PeriodTypeList);
    currentPatrolPeriod = 0;
    dropdownMandatoryPeriod = getDropDownMenuItems(mandatoryPeriodList);
    currentMaintainPeriod = 0;
    dropdownCorrectionPeriod = getDropDownMenuItems(model.PeriodTypeList);
    currentCorrectionPeriod = 0;
    dropdownClass = getDropDownMenuItems(equipmentClass);
    currentClass = dropdownClass[0].value;
    initDepart();
    initClass1();
    switch (widget.equipmentType) {
      case EquipmentType.MEDICAL:
        title = '医疗设备';
        break;
      case EquipmentType.MEASURE:
        title = '计量器具';
        break;
      case EquipmentType.OTHER:
        title = '其他设备';
        break;
    }
    if (widget.equipment != null) {
      getDevice(widget.equipment['ID']);
    }
    getRole();
    getSystemSetting();
    getFujiClass2();
  }

  Future getImage(List _imageList) async {
    List<Asset> image = await MultiImagePicker.pickImages(
        maxImages: 1,
        enableCamera: true
    );
    if (image != null) {
      image.forEach((_image) async {
        var _data = await _image.getByteData();
        var compressed = await FlutterImageCompress.compressWithList(
          _data.buffer.asUint8List(),
          minHeight: 800,
          minWidth: 600,
        );
        setState(() {
          _imageList.clear();
          _imageList.add({'fileName': 'equip_attach_${Uuid().v1()}.jpg', 'content': Uint8List.fromList(compressed)});
        });
      });
    }
  }

  void getCheckPeriod(int typeId) async {
    Map _data = {
      'equipmentID': widget.equipment!=null?widget.equipment['ID']:0,
      'typeID': typeId,
    };
    Map _info = {};
    switch (typeId) {
      case 2:
        _info['MaintenancePeriod'] = maintainPeriod.text;
        _info['MaintenanceType'] = {
          "ID": periodTypeList.firstWhere((item) => item['ID'] == currentMaintainPeriod)['ID']
        };
        break;
      case 3:
        _info['MandatoryTestPeriod'] = mandatoryInterval.text;
        _info['MandatoryTestType'] = {
          "ID": periodTypeList.firstWhere((item) => item['ID'] == currentMandatoryPeriod)['ID']
        };
        break;
      case 4:
        _info['PatrolPeriod'] = patrolPeriod.text;
        _info['PatrolType'] = {
          "ID": periodTypeList.firstWhere((item) => item['ID'] == currentPatrolPeriod)['ID']
        };
        break;
      case 5:
        _info['CorrectionPeriod'] = correctionPeriod.text;
        _info['CorrectionType'] = {
          "ID": periodTypeList.firstWhere((item) => item['ID'] == currentCorrectionPeriod)['ID']
        };
        break;
    }
    _data['equipmentInfo'] = _info;
    Map resp = await HttpRequest.request(
      '/equipment/getsysrequestlist',
      method: HttpRequest.POST,
      data: _data
    );
    if (resp['ResultCode'] == '00') {
      setState(() {
        periodList = resp['Data'];
      });
    }
  }

  void showPeriodSheet(String title) async {
    showDialog(context: context,
        builder: (context) => SimpleDialog(
          title: new Text(title),
          children: <Widget>[
            new Container(
              width: 300.0,
              height: periodList.length<=5?200:periodList.length*41.0,
              child: periodList.length==0?Center(
                child: Text(
                    '暂无计划服务生成时间',
                    style: TextStyle(
                      color: Colors.black54
                    ),
                ),
              ):Padding(
                padding: EdgeInsets.fromLTRB(60, 0, 20, 0),
                child: ListView(
                  controller: new ScrollController(),
                  shrinkWrap: true,
                  children: periodList.asMap().keys.map<Widget>((index) {
                    return TimelineTile(
                        alignment: TimelineAlign.left,
                        isFirst: index==0?true:false,
                        isLast: index==periodList.length-1?true:false,
                        indicatorStyle: IndicatorStyle(
                          width: 9,
                          color: Colors.blue,
                          indicatorY: 0.3,
                        ),
                        bottomLineStyle: const LineStyle(
                          color: Color(0xffebebeb),
                          width: 4,
                        ),
                        topLineStyle: const LineStyle(
                          color: Color(0xffebebeb),
                          width: 4,
                        ),
                        rightChild: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 13),
                          child: Container(
                            constraints: const BoxConstraints(
                              minHeight: 40,
                            ),
                            child: Text(
                              '${periodList[index].split('T')[0]}',
                              style: TextStyle(
                                  color: Color(0xff1e1e1e),
                                  fontSize: 14
                              ),
                            ),
                          ),
                        )
                    );
                  }).toList(),
                ),
              )
            )
          ],
        )
    );
  }

  Column buildImageRow(List imageList, String defaultPic) {
    List<Widget> _list = [];
    if (imageList.length > 0) {
      for (var image in imageList) {
        if (ImageUtil.isImageFile(image['fileName'])) {
          _list.add(
            Center(
              child: new Stack(
                children: <Widget>[
                  new Container(
                    width: 150.0,
                    child: BuildWidget.buildPhotoPageList(context, image['content']),
                  ),
                  new Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: widget.editable?new IconButton(
                        icon: Icon(Icons.cancel),
                        color: Colors.blue,
                        onPressed: () {
                          setState(() {
                            imageList.remove(image);
                            if (image['id'] != null) {
                              deleteFile(image['id']);
                            }
                          });
                        }):new Container(
                      child: SizedBox(
                        width: 1,
                      ),
                    ),
                  ),
                ],
              ),
            )
          );
        } else {
          _list.add(
            new Row(
              children: <Widget>[
                new Expanded(
                  flex: 8,
                  child: Text(image['fileName'], style: new TextStyle(color: Colors.blue),),
                ),
                new Expanded(
                  flex: 2,
                  child: widget.editable?new IconButton(
                      icon: Icon(Icons.cancel),
                      color: Colors.blue,
                      onPressed: () {
                        setState(() {
                          imageList.remove(image);
                          if (image['id'] != null) {
                            deleteFile(image['id']);
                          }
                        });
                      }):new Container(),
                )
              ],
            )
          );
        }
      }
    } else {
      _list.add(
        Center(
          child: Container(
              width: 100,
              height: 100,
              child: Center(
                child: Opacity(
                  opacity: 0.2,
                  child: Image.asset(
                      defaultPic
                  ),
                )
              )
          ),
        )
      );
    }
    return new Column(
        children: _list
    );
  }

  Future<String> getDeviceFile(int fileId) async {
    // todo: switch equipment type
    String url;
    switch (widget.equipmentType) {
      case EquipmentType.MEDICAL:
        url = '/Equipment/DownloadUploadFile';
        break;
      case EquipmentType.MEASURE:
        url = '/MeasInstrum/DownloadUploadFile';
        break;
      case EquipmentType.OTHER:
        url = '/OtherEqpt/DownloadUploadFile';
        break;
    }
    var resp = await HttpRequest.request(
      url,
      method: HttpRequest.POST,
      data: {
        'id': fileId
      }
    );
    return resp['ResultCode']=='00'?resp['Data']:null;
  }

  String formatDateString(String date) {
    if (date == 'null') {
      return 'YY-MM-DD';
    } else {
      return date.split('T')[0];
    }
  }

  String displayDate(String date) {
    return date=='YY-MM-DD'?'':date;
  }

  Future<Null> deleteFile(int fileId) async {
    String url;
    switch (widget.equipmentType) {
      case EquipmentType.MEDICAL:
        url = '/Equipment/DeleteEquipmentFile';
        break;
      case EquipmentType.MEASURE:
        url = '/MeasInstrum/DeleteEquipmentFile';
        break;
      case EquipmentType.OTHER:
        url = '/OtherEqpt/DeleteEquipmentFile';
        break;
    }
    var resp = await HttpRequest.request(
      url,
      method: HttpRequest.POST,
      data: {
        'fileID': fileId
      }
    );
    print(resp);
  }

  Future<Null> getSystemSetting() async {
    var resp = await HttpRequest.request(
      '/User/GetSystemSetting',
      method: HttpRequest.GET
    );
    if (resp['ResultCode'] == '00') {
      setState(() {
        autoAssetCode = resp['Data']['AutoAssetCode'];
      });
    }
  }

  void downloadFiles(List files) async {
    for(var item in files) {
      var _fileExt = item['FileName'].split('.');
      _fileExt = _fileExt.reversed.toList();
      switch (item['FileType']) {
        case 5:
          if (_fileExt[0].toLowerCase() == 'jpg' || _fileExt[0].toLowerCase() == 'png' || _fileExt[0].toLowerCase() == 'jpeg' ||
              _fileExt[0].toLowerCase() == 'bmp') {
            var _file = await getDeviceFile(item['ID']);
            if (_file != null) {
              setState(() {
                equipmentPlaques.add({
                  'fileName': item['FileName'],
                  'content': base64Decode(_file),
                  'id': item['ID']
                });
              });
            }
          } else {
            setState(() {
              equipmentPlaques.add({
                'fileName': item['FileName'],
                'content': '',
                'id': item['ID']
              });
            });
          }
          break;
        case 6:
          if (_fileExt[0].toLowerCase() == 'jpg' || _fileExt[0].toLowerCase() == 'png' || _fileExt[0].toLowerCase() == 'jpeg' ||
              _fileExt[0].toLowerCase() == 'bmp') {
            var _file = await getDeviceFile(item['ID']);
            if (_file != null) {
              setState(() {
                equipmentLabel.add({
                  'fileName': item['FileName'],
                  'content': base64Decode(_file),
                  'id': item['ID']
                });
              });
            }
          } else {
            setState(() {
              equipmentLabel.add({
                'fileName': item['FileName'],
                'content': '',
                'id': item['ID']
              });
            });
          }
          break;
        case 4:
          if (_fileExt[0].toLowerCase() == 'jpg' || _fileExt[0].toLowerCase() == 'png' || _fileExt[0].toLowerCase() == 'jpeg' ||
              _fileExt[0].toLowerCase() == 'bmp') {
            var _file = await getDeviceFile(item['ID']);
            if (_file != null) {
              setState(() {
                equipmentAppearance.add({
                  'fileName': item['FileName'],
                  'content': base64Decode(_file),
                  'id': item['ID']
                });
              });
            }
          } else {
            setState(() {
              equipmentAppearance.add({
                'fileName': item['FileName'],
                'content': '',
                'id': item['ID']
              });
            });
          }
          break;
      }
    }
  }

  Future<Null> getDevice(int deviceId) async {
    String _url;
    switch (widget.equipmentType) {
      case EquipmentType.MEDICAL:
        _url = '/Equipment/GetDeviceById';
        break;
      case EquipmentType.MEASURE:
        _url = '/MeasInstrum/GetMeasInstrumByID';
        break;
      case EquipmentType.OTHER:
        _url = '/OtherEqpt/GetOtherEqptByID';
    }

    var resp = await HttpRequest.request(
        _url,
        method: HttpRequest.GET, params: {'id': deviceId});
    if (resp['ResultCode'] == '00') {
      var _data = resp['Data'];
      if (widget.equipmentType == EquipmentType.MEDICAL) {
        await initClass1();
        setState(() {
          currentClass1 = _data['EquipmentClass1']['Description']==''?currentClass1:_data['EquipmentClass1']['Description'];
        });
        await initClass(_data['EquipmentClass1']['Code'], 2);
        if (_data['EquipmentClass2']['Description'] != '') {
          setState(() {
            currentClass2 = _data['EquipmentClass2']['Description'];
          });
          await initClass(_data['EquipmentClass1']['Code'] + _data['EquipmentClass2']['Code'], 3);
          if (_data['EquipmentClass3']['Description'] != '') {
            setState(() {
              currentClass3 = _data['EquipmentClass3']['Description'];
              classCode1 = _data['EquipmentClass1']['Code'];
              classCode2 = _data['EquipmentClass2']['Code'];
              classCode3 = _data['EquipmentClass3']['Code'];
            });
          }
        }
      }
      switch (widget.equipmentType) {
        case EquipmentType.MEDICAL:
          setState(() {
            oid = _data['OID'];
            name.text = _data['Name'];
            equipmentCode.text = _data['EquipmentCode'];
            serialCode.text = _data['SerialCode'];
            responseTime.text = _data['ResponseTimeLength'].toString();
            assetCode.text = _data['AssetCode'];
            brand.text = _data['Brand'];
            comments.text = _data['Comments'];
            depreciationYears.text = _data['DepreciationYears'].toString();
            contractName.text = _data['SaleContractName'];
            purchaseWay.text = _data['PurchaseWay'];
            purchaseAmount.text = _data['PurchaseAmount'].toString();
            installSite.text = _data['InstalSite'];
            warrantyStatus = _data['WarrantyStatus'];
            maintainPeriod.text = _data['MaintenancePeriod'].toString();
            patrolPeriod.text = _data['PatrolPeriod'].toString();
            correctionPeriod.text = _data['CorrectionPeriod'].toString();
            manufacturer = _data['Manufacturer'];
            supplier = _data['Supplier'];
            currentClass = _data['EquipmentLevel']['Name'];
            currentFixed = _data['FixedAsset'] ? '是' : '否';
            currentLevel = _data['AssetLevel']['Name'];
            validationStartDate = formatDateString(_data['ValidityStartDate'].toString());
            validationEndDate = formatDateString(_data['ValidityEndDate'].toString());
            installDate = formatDateString(_data['InstalDate'].toString());
            usageDate = formatDateString(_data['UseageDate'].toString());
            manufacturingDate = formatDateString(_data['ManufacturingDate'].toString());
            purchaseDate = formatDateString(_data['PurchaseDate'].toString());
            scrapDate = formatDateString(_data['ScrapDate'].toString());
            currentOrigin = _data['OriginType'];
            currentDepartment = _data['Department']['Name'];
            currentCheck = _data['Accepted'] ? '已验收' : '未验收';
            checkDate = formatDateString(_data['AcceptanceDate'].toString());
            currentStatus = _data['UsageStatus']['Name'];
            currentMachine = _data['EquipmentStatus']['Name'];
            currentMandatory = _data['MandatoryTestStatus']['ID'] == 0 ? '无' : _data['MandatoryTestStatus']['Name'];
            mandatoryDate = formatDateString(_data['MandatoryTestDate'].toString());
            currentRecall = _data['RecallFlag'] ? '是' : '否';
            currentServiceScope = _data['ServiceScope']?"是":"否";
            recallDate = formatDateString(_data['RecallDate'].toString());
            currentPatrolPeriod = _data['PatrolType']['ID'];
            currentMaintainPeriod = _data['MaintenanceType']['ID'];
            currentCorrectionPeriod = _data['CorrectionType']['ID'];
            getFujiClass1();
            getFujiClass2();
            fujiClass2 = _data['FujiClass2']['ID'];
            fujiClass2Name = _data['FujiClass2']['Name'];
            getFujiComponent();
            componentCodes.text = _data['CTSerialCode'];
            componentSeconds.text = _data['CTUsedSeconds'].toString();
            historyComponent = _data['HisComponentList'];
            historyConsumable = _data['HisConsumableList'];
            currentMandatoryType = _data['MandatoryTestPeriodType']['Name'];
            mandatoryDate = formatDateString(_data['MandatoryTestDate'].toString());
            mandatoryInterval.text = _data['MandatoryTestPeriod'].toString();
            currentMandatoryPeriod = _data['MandatoryTestType']['ID'];
          });
          downloadFiles(_data['EquipmentFile']);
          break;
        case EquipmentType.MEASURE:
          setState(() {
            oid = _data['OID'];
            name.text = _data['Name'];
            equipmentCode.text = _data['MeasInstrumCode'];
            serialCode.text = _data['SerialCode'];
            responseTime.text = _data['ResponseTimeLength'].toString();
            assetCode.text = _data['AssetCode'];
            currentLevel = _data['AssetLevel']['Name'];
            brand.text = _data['Brand'];
            comments.text = _data['Comments'];
            depreciationYears.text = _data['DepreciationYears'].toString();
            contractName.text = _data['SaleContractName'];
            purchaseWay.text = _data['PurchaseWay'];
            purchaseAmount.text = _data['PurchaseAmount'].toString();
            installSite.text = _data['InstalSite'];
            warrantyStatus = _data['WarrantyStatus'];
            maintainPeriod.text = _data['MaintenancePeriod'].toString();
            patrolPeriod.text = _data['PatrolPeriod'].toString();
            correctionPeriod.text = _data['CorrectionPeriod'].toString();
            manufacturer = _data['Manufacturer'];
            supplier = _data['Supplier'];
            validationStartDate = formatDateString(_data['ValidityStartDate'].toString());
            validationEndDate = formatDateString(_data['ValidityEndDate'].toString());
            installDate = formatDateString(_data['InstalDate'].toString());
            usageDate = formatDateString(_data['UseageDate'].toString());
            manufacturingDate = formatDateString(_data['ManufacturingDate'].toString());
            purchaseDate = formatDateString(_data['PurchaseDate'].toString());
            scrapDate = formatDateString(_data['ScrapDate'].toString());
            currentOrigin = _data['OriginType'];
            currentDepartment = _data['Department']['Name'];
            currentCheck = _data['Accepted'] ? '已验收' : '未验收';
            checkDate = formatDateString(_data['AcceptanceDate'].toString());
            currentStatus = _data['UsageStatus']['Name'];
            currentMachine = _data['EquipmentStatus']['Name'];
            currentMandatory = _data['MandatoryTestStatus']['ID'] == 0 ? '无' : _data['MandatoryTestStatus']['Name'];
            mandatoryDate = formatDateString(_data['MandatoryTestDate'].toString());
            currentRecall = _data['RecallFlag'] ? '是' : '否';
            currentServiceScope = _data['ServiceScope']?"是":"否";
            recallDate = formatDateString(_data['RecallDate'].toString());
            currentPatrolPeriod = _data['PatrolType']['ID'];
            currentMaintainPeriod = _data['MaintenanceType']['ID'];
            currentCorrectionPeriod = _data['CorrectionType']['ID'];
            currentMandatoryType = _data['MandatoryTestPeriodType']['Name'];
            mandatoryDate = formatDateString(_data['MandatoryTestDate'].toString());
            mandatoryInterval.text = _data['MandatoryTestPeriod'].toString();
            currentMandatoryPeriod = _data['MandatoryTestType']['ID'];
            relatedEquipment = _data['Equipment'];
          });
          downloadFiles(_data['MeasInstrumFile']);
          break;
        case EquipmentType.OTHER:
          setState(() {
            oid = _data['OID'];
            name.text = _data['Name'];
            equipmentCode.text = _data['OtherEqptCode'];
            serialCode.text = _data['SerialCode'];
            currentLevel = _data['AssetLevel']['Name'];
            responseTime.text = _data['ResponseTimeLength'].toString();
            assetCode.text = _data['AssetCode'];
            brand.text = _data['Brand'];
            comments.text = _data['Comments'];
            depreciationYears.text = _data['DepreciationYears'].toString();
            contractName.text = _data['SaleContractName'];
            purchaseWay.text = _data['PurchaseWay'];
            purchaseAmount.text = _data['PurchaseAmount'].toString();
            installSite.text = _data['InstalSite'];
            warrantyStatus = _data['WarrantyStatus'];
            maintainPeriod.text = _data['MaintenancePeriod'].toString();
            patrolPeriod.text = _data['PatrolPeriod'].toString();
            correctionPeriod.text = _data['CorrectionPeriod'].toString();
            manufacturer = _data['Manufacturer'];
            supplier = _data['Supplier'];
            validationStartDate = formatDateString(_data['ValidityStartDate'].toString());
            validationEndDate = formatDateString(_data['ValidityEndDate'].toString());
            installDate = formatDateString(_data['InstalDate'].toString());
            usageDate = formatDateString(_data['UseageDate'].toString());
            manufacturingDate = formatDateString(_data['ManufacturingDate'].toString());
            purchaseDate = formatDateString(_data['PurchaseDate'].toString());
            scrapDate = formatDateString(_data['ScrapDate'].toString());
            currentOrigin = _data['OriginType'];
            currentDepartment = _data['Department']['Name'];
            currentCheck = _data['Accepted'] ? '已验收' : '未验收';
            checkDate = formatDateString(_data['AcceptanceDate'].toString());
            currentStatus = _data['UsageStatus']['Name'];
            currentMachine = _data['EquipmentStatus']['Name'];
            currentMandatory = _data['MandatoryTestStatus']['ID'] == 0 ? '无' : _data['MandatoryTestStatus']['Name'];
            currentRecall = _data['RecallFlag'] ? '是' : '否';
            currentServiceScope = _data['ServiceScope']?"是":"否";
            recallDate = formatDateString(_data['RecallDate'].toString());
            currentPatrolPeriod = _data['PatrolType']['ID'];
            currentMaintainPeriod = _data['MaintenanceType']['ID'];
            currentCorrectionPeriod = _data['CorrectionType']['ID'];
            relatedEquipment = _data['Equipment'];
            currentMandatoryType = _data['MandatoryTestPeriodType']['Name'];
            mandatoryDate = formatDateString(_data['MandatoryTestDate'].toString());
            mandatoryInterval.text = _data['MandatoryTestPeriod'].toString();
            currentMandatoryPeriod = _data['MandatoryTestType']['ID'];
          });
          downloadFiles(_data['OtherEqptFile']);
          break;
      }
    }
  }

  void removeFocus() {
    _focusEquip.forEach((_focus) {
      _focus.unfocus();
    });
    _focusOther.forEach((_focus) {
      _focus.unfocus();
    });
  }

  List<FocusNode> _focusEquip = new List(20).map((item) {
    return new FocusNode();
  }).toList();

  List<FocusNode> _focusOther = new List(10).map((item) {
    return new FocusNode();
  }).toList();

  Future<bool> checkAssetCode() async {
    bool duplicate = false;
    String _url;
    switch (widget.equipmentType) {
      case EquipmentType.MEDICAL:
        _url = "/Equipment/CheckAssetCode";
        break;
      case EquipmentType.MEASURE:
        _url = '/MeasInstrum/CheckAssetCode';
        break;
      case EquipmentType.OTHER:
        _url = '/OtherEqpt/CheckAssetCode';
        break;
    }
    Map _param = {
      'assetCode': assetCode.text,
      'id': widget.equipment==null?0:widget.equipment['ID']
    };
    if (widget.equipmentType == EquipmentType.MEASURE || widget.equipmentType == EquipmentType.OTHER) {
      Map resp = await HttpRequest.request(
        _url,
        method: HttpRequest.GET,
        params: _param
      );
      if (resp['ResultCode'] == '00') {
        duplicate = resp['Data'];
      }
    }
    return duplicate;
  }

  Future<Null> saveEquipment() async {
    setState(() {
      expansionList = expansionList.map((item) {
        return true;
      }).toList();
    });
    String notification;
    if (widget.equipmentType == EquipmentType.MEASURE) {
      notification = '器具';
    } else {
      notification = '设备';
    }
    bool duplicate = await checkAssetCode();
    if (duplicate) {
      showDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: new Text('$notification资产编号重复'),
          )
      ).then((result) => FocusScope.of(context).requestFocus(_focusEquip[4]));
      return;
    }
    if (widget.equipmentType == EquipmentType.MEDICAL && fujiClass2==null) {
      showDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: new Text('富士II类不可为空'),
          )
      ).then((result) => _scrollController.jumpTo(400.0));
      return;
    }
    //if ((widget.equipmentType == EquipmentType.MEASURE || widget.equipmentType == EquipmentType.OTHER) && relatedEquipment==null) {
    //  showDialog(
    //      context: context,
    //      builder: (context) => CupertinoAlertDialog(
    //        title: new Text('关联设备不可为空'),
    //      )
    //  ).then((result) => _scrollController.jumpTo(500.0));
    //  return;
    //}
    if (name.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: new Text('$notification名称不可为空'),
        )
      ).then((result) => FocusScope.of(context).requestFocus(_focusEquip[0]));
      return;
    }
    if (equipmentCode.text.isEmpty) {
      showDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: new Text('$notification型号不可为空'),
          )
      ).then((result) => FocusScope.of(context).requestFocus(_focusEquip[1]));
      return;
    }
    if (serialCode.text.isEmpty) {
      showDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: new Text('$notification序列号不可为空'),
          )
      ).then((result) => FocusScope.of(context).requestFocus(_focusEquip[2]));
      return;
    }
    if (manufacturer == null) {
      showDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: new Text('$notification厂商不可为空'),
          )
      ).then((result) {
        _scrollController.jumpTo(200.0);
      });
      return;
    }
    if (responseTime.text.isEmpty || responseTime.text == "0" || responseTime.text == "") {
      showDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: new Text('标准响应时间不可为空'),
          )
      ).then((result) => FocusScope.of(context).requestFocus(_focusEquip[3]));
      return;
    }
    var _vStart = DateTime.tryParse(validationStartDate);
    var _vEnd = DateTime.tryParse(validationEndDate);
    if (_vStart!=null&&_vEnd!=null&&_vEnd.isBefore(_vStart)) {
      showDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: new Text('有效日期格式有误'),
          )
      ).then((result) {
        _scrollController.jumpTo(1000.0);
      }) ;
      return;
    }
    if (assetCode.text.isEmpty && !autoAssetCode) {
      showDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: new Text('资产编号不可为空'),
          )
      ).then((result) => FocusScope.of(context).requestFocus(_focusEquip[4]));
      return;
    }
    if (purchaseDate == 'YY-MM-DD' && widget.equipmentType == EquipmentType.MEDICAL) {
      showDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: new Text('采购日期不可为空'),
          )
      ).then((result) {
       _scrollController.jumpTo(fujiClass2Components.isEmpty?1600.0:2000.0);
      });
      return;
    }
    if (double.tryParse(purchaseAmount.text.toString()) !=null && double.tryParse(purchaseAmount.text.toString()) > 99999999.99) {
      showDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: new Text('采购金额需小于1亿'),
          )
      ).then((result) => FocusScope.of(context).requestFocus(_focusEquip[5]));
      return;
    }
    if (currentMachine == '已报废' && scrapDate == 'YY-MM-DD') {
      showDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: new Text('报废时间不可为空'),
          )
      ).then((result) {
        _scrollController.jumpTo(fujiClass2Components.isEmpty?2200.0:2600.0);
      });
      return;
    }
    if (currentMandatoryType == '固定日期' && mandatoryDate == 'YY-MM-DD') {
      showDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: new Text('强检时间不可为空'),
          )
      ).then((result) {
        _scrollController.jumpTo(fujiClass2Components.isEmpty?2200.0:2600.0);
      });
      return;
    }
    if (currentPatrolPeriod > 0 && patrolPeriod.text.isEmpty) {
      showDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: new Text('巡检周期不可为空'),
          )
      ).then((result) => FocusScope.of(context).requestFocus(_focusEquip[6]));
      return;
    }
    if (int.tryParse(patrolPeriod.text.toString()) != null && int.tryParse(patrolPeriod.text.toString()) <= 0 && currentPatrolPeriod > 0) {
      showDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: new Text('巡检周期需大于0'),
          )
      ).then((result) => FocusScope.of(context).requestFocus(_focusEquip[6]));
      return;
    }
    if (currentMaintainPeriod > 0 && maintainPeriod.text.isEmpty) {
      showDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: new Text('保养周期不可为空'),
          )
      ).then((result) => FocusScope.of(context).requestFocus(_focusEquip[7]));
      return;
    }
    if (int.tryParse(maintainPeriod.text.toString()) !=null && int.tryParse(maintainPeriod.text.toString()) <= 0 && currentMaintainPeriod > 0) {
      showDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: new Text('保养周期需大于0'),
          )
      ).then((result) => FocusScope.of(context).requestFocus(_focusEquip[7]));
      return;
    }
    if (currentCorrectionPeriod > 0 && correctionPeriod.text.isEmpty) {
      showDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: new Text('校准周期不可为空'),
          )
      ).then((result) => FocusScope.of(context).requestFocus(_focusEquip[8]));
      return;
    }
    if (int.tryParse(correctionPeriod.text.toString()) != null && int.tryParse(correctionPeriod.text.toString()) <= 0 && currentCorrectionPeriod > 0) {
      showDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: new Text('校准周期需大于0'),
          )
      ).then((result) => FocusScope.of(context).requestFocus(_focusEquip[8]));
      return;
    }
    if (installDate == 'YY-MM-DD') {
      showDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: new Text('安装日期不可为空'),
          )
      ).then((result) {
        _scrollController.jumpTo(2000.0);
      });
      return;
    }
    var _prefs = await prefs;
    var _userId = _prefs.getInt('userID');
    var _equipmentFiles = [];
    _equipmentFiles.addAll(equipmentPlaques
        .map((item) => item['id']==null?{
              'FileContent': base64Encode(item['content']),
              'FileName': item['fileName'],
              'FileType': 5,
              'ID': 0
            }:null)
        .toList());
    _equipmentFiles.addAll(equipmentLabel
        .map((item) => item['id']==null?{
              'FileContent': base64Encode(item['content']),
              'FileName': item['fileName'],
              'FileType': 6,
              'ID': 0
            }:null)
        .toList());
    _equipmentFiles.addAll(equipmentAppearance
        .map((item) => item['id']==null?{
              'FileContent': base64Encode(item['content']),
              'FileName': item['fileName'],
              'FileType': 4,
              'FileDesc': '',
              'ID': 0
            }:null)
        .toList());
    _equipmentFiles.removeWhere((item) => item==null);
    Map _body;
    String _url;
    switch (widget.equipmentType) {
      case EquipmentType.MEDICAL:
        _url = '/Equipment/SaveEquipment';
        _body = {
          "EquipmentLevel": {
            "ID": equipmentLevel[currentClass],
          },
          "Name": name.text,
          "EquipmentCode": equipmentCode.text,
          "SerialCode": serialCode.text,
          "Manufacturer": {'ID': manufacturer == null ? 0 : manufacturer['ID']},
          "EquipmentClass1": class1Item.firstWhere(
                  (item) => item['Description'] == currentClass1,
              orElse: () => {}),
          "EquipmentClass2": class2Item.firstWhere(
                  (item) => item['Description'] == currentClass2,
              orElse: () => {}),
          "EquipmentClass3": class3Item.firstWhere(
                  (item) => item['Description'] == currentClass3,
              orElse: () => {}),
          "ResponseTimeLength": responseTime.text,
          "FixedAsset": currentFixed == '是' ? true : false,
          "ServiceScope": currentServiceScope == '是'?true:false,
          "Brand": brand.text,
          "Comments": comments.text,
          "ManufacturingDate": manufacturingDate,
          "AssetCode": autoAssetCode&&widget.equipment==null?null:assetCode.text,
          "AssetLevel": {'ID': model.AssetsLevel[currentLevel]},
          "DepreciationYears": depreciationYears.text,
          "ValidityStartDate": validationStartDate,
          "ValidityEndDate": validationEndDate,
          "SaleContractName": contractName.text,
          "Supplier": {'ID': supplier == null ? 0 : supplier['ID']},
          "PurchaseWay": purchaseWay.text,
          "PurchaseAmount": purchaseAmount.text,
          "PurchaseDate": purchaseDate,
          "IsImport": currentOrigin == '进口' ? true : false,
          "Department": {
            "ID": model.Departments[currentDepartment],
          },
          "InstalSite": installSite.text,
          //"InstalStartDate": installStartDate,
          //"InstalEndDate": installEndDate,
          "InstalDate": installDate,
          "UseageDate": usageDate,
          "Accepted": currentCheck == '已验收' ? true : false,
          "AcceptanceDate": checkDate,
          "UsageStatus": {
            "ID": model.UsageStatus[currentStatus],
          },
          "EquipmentStatus": {
            "ID": model.EquipmentStatus[currentMachine],
          },
          "ScrapDate": scrapDate=='YY-MM-DD'?null:scrapDate,
          "MandatoryTestPeriodType": {
            "ID": mandatoryType[currentMandatoryType],
          },
          "MandatoryTestDate": currentMandatoryType=='固定日期'?mandatoryDate:'YY-MM-DD',
          "MandatoryTestType": {
            'ID': currentMandatoryType=='周期'?periodTypeList.firstWhere((item) => item['ID'] ==currentMandatoryPeriod)['ID']:0
          },
          "MandatoryTestPeriod": currentMandatoryType=='周期'?mandatoryInterval.text:0,
          "MaintenancePeriod": maintainPeriod.text.isEmpty?null:maintainPeriod.text,
          "MaintenanceType": {
            "ID": currentMaintainPeriod,
          },
          "PatrolPeriod": patrolPeriod.text.isEmpty?null:patrolPeriod.text,
          "PatrolType": {
            "ID": currentPatrolPeriod,
          },
          "CorrectionPeriod": correctionPeriod.text.isEmpty?null:correctionPeriod.text,
          "CorrectionType": {
            "ID": currentCorrectionPeriod,
          },
          "MandatoryTestStatus": {
            "ID": mandatoryFlagType[currentMandatory],
          },
          "RecallFlag": currentRecall == '是' ? true : false,
          "RecallDate": recallDate,
          "CreateUser": {'ID': _userId},
          "EquipmentFile": _equipmentFiles,
          "CTSerialCode": componentCodes.text,
          "CTUsedSeconds": componentSeconds.text,
          "FujiClass2": {
            "ID": fujiClass2
          }
        };
        break;
      case EquipmentType.MEASURE:
        _url = '/MeasInstrum/SaveMeasInstrumInfo';
        _body = {
          "EquipmentLevel": {
            "ID": equipmentLevel[currentClass],
          },
          "Equipment": relatedEquipment??{
            "ID": 0
          },
          "Name": name.text,
          "MeasInstrumCode": equipmentCode.text,
          "ModelCode": equipmentCode.text,
          "SerialCode": serialCode.text,
          "Manufacturer": {'ID': manufacturer == null ? 0 : manufacturer['ID']},
          "ResponseTimeLength": responseTime.text,
          "FixedAsset": currentFixed == '是' ? true : false,
          "ServiceScope": currentServiceScope == '是'?true:false,
          "Brand": brand.text,
          "Comments": comments.text,
          "ManufacturingDate": manufacturingDate,
          "AssetCode": autoAssetCode&&widget.equipment==null?null:assetCode.text,
          "AssetType": {
            "ID": 0
          },
          "AssetLevel": {'ID': model.AssetsLevel[currentLevel]},
          "DepreciationYears": depreciationYears.text,
          "ValidityStartDate": validationStartDate,
          "ValidityEndDate": validationEndDate,
          "SaleContractName": contractName.text,
          "Supplier": {'ID': supplier == null ? 0 : supplier['ID']},
          "PurchaseWay": purchaseWay.text,
          "PurchaseAmount": purchaseAmount.text,
          "PurchaseDate": purchaseDate,
          "IsImport": currentOrigin == '进口' ? true : false,
          "Department": {
            "ID": model.Departments[currentDepartment],
          },
          "InstalSite": installSite.text,
          //"InstalStartDate": installStartDate,
          //"InstalEndDate": installEndDate,
          "InstalDate": installDate,
          "UseageDate": usageDate,
          "Accepted": currentCheck == '已验收' ? true : false,
          "AcceptanceDate": checkDate,
          "UsageStatus": {
            "ID": model.UsageStatus[currentStatus],
          },
          "EquipmentStatus": {
            "ID": model.EquipmentStatus[currentMachine],
          },
          "ScrapDate": scrapDate=='YY-MM-DD'?null:scrapDate,
          "MaintenancePeriod": maintainPeriod.text.isEmpty?null:maintainPeriod.text,
          "MaintenanceType": {
            "ID": currentMaintainPeriod,
          },
          "PatrolPeriod": patrolPeriod.text.isEmpty?null:patrolPeriod.text,
          "PatrolType": {
            "ID": currentPatrolPeriod,
          },
          "CorrectionPeriod": correctionPeriod.text.isEmpty?null:correctionPeriod.text,
          "CorrectionType": {
            "ID": currentCorrectionPeriod,
          },
          "MandatoryTestStatus": {
            "ID": mandatoryFlagType[currentMandatory],
          },
          "RecallFlag": currentRecall == '是' ? true : false,
          "RecallDate": recallDate,
          "CreateUser": {'ID': _userId},
          "MeasInstrumFile": _equipmentFiles,
          "MandatoryTestPeriodType": {
            "ID": mandatoryType[currentMandatoryType],
          },
          "MandatoryTestDate": currentMandatoryType=='固定日期'?mandatoryDate:'YY-MM-DD',
          "MandatoryTestType": {
            'ID': currentMandatoryType=='周期'?periodTypeList.firstWhere((item) => item['ID'] ==currentMandatoryPeriod)['ID']:0
          },
          "MandatoryTestPeriod": currentMandatoryType=='周期'?mandatoryInterval.text:0,
        };
        break;
      case EquipmentType.OTHER:
        _url = '/OtherEqpt/SaveOtherEqptInfo';
        _body = {
          "EquipmentLevel": {
            "ID": equipmentLevel[currentClass],
          },
          "Name": name.text,
          "OtherEqptCode": equipmentCode.text,
          "SerialCode": serialCode.text,
          "Manufacturer": {'ID': manufacturer == null ? 0 : manufacturer['ID']},
          "EquipmentClass1": class1Item.firstWhere(
                  (item) => item['Description'] == currentClass1,
              orElse: () => {}),
          "EquipmentClass2": class2Item.firstWhere(
                  (item) => item['Description'] == currentClass2,
              orElse: () => {}),
          "EquipmentClass3": class3Item.firstWhere(
                  (item) => item['Description'] == currentClass3,
              orElse: () => {}),
          "ResponseTimeLength": responseTime.text,
          "FixedAsset": currentFixed == '是' ? true : false,
          "ServiceScope": currentServiceScope == '是'?true:false,
          "Brand": brand.text,
          "Comments": comments.text,
          "ManufacturingDate": manufacturingDate,
          "AssetCode": autoAssetCode&&widget.equipment==null?null:assetCode.text,
          "AssetLevel": {'ID': model.AssetsLevel[currentLevel]},
          "DepreciationYears": depreciationYears.text,
          "ValidityStartDate": validationStartDate,
          "ValidityEndDate": validationEndDate,
          "SaleContractName": contractName.text,
          "Supplier": {'ID': supplier == null ? 0 : supplier['ID']},
          "PurchaseWay": purchaseWay.text,
          "PurchaseAmount": purchaseAmount.text,
          "PurchaseDate": purchaseDate,
          "IsImport": currentOrigin == '进口' ? true : false,
          "Department": {
            "ID": model.Departments[currentDepartment],
          },
          "InstalSite": installSite.text,
          //"InstalStartDate": installStartDate,
          //"InstalEndDate": installEndDate,
          "InstalDate": installDate,
          "UseageDate": usageDate,
          "Accepted": currentCheck == '已验收' ? true : false,
          "AcceptanceDate": checkDate,
          "UsageStatus": {
            "ID": model.UsageStatus[currentStatus],
          },
          "EquipmentStatus": {
            "ID": model.EquipmentStatus[currentMachine],
          },
          "ScrapDate": scrapDate=='YY-MM-DD'?null:scrapDate,
          "MaintenancePeriod": maintainPeriod.text.isEmpty?null:maintainPeriod.text,
          "MaintenanceType": {
            "ID": currentMaintainPeriod,
          },
          "PatrolPeriod": patrolPeriod.text.isEmpty?null:patrolPeriod.text,
          "PatrolType": {
            "ID": currentPatrolPeriod,
          },
          "CorrectionPeriod": correctionPeriod.text.isEmpty?null:correctionPeriod.text,
          "CorrectionType": {
            "ID": currentCorrectionPeriod,
          },
          "MandatoryTestStatus": {
            "ID": mandatoryFlagType[currentMandatory],
          },
          "RecallFlag": currentRecall == '是' ? true : false,
          "RecallDate": recallDate,
          "CreateUser": {'ID': _userId},
          "OtherEqptFile": _equipmentFiles,
          "MandatoryTestPeriodType": {
            "ID": mandatoryType[currentMandatoryType],
          },
          "MandatoryTestDate": currentMandatoryType=='固定日期'?mandatoryDate:'YY-MM-DD',
          "MandatoryTestType": {
            'ID': currentMandatoryType=='周期'?periodTypeList.firstWhere((item) => item['ID'] ==currentMandatoryPeriod)['ID']:0
          },
          "MandatoryTestPeriod": currentMandatoryType=='周期'?mandatoryInterval.text:0,
          "Equipment": relatedEquipment??{
            "ID": 0
          }
        };
        break;
    }
    if (widget.equipment != null) {
      _body['ID'] = widget.equipment['ID'];
    } else {
      _body['ID'] = 0;
    }
    setState(() {
      netstat = true;
    });
    log("$_body");
    var resp = await HttpRequest.request(
        _url,
        method: HttpRequest.POST,
        data: {
          "userID": _userId,
          "info": _body
        });
    if (resp['ResultCode'] == '00') {
      showDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
                title: new Text('保存成功'),
              )).then((result) => Navigator.of(context).pop());
    } else {
      showDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
                title: new Text(resp['ResultMessage']),
              )).then((result) {
                if (resp['ResultMessage'] == '设备资产编号重复') {
                  FocusScope.of(context).requestFocus(_focusEquip[4]);
                }
      });
    }
    setState(() {
      netstat = false;
    });
  }

  void switchAsset(value) {
    print(value);
  }

  void showMandatory() async {
    if (currentMandatoryPeriod == 0 || mandatoryInterval.text == null || mandatoryInterval.text == '') {
      return;
    }
    await getCheckPeriod(3);
    showPeriodSheet('一年内计划强检');
  }

  void showPatrol() async {
    if (currentPatrolPeriod == 0 || patrolPeriod.text == null || patrolPeriod.text == '') {
      return;
    }
    await getCheckPeriod(4);
    showPeriodSheet('一年内计划巡检');
  }

  void showMaintain() async {
    if (currentMaintainPeriod == 0 || maintainPeriod.text == null || maintainPeriod.text == '') {
      return;
    }
    await getCheckPeriod(2);
    showPeriodSheet('一年内计划保养');
  }

  void showCorrection() async {
    if (currentCorrectionPeriod == 0 || correctionPeriod.text == null || correctionPeriod.text == '') {
      return;
    }
    await getCheckPeriod(5);
    showPeriodSheet('一年内计划校准');
  }

  void getFujiClass1() async {
    Map resp = await HttpRequest.request(
      '/equipment/GetFujiClass1ByEquipmentClass',
      method: HttpRequest.GET,
      params: {
        'equipmentClass1': classCode1==""?00:classCode1,
        'equipmentClass2': classCode2==""?00:classCode2
      }
    );
    if (resp['ResultCode'] == '00') {
      setState(() {
        fujiClass1 = resp['Data']['Name'];
      });
    }
  }

  void getFujiClass2() async {
    Map resp = await HttpRequest.request(
      '/equipment/GetFujiClass2ByEqptClass',
      method: HttpRequest.GET,
      params: {
        'equipmentClass1': classCode1==""?00:classCode1,
        'equipmentClass2': classCode2==""?00:classCode2
      }
    );
    if (resp['ResultCode'] == '00') {
      log("fuji 2 list:${resp['Data']}");
      fujiClass2List = resp['Data'];
      int ind = fujiClass2List.indexWhere((item) => item['ID'] == -1);
      //if (ind < 0) {
      //  fujiClass2List.add({
      //    'ID': -1,
      //    'Name': ''
      //  });
      //}
      setState(() {
        fujiClass2List = fujiClass2List;
      });
    }
  }

  void getFujiComponent() async {
    Map resp = await HttpRequest.request(
      '/InvComponent/QueryComponentsByFujiClass2ID',
      method: HttpRequest.GET,
      params: {
        'fujiClass2ID': fujiClass2,
        'componentTypeID': 3
      }
    );
    if (resp['ResultCode'] == '00') {
      setState(() {
        fujiClass2Components = resp['Data'];
      });
    }
  }

  Future<Null> pickDate<T>(BuildContext context, initialTime) async {
    DateTime _time;
    _time = DateTime.tryParse(initialTime)??DateTime.now();
    DatePicker.showDatePicker(
      context,
      pickerTheme: DateTimePickerTheme(
        showTitle: true,
        confirm: Text('确认', style: TextStyle(color: Colors.blueAccent)),
        cancel: Text('取消', style: TextStyle(color: Colors.redAccent)),
      ),
      minDateTime: DateTime.parse('2000-01-01'),
      maxDateTime: DateTime.now().add(Duration(days: 365*10)),
      initialDateTime: _time,
      dateFormat: 'yyyy-MM-dd',
      locale: DateTimePickerLocale.en_us,
      onClose: () => print(""),
      onCancel: () => print('onCancel'),
      onChange: (dateTime, List<int> index) {
      },
      onConfirm: (dateTime, List<int> index) {
        var _date = formatDate(dateTime, [yyyy, '-', mm, '-', dd]);
        setState(() {
          initialTime = _date;
        });
      },
    );
    //var val = await showDatePicker(
    //    context: context,
    //    initialDate: _time,
    //    firstDate:
    //        new DateTime.now().subtract(new Duration(days: 3650)), // 减 30 天
    //    lastDate: new DateTime.now().add(new Duration(days: 3650)), // 加 30 天
    //    locale: Locale('zh'));
    //return val==null?initialTime:val.toString().split(' ')[0];
  }

  List<Widget> _buildBasicInfo() {
    List<Widget> _list = [];
    switch (widget.equipmentType) {
      case EquipmentType.MEDICAL:
        _list.addAll([
          BuildWidget.buildRow('系统编号', oid),
          widget.editable?BuildWidget.buildInput('设备名称', name, lines: 1, focusNode: _focusEquip[0], required: true):BuildWidget.buildRow('设备名称', name.text),
          widget.editable?BuildWidget.buildInput('设备型号', equipmentCode, lines: 1, focusNode: _focusEquip[1], required: true):BuildWidget.buildRow('设备型号', equipmentCode.text),
          widget.editable?BuildWidget.buildInput('设备序列号', serialCode, lines: 1, focusNode: _focusEquip[2], required: true):BuildWidget.buildRow('设备序列号', serialCode.text),
          widget.editable?new Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: new Row(
              children: <Widget>[
                new Expanded(
                  flex: 4,
                  child: new Wrap(
                    alignment: WrapAlignment.end,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      new Text(
                        '*',
                        style: new TextStyle(
                            color: Colors.red
                        ),
                      ),
                      new Text(
                        '设备厂商',
                        style: new TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.w600),
                      )
                    ],
                  ),
                ),
                new Expanded(
                  flex: 1,
                  child: new Text(
                    '：',
                    style: new TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                new Expanded(
                  flex: 4,
                  child: new Text(
                    manufacturer == null ? '' : manufacturer['Name'],
                    style: new TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w400,
                        color: Colors.black54),
                  ),
                ),
                new Expanded(
                    flex: 2,
                    child: new IconButton(
                        focusNode: _focusOther[0],
                        icon: Icon(Icons.search),
                        onPressed: () async {
                          FocusScope.of(context).requestFocus(new FocusNode());
                          final _searchResult = await Navigator.of(context).push(new MaterialPageRoute(builder: (_) => SearchLazy(searchType: SearchType.MANUFACTURER,)));
                          print(_searchResult);
                          if (_searchResult != null &&
                              _searchResult != 'null') {
                            setState(() {
                              manufacturer = jsonDecode(_searchResult);
                            });
                          }
                        })),
              ],
            ),
          ):BuildWidget.buildRow('设备厂商', manufacturer==null?'':manufacturer['Name']),
          widget.editable?new Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: new Row(
              children: <Widget>[
                new Expanded(
                  flex: 4,
                  child: new Wrap(
                    alignment: WrapAlignment.end,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      new Text(
                        '*',
                        style: new TextStyle(
                            color: Colors.red
                        ),
                      ),
                      new Text(
                        '标准响应时间',
                        style: new TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.w600),
                      )
                    ],
                  ),
                ),
                new Expanded(
                  flex: 1,
                  child: new Text(
                    '：',
                    style: new TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                new Expanded(
                  flex: 4,
                  child: new TextField(
                    controller: responseTime,
                    maxLines: 1,
                    maxLength: 3,
                    focusNode: _focusEquip[3],
                    keyboardType: TextInputType.numberWithOptions(),
                    decoration: InputDecoration(
                      fillColor: Color(0xfff0f0f0),
                      filled: true,
                    ),
                  ),
                ),
                new Expanded(
                    flex: 2,
                    child: new Text(
                      ' 分',
                      style: new TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600
                      ),
                    )
                ),
              ],
            ),
          ):BuildWidget.buildRow('标准响应时间', '${responseTime.text} 分'),
          widget.editable?BuildWidget.buildDropdown('等级', currentClass, dropdownClass, changeClass, context: context):BuildWidget.buildRow('等级', currentClass),
          widget.editable&&isAdmin?BuildWidget.buildDropdown('设备类别(I)', currentClass1, dropdownClass1, changeClass1, context: context):BuildWidget.buildRow('设备类别(I)', currentClass1==null?'':currentClass1),
          widget.editable&&isAdmin?BuildWidget.buildDropdown('设备类别(II)', currentClass2, dropdownClass2, changeClass2, context: context):BuildWidget.buildRow('设备类别(II)', currentClass2==null?'':currentClass2),
          widget.editable&&isAdmin?BuildWidget.buildDropdown('设备类别(III)', currentClass3, dropdownClass3, changeClass3, context: context):BuildWidget.buildRow('设备类别(III)', currentClass3==null?'':currentClass3),
          BuildWidget.buildRow('分类编码', classCode1+classCode2+classCode3),
          widget.editable&&isAdmin?BuildWidget.buildRadio('整包范围', serviceScope, currentServiceScope, changeServiceScope):BuildWidget.buildRow('整包范围', currentServiceScope),
          widget.editable?BuildWidget.buildInput('品牌', brand, lines: 1, focusNode: _focusEquip[10]):BuildWidget.buildRow('品牌', brand.text),
          widget.editable?BuildWidget.buildInput('备注', comments, lines: 1, maxLength: 100, focusNode: _focusEquip[11]):BuildWidget.buildRow('备注', comments.text),
          widget.editable?new Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: new Row(
              children: <Widget>[
                new Expanded(
                  flex: 4,
                  child: new Wrap(
                    alignment: WrapAlignment.end,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      new Text(
                        '出厂日期',
                        style: new TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.w600),
                      )
                    ],
                  ),
                ),
                new Expanded(
                  flex: 1,
                  child: new Text(
                    '：',
                    style: new TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                new Expanded(
                  flex: 4,
                  child: new Text(
                    manufacturingDate,
                    style: new TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w400,
                        color: Colors.black54
                    ),
                  ),
                ),
                new Expanded(
                  flex: 2,
                  child: new IconButton(
                      icon: Icon(Icons.calendar_today, color: AppConstants.AppColors['btn_main'],),
                      onPressed: () async {
                        FocusScope.of(context).requestFocus(new FocusNode());
                        var _time = DateTime.tryParse(manufacturingDate)??DateTime.now();
                        DatePicker.showDatePicker(
                          context,
                          pickerTheme: DateTimePickerTheme(
                            showTitle: true,
                            confirm: Text('确认', style: TextStyle(color: Colors.blueAccent)),
                            cancel: Text('取消', style: TextStyle(color: Colors.redAccent)),
                          ),
                          minDateTime: DateTime.now().add(Duration(days: -7300)),
                          maxDateTime: DateTime.now().add(Duration(days: 365*10)),
                          initialDateTime: _time,
                          dateFormat: 'yyyy-MM-dd',
                          locale: DateTimePickerLocale.en_us,
                          onClose: () => print(""),
                          onCancel: () => print('onCancel'),
                          onChange: (dateTime, List<int> index) {
                          },
                          onConfirm: (dateTime, List<int> index) {
                            var _date = formatDate(dateTime, [yyyy, '-', mm, '-', dd]);
                            setState(() {
                              manufacturingDate = _date;
                            });
                          },
                        );
                      }),
                ),
              ],
            ),
          ):BuildWidget.buildRow('出厂日期', displayDate(manufacturingDate)),
          BuildWidget.buildRow("富士I类", fujiClass1??''),
          widget.editable?BuildWidget.buildDropdownNew("富士II类", fujiClass2, fujiClass2List, (val) => setState((){fujiClass2=val; getFujiComponent();}), required: true):BuildWidget.buildRow("富士II类", fujiClass2Name??'')
        ]);
        break;
      case EquipmentType.MEASURE:
        _list.addAll([
          BuildWidget.buildRow('系统编号', oid),
          widget.editable?BuildWidget.buildInput('器具名称', name, lines: 1, focusNode: _focusEquip[0], required: true):BuildWidget.buildRow('器具名称', name.text),
          widget.editable?BuildWidget.buildInput('器具型号', equipmentCode, lines: 1, focusNode: _focusEquip[1], required: true):BuildWidget.buildRow('器具型号', equipmentCode.text),
          widget.editable?BuildWidget.buildInput('器具序列号', serialCode, lines: 1, focusNode: _focusEquip[2], required: true):BuildWidget.buildRow('器具序列号', serialCode.text),
          widget.editable?new Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: new Row(
              children: <Widget>[
                new Expanded(
                  flex: 4,
                  child: new Wrap(
                    alignment: WrapAlignment.end,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      new Text(
                        '*',
                        style: new TextStyle(
                            color: Colors.red
                        ),
                      ),
                      new Text(
                        '器具厂商',
                        style: new TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.w600),
                      )
                    ],
                  ),
                ),
                new Expanded(
                  flex: 1,
                  child: new Text(
                    '：',
                    style: new TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                new Expanded(
                  flex: 4,
                  child: new Text(
                    manufacturer == null ? '' : manufacturer['Name'],
                    style: new TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w400,
                        color: Colors.black54),
                  ),
                ),
                new Expanded(
                    flex: 2,
                    child: new IconButton(
                        focusNode: _focusOther[0],
                        icon: Icon(Icons.search),
                        onPressed: () async {
                          FocusScope.of(context).requestFocus(new FocusNode());
                          final _searchResult = await Navigator.of(context).push(new MaterialPageRoute(builder: (_) => SearchLazy(searchType: SearchType.MANUFACTURER,)));
                          print(_searchResult);
                          if (_searchResult != null &&
                              _searchResult != 'null') {
                            setState(() {
                              manufacturer = jsonDecode(_searchResult);
                            });
                          }
                        })),
              ],
            ),
          ):BuildWidget.buildRow('器具厂商', manufacturer==null?'':manufacturer['Name']),
          widget.editable?new Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: new Row(
              children: <Widget>[
                new Expanded(
                  flex: 4,
                  child: new Wrap(
                    alignment: WrapAlignment.end,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      new Text(
                        '*',
                        style: new TextStyle(
                            color: Colors.red
                        ),
                      ),
                      new Text(
                        '标准响应时间',
                        style: new TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.w600),
                      )
                    ],
                  ),
                ),
                new Expanded(
                  flex: 1,
                  child: new Text(
                    '：',
                    style: new TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                new Expanded(
                  flex: 4,
                  child: new TextField(
                    controller: responseTime,
                    maxLines: 1,
                    maxLength: 3,
                    focusNode: _focusEquip[3],
                    keyboardType: TextInputType.numberWithOptions(),
                    decoration: InputDecoration(
                      fillColor: Color(0xfff0f0f0),
                      filled: true,
                    ),
                  ),
                ),
                new Expanded(
                    flex: 2,
                    child: new Text(
                      ' 分',
                      style: new TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600
                      ),
                    )
                ),
              ],
            ),
          ):BuildWidget.buildRow('标准响应时间', '${responseTime.text} 分'),
          widget.editable&&isAdmin?BuildWidget.buildRadio('整包范围', serviceScope, currentServiceScope, changeServiceScope):BuildWidget.buildRow('整包范围', currentServiceScope),
          widget.editable?BuildWidget.buildInput('品牌', brand, lines: 1, focusNode: _focusEquip[10]):BuildWidget.buildRow('品牌', brand.text),
          widget.editable?BuildWidget.buildInput('备注', comments, lines: 1, maxLength: 100, focusNode: _focusEquip[11]):BuildWidget.buildRow('备注', comments.text),
          widget.editable?new Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: new Row(
              children: <Widget>[
                new Expanded(
                  flex: 4,
                  child: new Wrap(
                    alignment: WrapAlignment.end,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      new Text(
                        '出厂日期',
                        style: new TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.w600),
                      )
                    ],
                  ),
                ),
                new Expanded(
                  flex: 1,
                  child: new Text(
                    '：',
                    style: new TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                new Expanded(
                  flex: 4,
                  child: new Text(
                    manufacturingDate,
                    style: new TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w400,
                        color: Colors.black54
                    ),
                  ),
                ),
                new Expanded(
                  flex: 2,
                  child: new IconButton(
                      icon: Icon(Icons.calendar_today, color: AppConstants.AppColors['btn_main'],),
                      onPressed: () async {
                        FocusScope.of(context).requestFocus(new FocusNode());
                        var _time = DateTime.tryParse(manufacturingDate)??DateTime.now();
                        DatePicker.showDatePicker(
                          context,
                          pickerTheme: DateTimePickerTheme(
                            showTitle: true,
                            confirm: Text('确认', style: TextStyle(color: Colors.blueAccent)),
                            cancel: Text('取消', style: TextStyle(color: Colors.redAccent)),
                          ),
                          minDateTime: DateTime.now().add(Duration(days: -7300)),
                          maxDateTime: DateTime.now().add(Duration(days: 365*10)),
                          initialDateTime: _time,
                          dateFormat: 'yyyy-MM-dd',
                          locale: DateTimePickerLocale.en_us,
                          onClose: () => print(""),
                          onCancel: () => print('onCancel'),
                          onChange: (dateTime, List<int> index) {
                          },
                          onConfirm: (dateTime, List<int> index) {
                            var _date = formatDate(dateTime, [yyyy, '-', mm, '-', dd]);
                            setState(() {
                              manufacturingDate = _date;
                            });
                          },
                        );
                      }),
                ),
              ],
            ),
          ):BuildWidget.buildRow('出厂日期', displayDate(manufacturingDate)),
        ]);
        break;
      case EquipmentType.OTHER:
        _list.addAll([
          BuildWidget.buildRow('系统编号', oid),
          widget.editable?BuildWidget.buildInput('设备名称', name, lines: 1, focusNode: _focusEquip[0], required: true):BuildWidget.buildRow('设备名称', name.text),
          widget.editable?BuildWidget.buildInput('设备型号', equipmentCode, lines: 1, focusNode: _focusEquip[1], required: true):BuildWidget.buildRow('设备型号', equipmentCode.text),
          widget.editable?BuildWidget.buildInput('设备序列号', serialCode, lines: 1, focusNode: _focusEquip[2], required: true):BuildWidget.buildRow('设备序列号', serialCode.text),
          widget.editable?new Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: new Row(
              children: <Widget>[
                new Expanded(
                  flex: 4,
                  child: new Wrap(
                    alignment: WrapAlignment.end,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      new Text(
                        '*',
                        style: new TextStyle(
                            color: Colors.red
                        ),
                      ),
                      new Text(
                        '设备厂商',
                        style: new TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.w600),
                      )
                    ],
                  ),
                ),
                new Expanded(
                  flex: 1,
                  child: new Text(
                    '：',
                    style: new TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                new Expanded(
                  flex: 4,
                  child: new Text(
                    manufacturer == null ? '' : manufacturer['Name'],
                    style: new TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w400,
                        color: Colors.black54),
                  ),
                ),
                new Expanded(
                    flex: 2,
                    child: new IconButton(
                        focusNode: _focusOther[0],
                        icon: Icon(Icons.search),
                        onPressed: () async {
                          FocusScope.of(context).requestFocus(new FocusNode());
                          final _searchResult = await Navigator.of(context).push(new MaterialPageRoute(builder: (_) => SearchLazy(searchType: SearchType.MANUFACTURER,)));
                          print(_searchResult);
                          if (_searchResult != null &&
                              _searchResult != 'null') {
                            setState(() {
                              manufacturer = jsonDecode(_searchResult);
                            });
                          }
                        })),
              ],
            ),
          ):BuildWidget.buildRow('设备厂商', manufacturer==null?'':manufacturer['Name']),
          widget.editable?new Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: new Row(
              children: <Widget>[
                new Expanded(
                  flex: 4,
                  child: new Wrap(
                    alignment: WrapAlignment.end,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      new Text(
                        '*',
                        style: new TextStyle(
                            color: Colors.red
                        ),
                      ),
                      new Text(
                        '标准响应时间',
                        style: new TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.w600),
                      )
                    ],
                  ),
                ),
                new Expanded(
                  flex: 1,
                  child: new Text(
                    '：',
                    style: new TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                new Expanded(
                  flex: 4,
                  child: new TextField(
                    controller: responseTime,
                    maxLines: 1,
                    maxLength: 3,
                    focusNode: _focusEquip[3],
                    keyboardType: TextInputType.numberWithOptions(),
                    decoration: InputDecoration(
                      fillColor: Color(0xfff0f0f0),
                      filled: true,
                    ),
                  ),
                ),
                new Expanded(
                    flex: 2,
                    child: new Text(
                      ' 分',
                      style: new TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600
                      ),
                    )
                ),
              ],
            ),
          ):BuildWidget.buildRow('标准响应时间', '${responseTime.text} 分'),
          widget.editable&&isAdmin?BuildWidget.buildRadio('整包范围', serviceScope, currentServiceScope, changeServiceScope):BuildWidget.buildRow('整包范围', currentServiceScope),
          widget.editable?BuildWidget.buildInput('品牌', brand, lines: 1, focusNode: _focusEquip[10]):BuildWidget.buildRow('品牌', brand.text),
          widget.editable?BuildWidget.buildInput('备注', comments, lines: 1, maxLength: 100, focusNode: _focusEquip[11]):BuildWidget.buildRow('备注', comments.text),
          widget.editable?new Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: new Row(
              children: <Widget>[
                new Expanded(
                  flex: 4,
                  child: new Wrap(
                    alignment: WrapAlignment.end,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      new Text(
                        '出厂日期',
                        style: new TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.w600),
                      )
                    ],
                  ),
                ),
                new Expanded(
                  flex: 1,
                  child: new Text(
                    '：',
                    style: new TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                new Expanded(
                  flex: 4,
                  child: new Text(
                    manufacturingDate,
                    style: new TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w400,
                        color: Colors.black54
                    ),
                  ),
                ),
                new Expanded(
                  flex: 2,
                  child: new IconButton(
                      icon: Icon(Icons.calendar_today, color: AppConstants.AppColors['btn_main'],),
                      onPressed: () async {
                        FocusScope.of(context).requestFocus(new FocusNode());
                        var _time = DateTime.tryParse(manufacturingDate)??DateTime.now();
                        DatePicker.showDatePicker(
                          context,
                          pickerTheme: DateTimePickerTheme(
                            showTitle: true,
                            confirm: Text('确认', style: TextStyle(color: Colors.blueAccent)),
                            cancel: Text('取消', style: TextStyle(color: Colors.redAccent)),
                          ),
                          minDateTime: DateTime.now().add(Duration(days: -7300)),
                          maxDateTime: DateTime.now().add(Duration(days: 365*10)),
                          initialDateTime: _time,
                          dateFormat: 'yyyy-MM-dd',
                          locale: DateTimePickerLocale.en_us,
                          onClose: () => print(""),
                          onCancel: () => print('onCancel'),
                          onChange: (dateTime, List<int> index) {
                          },
                          onConfirm: (dateTime, List<int> index) {
                            var _date = formatDate(dateTime, [yyyy, '-', mm, '-', dd]);
                            setState(() {
                              manufacturingDate = _date;
                            });
                          },
                        );
                      }),
                ),
              ],
            ),
          ):BuildWidget.buildRow('出厂日期', displayDate(manufacturingDate)),
        ]);
        break;
    }

    return _list;
  }

  List<Widget> _buildAssetInfo() {
    List<Widget> _list = [];
    _list.addAll([
      widget.editable?BuildWidget.buildRadio('固定资产', isFixed, currentFixed, changeValue):BuildWidget.buildRow('固定资产', currentFixed),
      widget.editable?BuildWidget.buildDropdown('资产等级', currentLevel, dropdownLevel, changeLevel, context: context):BuildWidget.buildRow('资产等级', currentLevel),
      widget.editable&&!autoAssetCode?BuildWidget.buildInput('资产编号', assetCode, lines: 1, focusNode: _focusEquip[4], required: true):BuildWidget.buildRow('资产编号', widget.editable&&widget.equipment==null?'系统自动生成':assetCode.text),
      widget.editable?BuildWidget.buildInput('折旧年限(年)', depreciationYears, lines: 1, maxLength: 3, inputType: TextInputType.number, focusNode: _focusEquip[12]):BuildWidget.buildRow('折旧年限(年)', depreciationYears.text),
      widget.editable?new Padding(
        padding: EdgeInsets.symmetric(vertical: 5.0),
        child: new Row(
          children: <Widget>[
            new Expanded(
              flex: 4,
              child: new Wrap(
                alignment: WrapAlignment.end,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  new Text(
                    '注册证有效日期',
                    style: new TextStyle(
                        fontSize: 16.0, fontWeight: FontWeight.w600),
                  )
                ],
              ),
            ),
            new Expanded(
              flex: 1,
              child: new Text(
                '：',
                style: new TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            new Expanded(
              flex: 6,
              child: new Column(
                children: <Widget>[
                  new Row(
                    children: <Widget>[
                      new Expanded(
                        flex: 4,
                        child: new Text(
                          validationStartDate,
                          style: new TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w400,
                              color: Colors.black54
                          ),
                        ),
                      ),
                      new Expanded(
                        flex: 2,
                        child: new IconButton(
                            icon: Icon(Icons.calendar_today, color: AppConstants.AppColors['btn_main'],),
                            onPressed: () async {
                              FocusScope.of(context).requestFocus(new FocusNode());
                              var _time = DateTime.tryParse(validationStartDate)??DateTime.now();
                              DatePicker.showDatePicker(
                                context,
                                pickerTheme: DateTimePickerTheme(
                                  showTitle: true,
                                  confirm: Text('确认', style: TextStyle(color: Colors.blueAccent)),
                                  cancel: Text('取消', style: TextStyle(color: Colors.redAccent)),
                                ),
                                minDateTime: DateTime.now().add(Duration(days: -7300)),
                                maxDateTime: DateTime.now().add(Duration(days: 365*10)),
                                initialDateTime: _time,
                                dateFormat: 'yyyy-MM-dd',
                                locale: DateTimePickerLocale.en_us,
                                onClose: () => print(""),
                                onCancel: () => print('onCancel'),
                                onChange: (dateTime, List<int> index) {
                                },
                                onConfirm: (dateTime, List<int> index) {
                                  var _date = formatDate(dateTime, [yyyy, '-', mm, '-', dd]);
                                  setState(() {
                                    validationStartDate = _date;
                                  });
                                },
                              );
                            }
                        ),
                      )
                    ],
                  ),
                  new Row(
                    children: <Widget>[
                      new Expanded(
                          flex: 4,
                          child: Focus(
                            focusNode: _focusOther[1],
                            child: new Text(
                              validationEndDate,
                              style: new TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black54
                              ),
                            ),
                          )
                      ),
                      new Expanded(
                        flex: 2,
                        child: new IconButton(
                            icon: Icon(Icons.calendar_today, color: AppConstants.AppColors['btn_main'],),
                            onPressed: () async {
                              FocusScope.of(context).requestFocus(new FocusNode());
                              var _time = DateTime.tryParse(validationEndDate)??DateTime.now();
                              DatePicker.showDatePicker(
                                context,
                                pickerTheme: DateTimePickerTheme(
                                  showTitle: true,
                                  confirm: Text('确认', style: TextStyle(color: Colors.blueAccent)),
                                  cancel: Text('取消', style: TextStyle(color: Colors.redAccent)),
                                ),
                                minDateTime: DateTime.now().add(Duration(days: -7300)),
                                maxDateTime: DateTime.now().add(Duration(days: 365*10)),
                                initialDateTime: _time,
                                dateFormat: 'yyyy-MM-dd',
                                locale: DateTimePickerLocale.en_us,
                                onClose: () => print(""),
                                onCancel: () => print('onCancel'),
                                onChange: (dateTime, List<int> index) {
                                },
                                onConfirm: (dateTime, List<int> index) {
                                  var _date = formatDate(dateTime, [yyyy, '-', mm, '-', dd]);
                                  setState(() {
                                    validationEndDate = _date;
                                  });
                                },
                              );
                            }
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ):BuildWidget.buildRow('注册证有效日期', '${displayDate(validationStartDate)}\n${displayDate(validationEndDate)}'),
    ]);
    switch (widget.equipmentType) {
      case EquipmentType.MEDICAL:
        _list.addAll([]);
        break;
      case EquipmentType.MEASURE:
        _list.addAll([]);
        break;
      case EquipmentType.OTHER:
        _list.addAll([]);
        break;
    }

    return _list;
  }

  List<Widget> _buildPurchaseInfo() {
    List<Widget> _list = [];
    _list.addAll([
      widget.editable?BuildWidget.buildInput('销售合同名称', contractName, lines: 1, focusNode: _focusEquip[13]):BuildWidget.buildRow('销售合同名称', contractName.text),
      widget.editable?BuildWidget.buildInput('购入方式', purchaseWay, lines: 1, focusNode: _focusEquip[14]):BuildWidget.buildRow('购入方式', purchaseWay.text),
      widget.editable?new Padding(
        padding: EdgeInsets.symmetric(vertical: 5.0),
        child: new Row(
          children: <Widget>[
            new Expanded(
              flex: 4,
              child: new Wrap(
                alignment: WrapAlignment.end,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  new Text(
                    widget.equipmentType==EquipmentType.MEDICAL?'*':'',
                    style: new TextStyle(
                        color: Colors.red
                    ),
                  ),
                  new Text(
                    '采购日期',
                    style: new TextStyle(
                        fontSize: 16.0, fontWeight: FontWeight.w600),
                  )
                ],
              ),
            ),
            new Expanded(
              flex: 1,
              child: new Text(
                '：',
                style: new TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            new Expanded(
              flex: 4,
              child: new Text(
                purchaseDate,
                style: new TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w400,
                    color: Colors.black54
                ),
              ),
            ),
            new Expanded(
              flex: 2,
              child: new IconButton(
                  icon: Icon(Icons.calendar_today, color: AppConstants.AppColors['btn_main'],),
                  focusNode: _focusOther[2],
                  onPressed: () async {
                    FocusScope.of(context).requestFocus(new FocusNode());
                    var _time = DateTime.tryParse(purchaseDate)??DateTime.now();
                    DatePicker.showDatePicker(
                      context,
                      pickerTheme: DateTimePickerTheme(
                        showTitle: true,
                        confirm: Text('确认', style: TextStyle(color: Colors.blueAccent)),
                        cancel: Text('取消', style: TextStyle(color: Colors.redAccent)),
                      ),
                      minDateTime: DateTime.now().add(Duration(days: -7300)),
                      maxDateTime: DateTime.now().add(Duration(days: 365*10)),
                      initialDateTime: _time,
                      dateFormat: 'yyyy-MM-dd',
                      locale: DateTimePickerLocale.en_us,
                      onClose: () => print(""),
                      onCancel: () => print('onCancel'),
                      onChange: (dateTime, List<int> index) {
                      },
                      onConfirm: (dateTime, List<int> index) {
                        var _date = formatDate(dateTime, [yyyy, '-', mm, '-', dd]);
                        setState(() {
                          purchaseDate = _date;
                        });
                      },
                    );
                  }),
            ),
          ],
        ),
      ):BuildWidget.buildRow('采购日期', displayDate(purchaseDate)),
      widget.editable?new Padding(
        padding: EdgeInsets.symmetric(vertical: 5.0),
        child: new Row(
          children: <Widget>[
            new Expanded(
              flex: 4,
              child: new Wrap(
                alignment: WrapAlignment.end,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  new Text(
                    '经销商',
                    style: new TextStyle(
                        fontSize: 16.0, fontWeight: FontWeight.w600),
                  )
                ],
              ),
            ),
            new Expanded(
              flex: 1,
              child: new Text(
                '：',
                style: new TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            new Expanded(
                flex: 4,
                child: new Text(
                  supplier == null ? '' : supplier['Name'],
                  style: new TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w400,
                      color: Colors.black54),
                )),
            new Expanded(
                flex: 2,
                child: new IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () async {
                      FocusScope.of(context).requestFocus(new FocusNode());
                      final _searchResult = await Navigator.of(context).push(new MaterialPageRoute(builder: (_) => SearchLazy(searchType: SearchType.VENDOR,)));
                      print(_searchResult);
                      if (_searchResult != null &&
                          _searchResult != 'null') {
                        setState(() {
                          supplier = jsonDecode(_searchResult);
                        });
                      }
                    })),
          ],
        ),
      ):BuildWidget.buildRow('经销商', supplier==null?'':supplier['Name']),
      widget.editable?BuildWidget.buildInput('采购金额(元)', purchaseAmount, lines: 1, maxLength: 11, inputType: TextInputType.numberWithOptions(decimal: true), focusNode: _focusEquip[5]):BuildWidget.buildRow('采购金额（元）', CommonUtil.CurrencyForm(double.tryParse(purchaseAmount.text), times: 1, digits: 0)),
      widget.editable?BuildWidget.buildRadio(widget.equipmentType==EquipmentType.MEASURE?'器具产地':'设备产地', origin, currentOrigin, changeOrigin):BuildWidget.buildRow(widget.equipmentType==EquipmentType.MEASURE?'器具产地':'设备产地', currentOrigin),
    ]);
    switch (widget.equipmentType) {
      case EquipmentType.MEDICAL:
        _list.addAll([]);
        break;
      case EquipmentType.MEASURE:
        _list.addAll([]);
        break;
      case EquipmentType.OTHER:
        _list.addAll([]);
        break;
    }
    return _list;
  }

  List<Widget> _buildUsageInfo() {
    List<Widget> _list = [];

    switch (widget.equipmentType) {
      case EquipmentType.MEDICAL:
        _list.addAll([
        ]);
        break;
      case EquipmentType.MEASURE:
        _list.addAll([
          widget.editable?new Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: new Row(
              children: <Widget>[
                new Expanded(
                  flex: 4,
                  child: new Wrap(
                    alignment: WrapAlignment.end,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      new Text(
                        '',
                        style: new TextStyle(
                            color: Colors.red
                        ),
                      ),
                      new Text(
                        '关联设备',
                        style: new TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.w600),
                      )
                    ],
                  ),
                ),
                new Expanded(
                  flex: 1,
                  child: new Text(
                    '：',
                    style: new TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                new Expanded(
                  flex: 4,
                  child: new Text(
                    relatedEquipment == null ? '' : relatedEquipment['Name'],
                    style: new TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w400,
                        color: Colors.black54),
                  ),
                ),
                new Expanded(
                    flex: 2,
                    child: new IconButton(
                        focusNode: _focusOther[0],
                        icon: Icon(Icons.search),
                        onPressed: () async {
                          FocusScope.of(context).requestFocus(new FocusNode());
                          final _searchResult = await Navigator.of(context).push(new MaterialPageRoute(builder: (_) => SearchLazy(searchType: SearchType.DEVICE, onlyType: EquipmentType.MEDICAL,)));
                          print(_searchResult);
                          if (_searchResult != null &&
                              _searchResult != 'null') {
                            setState(() {
                              relatedEquipment = jsonDecode(_searchResult);
                            });
                          }
                        })),
              ],
            ),
          ):BuildWidget.buildRow('关联设备', relatedEquipment==null?"":relatedEquipment['Name']),
        ]);
        break;
      case EquipmentType.OTHER:
        _list.addAll([
        ]);
    }

    _list.addAll([
      widget.editable&&departments!=null?BuildWidget.buildDropdownWithSearch('使用科室', currentDepartment, dropdownDepartments, changeDepartment, search: searchDepartment, required: true):new Container(),
      !widget.editable?BuildWidget.buildRow('使用科室', currentDepartment):new Container(),
      widget.editable?BuildWidget.buildInput('安装地点', installSite, lines: 1, focusNode: _focusEquip[15]):BuildWidget.buildRow('安装地点', installSite.text),
      widget.editable?new Padding(
        padding: EdgeInsets.symmetric(vertical: 5.0),
        child: new Row(
          children: <Widget>[
            new Expanded(
              flex: 4,
              child: new Wrap(
                alignment: WrapAlignment.end,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  new Text(
                    '*',
                    style: new TextStyle(
                        color: Colors.red
                    ),
                  ),
                  new Text(
                    '安装日期',
                    style: new TextStyle(
                        fontSize: 16.0, fontWeight: FontWeight.w600),
                  )
                ],
              ),
            ),
            new Expanded(
              flex: 1,
              child: new Text(
                '：',
                style: new TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            new Expanded(
              flex: 4,
              child: new Text(
                installDate,
                style: new TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w400,
                    color: Colors.black54
                ),
              ),
            ),
            new Expanded(
              flex: 2,
              child: new IconButton(
                  icon: Icon(Icons.calendar_today, color: AppConstants.AppColors['btn_main'],),
                  focusNode: _focusOther[4],
                  onPressed: () async {
                    FocusScope.of(context).requestFocus(new FocusNode());
                    var _time = DateTime.tryParse(installDate)??DateTime.now();
                    DatePicker.showDatePicker(
                      context,
                      pickerTheme: DateTimePickerTheme(
                        showTitle: true,
                        confirm: Text('确认', style: TextStyle(color: Colors.blueAccent)),
                        cancel: Text('取消', style: TextStyle(color: Colors.redAccent)),
                      ),
                      minDateTime: DateTime.now().add(Duration(days: -7300)),
                      maxDateTime: DateTime.now().add(Duration(days: 365*10)),
                      initialDateTime: _time,
                      dateFormat: 'yyyy-MM-dd',
                      locale: DateTimePickerLocale.en_us,
                      onClose: () => print(""),
                      onCancel: () => print('onCancel'),
                      onChange: (dateTime, List<int> index) {
                      },
                      onConfirm: (dateTime, List<int> index) {
                        var _date = formatDate(dateTime, [yyyy, '-', mm, '-', dd]);
                        setState(() {
                          installDate = _date;
                        });
                      },
                    );
                  }),
            ),
          ],
        ),
      ):BuildWidget.buildRow('安装日期', displayDate(installDate)),
      widget.editable?new Padding(
        padding: EdgeInsets.symmetric(vertical: 5.0),
        child: new Row(
          children: <Widget>[
            new Expanded(
              flex: 4,
              child: new Wrap(
                alignment: WrapAlignment.end,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  new Text(
                    '启用日期',
                    style: new TextStyle(
                        fontSize: 16.0, fontWeight: FontWeight.w600),
                  )
                ],
              ),
            ),
            new Expanded(
              flex: 1,
              child: new Text(
                '：',
                style: new TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            new Expanded(
              flex: 4,
              child: new Text(
                usageDate,
                style: new TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w400,
                    color: Colors.black54
                ),
              ),
            ),
            new Expanded(
              flex: 2,
              child: new IconButton(
                  icon: Icon(Icons.calendar_today, color: AppConstants.AppColors['btn_main'],),
                  onPressed: () async {
                    FocusScope.of(context).requestFocus(new FocusNode());
                    var _time = DateTime.tryParse(usageDate)??DateTime.now();
                    DatePicker.showDatePicker(
                      context,
                      pickerTheme: DateTimePickerTheme(
                        showTitle: true,
                        confirm: Text('确认', style: TextStyle(color: Colors.blueAccent)),
                        cancel: Text('取消', style: TextStyle(color: Colors.redAccent)),
                      ),
                      minDateTime: DateTime.now().add(Duration(days: -7300)),
                      maxDateTime: DateTime.now().add(Duration(days: 365*10)),
                      initialDateTime: _time,
                      dateFormat: 'yyyy-MM-dd',
                      locale: DateTimePickerLocale.en_us,
                      onClose: () => print(""),
                      onCancel: () => print('onCancel'),
                      onChange: (dateTime, List<int> index) {
                      },
                      onConfirm: (dateTime, List<int> index) {
                        var _date = formatDate(dateTime, [yyyy, '-', mm, '-', dd]);
                        setState(() {
                          usageDate = _date;
                        });
                      },
                    );
                  }),
            ),
          ],
        ),
      ):BuildWidget.buildRow('启用日期', displayDate(usageDate)),
      widget.editable?BuildWidget.buildRadio('验收状态', checkStatus, currentCheck, changeCheck):BuildWidget.buildRow('验收状态', currentCheck),
      widget.editable?new Padding(
        padding: EdgeInsets.symmetric(vertical: 5.0),
        child: new Row(
          children: <Widget>[
            new Expanded(
              flex: 4,
              child: new Wrap(
                alignment: WrapAlignment.end,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  new Text(
                    '验收时间',
                    style: new TextStyle(
                        fontSize: 16.0, fontWeight: FontWeight.w600),
                  )
                ],
              ),
            ),
            new Expanded(
              flex: 1,
              child: new Text(
                '：',
                style: new TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            new Expanded(
              flex: 4,
              child: new Text(
                checkDate,
                style: new TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w400,
                    color: Colors.black54
                ),
              ),
            ),
            new Expanded(
              flex: 2,
              child: new IconButton(
                  icon: Icon(Icons.calendar_today, color: AppConstants.AppColors['btn_main'],),
                  onPressed: () async {
                    FocusScope.of(context).requestFocus(new FocusNode());
                    var _time = DateTime.tryParse(checkDate)??DateTime.now();
                    DatePicker.showDatePicker(
                      context,
                      pickerTheme: DateTimePickerTheme(
                        showTitle: true,
                        confirm: Text('确认', style: TextStyle(color: Colors.blueAccent)),
                        cancel: Text('取消', style: TextStyle(color: Colors.redAccent)),
                      ),
                      minDateTime: DateTime.now().add(Duration(days: -7300)),
                      maxDateTime: DateTime.now().add(Duration(days: 365*10)),
                      initialDateTime: _time,
                      dateFormat: 'yyyy-MM-dd',
                      locale: DateTimePickerLocale.en_us,
                      onClose: () => print(""),
                      onCancel: () => print('onCancel'),
                      onChange: (dateTime, List<int> index) {
                      },
                      onConfirm: (dateTime, List<int> index) {
                        var _date = formatDate(dateTime, [yyyy, '-', mm, '-', dd]);
                        setState(() {
                          checkDate = _date;
                        });
                      },
                    );
                  }),
            ),
          ],
        ),
      ):BuildWidget.buildRow('验收日期', displayDate(checkDate)),
      widget.editable?BuildWidget.buildDropdown('使用状态', currentStatus, dropdownStatus, changeStatus, context: context):BuildWidget.buildRow('使用状态', currentStatus),
      widget.editable?BuildWidget.buildDropdown('设备状态', currentMachine, dropdownMachine, changeMachine, context: context):BuildWidget.buildRow('设备状态', currentMachine),
      widget.editable&&currentMachine=='已报废'?
      new Padding(
        padding: EdgeInsets.symmetric(vertical: 5.0),
        child: new Row(
          children: <Widget>[
            new Expanded(
              flex: 4,
              child: new Wrap(
                alignment: WrapAlignment.end,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  new Text(
                    '报废时间',
                    style: new TextStyle(
                        fontSize: 16.0, fontWeight: FontWeight.w600),
                  )
                ],
              ),
            ),
            new Expanded(
              flex: 1,
              child: new Text(
                '：',
                style: new TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            new Expanded(
              flex: 4,
              child: new Text(
                scrapDate,
                style: new TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w400,
                    color: Colors.black54
                ),
              ),
            ),
            new Expanded(
              flex: 2,
              child: new IconButton(
                  icon: Icon(Icons.calendar_today, color: AppConstants.AppColors['btn_main'],),
                  onPressed: () async {
                    FocusScope.of(context).requestFocus(new FocusNode());
                    var _time = DateTime.tryParse(scrapDate)??DateTime.now();
                    DatePicker.showDatePicker(
                      context,
                      pickerTheme: DateTimePickerTheme(
                        showTitle: true,
                        confirm: Text('确认', style: TextStyle(color: Colors.blueAccent)),
                        cancel: Text('取消', style: TextStyle(color: Colors.redAccent)),
                      ),
                      minDateTime: DateTime.now().add(Duration(days: -7300)),
                      maxDateTime: DateTime.now().add(Duration(days: 365*10)),
                      initialDateTime: _time,
                      dateFormat: 'yyyy-MM-dd',
                      locale: DateTimePickerLocale.en_us,
                      onClose: () => print(""),
                      onCancel: () => print('onCancel'),
                      onChange: (dateTime, List<int> index) {
                      },
                      onConfirm: (dateTime, List<int> index) {
                        var _date = formatDate(dateTime, [yyyy, '-', mm, '-', dd]);
                        setState(() {
                          scrapDate = _date;
                        });
                      },
                    );
                  }),
            ),
          ],
        ),
      ):new Container(),
      !widget.editable&&currentMachine=='已报废'?BuildWidget.buildRow('报废时间', displayDate(scrapDate)):new Container(),
      widget.editable?BuildWidget.buildDropdown('强检标记', currentMandatory, dropdownMandatory, changeMandatory, context: context):BuildWidget.buildRow('强检标记', currentMandatory),
      widget.editable?BuildWidget.buildDropdown('强检周期', currentMandatoryType, mandatoryTypes, changeMandatoryType, context: context):BuildWidget.buildRow('强检周期', currentMandatoryType),
      widget.editable&&currentMandatoryType=='固定日期'?new Padding(
        padding: EdgeInsets.symmetric(vertical: 5.0),
        child: new Row(
          children: <Widget>[
            new Expanded(
              flex: 4,
              child: new Wrap(
                alignment: WrapAlignment.end,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  new Text(
                    '强检时间',
                    style: new TextStyle(
                        fontSize: 16.0, fontWeight: FontWeight.w600),
                  )
                ],
              ),
            ),
            new Expanded(
              flex: 1,
              child: new Text(
                '：',
                style: new TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            new Expanded(
              flex: 4,
              child: new Text(
                mandatoryDate,
                style: new TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w400,
                    color: Colors.black54
                ),
              ),
            ),
            new Expanded(
              flex: 2,
              child: new IconButton(
                  icon: Icon(Icons.calendar_today, color: AppConstants.AppColors['btn_main'],),
                  onPressed: () async {
                    FocusScope.of(context).requestFocus(new FocusNode());
                    var _time = DateTime.tryParse(mandatoryDate)??DateTime.now().add(Duration(days: 30));
                    DateTime _date = DateTime.now();
                    DatePicker.showDatePicker(
                      context,
                      pickerTheme: DateTimePickerTheme(
                        showTitle: true,
                        confirm: Text('确认', style: TextStyle(color: Colors.blueAccent)),
                        cancel: Text('取消', style: TextStyle(color: Colors.redAccent)),
                      ),
                      minDateTime: DateTime(_date.year, _date.month+1, _date.day),
                      maxDateTime: DateTime.now().add(Duration(days: 365*10)),
                      initialDateTime: _time,
                      dateFormat: 'yyyy-MM-dd',
                      locale: DateTimePickerLocale.en_us,
                      onClose: () => print(""),
                      onCancel: () => print('onCancel'),
                      onChange: (dateTime, List<int> index) {
                      },
                      onConfirm: (dateTime, List<int> index) {
                        var _date = formatDate(dateTime, [yyyy, '-', mm, '-', dd]);
                        setState(() {
                          mandatoryDate = _date;
                        });
                      },
                    );
                  }),
            ),
          ],
        ),
      ):Container(),
      !widget.editable&&currentMandatoryType=="固定日期"?BuildWidget.buildRow('强检时间', displayDate(mandatoryDate)):Container(),
      widget.editable&&currentMandatoryType=='周期'?BuildWidget.buildDropdownWithInput('强检周期', mandatoryInterval, currentMandatoryPeriod, periodTypeList, changeMandatoryPeriod, showMandatory, inputType: TextInputType.number, context: context):Container(),
      !widget.editable&&currentMandatoryType=='周期'?Row(
        children: <Widget>[
          new Expanded(
            flex: 4,
            child: new Wrap(
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                new Text(
                  '强检周期',
                  style: new TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600
                  ),
                )
              ],
            ),
          ),
          new Expanded(
            flex: 1,
            child: new Text(
              '：',
              style: new TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          new Expanded(
            flex: 4,
            child: new Text(
              currentMandatoryPeriod==1?'无强检':'${mandatoryInterval.text} ${periodTypeList.firstWhere((item) => item['ID']==currentMandatoryPeriod)['Name']}',
              style: new TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w400,
                  color: Colors.black54
              ),
            ),
          ),
          new Expanded(
            flex: 2,
            child: currentMandatoryPeriod==1?Container():IconButton(icon: Icon(Icons.calendar_today), onPressed: () async {
              await getCheckPeriod(3);
              showPeriodSheet('一年内计划强检');
            }),
          )
        ],
      ):Container(),
      widget.editable?BuildWidget.buildRadio('召回标记', recall, currentRecall, changeRecall):BuildWidget.buildRow('召回标记', currentRecall),
      widget.editable?new Padding(
        padding: EdgeInsets.symmetric(vertical: 5.0),
        child: new Row(
          children: <Widget>[
            new Expanded(
              flex: 4,
              child: new Wrap(
                alignment: WrapAlignment.end,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  new Text(
                    '召回时间',
                    style: new TextStyle(
                        fontSize: 16.0, fontWeight: FontWeight.w600),
                  )
                ],
              ),
            ),
            new Expanded(
              flex: 1,
              child: new Text(
                '：',
                style: new TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            new Expanded(
              flex: 4,
              child: new Text(
                recallDate,
                style: new TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w400,
                    color: Colors.black54
                ),
              ),
            ),
            new Expanded(
              flex: 2,
              child: new IconButton(
                  icon: Icon(Icons.calendar_today, color: AppConstants.AppColors['btn_main'],),
                  onPressed: () async {
                    FocusScope.of(context).requestFocus(new FocusNode());
                    var _time = DateTime.tryParse(recallDate)??DateTime.now().add(Duration(days: 30));
                    DateTime _date = DateTime.now();
                    DatePicker.showDatePicker(
                      context,
                      pickerTheme: DateTimePickerTheme(
                        showTitle: true,
                        confirm: Text('确认', style: TextStyle(color: Colors.blueAccent)),
                        cancel: Text('取消', style: TextStyle(color: Colors.redAccent)),
                      ),
                      minDateTime: DateTime(_date.year, _date.month+1, _date.day),
                      maxDateTime: DateTime.now().add(Duration(days: 365*10)),
                      initialDateTime: _time,
                      dateFormat: 'yyyy-MM-dd',
                      locale: DateTimePickerLocale.en_us,
                      onClose: () => print(""),
                      onCancel: () => print('onCancel'),
                      onChange: (dateTime, List<int> index) {
                      },
                      onConfirm: (dateTime, List<int> index) {
                        var _date = formatDate(dateTime, [yyyy, '-', mm, '-', dd]);
                        setState(() {
                          recallDate = _date;
                        });
                      },
                    );
                  }),
            ),
          ],
        ),
      ):BuildWidget.buildRow('召回时间', displayDate(recallDate)),
      widget.editable?BuildWidget.buildDropdownWithInput('巡检周期', patrolPeriod, currentPatrolPeriod, periodTypeList, changePatrolPeriod, showPatrol, inputType: TextInputType.number, focusNode: _focusEquip[6], context: context):Row(
        children: <Widget>[
          new Expanded(
            flex: 4,
            child: new Wrap(
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                new Text(
                  '巡检周期',
                  style: new TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600
                  ),
                )
              ],
            ),
          ),
          new Expanded(
            flex: 1,
            child: new Text(
              '：',
              style: new TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          new Expanded(
            flex: 4,
            child: new Text(
              currentPatrolPeriod==0?'无巡检':'${patrolPeriod.text} ${periodTypeList.firstWhere((item) => item['ID']==currentPatrolPeriod)['Name']}',
              style: new TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w400,
                  color: Colors.black54
              ),
            ),
          ),
          new Expanded(
            flex: 2,
            child: currentPatrolPeriod==0?Container():IconButton(icon: Icon(Icons.calendar_today), onPressed: () async {
              print('check period');
              await getCheckPeriod(4);
              showPeriodSheet('一年内计划巡检');
            }),
          )
        ],
      ),
      widget.editable?BuildWidget.buildDropdownWithInput(
          '保养周期',
          maintainPeriod,
          currentMaintainPeriod,
          periodTypeList,
          changeMaintainPeriod,
          showMaintain,
          inputType: TextInputType.number, focusNode: _focusEquip[7], context: context):Row(
        children: <Widget>[
          new Expanded(
            flex: 4,
            child: new Wrap(
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                new Text(
                  '保养周期',
                  style: new TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600
                  ),
                )
              ],
            ),
          ),
          new Expanded(
            flex: 1,
            child: new Text(
              '：',
              style: new TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          new Expanded(
            flex: 4,
            child: new Text(
              currentMaintainPeriod==0?'无保养':'${maintainPeriod.text} ${periodTypeList.firstWhere((item) => item['ID']==currentMaintainPeriod)['Name']}',
              style: new TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w400,
                  color: Colors.black54
              ),
            ),
          ),
          new Expanded(
            flex: 2,
            child: currentMaintainPeriod==0?Container():IconButton(icon: Icon(Icons.calendar_today), onPressed: () async {
              print('check period');
              await getCheckPeriod(2);
              showPeriodSheet('一年内计划保养');
            }),
          )
        ],
      ),
      widget.editable?BuildWidget.buildDropdownWithInput(
          '校准周期',
          correctionPeriod,
          currentCorrectionPeriod,
          periodTypeList,
          changeCorrectionPeriod,
          showCorrection,
          inputType: TextInputType.number, focusNode: _focusEquip[8], context: context):Row(
        children: <Widget>[
          new Expanded(
            flex: 4,
            child: new Wrap(
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                new Text(
                  '校准周期',
                  style: new TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600
                  ),
                )
              ],
            ),
          ),
          new Expanded(
            flex: 1,
            child: new Text(
              '：',
              style: new TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          new Expanded(
            flex: 4,
            child: new Text(
              currentCorrectionPeriod==0?'无校准':'${correctionPeriod.text} ${periodTypeList.firstWhere((item) => item['ID']==currentCorrectionPeriod)['Name']}',
              style: new TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w400,
                  color: Colors.black54
              ),
            ),
          ),
          new Expanded(
            flex: 2,
            child: currentCorrectionPeriod==0?Container():IconButton(icon: Icon(Icons.calendar_today), onPressed: () async {
              print('check period');
              await getCheckPeriod(5);
              showPeriodSheet('一年内计划校准');
            }),
          )
        ],
      ),
    ]);

    return _list;
  }

  List<Widget> _buildComponent() {
    List<Widget> _list = [];
    _list.addAll(
      fujiClass2Components.asMap().keys.map((key) {
        return Card(
          child: Column(
            children: <Widget>[
              BuildWidget.buildRow('简称', fujiClass2Components[key]['Name']),
              BuildWidget.buildRow('描述', fujiClass2Components[key]['Description']),
              widget.editable?BuildWidget.buildInput('序列号', componentCodes, lines: 1, ):BuildWidget.buildRow('序列号', componentCodes.text),
              widget.editable?BuildWidget.buildInput('已使用秒次', componentSeconds, lines: 1, maxLength: 13, inputType: TextInputType.numberWithOptions(decimal: true)):BuildWidget.buildRow('已使用秒次', componentSeconds.text)
            ],
          ),
        );
      })
    );
    return _list;
  }

  List<Widget> _buildHisComponent() {
    List<Widget> _list = [];
    historyComponent.forEach((item) => _list.addAll([
      BuildWidget.buildRow('序列号', item['InvComponent']['SerialCode']),
      BuildWidget.buildRow('简称', item['InvComponent']['Component']['Name']),
      BuildWidget.buildRow('描述', item['InvComponent']['Component']['Description']),
      BuildWidget.buildRow('安装日期', formatDateString(item['InstalDate'].toString())),
      BuildWidget.buildRow('拆下日期', formatDateString(item['RemoveDate'].toString())),
      Divider(),
    ]));
    return _list;
  }

  List<Widget> _buildHistConsumable() {
    List<Widget> _list = [];
    historyConsumable.forEach((item) => _list.addAll([
      BuildWidget.buildRow('批次号', item['InvConsumable']['LotNum']),
      BuildWidget.buildRow('简称', item['InvConsumable']['Consumable']['Name']),
      BuildWidget.buildRow('描述', item['InvConsumable']['Consumable']['Description']),
      BuildWidget.buildRow('数量', item['Qty'].toString()),
      BuildWidget.buildRow('使用日期', formatDateString(item['UsedDate'].toString())),
    ]));
    return _list;
  }

  List<ExpansionPanel> buildExpansion(BuildContext context) {
    List<ExpansionPanel> _list = [];
    //device info
    _list.add(ExpansionPanel(canTapOnHeader: true,
        headerBuilder: (context, isExpanded) {
          return ListTile(
              leading: new Icon(
                Icons.info,
                size: 24.0,
                color: Colors.blue,
              ),
              title: Text(
                '设备信息',
                style:
                new TextStyle(fontSize: 20.0, fontWeight: FontWeight.w400),
              ));
        },
        body: new Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.0),
          child: new Column(
            children: _buildBasicInfo(),
          ),
        ),
        isExpanded: expansionList[0]));
    if (fujiClass2Components.isNotEmpty) {
      _list.add(ExpansionPanel(canTapOnHeader: true,
          headerBuilder: (context, isExpanded) {
            return ListTile(
                leading: new Icon(
                  Icons.settings_applications,
                  size: 24.0,
                  color: Colors.blue,
                ),
                title: Text(
                  'CT球管信息',
                  style:
                  new TextStyle(fontSize: 20.0, fontWeight: FontWeight.w400),
                ));
          },
          body: new Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            child: new Column(
              children: _buildComponent(),
            ),
          ),
          isExpanded: expansionList[1]));
    }
    //asset info
    _list.add(ExpansionPanel(canTapOnHeader: true,
        headerBuilder: (context, isExpanded) {
          return ListTile(
              leading: new Icon(
                Icons.web_asset,
                size: 24.0,
                color: Colors.blue,
              ),
              title: Text(
                '资产信息',
                style:
                new TextStyle(fontSize: 20.0, fontWeight: FontWeight.w400),
              ));
        },
        body: new Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.0),
          child: new Column(
            children: _buildAssetInfo(),
          ),
        ),
        isExpanded: expansionList[_list.length]));
    //purchasing info
    _list.add(ExpansionPanel(canTapOnHeader: true,
        headerBuilder: (context, isExpanded) {
          return ListTile(
              leading: new Icon(
                Icons.shopping_basket,
                size: 24.0,
                color: Colors.blue,
              ),
              title: Text(
                '采购信息',
                style:
                new TextStyle(fontSize: 20.0, fontWeight: FontWeight.w400),
              ));
        },
        body: new Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.0),
          child: new Column(
            children: _buildPurchaseInfo(),
          ),
        ),
        isExpanded: expansionList[_list.length]));
    //status info
    _list.add(ExpansionPanel(canTapOnHeader: true,
        headerBuilder: (context, isExpanded) {
          return ListTile(
              leading: new Icon(
                Icons.network_check,
                size: 24.0,
                color: Colors.blue,
              ),
              title: Text(
                '使用状态',
                style:
                new TextStyle(fontSize: 20.0, fontWeight: FontWeight.w400),
              ));
        },
        body: new Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.0),
          child: new Column(
            children: _buildUsageInfo(),
          ),
        ),
        isExpanded: expansionList[_list.length]));
    //equipment photos
    if (!widget.editable && widget.equipmentType == EquipmentType.MEDICAL) {
      _list.add(ExpansionPanel(canTapOnHeader: true,
          headerBuilder: (context, isExpanded) {
            return ListTile(
                leading: new Icon(
                  Icons.settings,
                  size: 24.0,
                  color: Colors.blue,
                ),
                title: Text(
                  '历史零件',
                  style:
                  new TextStyle(fontSize: 20.0, fontWeight: FontWeight.w400),
                ));
          },
          body: new Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            child: new Column(
              children: _buildHisComponent(),
            ),
          ),
          isExpanded: expansionList[_list.length]));

      _list.add(ExpansionPanel(canTapOnHeader: true,
          headerBuilder: (context, isExpanded) {
            return ListTile(
                leading: new Icon(
                  Icons.battery_charging_full,
                  size: 24.0,
                  color: Colors.blue,
                ),
                title: Text(
                  '历史耗材',
                  style:
                  new TextStyle(fontSize: 20.0, fontWeight: FontWeight.w400),
                ));
          },
          body: new Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            child: new Column(
              children: _buildHistConsumable(),
            ),
          ),
          isExpanded: expansionList[_list.length]));
    }
    _list.add(ExpansionPanel(canTapOnHeader: true,
        headerBuilder: (context, isExpanded) {
          return ListTile(
              leading: new Icon(
                Icons.attach_file,
                size: 24.0,
                color: Colors.blue,
              ),
              title: Text(
                '设备附件',
                style:
                    new TextStyle(fontSize: 20.0, fontWeight: FontWeight.w400),
              ));
        },
        body: new Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.0),
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Padding(
                padding: EdgeInsets.symmetric(vertical: 5.0),
                child: new Row(
                  children: <Widget>[
                    new Text(
                      '设备铭牌：',
                      style: new TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.w600),
                    ),
                    widget.editable?new IconButton(
                        icon: Icon(Icons.add_a_photo),
                        onPressed: () {
                          getImage(equipmentPlaques);
                        }):new Container()
                  ],
                ),
              ),
              buildImageRow(equipmentPlaques, 'assets/plaque.png'),
              new Padding(
                padding: EdgeInsets.symmetric(vertical: 5.0),
                child: new Row(
                  children: <Widget>[
                    new Text(
                      '设备外观：',
                      style: new TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.w600),
                    ),
                    widget.editable?new IconButton(
                        icon: Icon(Icons.add_a_photo),
                        onPressed: () {
                          getImage(equipmentAppearance);
                        }):new Container()
                  ],
                ),
              ),
              buildImageRow(equipmentAppearance, 'assets/appearance.png'),
              new Padding(
                padding: EdgeInsets.symmetric(vertical: 5.0),
                child: new Row(
                  children: <Widget>[
                    new Text(
                      '设备标签：',
                      style: new TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.w600),
                    ),
                    widget.editable?new IconButton(
                        icon: Icon(Icons.add_a_photo),
                        onPressed: () {
                          getImage(equipmentLabel);
                        }):new Container()
                  ],
                ),
              ),
              buildImageRow(equipmentLabel, 'assets/label.png'),
            ],
          ),
        ),
        isExpanded: expansionList[_list.length]));
    return _list;
  }

  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: widget.editable?Text(widget.equipment == null ? '添加$title' : '编辑$title'):Text('查看$title'),
          elevation: 0.7,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).accentColor
                ],
              ),
            ),
          ),
        ),
        body: new GestureDetector(
          onTap: () {
            print('equipment tab');
            FocusNode currentFocus = FocusScope.of(context);
            currentFocus.unfocus();
            if (!currentFocus.hasPrimaryFocus) {
            }
          },
          child: new Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Card(
              child: new ListView(
                controller: _scrollController,
                children: <Widget>[
                  new ExpansionPanelList(
                    animationDuration: Duration(milliseconds: 200),
                    expansionCallback: (index, isExpanded) {
                      setState(() {
                        expansionList[index] = !isExpanded;
                      });
                    },
                    children: buildExpansion(context),
                  ),
                  SizedBox(height: 24.0),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      widget.editable?new Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5.0),
                        child: new RaisedButton(
                          onPressed: () {
                            FocusScope.of(context).requestFocus(new FocusNode());
                            netstat?null:saveEquipment();
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: EdgeInsets.all(12.0),
                          color: new Color(0xff2E94B9),
                          child:
                          Text('保存', style: TextStyle(color: Colors.white)),
                        ),
                      ):new Container(),
                      new Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5.0),
                        child: new RaisedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: EdgeInsets.all(12.0),
                          color: new Color(0xffD25565),
                          child:
                          Text('返回', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          )),
        );
  }
}
