
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
      home: OverlayExample(),
    );
  }
}

class OverlayExample extends StatelessWidget {
  const OverlayExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Stack Overlay Example")),
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                "https://images.unsplash.com/photo-1507525428034-b723cf961d3e",
                width: 300,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),

            // Semi-transparent overlay
            Container(
              width: 300,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
            ),

            // Text on top
            const Text(
              "Explore the Ocean 🌊",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
