import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.black,
      ),
      home: MyHomePage(title: 'Calculator'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String formula = '';
  String result = '';
  List<String> prevResult = [];
  bool calculated = false;

  RegExp ops = new RegExp('[+|\\-|x|\u{00F7}]');
  RegExp opsNoSub = new RegExp('[+|x|\u{00F7}]');
  RegExp nums = new RegExp('[1-9]');

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

    while (operator > 0 ||
        (operator == 0 && f.indexOf(re, 1) != -1) ||
        (operator == -1 && re == mulDiv)) {
      if (operator == -1) {
        re = plusMin;
      } else {
        if (operator == 0) {
          operator = f.indexOf(re, 1);
        }
        // Find previous operator index
        preOpI = f.substring(0, operator).lastIndexOf(ops);

        if (preOpI == 0 ||
            (preOpI > -1 && f[preOpI] == '-' && f[preOpI - 1].contains(ops))) {
          preOpI -= 1;
        }

        // Get first number
        num1 = double.parse(f.substring(preOpI + 1, operator));

        nextOpI = f.indexOf(ops, operator + 1);

        if (nextOpI == operator + 1) {
          nextOpI = f.indexOf(ops, nextOpI + 1);
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

  specialButtonPressed(String buttonText) {
    if (buttonText == 'CLR') {
      setState(() {
        formula = '';
      });
    } else if (buttonText == 'DEL') {
      if (formula.isNotEmpty) {
        setState(() {
          formula = formula.substring(0, formula.length - 1);
        });
      }
    } else if (formula.isNotEmpty) {
      if (buttonText == '90%') {
        setState(() {
          formula += 'x.9';
        });
      } else if (buttonText == 'x1.23') {
        setState(() {
          formula += 'x1.23';
        });
      }
    }
    try {
      calculatePreview(buttonText);
    } catch (e) {
      print('error for preview');
    }
  }

  buttonPressed(String buttonText) {
    if (buttonText == '=') {
      try {
        if (formula.length > 0) {
          setState(() {
            formula = calculate();
            result = '';
            prevResult.clear();
            calculated = true;
          });
        }
      } catch (e) {
        print('error on equals');
      }
    } else {
      if (buttonText.contains(opsNoSub) && formula.length == 0) {
        // Do nothing
      } else if (buttonText.contains(opsNoSub) &&
          formula.startsWith('-') &&
          formula.length == 1) {
        // Do nothing
      } else if (buttonText == '-' &&
          ((formula.length > 2 &&
              formula[formula.length - 1] == '-' &&
              formula[formula.length - 2].contains(ops)) ||
              (formula.length == 1 && formula.endsWith('-')))) {
        // Do nothing
      } else if (buttonText.contains(opsNoSub) &&
          formula.length > 2 &&
          formula[formula.length - 1] == '-' &&
          formula[formula.length - 2].contains(ops)) {
        setState(() {
          formula = formula.substring(0, formula.length - 2) + buttonText;
        });
      } else if (buttonText.contains(opsNoSub) &&
          (formula.endsWith('+') ||
              formula.endsWith('-') ||
              formula.endsWith('x') ||
              formula.endsWith('\u{00F7}'))) {
        setState(() {
          formula = formula.substring(0, formula.length - 1) + buttonText;
        });
      } else if (buttonText.contains('0') &&
          formula.endsWith('0') &&
          ((formula.lastIndexOf('.') == -1 &&
              !formula.contains(nums)) ||
              (formula.lastIndexOf('.') < formula.lastIndexOf(ops) &&
                  !formula.contains(
                      nums, formula.lastIndexOf(ops))))) {
        // Do nothing
      } else {
        int i = formula.lastIndexOf(ops);
        if (buttonText == '.' &&
            ((i >= 0 && formula.substring(i).contains('.')) ||
                (i == -1 && formula.contains('.')))) {
          // Do nothing
        } else {
          if (calculated && buttonText.contains(RegExp('.|[1-9]'))) {
            setState(() {
              formula = '';
              calculated = false;
            });
          }
          setState(() {
            formula += buttonText;
          });
        }
      }
    }

    try {
      calculatePreview(buttonText);
    } catch (e) {
      print('error for preview');
    }
  }

  calculatePreview(String buttonText) {
    // Calculate the preview result of the formula
    if (formula.isNotEmpty) {
      if (buttonText != '=' &&
          !formula[formula.length - 1]
              .contains(new RegExp('[+|\\-|x|\u{00F7}|.]'))) {
        if (buttonText != 'DEL') {
          setState(() {
            result = calculate();
            prevResult.add(result);
          });
        }
      } else {
        if (buttonText == 'DEL') {
          setState(() {
            prevResult.removeLast();
            result = prevResult.last;
          });
        }
      }
      // Clear result when formula is empty
    } else {
      setState(() {
        result = '';
        prevResult = [];
      });
    }
//    print('result ' + result);
//    print('prevResult ' + prevResult.toString());
//    print('');
  }

  Widget button(String buttonText) {
    return new Expanded(
        child: ButtonTheme(
          height: MediaQuery
              .of(context)
              .size
              .height / 5 * 3 / 5,
          child: FlatButton(
            color: Colors.grey[900],
            child: Text(
              buttonText,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () => buttonPressed(buttonText),
          ),
        ));
  }

  Widget specialButton(String buttonText) {
    return new Expanded(
        child: ButtonTheme(
          height: MediaQuery
              .of(context)
              .size
              .height / 5 * 3 / 5,
          child: FlatButton(
            color: Colors.grey[900],
            child: Text(
              buttonText,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () => specialButtonPressed(buttonText),
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
      ),
      body: Container(
        color: Colors.black,
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
                  color: Colors.white,
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
                  color: Colors.grey,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: Colors.black,
              ),
            ),
            Column(
              children: [
                Row(
                  children: [
                    specialButton('CLR'),
                    specialButton('DEL'),
                    specialButton('90%'),
                    button("\u{00F7}"),
                  ],
                ),
                Row(
                  children: [
                    button("7"),
                    button("8"),
                    button("9"),
                    button("x"),
                  ],
                ),
                Row(
                  children: [
                    button("4"),
                    button("5"),
                    button("6"),
                    button("-"),
                  ],
                ),
                Row(
                  children: [
                    button("1"),
                    button("2"),
                    button("3"),
                    button("+"),
                  ],
                ),
                Row(
                  children: [
                    button("."),
                    button("0"),
                    specialButton('x1.23'),
                    button("="),
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
