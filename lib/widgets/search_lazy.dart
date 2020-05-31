import 'dart:async';
import 'package:atoi/utils/http_request.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:convert';

class SearchLazy extends StatefulWidget {

  SearchLazy({Key key, this.searchType}):super(key: key);

  final SearchType searchType;

  _SearchLazyState createState() => _SearchLazyState();
}

class _SearchLazyState extends State<SearchLazy> {
  var suggestionList = [];
  List selected = [];
  ScrollController _scrollController = new ScrollController();
  int offset = 0;
  bool _noMore = false;
  TextEditingController query = new TextEditingController();
  String hintText = '请输入设备名称/型号/序列';

  void initState() {
    getData('');
    super.initState();
    switch (widget.searchType) {
      case SearchType.DEVICE:
        setState(() {
          hintText = '请输入设备名称/型号/序列';
        });
        break;
      case SearchType.DEPARTMENT:
        setState(() {
          hintText = '请输入科室名称/拼音/ID';
        });
        break;
    }
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        var _length = suggestionList.length;
        offset += 20;
        getData(query.text).then((result) {
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

  Future<Null> getData(String filter) async {
    String _url;
    Map<String, dynamic> _params;
    switch (widget.searchType) {
      case SearchType.DEVICE:
        _url = '/Equipment/Getdevices';
        _params = {
          'filterText': filter,
          'filterField': 'e.Name',
          'departmentId': -1,
          'CurRowNum': offset,
          'PageSize': 20
        };
        break;
      case SearchType.DEPARTMENT:
        _url = '/User/GetDepartments';
        _params = {
          'filterText': filter,
          'CurRowNum': offset,
          'PageSize': 20
        };
        break;
    }
    var resp = await HttpRequest.request(
        _url,
        method: HttpRequest.GET,
        params: _params
    );
    if (resp['ResultCode'] == '00') {
      setState(() {
        suggestionList.addAll(resp['Data']);
      });
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: Colors.grey,), onPressed: () {
          Navigator.of(context).pop();
        }),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.cancel, color: Colors.grey,),
            onPressed: () {
              query.clear();
            },
          )
        ],
        title: TextField(
          controller: query,
          focusNode: new FocusNode(),
          textInputAction: TextInputAction.search,
          onSubmitted: (String _) {
          },
          onChanged: (val) {
            setState(() {
              offset = 0;
              suggestionList.clear();
            });
            getData(val);
          },
          decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hintText,
              hintStyle: TextStyle(
                  fontSize: 16.0,
                  color: Colors.grey
              )//theme.inputDecorationTheme.hintStyle,
          ),
        ),
      ),
      body: Container(
        height: 1200.0,
        child: ListView.builder(
          controller: _scrollController,
          itemCount: suggestionList.length>=20?suggestionList.length+1:suggestionList.length,
          itemBuilder: (context, i) {
            if (i != suggestionList.length) {
              return ListTile(
                title: Text(widget.searchType==SearchType.DEPARTMENT?'${suggestionList[i]['Description']}-${suggestionList[i]['DepartmentType']['Name']}':'${suggestionList[i]['Name']}/${suggestionList[i]['EquipmentCode']}/${suggestionList[i]['SerialCode']}',
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.grey
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop(jsonEncode(suggestionList[i]));
                },
              );
            } else {
              return _noMore?new Center(child: new Text(widget.searchType==SearchType.DEVICE?'没有更多设备':'没有更多科室'),):new SpinKitThreeBounce(color: Colors.blue,);
            }
          },
        ),
      )
    );
  }
}

enum SearchType {
  DEVICE,
  DEPARTMENT
}