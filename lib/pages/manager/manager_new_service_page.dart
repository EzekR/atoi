import 'package:flutter/material.dart';
import 'package:atoi/widgets/search_bar.dart';

class ManagerNewServicePage extends StatefulWidget{
  static String tag = 'manager-new-service-page';
  final String type;

  ManagerNewServicePage({this.type});

  _ManagerNewServicePageState createState() => new _ManagerNewServicePageState();
}

class _ManagerNewServicePageState extends State<ManagerNewServicePage> {

  SearchBarDelegate searchResult;


  Widget build(BuildContext context) {

    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.type),
        elevation: 0.7,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).accentColor
              ],
            ),
          ),
        ),
        actions: <Widget>[
          new IconButton(
            icon: Icon(Icons.search),
            color: Colors.white,
            iconSize: 30.0,
            onPressed: () =>
                showSearch(context: context, delegate: SearchBarDelegate())
            ,
          ),
          new IconButton(
              icon: Icon(Icons.crop_free),
              color: Colors.white,
              iconSize: 30.0,
              onPressed: () {})
        ],
      ),
    );
  }
}

