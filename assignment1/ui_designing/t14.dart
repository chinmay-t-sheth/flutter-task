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
      title: 'Photo Gallery',
      home: const PhotoGalleryScreen(),
    );
  }
}

class PhotoGalleryScreen extends StatelessWidget {
  const PhotoGalleryScreen({super.key});

  // Sample image URLs
  final List<String> _imageUrls = const [
    "https://picsum.photos/id/1001/300/300",
    "https://picsum.photos/id/1002/300/300",
    "https://picsum.photos/id/1003/300/300",
    "https://picsum.photos/id/1004/300/300",
    "https://picsum.photos/id/1005/300/300",
    "https://picsum.photos/id/1006/300/300",
    "https://picsum.photos/id/1008/300/300",
    "https://picsum.photos/id/1010/300/300",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Photo Gallery"),
        centerTitle: true,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // 3 images per row
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: _imageUrls.length,
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              _imageUrls[index],
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
