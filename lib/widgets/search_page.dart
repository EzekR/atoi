import 'package:flutter/material.dart';
import 'package:floating_search_bar/floating_search_bar.dart';
import 'package:atoi/utils/http_request.dart';

class SearchPage extends StatefulWidget {

  SearchPage({Key key, this.equipments}):super(key: key);

  final List equipments;

  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  var suggestionList = [];
  List selected = [];
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
    setState(() {
      suggestionList = resp['Data'];
    });
    print('equips:${widget.equipments}');
    if (widget.equipments != null) {
      setState(() {
        for(var item in widget.equipments) {
          selected.add(item);
        }
      });
    }
  }

  Widget build(BuildContext context) {
    return FloatingSearchBar.builder(
      itemCount: suggestionList.length,
      itemBuilder: (BuildContext context, int i) {
        return CheckboxListTile(
          value: selected.firstWhere((item) => item['SerialCode'] == suggestionList[i]['SerialCode'], orElse: ()=>null)!=null?true:false,
          title: RichText(
              text: TextSpan(
                  text: '${suggestionList[i]['Name']}/${suggestionList[i]['EquipmentCode']}/${suggestionList[i]['SerialCode']}'.substring(0, query.length),
                  style: TextStyle(
                      color: Colors.grey ),
                  children: [
                    TextSpan(
                        text: '${suggestionList[i]['Name']}/${suggestionList[i]['EquipmentCode']}/${suggestionList[i]['SerialCode']}'.substring(query.length),
                        style: TextStyle(color: Colors.grey))
                  ])),
          onChanged: (bool value) {
            setState(() {
              value?selected.add(suggestionList[i]):selected.removeWhere((item) => item['SerialCode']==suggestionList[i]['SerialCode']);
            });
          },
        );
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
        hintText: "请输入设备名称/型号/序列号",
        hintStyle: new TextStyle(
          fontSize: 14.0,
          color: Colors.grey,
          fontWeight: FontWeight.w600
        )
      ),
    );
  }
}
