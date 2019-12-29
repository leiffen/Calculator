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

  RegExp ops = new RegExp('[+|\\-|x|\u{00F7}]');
  RegExp opsNoSub = new RegExp('[+|x|\u{00F7}]');

  String calculate() {
    double num1;
    double num2;
    int preOpI;
    int nextOpI;
    String f = formula;

    RegExp re = RegExp('[x|\u{00F7}]');

    int operator = f.indexOf(re);
    while (f.contains(ops)) {
      if (operator == -1) {
        re = RegExp('[+|\\-]');
      } else {
        // Find previous operator index
        preOpI = f.substring(0, operator).lastIndexOf(ops);
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
        if (f[operator] == '+') {
          r = num1 + num2;
        } else if (f[operator] == '-') {
          r = num1 - num2;
        } else if (f[operator] == 'x') {
          r = num1 * num2;
        } else if (f[operator] == '\u{00F7}') {
          r = num1 / num2;
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

  buttonPressed(String buttonText) {
    // CLEAR button
    if (buttonText == 'CLR') {
      setState(() {
        formula = '';
      });

      // DELETE button
    } else if (buttonText == 'DEL') {
      if (formula.isNotEmpty) {
        setState(() {
          formula = formula.substring(0, formula.length - 1);
        });
      }

      // EQUALS button
    } else if (buttonText == '=') {
      setState(() {
        formula = calculate();
        result = '';
      });
    } else {
      if (buttonText.contains(opsNoSub) && formula.length == 0) {
        // Do nothing
      } else if (buttonText.contains(opsNoSub) &&
          formula.startsWith('-') &&
          formula.length == 1) {
        // Do nothing
      } else if (buttonText == '-' &&
          formula.length > 2 &&
          formula[formula.length - 1] == '-' &&
          formula[formula.length - 2].contains(ops)) {
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
                  !formula.contains(RegExp('[1-9]'))) ||
              (formula.lastIndexOf('.') < formula.lastIndexOf(ops) &&
                  !formula.contains(
                      RegExp('[1-9]'), formula.lastIndexOf(ops))))) {
        // Do nothing
      } else {
        int i = formula.lastIndexOf(ops);
        if (buttonText == '.' &&
            ((i >= 0 && formula.substring(i).contains('.')) ||
                (i == -1 && formula.contains('.')))) {
          // Do nothing
        } else {
          setState(() {
            formula += buttonText;
          });
        }
      }
    }

    // Calculate the preview result of the formula
    if (formula.isNotEmpty) {
      if (buttonText != '=' &&
          !formula[formula.length - 1]
              .contains(new RegExp('[+|\\-|x|\u{00F7}|.]'))) {
        setState(() {
//          result = calculate();
        });
      }
      // Clear result when formula is empty
    } else {
      setState(() {
        result = '';
      });
    }

    print(formula);
  }

  Widget button(String buttonText) {
    return new Expanded(
        child: ButtonTheme(
      height: MediaQuery.of(context).size.height / 5 * 3 / 5,
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
      height: MediaQuery.of(context).size.height / 5 * 3 / 5,
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
        onPressed: () => buttonPressed(buttonText),
      ),
    ));
  }

  Widget blank() {
    return new Expanded(
      child: Container(
        height: MediaQuery.of(context).size.height / 5 * 3 / 5,
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
                    blank(),
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
