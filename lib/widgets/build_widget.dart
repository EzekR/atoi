import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:photo_view/photo_view.dart';
import 'dart:typed_data';
import 'dart:io';

/// 页面通用组件构建类
class BuildWidget {


  /// 构建页面信息行
  static GestureDetector buildRow(String labelText, String defaultText, {Function onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: new Padding(
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
                        fontSize: 16.0,
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
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            new Expanded(
              flex: 6,
              child: new Text(
                defaultText,
                style: new TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w400,
                    color: onTap==null?Colors.black54:Color(0xff2c5c85)
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  /// 构建列表信息行
  static GestureDetector buildCardRow(String leading, String content, {Function onTap}) {
    return new GestureDetector(
      onTap: onTap,
      child: new Row(
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
                  color: onTap==null?Colors.grey:Color(0xff2c5c85)
              ),
            ),
          )
        ],
      ),
    );
  }

  static GestureDetector buildCardInput(String leading, TextEditingController content, {Function onTap, bool required}) {
    required = required??false;
    return new GestureDetector(
      onTap: onTap,
      child: new Row(
        children: <Widget>[
          new Expanded(
              flex: 3,
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  required?new Text(
                    '*',
                    style: TextStyle(
                      color: Colors.red
                    ),
                  ):Container(),
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
            child: new TextField(
              controller: content,
              maxLength: 20,
              maxLines: 1,
            ),
          )
        ],
      ),
    );
  }

  static Row buildCardDropdown(String title, int currentItem, List dropdownItems, Function changeDropdown, {bool required}) {
    return new Row(
      children: <Widget>[
        new Expanded(
          flex: 3,
          child: new Wrap(
            alignment: WrapAlignment.end,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              required?new Text(
                '*',
                style: new TextStyle(
                    color: Colors.red
                ),
              ):Container(),
              new Text(
                title,
                style: new TextStyle(
                    fontSize: 16.0,
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
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        new Expanded(
          flex: 7,
          child: new DropdownButton(
            value: currentItem,
            items: dropdownItems.map<DropdownMenuItem>((item) {
              return DropdownMenuItem(
                value: item['value'],
                child: Text(
                  item['text'],
                  style: TextStyle(
                      fontSize: 12.0
                  ),
                ),
              );
            }).toList(),
            onChanged: changeDropdown,
            style: new TextStyle(
              color: Colors.black54,
              fontSize: 12.0,
            ),
          ),
        ),
      ],
    );
  }

  /// 构建常用下拉菜单（4、6分）
  static GestureDetector buildDropdown(String title, String currentItem, List dropdownItems, Function changeDropdown, {FocusNode focusNode, BuildContext context, bool required}) {
    //if (context != null) {
    //  FocusScope.of(context).requestFocus(new FocusNode());
    //}
    required = required??false;
    return new GestureDetector(
      onTap: () {
        print('dropdown tab');
      },
      child: new Row(
        children: <Widget>[
          new Expanded(
            flex: 4,
            child: new Wrap(
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                required?new Text(
                  '*',
                  style: new TextStyle(
                    color: Colors.red
                  ),
                ):Container(),
                new Text(
                  title,
                  style: new TextStyle(
                      fontSize: 16.0,
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
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          new Expanded(
              flex: 6,
              child: new GestureDetector(
                onTap: () {
                },
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
          )
        ],
      ),
    );
  }

  /// 构建常用输入框（4、6分）
  static Padding buildInput(String labelText, TextEditingController controller, {TextInputType inputType, int lines, int maxLength, FocusNode focusNode, Function tapEvent, bool required}) {
    inputType??TextInputType.text;
    lines = lines ?? 3;
    maxLength = maxLength ?? 30;
    focusNode = focusNode ?? new FocusNode();
    required = required??false;
    return new Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: new Row(
        children: <Widget>[
          new Expanded(
            flex: 4,
            child: new Wrap(
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.start,
              children: <Widget>[
                required?new Text(
                  '*',
                  style: new TextStyle(
                      color: Colors.red
                  ),
                ):Container(),
                new Text(
                  labelText,
                  style: new TextStyle(
                      fontSize: 16.0,
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
                fontSize: 16.0,
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
              focusNode: focusNode,
              //textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                fillColor: Color(0xfff0f0f0),
                filled: true,
              ),
              onSubmitted: (_) {
                //focusNode.unfocus();
              },
              onTap: () {
                focusNode.requestFocus();
              },
            ),
          )
        ],
      ),
    );
  }

  /// 构建左对齐输入框
  static Padding buildInputLeft(String labelText, TextEditingController controller, {TextInputType inputType, int lines, int maxLength, FocusNode focusNode, bool required}) {
    inputType??TextInputType.text;
    lines = lines ?? 3;
    maxLength = maxLength ?? 30;
    focusNode = focusNode ?? new FocusNode();
    required = required??false;
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
                required?new Text(
                  '*',
                  style: new TextStyle(
                      color: Colors.red
                  ),
                ):Container(),
                new Text(
                  labelText,
                  style: new TextStyle(
                      fontSize: 16.0,
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
              focusNode: focusNode,
              decoration: InputDecoration(
                fillColor: Color(0xfff0f0f0),
                filled: true,
              ),
              onTap: () {
                focusNode.requestFocus();
              },
            ),
          )
        ],
      ),
    );
  }

  /// 构建左对齐下拉菜单
  static Row buildDropdownLeft(String title, String currentItem, List dropdownItems, Function changeDropdown, {FocusNode focusNode, BuildContext context, bool required}) {
    //if (context != null) {
    //  FocusScope.of(context).requestFocus(new FocusNode());
    //}
    required = required??false;
    return new Row(
      children: <Widget>[
        new Expanded(
          flex: 4,
          child: new Wrap(
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              required?new Text(
                '*',
                style: new TextStyle(
                    color: Colors.red
                ),
              ):Container(),
              new Text(
                title,
                style: new TextStyle(
                    fontSize: 16.0,
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
  static Row buildDropdownWithInput(String title, TextEditingController controller, String currentItem, List dropdownItems, Function changeDropdown, Function showPeriod, {TextInputType inputType, FocusNode focusNode, BuildContext context, bool required}) {
    inputType??TextInputType.text;
    focusNode = focusNode ?? new FocusNode();
    //if (context != null) {
    //  FocusScope.of(context).requestFocus(new FocusNode());
    //}
    required = required??false;
    return new Row(
      children: <Widget>[
        new Expanded(
          flex: 4,
          child: new Wrap(
            alignment: WrapAlignment.end,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              required?new Text(
                '*',
                style: new TextStyle(
                    color: Colors.red
                ),
              ):Container(),
              new Text(
                title,
                style: new TextStyle(
                    fontSize: 16.0,
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
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        new Expanded(
          flex: 2,
          child: new TextField(
            controller: controller,
            keyboardType: inputType,
            enabled: currentItem=='无'?false:true,
            focusNode: focusNode,
            decoration: InputDecoration(
              fillColor: Color(0xfff0f0f0),
              filled: true,
            ),
          ),
        ),
        new Expanded(
          flex: 2,
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 5,
              ),
              new DropdownButton(
                value: currentItem,
                items: dropdownItems,
                style: new TextStyle(
                    fontSize: 10.0,
                    color: Colors.black
                ),
                onChanged: changeDropdown,
              ),
            ],
          )
        ),
        new Expanded(
          flex: 2,
          child: IconButton(icon: Icon(Icons.calendar_today), onPressed: showPeriod),
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
  static Padding buildSwitch(String labelText, Function switchMethod, {FocusNode focusNode, bool required}) {
    focusNode = focusNode??new FocusNode();
    required = required??false;
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
                required?new Text(
                  '*',
                  style: new TextStyle(
                      color: Colors.red
                  ),
                ):Container(),
                new Text(
                  labelText,
                  style: new TextStyle(
                      fontSize: 16.0,
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
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          new Expanded(
            flex: 6,
            child: new Switch.adaptive(
                value: true,
                focusNode: focusNode,
                onChanged: switchMethod
            )
          )
        ],
      ),
    );
  }

  /// 构建输入单选
  static Padding buildRadio(String labelText, List groupValue, String currentValue, Function changeValue, {bool required}) {
    required = required??false;
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
                required?new Text(
                  '*',
                  style: new TextStyle(
                      color: Colors.red
                  ),
                ):Container(),
                new Text(
                  labelText,
                  style: new TextStyle(
                      fontSize: 16.0,
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
                fontSize: 16.0,
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
  static Padding buildRadioVert(String labelText, List groupValue, String currentValue, Function changeValue,{bool required}) {
    required = required??false;
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
                required?new Text(
                  '*',
                  style: new TextStyle(
                      color: Colors.red
                  ),
                ):Container(),
                new Text(
                  labelText,
                  style: new TextStyle(
                      fontSize: 16.0,
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
                fontSize: 16.0,
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
  static Padding buildRadioLeft(String labelText, List groupValue, String currentValue, Function changeValue, {bool required}) {
    required = required??false;
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
                required?new Text(
                  '*',
                  style: new TextStyle(
                      color: Colors.red
                  ),
                ):Container(),
                new Text(
                  labelText,
                  style: new TextStyle(
                      fontSize: 16.0,
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

  /// 构建可放大缩小的图片
  static PhotoView buildFilePhoto(File image) {
    return PhotoView(
      imageProvider: FileImage(image),
      backgroundDecoration: BoxDecoration(
        color: Colors.white
      ),
    );
  }

  static PhotoView buildListPhoto(List<int> image) {
    return PhotoView(
      imageProvider: MemoryImage(Uint8List.fromList(image)),
      backgroundDecoration: BoxDecoration(
        color: Colors.white
      ),
    );
  }

  static GestureDetector buildPhotoPageList(BuildContext context, List<int> image) {
    //final List<int> _image = Uint8List.fromList(image);
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(new MaterialPageRoute(builder: (_) =>
            FullScreenWrapper(
              imageProvider: MemoryImage(Uint8List.fromList(image)),
              backgroundDecoration: BoxDecoration(
                color: Colors.white
              ),
            )
        ));
      },
      child: Image.memory(image),
    );
  }

  static GestureDetector buildPhotoPageFile(BuildContext context, File image) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(new MaterialPageRoute(builder: (_) =>
            FullScreenWrapper(
              imageProvider: FileImage(image),
              backgroundDecoration: BoxDecoration(
                  color: Colors.white
              ),
            )
        ));
      },
      child: Image.file(image),
    );
  }

  static GestureDetector buildDropdownWithSearch(String title, String currentItem, List dropdownItems, Function changeDropdown, {FocusNode focusNode, BuildContext context, Function search, bool required}) {
    required = required??false;
    focusNode = focusNode??new FocusNode();
    //if (context != null) {
    //  FocusScope.of(context).requestFocus(new FocusNode());
    //}
    return new GestureDetector(
      onTap: () {
        print('dropdown tab');
      },
      child: new Row(
        children: <Widget>[
          new Expanded(
            flex: 4,
            child: new Wrap(
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                required?new Text(
                  '*',
                  style: new TextStyle(
                      color: Colors.red
                  ),
                ):Container(),
                new Text(
                  title,
                  style: new TextStyle(
                      fontSize: 16.0,
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
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          new Expanded(
              flex: 5,
              child: new GestureDetector(
                onTap: () {
                },
                child: new DropdownButton(
                  value: currentItem,
                  items: dropdownItems,
                  onChanged: changeDropdown,
                  style: new TextStyle(
                    color: Colors.black54,
                    fontSize: 12.0,
                  ),
                  focusNode: focusNode,
                  //isDense: true,
                  //isExpanded: true,
                ),
              )
          ),
          new Expanded(
              flex: 1,
              child: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    search();
                  }
              )
          )
        ],
      ),
    );
  }
}

class FullScreenWrapper extends StatelessWidget {
  const FullScreenWrapper({
    this.imageProvider,
    this.backgroundDecoration,
    this.minScale,
    this.maxScale,
    this.initialScale,
    this.basePosition = Alignment.center,
    this.filterQuality = FilterQuality.none,
  });

  final ImageProvider imageProvider;
  final Decoration backgroundDecoration;
  final dynamic minScale;
  final dynamic maxScale;
  final dynamic initialScale;
  final Alignment basePosition;
  final FilterQuality filterQuality;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        constraints: BoxConstraints.expand(
          height: MediaQuery.of(context).size.height,
        ),
        child: PhotoView(
          imageProvider: imageProvider,
          backgroundDecoration: backgroundDecoration,
          minScale: minScale,
          maxScale: maxScale,
          initialScale: initialScale,
          basePosition: basePosition,
        ),
      ),
    );
  }
}