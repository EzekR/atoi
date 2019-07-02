import 'package:flutter/material.dart';
import 'package:atoi/models/models.dart';
import 'package:scoped_model/scoped_model.dart';


class SearchBarDelegate extends SearchDelegate<String> {

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
    print(mainModel.result);
    close(context, null);
  }
  
  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList = query.isEmpty
        ? recentSuggest
        : searchList.where((input) => input.startsWith(query)).toList();
    return ListView.builder(
        itemCount: suggestionList.length,
        itemBuilder: (context, index) => ListTile(

          onTap: (){
            query = suggestionList[index];
            showResults(context);},

          title: RichText(
              text: TextSpan(
                  text: suggestionList[index].substring(0, query.length),
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(
                        text: suggestionList[index].substring(query.length),
                        style: TextStyle(color: Colors.grey))
                  ])),
        ));
  }
}
