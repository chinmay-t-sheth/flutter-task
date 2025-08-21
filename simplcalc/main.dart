import 'package:flutter/material.dart';

void main() {
  runApp(CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Calculator',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

enum Operation { add, subtract, multiply, divide }

class _CalculatorScreenState extends State<CalculatorScreen> {
  final TextEditingController _num1Controller = TextEditingController();
  final TextEditingController _num2Controller = TextEditingController();

  Operation? _selectedOperation;
  String _result = "";

  void _calculate() {
    final double? num1 = double.tryParse(_num1Controller.text);
    final double? num2 = double.tryParse(_num2Controller.text);

    if (num1 == null || num2 == null || _selectedOperation == null) {
      setState(() {
        _result = "Please enter valid numbers and select an operation.";
      });
      return;
    }

    double answer;
    switch (_selectedOperation) {
      case Operation.add:
        answer = num1 + num2;
        break;
      case Operation.subtract:
        answer = num1 - num2;
        break;
      case Operation.multiply:
        answer = num1 * num2;
        break;
      case Operation.divide:
        if (num2 == 0) {
          setState(() {
            _result = "Error: Division by zero";
          });
          return;
        }
        answer = num1 / num2;
        break;
      default:
        answer = 0;
    }

    setState(() {
      _result = "Result: $answer";
    });
  }

  Widget _buildRadio(Operation operation, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<Operation>(
          value: operation,
          groupValue: _selectedOperation,
          onChanged: (Operation? value) {
            setState(() {
              _selectedOperation = value;
            });
          },
        ),
        Text(label),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Simple Calculator")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _num1Controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Enter first number"),
            ),
            TextField(
              controller: _num2Controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Enter second number"),
            ),
            SizedBox(height: 20),
            Wrap(
              spacing: 10,
              children: [
                _buildRadio(Operation.add, "Add"),
                _buildRadio(Operation.subtract, "Subtract"),
                _buildRadio(Operation.multiply, "Multiply"),
                _buildRadio(Operation.divide, "Divide"),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _calculate,
              child: Text("Calculate"),
            ),
            SizedBox(height: 20),
            Text(
              _result,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }
}
