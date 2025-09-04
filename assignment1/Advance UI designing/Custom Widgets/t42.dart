import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ProgressBarExample(),
    );
  }
}

class ProgressBarExample extends StatefulWidget {
  const ProgressBarExample({super.key});

  @override
  State<ProgressBarExample> createState() => _ProgressBarExampleState();
}

class _ProgressBarExampleState extends State<ProgressBarExample> {
  double progress = 0.4; // 40% progress

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Custom ProgressBar")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomProgressBar(percentage: progress),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  progress += 0.1;
                  if (progress > 1.0) progress = 0.0; // reset
                });
              },
              child: const Text("Increase Progress"),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomProgressBar extends StatelessWidget {
  final double percentage; // Value between 0.0 - 1.0
  final double height;
  final Color backgroundColor;
  final Color progressColor;

  const CustomProgressBar({
    super.key,
    required this.percentage,
    this.height = 20,
    this.backgroundColor = Colors.grey,
    this.progressColor = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          FractionallySizedBox(
            widthFactor: percentage.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: progressColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Center(
            child: Text(
              "${(percentage * 100).toInt()}%",
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
    );
  }
}
