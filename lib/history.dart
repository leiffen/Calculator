import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dialog.dart';

class History extends StatefulWidget {
  const History({Key key, this.primaryColor}) : super(key: key);

  final Color primaryColor;

  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  final String fileName = "/history.json";

  List data = [];
  File jsonFile;

  @override
  void initState() {
    super.initState();
    getApplicationDocumentsDirectory().then((Directory directory) {
      jsonFile = new File(directory.path + fileName);
      if (jsonFile.existsSync()) {
        this.setState(() {
          data = jsonDecode(jsonFile.readAsStringSync());
        });
      }
    });
  }

  void clearHistory() {
    jsonFile.writeAsStringSync(jsonEncode([]));
    setState(() {
      data = [];
    });
  }

  List<Widget> list() {
    List<Widget> widgetList = new List<Widget>();
    data.forEach( (dateObjects) {
      dateObjects['values'].forEach( (val) {
        widgetList.add(
          Card(
            color: Colors.black,
            child: Padding (
              padding: EdgeInsets.only(top: 10.0, bottom: 10.0, right: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    val['formula'],
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 20,),
                  ),
                  Text(
                    val['result'],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,),
                  )
                ],
              ),
            ),
          )
        );
      });
      widgetList.add(
          Card(
            color: Colors.black,
            child: Padding (
              padding: EdgeInsets.only(top: 10.0, bottom: 10.0, left: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    dateObjects['date'].split(' ')[0],
                    style: TextStyle(
                      color: widget.primaryColor,
                      fontSize: 20,),
                  ),
                ],
              ),
            ),
          )
      );
    });
    return widgetList;
  }

  @override
  Widget build(BuildContext context) {
    Dialogs dialog = new Dialogs();
    return Scaffold(
      appBar: AppBar(
        title: Text("History"),
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back,
          ),
        ),
        actions: <Widget>[
          Padding(
              padding: EdgeInsets.only(right: 10.0),
              child: GestureDetector(
                onTap: () {
                  dialog.ok(context, "Clear History", "Are you sure to clear all history?", "Clear", clearHistory);
                },
                child: Icon(
                  Icons.delete,
                  size: 26.0,
                ),
              )),
        ],
      ),
      body: Container(
        color: Colors.black,
        child: Center(
          child: ListView(
            reverse: true,
            children: list(),
          ),
        ),
      ),
    );
  }
}
