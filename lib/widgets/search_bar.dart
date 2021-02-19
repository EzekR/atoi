import 'package:flutter/material.dart';
import 'package:atoi/models/models.dart';
import 'package:scoped_model/scoped_model.dart';
import 'dart:convert';
import 'package:atoi/utils/http_request.dart';

/// 搜索页面类
class SearchBarDelegate extends SearchDelegate<String>{

  static const searchList = [];

  static const recentSuggest = [];

  var suggestionList = [];
  var selected;
  int offset = 0;

  Future<Null> getDevices(String filter) async {
    var resp = await HttpRequest.request(
      '/Equipment/Getdevices',
      method: HttpRequest.GET,
      params: {
        'filterText': filter,
        'filterField': 'e.Name',
        'departmentId': -1,
        'PageSize': 10,
        'CurRowNum': offset
      }
    );
    print(resp);
    if (resp['ResultCode'] == '00') {
      suggestionList = resp['Data'];
    }
  }

  void getMore() {
    offset += 10;
    getDevices(query);
  }

  final Map<String, String> equipmentInfo = {};

  @override
  List<Widget> buildActions(BuildContext context) {
    return [IconButton(icon: Icon(Icons.clear), onPressed: () => query = "")];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        icon: AnimatedIcon(
            icon: AnimatedIcons.menu_arrow, progress: transitionAnimation),
            onPressed: () => close(context, null));
  }


  @override
  Widget buildResults(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (context, child, mainModel) {
        return Center(
          child: Container(
            width: 100.0,
            height: 100.0,
            child: Card(
              color: Colors.redAccent,
              child: Center(
                child: Text(query),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void showResults(BuildContext context) {
    Map<String, String> mutated = {
      'equipNo': '10086',
      'equipLevel': '重要',
      'name': '医用磁共振设备',
      'model': 'Philips 781-296',
      'department': '磁共振',
      'location': '磁共振1室',
      'manufacturer': '飞利浦',
      'guarantee': '保内'
    };
    MainModel mainModel = ScopedModel.of<MainModel>(context);
    mainModel.setResult(mutated);
    close(context, jsonEncode(selected));
  }
  
  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder(
      builder: (context, snapshot) {
        return ListView.builder(
            itemCount: suggestionList.length>=10?suggestionList.length+1:suggestionList.length,
            itemBuilder: (context, i) {
              if (i != suggestionList.length) {
                return ListTile(
                  onTap: (){
                    query = suggestionList[i]['Name'];
                    selected = suggestionList[i];
                    showResults(context);
                  },
                  title: RichText(
                      text: TextSpan(
                          text: '${suggestionList[i]['Name']}/${suggestionList[i]['ModelCode']}/${suggestionList[i]['SerialCode']}',
                          style: TextStyle(
                              color: Colors.grey),
                          children: [
                          ])),
                );
              } else {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    FlatButton(
                      child: Text(
                        '点击获取更多设备',
                        style: TextStyle(
                          fontSize: 10.0,
                        ),
                      ),
                      onPressed: () {
                        getMore();
                      },
                    )
                  ],
                );
              }
            });
      },
      future: getDevices(query),
    );
  }
}
