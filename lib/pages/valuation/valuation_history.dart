import 'package:atoi/utils/http_request.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';

class ValuationHistory extends StatefulWidget {

  _ValuationHistoryState createState() => new _ValuationHistoryState();
}

class _ValuationHistoryState extends State<ValuationHistory> {

  ScrollController _scrollController = new ScrollController();
  List executions = [];
  int offset = 0;
  bool _noMore = false;
  bool _loading = false;
  TextEditingController _keywords = new TextEditingController();
  String field = 'sp.ID';
  String startDate;
  String endDate;

  Future<Null> getHistory() async {
    Map resp = await HttpRequest.request(
      '/Valuation/QueryValHistory',
      method: HttpRequest.GET,
      params: {
        'CurRowNum': offset,
        'PageSize': 10
      }
    );
    if (resp['ResultCode'] == '00') {
      setState(() {
        executions.addAll(resp['Data']);
      });
    }
  }

  void initState() {
    super.initState();
    startDate = formatDate(DateTime.now().add(Duration(days: -30)), [yyyy, '-', mm, '-', dd]);
    endDate = formatDate(DateTime.now(), [yyyy, '-', mm, '-', dd]);
    getHistory();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        var _length = executions.length;
        offset += 10;
        getHistory().then((result) {
          if (executions.length == _length) {
            setState(() {
              _noMore = true;
            });
          } else {
            setState(() {
              _noMore = false;
            });
          }
        });
      }
    });
  }

  void showSheet(BuildContext context) {
    showModalBottomSheet(context: context, builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Column(
            children: <Widget>[
              Container(
                height: 300.0,
                child: ListView(
                  children: <Widget>[
                    SizedBox(height: 18.0,),
                    Row(
                      children: <Widget>[
                        SizedBox(width: 16.0,),
                        Text('搜索', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),)
                      ],
                    ),
                    SizedBox(height: 6.0,),
                    Row(
                      children: <Widget>[
                        SizedBox(width: 16.0,),
                        Container(
                            width: 230.0,
                            height: 40.0,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                              color: Color(0xfff2f2f2),
                            ),
                            child: Row(
                              children: <Widget>[
                                SizedBox(width: 10.0,),
                                Icon(Icons.search, color: Color(0xffaaaaaa),),
                                SizedBox(width: 10.0,),
                                Container(
                                    width: 150.0,
                                    child: Align(
                                      alignment: Alignment(0.0, -0.5),
                                      child: TextField(
                                        decoration: InputDecoration.collapsed(hintText: ''),
                                        controller: _keywords,
                                      ),
                                    )
                                ),
                              ],
                            )
                        ),
                        SizedBox(width: 16.0,),
                        Container(
                          width: 130.0,
                          height: 40.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0),
                            color: Color(0xfff2f2f2),
                          ),
                          child: Row(
                            children: <Widget>[
                              SizedBox(width: 6.0,),
                              DropdownButton(
                                value: field,
                                underline: Container(),
                                items: <DropdownMenuItem>[
                                  DropdownMenuItem(
                                    value: 'sp.ID',
                                    child: Text('系统编号'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'sp.SerialCode',
                                    child: Text('序列号'),
                                  ),
                                ],
                                onChanged: (val) {
                                  FocusScope.of(context).requestFocus(new FocusNode());
                                  setState(() {
                                    field = val;
                                  });
                                },
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 18.0,),
                    Row(
                      children: <Widget>[
                        SizedBox(width: 16.0,),
                        Text('添加日期', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),)
                      ],
                    ),
                    SizedBox(height: 6.0,),
                    Row(
                      children: <Widget>[
                        SizedBox(width: 16.0,),
                        Container(
                          width: 116.0,
                          height: 40.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0),
                            color: Color(0xfff2f2f2),
                          ),
                          child: Center(
                            child: FlatButton(
                                onPressed: () {
                                  FocusScope.of(context).requestFocus(new FocusNode());
                                  DatePicker.showDatePicker(
                                    context,
                                    pickerTheme: DateTimePickerTheme(
                                      showTitle: true,
                                      confirm: Text('确认', style: TextStyle(color: Colors.blueAccent)),
                                      cancel: Text('取消', style: TextStyle(color: Colors.redAccent)),
                                    ),
                                    minDateTime: DateTime.parse('2000-01-01'),
                                    maxDateTime: DateTime.parse('2030-01-01'),
                                    initialDateTime: DateTime.parse(startDate),
                                    dateFormat: 'yyyy-MM-dd',
                                    locale: DateTimePickerLocale.en_us,
                                    onClose: () => print(""),
                                    onCancel: () => print('onCancel'),
                                    onChange: (dateTime, List<int> index) {
                                    },
                                    onConfirm: (dateTime, List<int> index) {
                                      setState(() {
                                        startDate = formatDate(dateTime, [yyyy,'-', mm, '-', dd]);
                                      });
                                    },
                                  );
                                },
                                child: Text(startDate, style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12.0),)
                            ),
                          ),
                        ),
                        Text('   -   '),
                        Container(
                          width: 116.0,
                          height: 40.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0),
                            color: Color(0xfff2f2f2),
                          ),
                          child: Center(
                            child: FlatButton(
                                onPressed: () {
                                  FocusScope.of(context).requestFocus(new FocusNode());
                                  DatePicker.showDatePicker(
                                    context,
                                    pickerTheme: DateTimePickerTheme(
                                      showTitle: true,
                                      confirm: Text('确认', style: TextStyle(color: Colors.blueAccent)),
                                      cancel: Text('取消', style: TextStyle(color: Colors.redAccent)),
                                    ),
                                    minDateTime: DateTime.parse('2000-01-01'),
                                    maxDateTime: DateTime.parse('2030-01-01'),
                                    initialDateTime: DateTime.parse(endDate),
                                    dateFormat: 'yyyy-MM-dd',
                                    locale: DateTimePickerLocale.en_us,
                                    onClose: () => print(""),
                                    onCancel: () => print('onCancel'),
                                    onChange: (dateTime, List<int> index) {
                                    },
                                    onConfirm: (dateTime, List<int> index) {
                                      setState(() {
                                        endDate = formatDate(dateTime, [yyyy,'-', mm, '-', dd]);
                                      });
                                    },
                                  );
                                },
                                child: Text(endDate, style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12.0),)
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.0,),
                    SizedBox(height: 30.0,),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    width: 100.0,
                    height: 40.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      border: Border.all(
                          color: Color(0xff3394B9),
                          width: 1.0
                      ),
                      color: Color(0xffEBF9FF),
                    ),
                    child: Center(
                      child: FlatButton(onPressed: () {
                        setState((){
                          field = 'sp.ID';
                          _keywords.clear();
                        });
                      }, child: Text('重置')),
                    ),
                  ),
                  Container(
                    width: 100.0,
                    height: 40.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      color: Color(0xff3394B9),
                    ),
                    child: Center(
                      child: FlatButton(onPressed: () {
                        Navigator.of(context).pop();
                      }, child: Text('确认', style: TextStyle(color: Colors.white),)),
                    ),
                  ),
                ],
              )
            ],
          );
        },
      );
    });
  }

  Card buildHistoryCard(Map item) {
    return Card(
      child: Column(
        children: <Widget>[
          ListTile(
            onTap: () {
            },
            leading: Icon(
              Icons.add_to_photos,
              color: Color(0xff14BD98),
              size: 36.0,
            ),
            title: Text(
              "系统编号： ${item['ID']}",
              style: new TextStyle(
                  fontSize: 16.0,
                  color: Theme.of(context).primaryColor
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: Text('估价执行历史'),
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
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSheet(context);
            },
          )
        ],
      ),
      body: _loading?new Center(child: new SpinKitThreeBounce(color: Colors.blue,),):(executions.length==0?Center(child: Text('无执行历史'),):new ListView.builder(
        itemCount: executions.length>10?executions.length+1:executions.length,
        controller: _scrollController,
        itemBuilder: (context, i) {
          if (i !=executions.length) {
            return buildHistoryCard(executions[i]);
          } else {
            return new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _noMore?new Center(child: new Text('没有更多执行历史'),):new SpinKitChasingDots(color: Colors.blue,)
              ],
            );
          }
        },
      )),
    );
  }
}