import 'package:flutter/material.dart';
import 'package:atoi/models/models.dart';
import 'package:scoped_model/scoped_model.dart';
import 'dart:convert';
import 'package:atoi/utils/http_request.dart';

class SearchBarCheckBoxDelegate extends SearchDelegate<String>{

  static const searchList = [
    "ChengDu",
    "ShangHai",
    "BeiJing",
    "TianJing",
    "NanJing",
    "ShenZheng"
  ];

  static const recentSuggest = [
    "编号：0000001",
    "编号：0000002"
  ];

  var suggestionList = [];
  List selected = [];
  bool value = false;

  Future<Null> getDevices(String filter) async {
    var resp = await HttpRequest.request(
        '/Equipment/Getdevices',
        method: HttpRequest.GET,
        params: {
          'filterText': filter
        }
    );
    print(resp);
    suggestionList = resp['Data'];
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

  void checkIt(bool val, Map item) {
    val?selected.add(item):selected.remove(item);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder(
      builder: (context, snapshot) {
        return ListView.builder(
            itemCount: suggestionList.length,
            itemBuilder: (context, i) {
              return CheckboxListTile(
                value: selected.contains(suggestionList[i])?true:false,
                title: RichText(
                  text: TextSpan(
                      text: '${suggestionList[i]['Name']}/${suggestionList[i]['EquipmentCode']}/${suggestionList[i]['SerialCode']}'.substring(0, query.length),
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                      children: [
                        TextSpan(
                            text: '${suggestionList[i]['Name']}/${suggestionList[i]['EquipmentCode']}/${suggestionList[i]['SerialCode']}'.substring(query.length),
                            style: TextStyle(color: Colors.grey))
                      ])),
                onChanged: (bool value) {
                  print(value);
                  print(this);
                  checkIt(value, suggestionList[i]);
                },
              );
            }
//                ListTile(
//              onTap: (){
//                query = suggestionList[i]['Name'];
//                selected = suggestionList[i];
//                showResults(context);
//              },
//              title: RichText(
//                  text: TextSpan(
//                      text: '${suggestionList[i]['Name']}/${suggestionList[i]['EquipmentCode']}/${suggestionList[i]['SerialCode']}'.substring(0, query.length),
//                      style: TextStyle(
//                          color: Colors.black, fontWeight: FontWeight.bold),
//                      children: [
//                        TextSpan(
//                            text: '${suggestionList[i]['Name']}/${suggestionList[i]['EquipmentCode']}/${suggestionList[i]['SerialCode']}'.substring(query.length),
//                            style: TextStyle(color: Colors.grey))
//                      ])),
//            )
        );
      },
      future: getDevices(query),
    );
  }
}
