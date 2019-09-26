import 'package:flutter/material.dart';
import 'package:floating_search_bar/floating_search_bar.dart';
import 'package:atoi/utils/http_request.dart';

class SearchPage extends StatefulWidget {
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  var suggestionList = [];

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
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          leading: Text(suggestionList[index]['Name']),
        );
      },
      trailing: FlatButton(onPressed: () {}, child: new Text('搜索')),
      onChanged: (String value) {
        print(value);
        getDevices(value);
      },
      onTap: () {},
      decoration: InputDecoration.collapsed(
        hintText: "",
      ),
    );
  }
}
