
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
      home: ProfilePage(),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile Page")),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Background
          Container(
            height: double.infinity,
            color: Colors.blue[50],
          ),

          // Profile Image in the center (using Positioned)
          Positioned(
            top: 60,
            child: CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(
                "https://images.unsplash.com/photo-1502767089025-6572583495b0",
              ),
            ),
          ),

          // Name + Bio below
          Positioned(
            top: 200,
            left: 0,
            right: 0,
            child: Column(
              children: const [
                Text(
                  "John Doe",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Flutter Developer | Tech Enthusiast 🚀",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
