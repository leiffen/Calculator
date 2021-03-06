import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'history.dart';

class Calculator extends StatefulWidget {
  Calculator({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _CalculatorState createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  final String historyFileName = "/history.json";
  final String themeFileName = "/theme.json";

  final RegExp regOps = new RegExp('[+|\\-|x|\u{00F7}]');
  final RegExp regOpsNoSub = new RegExp('[+|x|\u{00F7}]');
  final RegExp regNumbs = new RegExp('[1-9]');

  final Color backgroundColor = Colors.black;
  final Color formulaColor = Colors.white;
  final Color resultColor = Colors.grey;
  final Color errorColor = Colors.red;

  String formula = '';
  String result = '';
  List<String> prevResult = [];
  String deleted = '';

  bool calculated = false;
  bool badExp = false;

  Color primaryColor;

  @override
  void initState() {
    super.initState();
    getColorTheme();
  }

  void getColorTheme() async {
    await getApplicationDocumentsDirectory().then((Directory directory) {
      Directory dir = directory;
      File jsonFile = new File(dir.path + themeFileName);
      Map<String, dynamic> content;

      if (jsonFile.existsSync()) {
        content = jsonDecode(jsonFile.readAsStringSync());
        this.setState(() {
          primaryColor = Color(content['colorThemeList'][content['colorTheme']]);
        });
      } else {
        addColorTheme();
      }
    });
  }

  void addColorTheme() async {
    await getApplicationDocumentsDirectory().then((Directory directory) {
      Directory dir = directory;
      File jsonFile = new File(dir.path + themeFileName);
      Map<String, dynamic> content;
      jsonFile.createSync();
      content = {
        'colorTheme': 'green',
        'colorThemeList': {'orange': 0xfff4a950, "red": 0xffea4335, "blue": 0xff4285f4, "green": 0xff34a853}
      };
      jsonFile.writeAsStringSync(jsonEncode(content));

      this.setState(() {
        primaryColor = Color(content['colorThemeList'][content['colorTheme']]);
      });
    });
  }

  Future<bool> addToHistory() async {
    await getApplicationDocumentsDirectory().then((Directory directory) {
      Directory dir = directory;
      File jsonFile = new File(dir.path + historyFileName);
      DateTime now = new DateTime.now();
      String date = new DateTime(now.year, now.month, now.day).toString();
      List<dynamic> content;

      if (jsonFile.existsSync()) {
        content = jsonDecode(jsonFile.readAsStringSync());
        if (content.isNotEmpty && content.first['date'] == date) {
          content.first['values'].insert(0, {"formula": formula, "result": result});
        } else {
          content.insert(0, {
            'date': date,
            'values': [
              {"formula": formula, "result": result}
            ]
          });
        }
        jsonFile.writeAsStringSync(jsonEncode(content));
      } else {
        jsonFile.createSync();
        content = [
          {
            'date': date,
            'values': [
              {"formula": formula, "result": result}
            ]
          }
        ];
        jsonFile.writeAsStringSync(jsonEncode(content));
      }
    });
    return true;
  }

  String calculate() {
    double num1;
    double num2;
    int preOpI;
    int nextOpI;
    String f = formula;

    RegExp mulDiv = new RegExp('[x|\u{00F7}]');
    RegExp plusMin = new RegExp('[+|\\-]');

    RegExp re = mulDiv;

    int operator = f.indexOf(re);

    while (operator > 0 || (operator == 0 && f.indexOf(re, 1) != -1) || (operator == -1 && re == mulDiv)) {
      if (operator == -1) {
        re = plusMin;
      } else {
        if (operator == 0) {
          operator = f.indexOf(re, 1);
        }
        // Find previous operator index
        preOpI = f.substring(0, operator).lastIndexOf(regOps);

        if (preOpI == 0 || (preOpI > -1 && f[preOpI] == '-' && f[preOpI - 1].contains(regOps))) {
          preOpI -= 1;
        }

        // Get first number
        num1 = double.parse(f.substring(preOpI + 1, operator));

        nextOpI = f.indexOf(regOps, operator + 1);

        if (nextOpI == operator + 1) {
          nextOpI = f.indexOf(regOps, nextOpI + 1);
        }

        if (nextOpI < 0) {
          nextOpI = f.length;
        }

        num2 = double.parse(f.substring(operator + 1, nextOpI));

        double r = 0;
        if (f[operator] == 'x') {
          r = num1 * num2;
        } else if (f[operator] == '\u{00F7}') {
          r = num1 / num2;
        } else if (f[operator] == '+') {
          r = num1 + num2;
        } else if (f[operator] == '-') {
          r = num1 - num2;
        }

        f = f.replaceRange(preOpI + 1, nextOpI, r.toString());
      }
      operator = f.indexOf(re);
    }

    double temp = double.parse(f);

    if (temp % 1 == 0) {
      f = temp.round().toString();
    }

    return f;
  }

  void checkBadExp() {
    if (badExp) {
      setState(() {
        result = prevResult.isNotEmpty ? prevResult.last : '';
        badExp = false;
      });
    }
  }

  void buttonPressed(String buttonText) {
    if (buttonText == 'CLR' || buttonText == 'DEL') {
      _buttonPressed(buttonText);
    } else if (!((buttonText == '90%' || buttonText == 'x1.23') && formula.isEmpty)) {
      if (buttonText == '90%') {
        buttonText = 'x.9';
      }
      for (int i = 0; i < buttonText.length; i++) {
        _buttonPressed(buttonText[i]);
      }
    }
  }

  Future<void> _buttonPressed(String buttonText) async {
    checkBadExp();
    if (calculated) {
      setState(() {
        result = formula;
      });
    }
    if (buttonText == 'CLR') {
      setState(() {
        formula = '';
      });
    } else if (buttonText == 'DEL') {
      if (formula.isNotEmpty) {
        setState(() {
          deleted = formula[formula.length - 1];
          formula = formula.substring(0, formula.length - 1);
        });
      }
    } else if (buttonText == '=') {
      try {
        if (formula.length > 0) {
          String res = calculate();
          addToHistory().then((addedHistory) =>
              setState(() {
                formula = res;
                result = '';
                prevResult.clear();
                calculated = true;
              }));
        }
      } catch (e) {
        setState(() {
          result = 'Bad Expression';
          badExp = true;
        });
      }
    } else {
      if (buttonText.contains(regOpsNoSub) && formula.length == 0) {
        // Do nothing
      } else if (buttonText.contains(regOpsNoSub) && formula.startsWith('-') && formula.length == 1) {
        // Do nothing
      } else if (buttonText == '-' &&
          ((formula.length > 2 && formula[formula.length - 1] == '-' && formula[formula.length - 2].contains(regOps)) ||
              (formula.length == 1 && formula.endsWith('-')))) {
        // Do nothing
      } else if (buttonText.contains(regOpsNoSub) &&
          formula.length > 2 &&
          formula[formula.length - 1] == '-' &&
          formula[formula.length - 2].contains(regOps)) {
        setState(() {
          formula = formula.substring(0, formula.length - 2) + buttonText;
        });
      } else if (buttonText.contains(regOpsNoSub) &&
          (formula.endsWith('+') || formula.endsWith('-') || formula.endsWith('x') || formula.endsWith('\u{00F7}'))) {
        setState(() {
          formula = formula.substring(0, formula.length - 1) + buttonText;
        });
      } else if (buttonText.contains('0') &&
          formula.endsWith('0') &&
          ((formula.lastIndexOf('.') == -1 && !formula.contains(regNumbs)) ||
              (formula.lastIndexOf('.') < formula.lastIndexOf(regOps) &&
                  !formula.contains(regNumbs, formula.lastIndexOf(regOps))))) {
        // Do nothing
      } else {
        int i = formula.lastIndexOf(regOps);
        if (buttonText == '.' &&
            ((i >= 0 && formula.substring(i).contains('.')) || (i == -1 && formula.contains('.')))) {
          // Do nothing
        } else {
          if (calculated && !buttonText.contains(regOps) && buttonText.contains(new RegExp('[.|1-9]'))) {
            setState(() {
              formula = '';
            });
          }
          setState(() {
            formula += buttonText;
          });
        }
      }
      calculated = false;
    }

    try {
      if (!badExp) calculatePreview(buttonText);
    } catch (e) {}
  }

  void calculatePreview(String buttonText) {
    // Calculate the preview result of the formula
    if (formula.isNotEmpty) {
      if (buttonText != '=' &&
          buttonText != 'DEL' &&
          !formula[formula.length - 1].contains(new RegExp('[+|\\-|x|\u{00F7}|.]'))) {
        setState(() {
          result = calculate();
          prevResult.add(result);
        });
      } else if (buttonText == 'DEL' && !deleted.contains(new RegExp('[+|\\-|x|\u{00F7}|.]'))) {
        setState(() {
          prevResult.removeLast();
          result = prevResult.last;
        });
      } else {
        setState(() {
          result = prevResult.last;
        });
      }
      // Clear result when formula is empty
    } else {
      setState(() {
        result = '';
        prevResult = [];
        deleted = '';
      });
    }
  }

  Widget button(String buttonText, {double fontSize = 24.0, Color textColor = Colors.white, Color bgColor}) {
    return new Expanded(
        child: ButtonTheme(
          height: MediaQuery
              .of(context)
              .size
              .height / 5 * 3 / 5,
          child: FlatButton(
            color: bgColor != null ? bgColor : Color.fromRGBO(20, 20, 20, 1),
            child: Text(
              buttonText,
              style: TextStyle(
                color: textColor,
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () => buttonPressed(buttonText),
          ),
        ));
  }

  Widget blank() {
    return new Expanded(
      child: Container(
        height: MediaQuery
            .of(context)
            .size
            .height / 5 * 3 / 5,
        color: Colors.grey[900],
        child: Text(
          '',
          style: TextStyle(
            fontSize: 20.0,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          Padding(
              padding: EdgeInsets.only(right: 10.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) => History(primaryColor: primaryColor)));
                },
                child: Icon(
                  Icons.history,
                  size: 26.0,
                ),
              )),
        ],
      ),
      body: Container(
        color: backgroundColor,
        child: Column(
          children: <Widget>[
            Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.symmetric(
                vertical: 24.0,
                horizontal: 12.0,
              ),
              child: Text(
                formula,
                style: TextStyle(
                  fontSize: 48.0,
                  fontWeight: FontWeight.bold,
                  color: badExp ? errorColor : formulaColor,
                ),
              ),
            ),
            Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 12.0,
              ),
              child: Text(
                result,
                style: TextStyle(
                  fontSize: 36.0,
                  fontWeight: FontWeight.bold,
                  color: badExp ? errorColor : resultColor,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: backgroundColor,
              ),
            ),
            Column(
              children: [
                Row(
                  children: [
                    button('CLR', fontSize: 14),
                    button('DEL', fontSize: 14),
                    button('90%', fontSize: 14),
                    button("\u{00F7}", fontSize: 30, textColor: primaryColor),
                  ],
                ),
                Row(
                  children: [
                    button("7"),
                    button("8"),
                    button("9"),
                    button("x", fontSize: 26, textColor: primaryColor),
                  ],
                ),
                Row(
                  children: [
                    button("4"),
                    button("5"),
                    button("6"),
                    button("-", fontSize: 36, textColor: primaryColor),
                  ],
                ),
                Row(
                  children: [
                    button("1"),
                    button("2"),
                    button("3"),
                    button("+", fontSize: 30, textColor: primaryColor),
                  ],
                ),
                Row(
                  children: [
                    button("."),
                    button("0"),
                    button('x1.23', fontSize: 14),
                    button("=", fontSize: 30, bgColor: primaryColor),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
