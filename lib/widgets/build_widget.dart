import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

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
          flex: 4,
          child: new Wrap(
            alignment: WrapAlignment.end,
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
            style: new TextStyle(
              color: Colors.black54,
              fontSize: 12.0,
            ),
            //isDense: true,
            //isExpanded: true,
          ),
        )
      ],
    );
  }

  static Padding buildInput(String labelText, TextEditingController controller, {TextInputType inputType, int lines, int maxLength}) {
    inputType??TextInputType.text;
    lines = lines ?? 3;
    maxLength = maxLength ?? 30;
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
            child: new TextField(
              controller: controller,
              maxLines: lines,
              maxLength: maxLength,
              keyboardType: inputType,
              decoration: InputDecoration(
                fillColor: Color(0xfff0f0f0),
                filled: true,
              ),
            ),
          )
        ],
      ),
    );
  }

  static Row buildDropdownLeft(String title, String currentItem, List dropdownItems, Function changeDropdown) {
    return new Row(
      children: <Widget>[
        new Expanded(
          flex: 4,
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

  static Row buildDropdownWithInput(String title, TextEditingController controller, String currentItem, List dropdownItems, Function changeDropdown, {TextInputType inputType}) {
    inputType??TextInputType.text;
    return new Row(
      children: <Widget>[
        new Expanded(
          flex: 4,
          child: new Wrap(
            alignment: WrapAlignment.end,
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
          flex: 3,
          child: new TextField(
            controller: controller,
            keyboardType: inputType,
            decoration: InputDecoration(
              fillColor: Color(0xfff0f0f0),
              filled: true,
            ),
          ),
        ),
        new Expanded(
          flex: 1,
          child: new Text(' '),
        ),
        new Expanded(
          flex: 2,
          child: new DropdownButton(
            value: currentItem,
            items: dropdownItems,
            style: new TextStyle(
              fontSize: 12.0,
              color: Colors.black
            ),
            onChanged: changeDropdown,
          ),
        )
      ],
    );
  }

  static Row buildListLoading(bool loading) {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        loading?new SpinKitChasingDots(color: Colors.blue,):new Text('没有更多')
      ],
    );
  }

  static Padding buildSwitch(String labelText, Function switchMethod) {
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
            child: new Switch.adaptive(
                value: true,
                onChanged: switchMethod
            )
          )
        ],
      ),
    );
  }

  static Padding buildRadio(String labelText, List groupValue, String currentValue, Function changeValue) {
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
              flex: 3,
              child: new Row(
                children: <Widget>[
                  new Radio(
                    value: groupValue[0],
                    groupValue: currentValue,
                    onChanged: changeValue,
                  ),
                  new Align(
                    alignment: Alignment(-10.0, 0),
                    child: new Text(groupValue[0])
                  ),
                ],
              )
          ),
          new Expanded(
              flex: 3,
              child: new Row(
                children: <Widget>[
                  new Radio(
                    value: groupValue[1],
                    groupValue: currentValue,
                    onChanged: changeValue,
                  ),
                  new Text(groupValue[1])
                ],
              )
          ),
        ],
      ),
    );
  }
}