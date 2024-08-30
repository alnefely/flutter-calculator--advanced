import 'package:flutter/material.dart';
import 'package:expressions/expressions.dart';

void main() => runApp(CalcApp());

class CalcApp extends StatefulWidget {
  @override
  _CalcAppState createState() => _CalcAppState();
}

class _CalcAppState extends State<CalcApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode,
      home: Calculator(
        onThemeToggle: () {
          setState(() {
            _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
          });
        },
      ),
    );
  }
}

class Calculator extends StatefulWidget {
  final VoidCallback onThemeToggle;

  Calculator({required this.onThemeToggle});

  @override
  _CalculatorState createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  String _output = "0";
  String _input = "";
  List<String> _history = [];
  bool _shouldClear = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calculator'),
        actions: [
          IconButton(
            icon: Icon(Theme.of(context).brightness == Brightness.dark ? Icons.wb_sunny : Icons.nights_stay),
            onPressed: widget.onThemeToggle,
          ),
          IconButton(
            icon: Icon(Icons.delete_forever),
            onPressed: () {
              setState(() {
                _history.clear();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              alignment: Alignment.bottomRight,
              padding: EdgeInsets.all(24),
              child: Text(
                _output,
                style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: _history.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_history[index]),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        _history.removeAt(index);
                      });
                    },
                  ),
                  onTap: () {
                    setState(() {
                      _input = _history[index];
                      _output = _input;
                    });
                  },
                );
              },
            ),
          ),
          Divider(),
          Column(children: [
            _buildButtonRow("7", "8", "9", "/"),
            _buildButtonRow("4", "5", "6", "x"),
            _buildButtonRow("1", "2", "3", "-"),
            _buildButtonRow(".", "0", "=", "+"),
            _buildButtonRow("C", "Del", "", ""),
          ]),
        ],
      ),
    );
  }

  Widget _buildButtonRow(String a, String b, String c, String d) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        _buildButton(a),
        _buildButton(b),
        _buildButton(c),
        _buildButton(d),
      ],
    );
  }

  Widget _buildButton(String label) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () => _buttonPressed(label),
        child: Text(label, style: TextStyle(fontSize: 24)),
      ),
    );
  }

  void _buttonPressed(String buttonText) {
    setState(() {
      if (buttonText == "C") {
        _output = "0";
        _input = "";
        _shouldClear = false;
      } else if (buttonText == "Del") {
        _input = _input.isNotEmpty ? _input.substring(0, _input.length - 1) : "";
        _output = _input;
      } else if (buttonText == "=") {
        try {
          final expression = Expression.parse(_input.replaceAll('x', '*'));
          final evaluator = const ExpressionEvaluator();
          var result = evaluator.eval(expression, {});
          _output = result.toString();
          _history.insert(0, "$_input = $_output");
          _input = _output;
          _shouldClear = true;
        } catch (e) {
          _output = "Error";
        }
      } else {
        if (_shouldClear) {
          _input = buttonText;
          _shouldClear = false;
        } else {
          _input += buttonText;
        }
        _output = _input;
      }
    });
  }
}