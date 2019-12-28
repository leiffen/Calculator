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

  String delclr = 'DEL';

  RegExp ops = new RegExp('[+|\\-|x|\u{00F7}]');
  RegExp opsNoSub = new RegExp('[+|x|\u{00F7}]');

  String calculate() {
    double num1;
    double num2;
    int ptr = 0;
    String f = formula;

    for (int operator = f.indexOf(ops);
        operator >= 0;
        operator = f.indexOf(ops, ptr)) {
      if (operator == 0) {
        ptr = 1;
      } else {
        num1 = double.parse(f.substring(0, operator));
        print(num1);
        int nextOperator = f.indexOf(ops, operator + 1);

        if (nextOperator == operator + 1) {
          nextOperator = f.indexOf(ops, nextOperator + 1);
        }

        if (nextOperator < 0) {
          nextOperator = f.length;
        }

        num2 = double.parse(f.substring(operator + 1, nextOperator));

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

        f = f.replaceRange(0, nextOperator, r.toString());

        ptr = 0;
      }
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
        delclr = 'CLR';
        formula = calculate();
        result = '';
      });
    } else {

      // Switch between CLEAR and DELETE
      if (delclr != 'DEL') {
        setState(() {
          delclr = 'DEL';
        });
      }

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
          (formula.lastIndexOf('.') == -1 ||
              formula.lastIndexOf('.') < formula.lastIndexOf(ops))) {
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
          result = calculate();
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
      child: FlatButton(
        color: Colors.grey[900],
        padding: EdgeInsets.all(30.0),
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
    );
  }

  Widget blank() {
    return new Expanded(
      child: Container(
        color: Colors.grey[900],
        padding: EdgeInsets.all(30.0),
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
                    button(delclr),
                    blank(),
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
                    blank(),
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
