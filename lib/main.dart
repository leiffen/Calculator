import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Calculator'),
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
  RegExp ops = new RegExp('[+|\\-|x|\u{00F7}]');
  RegExp opsNoSub = new RegExp('[+|x|\u{00F7}]');

  calculate() {
    double num1;
    double num2;
    int ptr = 0;

    for (int operator = formula.indexOf(ops);
        operator >= 0;
        operator = formula.indexOf(ops, ptr)) {
      if (operator == 0) {
        ptr = 1;
      } else {
        num1 = double.parse(formula.substring(0, operator));
        print(num1);
        int nextOperator = formula.indexOf(ops, operator + 1);

        if (nextOperator == operator + 1) {
          nextOperator = formula.indexOf(ops, nextOperator + 1);
        }

        if (nextOperator < 0) {
          nextOperator = formula.length;
        }

        num2 = double.parse(formula.substring(operator + 1, nextOperator));

        double result = 0;
        if (formula[operator] == '+') {
          result = num1 + num2;
        } else if (formula[operator] == '-') {
          result = num1 - num2;
        } else if (formula[operator] == 'x') {
          result = num1 * num2;
        } else if (formula[operator] == '\u{00F7}') {
          result = num1 / num2;
        }

        setState(() {
          formula = formula.replaceRange(0, nextOperator, result.toString());
        });
        ptr = 0;
        print(formula);
      }
    }
  }

  buttonPressed(String buttonText) {
    if (buttonText == 'clr') {
      setState(() {
        formula = '';
      });
    } else if (buttonText.contains(opsNoSub) && formula.length == 0) {
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
    } else if (buttonText == '=') {
      calculate();
    } else {
      int i = formula.lastIndexOf(ops);
      if (buttonText == '.' &&
          ((i >= 0 && formula.substring(i).contains('.')) ||
              formula.contains('.'))) {
        // Do nothing
      } else {
        setState(() {
          formula += buttonText;
        });
      }
    }
    print(formula);
  }

  Widget button(String buttonText) {
    return new Expanded(
      child: OutlineButton(
        padding: EdgeInsets.all(24.0),
        child: Text(
          buttonText,
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        onPressed: () => buttonPressed(buttonText),
      ),
    );
  }

  Widget blank() {
    return new Expanded(
      child: OutlineButton(
        padding: EdgeInsets.all(24.0),
        child: Text(
          "",
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
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
                ),
              ),
            ),
            Expanded(
              child: Divider(),
            ),
            Column(
              children: [
                Row(
                  children: [
                    button("7"),
                    button("8"),
                    button("9"),
                    button("\u{00F7}"),
                    button("clr"),
                  ],
                ),
                Row(
                  children: [
                    button("4"),
                    button("5"),
                    button("6"),
                    button("x"),
                    blank(),
                  ],
                ),
                Row(
                  children: [
                    button("1"),
                    button("2"),
                    button("3"),
                    button("-"),
                    blank(),
                  ],
                ),
                Row(
                  children: [
                    button("."),
                    button("0"),
                    blank(),
                    button("+"),
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
