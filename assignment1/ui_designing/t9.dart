import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculator UI',
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _output = "0"; // Displayed result
  String _input = "";   // Expression being built

  void _buttonPressed(String value) {
    setState(() {
      if (value == "C") {
        _input = "";
        _output = "0";
      } else if (value == "=") {
        try {
          // Simple evaluation (only + - * /) using Dart's expression parsing
          _output = _evaluateExpression(_input);
        } catch (e) {
          _output = "Error";
        }
      } else {
        _input += value;
        _output = _input;
      }
    });
  }

  String _evaluateExpression(String expression) {
    // Very basic evaluator: uses Dart's double.parse and split
    // (for real apps, better use a math parser library!)
    try {
      // Replace × and ÷ with * and /
      expression = expression.replaceAll("×", "*").replaceAll("÷", "/");
      // Using Dart's built-in parsing via 'Expression evaluation' would need packages
      // For now: just return the string (UI focus only)
      return expression;
    } catch (e) {
      return "Error";
    }
  }

  Widget _buildButton(String text, {Color? color}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? Colors.blueGrey[200],
            padding: const EdgeInsets.symmetric(vertical: 20),
          ),
          onPressed: () => _buttonPressed(text),
          child: Text(
            text,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Calculator"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Display area
          Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.all(20),
            child: Text(
              _output,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(),

          // Buttons
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    _buildButton("7"),
                    _buildButton("8"),
                    _buildButton("9"),
                    _buildButton("÷", color: Colors.orange),
                  ],
                ),
                Row(
                  children: [
                    _buildButton("4"),
                    _buildButton("5"),
                    _buildButton("6"),
                    _buildButton("×", color: Colors.orange),
                  ],
                ),
                Row(
                  children: [
                    _buildButton("1"),
                    _buildButton("2"),
                    _buildButton("3"),
                    _buildButton("-", color: Colors.orange),
                  ],
                ),
                Row(
                  children: [
                    _buildButton("0"),
                    _buildButton("C", color: Colors.red),
                    _buildButton("=", color: Colors.green),
                    _buildButton("+", color: Colors.orange),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
