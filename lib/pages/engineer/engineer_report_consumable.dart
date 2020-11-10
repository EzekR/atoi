import 'package:flutter/material.dart';

class EngineerReportConsumable extends StatefulWidget {
  _EngineerReportConsumableState createState() => _EngineerReportConsumableState();
}

class _EngineerReportConsumableState extends State<EngineerReportConsumable> {

  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text('新增'),
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
      ),
    );
  }
}