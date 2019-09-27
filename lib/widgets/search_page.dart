import 'package:flutter/material.dart';
import 'package:floating_search_bar/floating_search_bar.dart';
import 'package:atoi/utils/http_request.dart';

class SearchPage extends StatefulWidget {
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  var suggestionList = [];
  List<Map> selected = [];
  String query = '';

  void initState() {
    getDevices('');
    super.initState();
  }

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

  Widget build(BuildContext context) {
    return FloatingSearchBar.builder(
      itemCount: suggestionList.length,
      itemBuilder: (BuildContext context, int i) {
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
            setState(() {
              value?selected.add(suggestionList[i]):selected.remove(suggestionList[i]);
            });
          },
        );
      },
      leading: new IconButton(icon: new Icon(Icons.arrow_back), onPressed: () {
        Navigator.of(context).pop(selected);
      },),
      trailing: FlatButton(onPressed: () {}, child: new Text('搜索')),
      onChanged: (String value) {
        setState(() {
          query = value;
        });
        getDevices(query);
      },
      onTap: () {},
      decoration: InputDecoration.collapsed(
        hintText: "",
      ),
    );
  }
}
