import 'package:atoi/pages/equipments/equipments_list.dart';
import 'package:flutter/material.dart';
import 'package:floating_search_bar/floating_search_bar.dart';
import 'package:atoi/utils/http_request.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SearchPage extends StatefulWidget {

  SearchPage({Key key, this.equipments, this.onlyType, this.multiType, this.fujiClass2}):super(key: key);

  final List equipments;
  final EquipmentType onlyType;
  final MultiSearchType multiType;
  final int fujiClass2;

  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  var suggestionList = [];
  List selected = [];
  String query = '';
  ScrollController _scrollController = new ScrollController();
  int offset = 0;
  bool _noMore = false;
  int deviceType = 1;
  String deviceUrl = "/Equipment/Getdevices";

  void initState() {
    getDevices('');
    super.initState();
    if (widget.equipments != null) {
      setState(() {
        for(var item in widget.equipments) {
          selected.add(item);
        }
      });
    }
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        var _length = suggestionList.length;
        offset += 20;
        getDevices(query).then((result) {
          if (suggestionList.length == _length) {
            setState(() {
              _noMore = true;
            });
          } else {
            setState(() {
              _noMore = false;
            });
          }
        });
      }
    });
  }

  Future<Null> getDevices(String filter) async {
    Map _params;
    switch (deviceType) {
      case 1:
        deviceUrl = "/Equipment/Getdevices";
        break;
      case 2:
        deviceUrl = "/MeasInstrum/QueryMeasInstrums";
        break;
      case 3:
        deviceUrl = "/OtherEqpt/QueryOtherEqpts";
        break;
    }
    switch (deviceType) {
      case 1:
        _params = {
          'filterText': filter,
          'filterField': 'e.Name',
          'departmentId': -1,
          'PageSize': 20,
          'CurRowNum': offset
        };
        break;
      case 2:
        _params = {
          'status': 0,
          'departmentID':-1,
          'useStatus':false,
          'filterField': 'mi.Name',
          'filterText': filter,
          'curRowNum': offset,
          'sortField': 'mi.Name',
          'sortDirection': true,
          'pageSize':10
        };
        break;
      case 3:
        _params = {
          'status': 0,
          'departmentID':-1,
          'useStatus':false,
          'filterField': 'oe.Name',
          'filterText': filter,
          'curRowNum': offset,
          'sortField': 'oe.Name',
          'sortDirection': true,
          'pageSize':10
        };
        break;
    }
    String _url;
    switch (widget.multiType) {
      case MultiSearchType.COMPONENT:
        _url = '/InvComponent/QueryComponentsByFujiClass2ID';
        _params = {
          'fujiClass2ID': widget.fujiClass2,
          'filterField': 'c.Name',
          'filterText': filter
        };
        break;
      case MultiSearchType.EQUIPMENT:
        _url = deviceUrl;
        break;
      case MultiSearchType.CONSUMABLE:
        _url = '/InvConsumable/QueryConsumablesByFujiClass2ID';
        _params = {
          'fujiClass2ID': widget.fujiClass2,
          'filterField': 'c.Name',
          'filterText': filter
        };
        break;
    }
    var resp = await HttpRequest.request(
        _url,
        method: HttpRequest.GET,
        params: _params
    );
    print(resp);
    if (resp['ResultCode'] == '00') {
      setState(() {
        suggestionList.addAll(resp['Data']);
      });
    }
  }

  Widget build(BuildContext context) {
    return FloatingSearchBar.builder(
      scrollController: _scrollController,
      itemCount: suggestionList.length>=20?suggestionList.length+1:suggestionList.length,
      itemBuilder: (BuildContext context, int i) {
        if (i != suggestionList.length) {
          return CheckboxListTile(
            value: selected.firstWhere((item) => item['ID'] == suggestionList[i]['ID'], orElse: ()=>null)!=null?true:false,
            title: RichText(
                text: TextSpan(
                    text: widget.multiType!=MultiSearchType.EQUIPMENT?'${suggestionList[i]['Name']}/${suggestionList[i]['OID']}/${suggestionList[i]['Type']['Name']}':'${suggestionList[i]['Name']}/${suggestionList[i]['ModelCode']}/${suggestionList[i]['SerialCode']}',
                    style: TextStyle(
                        color: Colors.grey ),
                    children: [
                    ])),
            onChanged: (bool value) {
              setState(() {
                value?selected.add(suggestionList[i]):selected.removeWhere((item) => item['ID']==suggestionList[i]['ID']);
              });
            },
          );
        } else {
          return _noMore?new Center(child: new Text('没有更多设备'),):new SpinKitThreeBounce(color: Colors.blue,);
        }
      },
      leading: new IconButton(icon: new Icon(Icons.arrow_back), onPressed: () {
        setState(() {
          selected = [];
        });
        Navigator.of(context).pop();
      },),
      trailing: Container(
        width: 120.0,
        child: Row(
          children: <Widget>[
            widget.onlyType==null?PopupMenuButton(
              onSelected: (val) {
                print(val);
                setState(() {
                  suggestionList.clear();
                  deviceType = val;
                  selected.clear();
                });
                getDevices(query);
              },
              icon: Icon(Icons.menu, color: Colors.grey,),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 1,
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.devices, color: Colors.blueAccent,),
                      SizedBox(width: 10.0,),
                      Text('医疗设备')
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 2,
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.straighten, color: Colors.blueAccent,),
                      SizedBox(width: 10.0,),
                      Text('计量器具')
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 3,
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.devices_other, color: Colors.blueAccent,),
                      SizedBox(width: 10.0,),
                      Text('其他设备')
                    ],
                  ),
                ),
              ],
            ):Container(),
            FlatButton(onPressed: () {
              // todo: 判断非空
              if (selected.isNotEmpty) {
                selected[0]['AssetType'] = {
                  "ID": deviceType
                };
              }
              Navigator.of(context).pop(selected);
            }, child: new Text('确认')),
          ],
        ),
      ),
      onChanged: (String value) {
        setState(() {
          query = value;
        });
        suggestionList.clear();
        getDevices(query);
      },
      onTap: () {},
      decoration: InputDecoration.collapsed(
        hintText: widget.multiType==MultiSearchType.COMPONENT?"请输入零件名称":"请输入设备名称",
        hintStyle: new TextStyle(
          fontSize: 14.0,
          color: Colors.grey,
          fontWeight: FontWeight.w600
        )
      ),
    );
  }
}

enum MultiSearchType {
  EQUIPMENT,
  COMPONENT,
  CONSUMABLE
}