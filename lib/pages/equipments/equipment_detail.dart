import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:atoi/widgets/build_widget.dart';
import 'package:atoi/widgets/search_bar_vendor.dart';
import 'dart:convert';
import 'package:scoped_model/scoped_model.dart';
import 'package:atoi/models/models.dart';
import 'package:atoi/utils/http_request.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:atoi/utils/constants.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:date_format/date_format.dart';

/// 设备详情页面类
class EquipmentDetail extends StatefulWidget {
  EquipmentDetail({Key key, this.equipment, this.editable}) : super(key: key);
  final Map equipment;
  final bool editable;
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
  List<bool> expansionList = [
    true, false, false, false, false
  ];

  bool isSearchState = false;
  bool isAdmin = true;
  bool netstat = false;

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

  List patrolPeriodList = ['无', '天/次', '月/次', '年/次'];
  List<DropdownMenuItem<String>> dropdownPatrolPeriod;
  String currentPatrolPeriod;

  List mandatoryPeriodList = ['无', '天/次', '月/次', '年/次'];
  List<DropdownMenuItem<String>> dropdownMandatoryPeriod;
  String currentMaintainPeriod;

  List correctionPeriodList = ['无', '天/次', '月/次', '年/次'];
  List<DropdownMenuItem<String>> dropdownCorrectionPeriod;
  String currentCorrectionPeriod;

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

  List equipmentPlaques = [];
  List equipmentLabel = [];
  List equipmentAppearance = [];

  Future<SharedPreferences> prefs = SharedPreferences.getInstance();

  Future<Null> getRole() async {
    var _prefs = await prefs;
    var _role = _prefs.getInt('role');
    isAdmin = _role == 1?true:false;
  }

  void changeValue(value) {
    setState(() {
      currentFixed = value;
    });
  }

  void changeServiceScope(value) {
    setState(() {
      currentServiceScope = value;
    });
  }

  void changeOrigin(value) {
    setState(() {
      currentOrigin = value;
    });
  }

  void changeCheck(value) {
    setState(() {
      currentCheck = value;
    });
  }

  void changeRecall(value) {
    setState(() {
      currentRecall = value;
    });
  }

  void initDepart() {
    print(model.DepartmentsList);
    departments = model.DepartmentsList;
    dropdownDepartments = getDropDownMenuItems(departments);
    currentDepartment = dropdownDepartments[0].value;
    print(currentDepartment);
  }

  List<DropdownMenuItem<String>> getDropDownMenuItems(List list) {
    List<DropdownMenuItem<String>> items = new List();
    for (String method in list) {
      items.add(new DropdownMenuItem(
          value: method,
          child: new Text(
            method,
            style: new TextStyle(
                fontSize: 16.0,
            ),
          )));
    }
    return items;
  }

  void changeLevel(String selectedMethod) {
    setState(() {
      currentLevel = selectedMethod;
    });
  }

  void changeDepartment(String selectedMethod) {
    setState(() {
      currentDepartment = selectedMethod;
    });
  }

  void changeStatus(String selectedMethod) {
    setState(() {
      currentStatus = selectedMethod;
    });
  }

  void changeMachine(String selectedMethod) {
    setState(() {
      currentMachine = selectedMethod;
    });
  }

  void changeMandatory(String selectedMethod) {
    setState(() {
      currentMandatory = selectedMethod;
    });
  }

  void changePatrolPeriod(String selectedMethod) {
    if (selectedMethod == '无') {
      patrolPeriod.clear();
    }
    setState(() {
      currentPatrolPeriod = selectedMethod;
    });
  }

  void changeMandatoryPeriod(String selectedMethod) {
    if (selectedMethod == '无') {
      maintainPeriod.clear();
    }
    setState(() {
      currentMaintainPeriod = selectedMethod;
    });
  }

  void changeCorrectionPeriod(String selectedMethod) {
    if (selectedMethod == '无') {
      correctionPeriod.clear();
    }
    setState(() {
      currentCorrectionPeriod = selectedMethod;
    });
  }

  void changeClass(String selectedMethod) {
    setState(() {
      currentClass = selectedMethod;
    });
  }

