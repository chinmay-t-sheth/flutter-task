import 'package:flutter/material.dart';

void main() {
  runApp(NumberRangeApp());
}

class NumberRangeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Number Range App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: InputScreen(),
    );
  }
}

class InputScreen extends StatefulWidget {
  @override
  _InputScreenState createState() => _InputScreenState();
}

class _InputScreenState extends State<InputScreen> {
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController = TextEditingController();

  void _navigateToResult() {
    final int? start = int.tryParse(_startController.text);
    final int? end = int.tryParse(_endController.text);

    if (start != null && end != null && end > start + 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(start: start, end: end),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Enter valid numbers (end should be greater than start + 1).")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Enter Numbers")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _startController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Enter Start Number"),
            ),
            TextField(
              controller: _endController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Enter End Number"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _navigateToResult,
              child: Text("Show Numbers"),
            ),
          ],
        ),
      ),
    );
  }
}

class ResultScreen extends StatelessWidget {
  final int start;
  final int end;

  ResultScreen({required this.start, required this.end});

  @override
  Widget build(BuildContext context) {
    List<int> numbers = [];
    for (int i = start + 1; i < end; i++) {
      numbers.add(i);
    }

    return Scaffold(
      appBar: AppBar(title: Text("Numbers Between $start and $end")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: numbers.isEmpty
            ? Center(child: Text("No numbers in between"))
            : ListView.builder(
                itemCount: numbers.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(numbers[index].toString()),
                  );
                },
              ),
      ),
    );
  }
}
