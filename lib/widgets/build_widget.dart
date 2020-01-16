import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

/// 页面通用组件构建类
class BuildWidget {

  /// 构建页面信息行
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

  /// 构建列表信息行
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

  /// 构建常用下拉菜单（4、6分）
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

  /// 构建常用输入框（4、6分）
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

  /// 构建左对齐输入框
  static Padding buildInputLeft(String labelText, TextEditingController controller, {TextInputType inputType, int lines, int maxLength}) {
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
              alignment: WrapAlignment.start,
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
            flex: 7,
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

  /// 构建左对齐下拉菜单
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

  /// 构建带输入框的下拉菜单
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
            enabled: currentItem=='无'?false:true,
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

  /// 构建懒加载动画
  static Row buildListLoading(bool loading) {
    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        loading?new SpinKitChasingDots(color: Colors.blue,):new Text('没有更多')
      ],
    );
  }

  /// 构建输入开关
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

  /// 构建输入单选
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

  /// 构建垂直输入单选框
  static Padding buildRadioVert(String labelText, List groupValue, String currentValue, Function changeValue) {
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
              child: new Column(
                children: <Widget>[
                  new Row(
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
                  ),
                  groupValue.length==2?new Row(
                    children: <Widget>[
                      new Radio(
                        value: groupValue[1],
                        groupValue: currentValue,
                        onChanged: changeValue,
                      ),
                      new Text(groupValue[1])
                    ],
                  ):new Container()
                ],
              )
          ),
        ],
      ),
    );
  }

  /// 构建左对齐单选框
  static Padding buildRadioLeft(String labelText, List groupValue, String currentValue, Function changeValue) {
    return new Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: new Row(
        children: <Widget>[
          new Expanded(
            flex: 4,
            child: new Wrap(
              alignment: WrapAlignment.start,
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
              flex: 4,
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