  Future<Null> initClass1() async {
    var resp = await HttpRequest.request('/Equipment/GetEquipmentClass',
        method: HttpRequest.GET, params: {'level': 1});
    if (resp['ResultCode'] == '00') {
      List _listData = resp['Data'].map((item) {
        return item['Description'];
      }).toList();
      setState(() {
        class1 = _listData;
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
    var _selectedItem = class1Item.firstWhere((item) {
      return item['Description'] == selectedClass;
    });
    print(_selectedItem);
    initClass(_selectedItem['Code'], 2);
    setState(() {
      currentClass1 = selectedClass;
      classCode1 = _selectedItem['Code'];
    });
  }

  void changeClass2(String selectedMethod) {
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
  }

  void changeClass3(String selectedMethod) {
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
    dropdownPatrolPeriod = getDropDownMenuItems(model.PeriodTypeList);
    currentPatrolPeriod = dropdownPatrolPeriod[0].value;
    dropdownMandatoryPeriod = getDropDownMenuItems(model.PeriodTypeList);
    currentMaintainPeriod = dropdownMandatoryPeriod[0].value;
    dropdownCorrectionPeriod = getDropDownMenuItems(model.PeriodTypeList);
    currentCorrectionPeriod = dropdownCorrectionPeriod[0].value;
    dropdownClass = getDropDownMenuItems(equipmentClass);
    currentClass = dropdownClass[0].value;
    initDepart();
    initClass1();
    if (widget.equipment != null) {
      getDevice(widget.equipment['ID']);
    }
    getRole();
  }

  void showSheet(context, List _imageList) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return new ListView(
            shrinkWrap: true,
            children: <Widget>[
              ListTile(
                trailing: new Icon(Icons.collections),
                title: new Text('从相册添加'),
                onTap: () {
                  getImage(ImageSource.gallery, _imageList);
                },
              ),
              ListTile(
                trailing: new Icon(Icons.add_a_photo),
                title: new Text('拍照添加'),
                onTap: () {
                  getImage(ImageSource.camera, _imageList);
                },
              ),
            ],
          );
        });
  }

  Future getImage(ImageSource sourceType, List _imageList) async {
    try {
      var image = await ImagePicker.pickImage(
        source: sourceType,
      );
      if (image != null) {
        if (_imageList.length > 0 && _imageList[0]['id'] != null) {
          await deleteFile(_imageList[0]['id']);
        }
        var bytes = await image.readAsBytes();
        var _compressed = await FlutterImageCompress.compressWithList(bytes,
            minWidth: 480, minHeight: 600);
        _imageList.clear();
        setState(() {
          _imageList.add({'fileName': image.path, 'content': _compressed});
        });
      }
    } catch(e) {
      print('take photo error:'+e.toString());
    }
  }

