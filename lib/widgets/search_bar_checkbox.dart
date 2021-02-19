import 'package:flutter/material.dart';
import 'package:atoi/models/models.dart';
import 'package:scoped_model/scoped_model.dart';
import 'dart:convert';
import 'package:atoi/utils/http_request.dart';

/// 带复选框的搜索页面类
class SearchBarCheckBoxDelegate extends SearchDelegate<String>{

  static const searchList = [];

  static const recentSuggest = [];

  var suggestionList = [];
  List selected = [];
  bool value = false;
  SearchModel model;

  Future<Null> getDevices(String filter) async {
    var resp = await HttpRequest.request(
        '/Equipment/Getdevices',
        method: HttpRequest.GET,
        params: {
          'filterText': filter,
          'filterField': 'e.ID',
          'departmentId': -1
        }
    );
    print(resp);
    if (resp['ResultCode'] == '00') {
      suggestionList = resp['Data'];
    }
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
    close(context, jsonEncode(selected));
  }

  void checkIt(bool val, Map item) {
    val?selected.add(item):selected.remove(item);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder(
      builder: (context, snapshot) {
        model = MainModel.of(context);
        return ListView.builder(
            itemCount: suggestionList.length,
            itemBuilder: (context, i) {
              return CheckboxListTile(
                value: model.selected.contains(suggestionList[i])?true:false,
                title: RichText(
                  text: TextSpan(
                      text: '${suggestionList[i]['Name']}/${suggestionList[i]['ModelCode']}/${suggestionList[i]['SerialCode']}',
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w400),
                      children: [
                      ])),
                onChanged: (bool value) {
                  print(value);
                  value?model.addToSelected(suggestionList[i]):model.removeSelected(suggestionList[i]);
                },
              );
            }
        );
      },
      future: getDevices(query),
    );
  }
}
