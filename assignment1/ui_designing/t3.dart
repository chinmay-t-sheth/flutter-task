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
      title: 'Text Styling Demo',
      home: const TextStylingScreen(),
    );
  }
}

class TextStylingScreen extends StatelessWidget {
  const TextStylingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Hello, Flutter!",
              style: TextStyle(
                fontSize: 28, // bigger font
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 20), // space between texts
            Text(
              "Styled Text Example",
              style: TextStyle(
                fontSize: 20, // smaller font
                fontStyle: FontStyle.italic,
                color: Colors.green,
                letterSpacing: 2, // adds spacing between letters
              ),
            ),
          ],
        ),
      ),
    );
  }
}