  GridView buildImageRow(List imageList) {
    List<Widget> _list = [];
    if (imageList.length > 0) {
      for (var image in imageList) {
        var _suffix = image['fileName'].split('.');
        _suffix = _suffix.reversed.toList();
        if (_suffix[0] == 'jpg' || _suffix[0] == 'jpeg' || _suffix[0] == 'bmp' || _suffix[0] == 'png') {
          _list.add(new Stack(
            alignment: FractionalOffset(1.0, 0),
            children: <Widget>[
              new Container(
                width: 150.0,
                child: BuildWidget.buildPhotoPageList(context, image['content']),
              ),
              new Padding(
                padding: EdgeInsets.symmetric(horizontal: 0.0),
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
          ));
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
    }
    return new GridView.count(
        shrinkWrap: true,
        primary: false,
        mainAxisSpacing: 5,
        crossAxisSpacing: 5,
        crossAxisCount: 2,
        children: _list);
  }

  Future<String> getDeviceFile(int fileId) async {
    var resp = await HttpRequest.request(
      '/Equipment/DownloadUploadFile',
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
    var resp = await HttpRequest.request(
      '/Equipment/DeleteEquipmentFile',
      method: HttpRequest.POST,
      data: {
        'fileID': fileId
      }
    );
    print(resp);
  }

  Future<Null> getDevice(int deviceId) async {
    var resp = await HttpRequest.request('/Equipment/GetDeviceById',
        method: HttpRequest.GET, params: {'id': deviceId});
    if (resp['ResultCode'] == '00') {
      var _data = resp['Data'];
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
        //installStartDate = formatDate(_data['InstalStartDate'].toString());
        //installEndDate = formatDate(_data['InstalEndDate'].toString());
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
        currentMandatory = _data['MandatoryTestStatus']['ID'] == 0
            ? '无'
            : _data['MandatoryTestStatus']['Name'];
        mandatoryDate = formatDateString(_data['MandatoryTestDate'].toString());
        currentRecall = _data['RecallFlag'] ? '是' : '否';
        currentServiceScope = _data['ServiceScope']?"是":"否";
        recallDate = formatDateString(_data['RecallDate'].toString());
        currentPatrolPeriod = _data['PatrolType']['Name'] == ''
            ? '无'
            : _data['PatrolType']['Name'];
        currentMaintainPeriod = _data['MaintenanceType']['Name'] == ''
            ? '无'
            : _data['MaintenanceType']['Name'];
        currentCorrectionPeriod = _data['CorrectionType']['Name'] == ''
            ? '无'
            : _data['CorrectionType']['Name'];
      });
      //download equipment files
      var _files = _data['EquipmentFile'];
      for(var item in _files) {
        var _fileExt = item['FileName'].split('.');
        _fileExt = _fileExt.reversed.toList();
        switch (item['FileType']) {
          case 5:
            if (_fileExt[0] == 'jpg' || _fileExt[0] == 'png' || _fileExt[0] == 'jpeg' ||
                _fileExt[0] == 'bmp') {
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
            if (_fileExt[0] == 'jpg' || _fileExt[0] == 'png' || _fileExt[0] == 'jpeg' ||
                _fileExt[0] == 'bmp') {
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
            if (_fileExt[0] == 'jpg' || _fileExt[0] == 'png' || _fileExt[0] == 'jpeg' ||
                _fileExt[0] == 'bmp') {
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
  }

  List<FocusNode> _focusEquip = new List(10).map((item) {
    return new FocusNode();
  }).toList();

  Future<Null> saveEquipment() async {
    if (name.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: new Text('设备名称不可为空'),
        )
      ).then((result) => FocusScope.of(context).requestFocus(_focusEquip[0]));
      return;
    }
    if (equipmentCode.text.isEmpty) {
      showDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: new Text('设备型号不可为空'),
          )
      ).then((result) => FocusScope.of(context).requestFocus(_focusEquip[1]));
      return;
    }
    if (serialCode.text.isEmpty) {
      showDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: new Text('设备序列号不可为空'),
          )
      ).then((result) => FocusScope.of(context).requestFocus(_focusEquip[2]));
      return;
    }
    if (manufacturer == null) {
      showDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: new Text('设备厂商不可为空'),
          )
      );
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
      );
      return;
    }
    if (assetCode.text.isEmpty) {
      showDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: new Text('资产编号不可为空'),
          )
      ).then((result) => FocusScope.of(context).requestFocus(_focusEquip[4]));
      return;
    }
    if (purchaseDate == 'YY-MM-DD') {
      showDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: new Text('采购日期不可为空'),
          )
      );
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
      );
      return;
    }
    if (currentPatrolPeriod != '无' && patrolPeriod.text.isEmpty) {
      showDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: new Text('巡检周期不可为空'),
          )
      ).then((result) => FocusScope.of(context).requestFocus(_focusEquip[6]));
      return;
    }
    if (int.tryParse(patrolPeriod.text.toString()) != null && int.tryParse(patrolPeriod.text.toString()) <= 0 && currentPatrolPeriod != '无') {
      showDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: new Text('巡检周期需大于0'),
          )
      ).then((result) => FocusScope.of(context).requestFocus(_focusEquip[6]));
      return;
    }
    if (currentMaintainPeriod != '无' && maintainPeriod.text.isEmpty) {
      showDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: new Text('保养周期不可为空'),
          )
      ).then((result) => FocusScope.of(context).requestFocus(_focusEquip[7]));
      return;
    }
    if (int.tryParse(maintainPeriod.text.toString()) !=null && int.tryParse(maintainPeriod.text.toString()) <= 0 && currentMaintainPeriod !='无') {
      showDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: new Text('保养周期需大于0'),
          )
      ).then((result) => FocusScope.of(context).requestFocus(_focusEquip[7]));
      return;
    }
    if (currentCorrectionPeriod != '无' && correctionPeriod.text.isEmpty) {
      showDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: new Text('校准周期不可为空'),
          )
      ).then((result) => FocusScope.of(context).requestFocus(_focusEquip[8]));
      return;
    }
    if (int.tryParse(correctionPeriod.text.toString()) != null && int.tryParse(correctionPeriod.text.toString()) <= 0 && currentCorrectionPeriod != '无') {
      showDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: new Text('校准周期需大于0'),
          )
      ).then((result) => FocusScope.of(context).requestFocus(_focusEquip[8]));
      return;
    }
    if (usageDate == 'YY-MM-DD') {
      showDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: new Text('启用日期不可为空'),
          )
      );
      return;
    }
    if (installDate == 'YY-MM-DD') {
      showDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: new Text('安装日期不可为空'),
          )
      );
      return;
    }
    //var _iStart = DateTime.parse(installStartDate);
    //var _iEnd = DateTime.parse(installEndDate);
    //if (_iEnd.isBefore(_iStart)) {
    //  showDialog(
    //      context: context,
    //      builder: (context) => CupertinoAlertDialog(
    //        title: new Text('安装日期格式有误'),
    //      )
    //  );
    //  return;
    //}
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
    print(_equipmentFiles);
    var _data = {
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
      "AssetCode": assetCode.text,
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
        "ID": model.PeriodType[currentMaintainPeriod],
      },
      "PatrolPeriod": patrolPeriod.text.isEmpty?null:patrolPeriod.text,
      "PatrolType": {
        "ID": model.PeriodType[currentPatrolPeriod],
      },
      "CorrectionPeriod": correctionPeriod.text.isEmpty?null:correctionPeriod.text,
      "CorrectionType": {
        "ID": model.PeriodType[currentCorrectionPeriod],
      },
      "MandatoryTestStatus": {
        "ID": mandatoryFlagType[currentMandatory],
      },
      "MandatoryTestDate": mandatoryDate,
      "RecallFlag": currentRecall == '是' ? true : false,
      "RecallDate": recallDate,
      "CreateUser": {'ID': _userId},
      "EquipmentFile": _equipmentFiles,
    };
    if (widget.equipment != null) {
      _data['ID'] = widget.equipment['ID'];
    } else {
      _data['ID'] = 0;
    }
    setState(() {
      netstat = true;
    });
    var resp = await HttpRequest.request('/Equipment/SaveEquipment',
        method: HttpRequest.POST, data: {"userID": _userId, "info": _data});
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
              ));
    }
    setState(() {
      netstat = false;
    });
  }

  void switchAsset(value) {
    print(value);
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
      maxDateTime: DateTime.parse('2030-01-01'),
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


  List<ExpansionPanel> buildExpansion(BuildContext context) {
    List<ExpansionPanel> _list = [];
    //device info
    _list.add(ExpansionPanel(
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
            children: <Widget>[
              BuildWidget.buildRow('系统编号', oid),
              widget.editable?BuildWidget.buildInput('设备名称', name, lines: 1, focusNode: _focusEquip[0]):BuildWidget.buildRow('设备名称', name.text),
              widget.editable?BuildWidget.buildInput('设备型号', equipmentCode, lines: 1, focusNode: _focusEquip[1]):BuildWidget.buildRow('设备型号', equipmentCode.text),
              widget.editable?BuildWidget.buildInput('设备序列号', serialCode, lines: 1, focusNode: _focusEquip[2]):BuildWidget.buildRow('设备序列号', serialCode.text),
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
                        )),
                    new Expanded(
                        flex: 2,
                        child: new IconButton(
                            icon: Icon(Icons.search),
                            onPressed: () async {
                              final _searchResult = await showSearch(
                                  context: context,
                                  delegate: SearchBarVendor(),
                                  hintText: '请输厂商名称');
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
              widget.editable?BuildWidget.buildDropdown('等级', currentClass, dropdownClass, changeClass):BuildWidget.buildRow('等级', currentClass),
              widget.editable?BuildWidget.buildDropdown('设备类别(I)', currentClass1, dropdownClass1, changeClass1):BuildWidget.buildRow('设备类别(I)', currentClass1==null?'':currentClass1),
              widget.editable?BuildWidget.buildDropdown('设备类别(II)', currentClass2, dropdownClass2, changeClass2):BuildWidget.buildRow('设备类别(II)', currentClass2==null?'':currentClass2),
              widget.editable?BuildWidget.buildDropdown('设备类别(III)', currentClass3, dropdownClass3, changeClass3):BuildWidget.buildRow('设备类别(III)', currentClass3==null?'':currentClass3),
              BuildWidget.buildRow('分类编码', classCode1+classCode2+classCode3),
              widget.editable&&isAdmin?BuildWidget.buildRadio('整包范围', serviceScope, currentServiceScope, changeServiceScope):BuildWidget.buildRow('整包范围', currentServiceScope),
              widget.editable?BuildWidget.buildInput('品牌', brand, lines: 1):BuildWidget.buildRow('品牌', brand.text),
              widget.editable?BuildWidget.buildInput('备注', comments, lines: 1):BuildWidget.buildRow('备注', comments.text),
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
                            var _time = DateTime.tryParse(manufacturingDate)??DateTime.now();
                            DatePicker.showDatePicker(
                              context,
                              pickerTheme: DateTimePickerTheme(
                                showTitle: true,
                                confirm: Text('确认', style: TextStyle(color: Colors.blueAccent)),
                                cancel: Text('取消', style: TextStyle(color: Colors.redAccent)),
                              ),
                              minDateTime: DateTime.now().add(Duration(days: -7300)),
                              maxDateTime: DateTime.parse('2030-01-01'),
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
            ],
          ),
        ),
        isExpanded: expansionList[0]));
    //asset info
    _list.add(ExpansionPanel(
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
            children: <Widget>[
              widget.editable?BuildWidget.buildRadio('固定资产', isFixed, currentFixed, changeValue):BuildWidget.buildRow('固定资产', currentFixed),
              widget.editable?BuildWidget.buildDropdown('资产等级', currentLevel, dropdownLevel, changeLevel):BuildWidget.buildRow('资产等级', currentLevel),
              widget.editable?BuildWidget.buildInput('资产编号', assetCode, lines: 1, focusNode: _focusEquip[4]):BuildWidget.buildRow('资产编号', assetCode.text),
              widget.editable?BuildWidget.buildInput('折旧年限(年)', depreciationYears, lines: 1, maxLength: 3, inputType: TextInputType.number):BuildWidget.buildRow('折旧年限', depreciationYears.text),
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
                                      var _time = DateTime.tryParse(validationStartDate)??DateTime.now();
                                      DatePicker.showDatePicker(
                                        context,
                                        pickerTheme: DateTimePickerTheme(
                                          showTitle: true,
                                          confirm: Text('确认', style: TextStyle(color: Colors.blueAccent)),
                                          cancel: Text('取消', style: TextStyle(color: Colors.redAccent)),
                                        ),
                                        minDateTime: DateTime.now().add(Duration(days: -7300)),
                                        maxDateTime: DateTime.parse('2030-01-01'),
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
                                child: new Text(
                                  validationEndDate,
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
                                      var _time = DateTime.tryParse(validationEndDate)??DateTime.now();
                                      DatePicker.showDatePicker(
                                        context,
                                        pickerTheme: DateTimePickerTheme(
                                          showTitle: true,
                                          confirm: Text('确认', style: TextStyle(color: Colors.blueAccent)),
                                          cancel: Text('取消', style: TextStyle(color: Colors.redAccent)),
                                        ),
                                        minDateTime: DateTime.now().add(Duration(days: -7300)),
                                        maxDateTime: DateTime.parse('2030-01-01'),
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
                                      //var _start = DateTime.tryParse(validationStartDate);
                                      //var _end = DateTime.tryParse(_date);
                                      //if (_start!=null && _end!=null && _end.isBefore(_start)) {
                                      //  showDialog(context: context, builder: (context) => CupertinoAlertDialog(
                                      //    title: new Text('有效日期格式有误'),
                                      //  ));
                                      //} else {
                                      //  setState(() {
                                      //    validationEndDate = _date;
                                      //  });
                                      //}
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
            ],
          ),
        ),
        isExpanded: expansionList[1]));
    //purchasing info
    _list.add(ExpansionPanel(
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
            children: <Widget>[
              widget.editable?BuildWidget.buildInput('销售合同名称', contractName, lines: 1):BuildWidget.buildRow('销售合同名称', contractName.text),
              widget.editable?BuildWidget.buildInput('购入方式', purchaseWay, lines: 1):BuildWidget.buildRow('购入方式', purchaseWay.text),
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
                          onPressed: () async {
                            var _time = DateTime.tryParse(purchaseDate)??DateTime.now();
                            DatePicker.showDatePicker(
                              context,
                              pickerTheme: DateTimePickerTheme(
                                showTitle: true,
                                confirm: Text('确认', style: TextStyle(color: Colors.blueAccent)),
                                cancel: Text('取消', style: TextStyle(color: Colors.redAccent)),
                              ),
                              minDateTime: DateTime.now().add(Duration(days: -7300)),
                              maxDateTime: DateTime.parse('2030-01-01'),
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
                              final _searchResult = await showSearch(
                                  context: context,
                                  delegate: SearchBarVendor(),
                                  hintText: '请输供应商名称');
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
              widget.editable?BuildWidget.buildInput('采购金额(元)', purchaseAmount, lines: 1, maxLength: 11, inputType: TextInputType.numberWithOptions(decimal: true), focusNode: _focusEquip[5]):BuildWidget.buildRow('采购金额（元）', purchaseAmount.text),
              widget.editable?BuildWidget.buildRadio('设备产地', origin, currentOrigin, changeOrigin):BuildWidget.buildRow('设备产地', currentOrigin),
            ],
          ),
        ),
        isExpanded: expansionList[2]));
    //status info
    _list.add(ExpansionPanel(
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
            children: <Widget>[
              widget.editable&&departments!=null?BuildWidget.buildDropdown('使用科室', currentDepartment, dropdownDepartments, changeDepartment):new Container(),
              !widget.editable?BuildWidget.buildRow('使用科室', currentDepartment):new Container(),
              widget.editable?BuildWidget.buildInput('安装地点', installSite, lines: 1):BuildWidget.buildRow('安装地点', installSite.text),
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
                          onPressed: () async {
                            var _time = DateTime.tryParse(installDate)??DateTime.now();
                            DatePicker.showDatePicker(
                              context,
                              pickerTheme: DateTimePickerTheme(
                                showTitle: true,
                                confirm: Text('确认', style: TextStyle(color: Colors.blueAccent)),
                                cancel: Text('取消', style: TextStyle(color: Colors.redAccent)),
                              ),
                              minDateTime: DateTime.now().add(Duration(days: -7300)),
                              maxDateTime: DateTime.parse('2030-01-01'),
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
                            var _time = DateTime.tryParse(usageDate)??DateTime.now();
                            DatePicker.showDatePicker(
                              context,
                              pickerTheme: DateTimePickerTheme(
                                showTitle: true,
                                confirm: Text('确认', style: TextStyle(color: Colors.blueAccent)),
                                cancel: Text('取消', style: TextStyle(color: Colors.redAccent)),
                              ),
                              minDateTime: DateTime.now().add(Duration(days: -7300)),
                              maxDateTime: DateTime.parse('2030-01-01'),
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
              //widget.editable?new Padding(
              //  padding: EdgeInsets.symmetric(vertical: 5.0),
              //  child: new Row(
              //    children: <Widget>[
              //      new Expanded(
              //        flex: 4,
              //        child: new Wrap(
              //          alignment: WrapAlignment.end,
              //          crossAxisAlignment: WrapCrossAlignment.center,
              //          children: <Widget>[
              //            new Text(
              //              '安装日期',
              //              style: new TextStyle(
              //                  fontSize: 16.0, fontWeight: FontWeight.w600),
              //            )
              //          ],
              //        ),
              //      ),
              //      new Expanded(
              //        flex: 1,
              //        child: new Text(
              //          '：',
              //          style: new TextStyle(
              //            fontSize: 16.0,
              //            fontWeight: FontWeight.w600,
              //          ),
              //        ),
              //      ),
              //      new Expanded(
              //        flex: 6,
              //        child: new Column(
              //          children: <Widget>[
              //            new Row(
              //              children: <Widget>[
              //                new Expanded(
              //                  flex: 4,
              //                  child: new Text(
              //                    installStartDate,
              //                    style: new TextStyle(
              //                        fontSize: 16.0,
              //                        fontWeight: FontWeight.w400,
              //                        color: Colors.black54
              //                    ),
              //                  ),
              //                ),
              //                new Expanded(
              //                  flex: 2,
              //                  child: new IconButton(
              //                      icon: Icon(Icons.calendar_today, color: AppConstants.AppColors['btn_main'],),
              //                      onPressed: () async {
              //                        var _date = await pickDate(initialTime: installStartDate);
              //                        setState(() {
              //                          installStartDate = _date;
              //                        });
              //                      }
              //                  ),
              //                )
              //              ],
              //            ),
              //            new Row(
              //              children: <Widget>[
              //                new Expanded(
              //                  flex: 4,
              //                  child: new Text(
              //                    installEndDate,
              //                    style: new TextStyle(
              //                        fontSize: 16.0,
              //                        fontWeight: FontWeight.w400,
              //                        color: Colors.black54
              //                    ),
              //                  ),
              //                ),
              //                new Expanded(
              //                  flex: 2,
              //                  child: new IconButton(
              //                      icon: Icon(Icons.calendar_today, color: AppConstants.AppColors['btn_main'],),
              //                      onPressed: () async {
              //                        var _date = await pickDate(initialTime: installEndDate);
              //                        var _start = DateTime.tryParse(installStartDate);
              //                        var _end = DateTime.tryParse(_date);
              //                        if (_start!=null && _end!=null && _end.isBefore(_start)) {
              //                          showDialog(context: context, builder: (context) => CupertinoAlertDialog(
              //                            title: new Text('安装日期格式有误'),
              //                          ));
              //                        } else {
              //                          setState(() {
              //                            installEndDate = _date;
              //                          });
              //                        }
              //                      }
              //                  ),
              //                )
              //              ],
              //            ),
              //          ],
              //        ),
              //      ),
              //    ],
              //  ),
              //):BuildWidget.buildRow('安装日期', '${displayDate(installStartDate)}\n${displayDate(installEndDate)}'),
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
                            var _time = DateTime.tryParse(checkDate)??DateTime.now();
                            DatePicker.showDatePicker(
                              context,
                              pickerTheme: DateTimePickerTheme(
                                showTitle: true,
                                confirm: Text('确认', style: TextStyle(color: Colors.blueAccent)),
                                cancel: Text('取消', style: TextStyle(color: Colors.redAccent)),
                              ),
                              minDateTime: DateTime.now().add(Duration(days: -7300)),
                              maxDateTime: DateTime.parse('2030-01-01'),
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
              widget.editable?BuildWidget.buildDropdown('使用状态', currentStatus, dropdownStatus, changeStatus):BuildWidget.buildRow('使用状态', currentStatus),
              BuildWidget.buildRow('维保状态', warrantyStatus),
              widget.editable?BuildWidget.buildDropdown('设备状态', currentMachine, dropdownMachine, changeMachine):BuildWidget.buildRow('设备状态', currentMachine),
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
                            var _time = DateTime.tryParse(scrapDate)??DateTime.now();
                            DatePicker.showDatePicker(
                              context,
                              pickerTheme: DateTimePickerTheme(
                                showTitle: true,
                                confirm: Text('确认', style: TextStyle(color: Colors.blueAccent)),
                                cancel: Text('取消', style: TextStyle(color: Colors.redAccent)),
                              ),
                              minDateTime: DateTime.now().add(Duration(days: -7300)),
                              maxDateTime: DateTime.parse('2030-01-01'),
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
              widget.editable?BuildWidget.buildDropdown('强检标记', currentMandatory, dropdownMandatory, changeMandatory):BuildWidget.buildRow('强检标记', currentMandatory),
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
                            var _time = DateTime.tryParse(mandatoryDate)??DateTime.now();
                            DatePicker.showDatePicker(
                              context,
                              pickerTheme: DateTimePickerTheme(
                                showTitle: true,
                                confirm: Text('确认', style: TextStyle(color: Colors.blueAccent)),
                                cancel: Text('取消', style: TextStyle(color: Colors.redAccent)),
                              ),
                              minDateTime: DateTime.now().add(Duration(days: -7300)),
                              maxDateTime: DateTime.parse('2030-01-01'),
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
              ):BuildWidget.buildRow('强检时间', displayDate(mandatoryDate)),
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
                            var _time = DateTime.tryParse(recallDate)??DateTime.now();
                            DatePicker.showDatePicker(
                              context,
                              pickerTheme: DateTimePickerTheme(
                                showTitle: true,
                                confirm: Text('确认', style: TextStyle(color: Colors.blueAccent)),
                                cancel: Text('取消', style: TextStyle(color: Colors.redAccent)),
                              ),
                              minDateTime: DateTime.now().add(Duration(days: -7300)),
                              maxDateTime: DateTime.parse('2030-01-01'),
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
              widget.editable?BuildWidget.buildDropdownWithInput('巡检周期', patrolPeriod, currentPatrolPeriod, dropdownPatrolPeriod, changePatrolPeriod, inputType: TextInputType.number, focusNode: _focusEquip[6]):BuildWidget.buildRow('巡检周期', currentPatrolPeriod=='无'?'无巡检':'${patrolPeriod.text} $currentPatrolPeriod'),
              widget.editable?BuildWidget.buildDropdownWithInput(
                  '保养周期',
                  maintainPeriod,
                  currentMaintainPeriod,
                  dropdownMandatoryPeriod,
                  changeMandatoryPeriod,
                  inputType: TextInputType.number, focusNode: _focusEquip[7]):BuildWidget.buildRow('保养周期', currentMaintainPeriod=='无'?'无保养':'${maintainPeriod.text} $currentMaintainPeriod'),
              widget.editable?BuildWidget.buildDropdownWithInput(
                  '校准周期',
                  correctionPeriod,
                  currentCorrectionPeriod,
                  dropdownCorrectionPeriod,
                  changeCorrectionPeriod,
                  inputType: TextInputType.number, focusNode: _focusEquip[8]):BuildWidget.buildRow('校准周期', currentCorrectionPeriod=='无'?'无校准':'${correctionPeriod.text} $currentCorrectionPeriod'),
            ],
          ),
        ),
        isExpanded: expansionList[3]));
    //equipment photos
    _list.add(ExpansionPanel(
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
                          showSheet(context, equipmentPlaques);
                        }):new Container()
                  ],
                ),
              ),
              buildImageRow(equipmentPlaques),
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
                          showSheet(context, equipmentAppearance);
                        }):new Container()
                  ],
                ),
              ),
              buildImageRow(equipmentAppearance),
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
                          showSheet(context, equipmentLabel);
                        }):new Container()
                  ],
                ),
              ),
              buildImageRow(equipmentLabel),
            ],
          ),
        ),
        isExpanded: expansionList[4]));
    return _list;
  }

  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: widget.editable?Text(widget.equipment == null ? '添加设备' : '编辑设备'):Text('查看设备'),
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
        body: new Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Card(
            child: new ListView(
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
        ));
  }
}
