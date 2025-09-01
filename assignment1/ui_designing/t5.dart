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
      title: 'Row Layout Demo',
      home: const RowLayoutScreen(),
    );
  }
}

class RowLayoutScreen extends StatelessWidget {
  const RowLayoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Responsive Row Layout"),
        centerTitle: true,
      ),
      body: Row(
        children: [
          // First Container - takes 1/4 of screen width
          Expanded(
            flex: 1,
            child: Container(
              height: double.infinity,
              color: Colors.red,
              child: const Center(
                child: Text(
                  "1",
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),
          ),

          // Second Container - takes 2/4 of screen width
          Expanded(
            flex: 2,
            child: Container(
              height: double.infinity,
              color: Colors.green,
              child: const Center(
                child: Text(
                  "2",
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),
          ),

          // Third Container - takes 1/4 of screen width
          Expanded(
            flex: 1,
            child: Container(
              height: double.infinity,
              color: Colors.blue,
              child: const Center(
                child: Text(
                  "3",
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
