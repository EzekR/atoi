import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SuperHome extends StatefulWidget {
  _SuperHomeState createState() => _SuperHomeState();
}

class _SuperHomeState extends State<SuperHome> {

  void initState() {
    super.initState();
  }

  Widget build (BuildContext context) {
    return Scaffold(
      backgroundColor: new Color(0xfffafafa),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        elevation: 0.7,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Theme.of(context).accentColor,
                new Color(0xff4e8faf)
              ],
            ),
          ),
        ),
      ),
    );
  }

}