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
      home: const AssetImageDemo(),
    );
  }
}

class AssetImageDemo extends StatelessWidget {
  const AssetImageDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Asset Image with BoxFit")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 200,
              height: 150,
              color: Colors.grey[300],
              child: Image.asset(
                "assets/images/flutter_logo.png",
                fit: BoxFit.cover,  
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Experiment with BoxFit: cover, contain, fill, etc.",
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
