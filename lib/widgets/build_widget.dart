import 'package:flutter/material.dart';

class BuildWidget {

  static Padding buildRow(String labelText, String defaultText) {
    return new Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: new Row(
        children: <Widget>[
          new Expanded(
            flex: 4,
            child: new Wrap(
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                new Text(
                  labelText,
                  style: new TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w600
                  ),
                )
              ],
            ),
          ),
          new Expanded(
            flex: 1,
            child: new Text(
              '：',
              style: new TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          new Expanded(
            flex: 6,
            child: new Text(
              defaultText,
              style: new TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w400,
                  color: Colors.black54
              ),
            ),
          )
        ],
      ),
    );
  }

  static Row buildCardRow(String leading, String content) {
    return new Row(
      children: <Widget>[
        new Expanded(
          flex: 3,
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              new Text(
                leading,
                style: new TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600
                ),
              ),
            ],
          )
        ),
        new Expanded(
          flex: 1,
          child: new Text(':',
            style: new TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w600
            ),
          )
        ),
        new Expanded(
          flex: 7,
          child: new Text(
            content,
            style: new TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w400,
                color: Colors.grey
            ),
          ),
        )
      ],
    );
  }

  static Row buildDropdown(String title, String currentItem, List dropdownItems, Function changeDropdown) {
    return new Row(
      children: <Widget>[
        new Expanded(
          flex: 3,
          child: new Wrap(
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              new Text(
                title,
                style: new TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w600
                ),
              )
            ],
          ),
        ),
        new Expanded(
          flex: 1,
          child: new Text(
            '：',
            style: new TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        new Expanded(
          flex: 6,
          child: new DropdownButton(
            value: currentItem,
            items: dropdownItems,
            onChanged: changeDropdown,
          ),
        )
      ],
    );
  }
}