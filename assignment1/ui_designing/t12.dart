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
      title: 'Toggle Background',
      home: const ToggleBackgroundScreen(),
    );
  }
}

class ToggleBackgroundScreen extends StatefulWidget {
  const ToggleBackgroundScreen({super.key});

  @override
  State<ToggleBackgroundScreen> createState() => _ToggleBackgroundScreenState();
}

class _ToggleBackgroundScreenState extends State<ToggleBackgroundScreen> {
  bool _isToggled = false; // switch state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isToggled ? Colors.black : Colors.white,
      appBar: AppBar(
        title: const Text("Toggle Background Color"),
        centerTitle: true,
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Dark Mode",
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 10),
            Switch(
              value: _isToggled,
              onChanged: (value) {
                setState(() {
                  _isToggled = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
