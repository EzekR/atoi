import 'package:flutter/material.dart';
import 'package:floating_search_bar/floating_search_bar.dart';
import 'package:atoi/utils/http_request.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SearchPage extends StatefulWidget {

  SearchPage({Key key, this.equipments}):super(key: key);

  final List equipments;

  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  var suggestionList = [];
  List selected = [];
  String query = '';
  ScrollController _scrollController = new ScrollController();
  int offset = 0;
  bool _noMore = false;

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
    var resp = await HttpRequest.request(
        '/Equipment/Getdevices',
        method: HttpRequest.GET,
        params: {
          'filterText': filter,
          'filterField': 'e.Name',
          'departmentId': -1,
          'PageSize': 20,
          'CurRowNum': offset
        }
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
                    text: '${suggestionList[i]['Name']}/${suggestionList[i]['EquipmentCode']}/${suggestionList[i]['SerialCode']}',
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
      trailing: FlatButton(onPressed: () {
        Navigator.of(context).pop(selected);
      }, child: new Text('确认')),
      onChanged: (String value) {
        setState(() {
          query = value;
        });
        getDevices(query);
      },
      onTap: () {},
      decoration: InputDecoration.collapsed(
        hintText: "请输入设备名称",
        hintStyle: new TextStyle(
          fontSize: 14.0,
          color: Colors.grey,
          fontWeight: FontWeight.w600
        )
      ),
    );
  }
}
