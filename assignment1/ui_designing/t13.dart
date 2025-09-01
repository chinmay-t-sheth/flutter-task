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
      title: 'Image Switcher',
      home: const ImageSwitcherScreen(),
    );
  }
}

class ImageSwitcherScreen extends StatefulWidget {
  const ImageSwitcherScreen({super.key});

  @override
  State<ImageSwitcherScreen> createState() => _ImageSwitcherScreenState();
}

class _ImageSwitcherScreenState extends State<ImageSwitcherScreen> {
  // Two different image URLs
  final List<String> _images = [
    "https://picsum.photos/id/1011/400/300",
    "https://picsum.photos/id/1025/400/300",
  ];

  int _currentIndex = 0; // which image is showing

  void _changeImage() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % _images.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Image Switcher"),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
            _images[_currentIndex],
            height: 250,
            width: 350,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _changeImage,
            child: const Text("Change Image"),
          ),
        ],
      ),
    );
  }
}
