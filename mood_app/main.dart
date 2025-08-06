import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

// Root App
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dart Widget App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Scaffold(
        appBar: AppBar(title: Text('My Widget App')),
        body: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              ProfileWidget(),
              SizedBox(height: 20),
              LikeButtonWidget(),
              SizedBox(height: 20),
              MoodSelectorWidget(),
              Spacer(),
              FooterWidget(),
            ],
          ),
        ),
      ),
    );
  }
}

// 1. Profile Widget - Stateless
class ProfileWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundImage: NetworkImage(
              'https://i.pravatar.cc/150?img=3'), // Replace with your image link
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Chinamy", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text("Aspiring Flutter Developer", style: TextStyle(color: Colors.grey[700])),
            ],
          ),
        )
      ],
    );
  }
}

// 2. Like Button Widget - Stateful
class LikeButtonWidget extends StatefulWidget {
  @override
  _LikeButtonWidgetState createState() => _LikeButtonWidgetState();
}

class _LikeButtonWidgetState extends State<LikeButtonWidget> {
  int likes = 0;

  void _incrementLikes() {
    setState(() {
      likes++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text('Likes: $likes'),
        trailing: IconButton(
          icon: Icon(Icons.thumb_up),
          onPressed: _incrementLikes,
          color: Colors.blue,
        ),
      ),
    );
  }
}

// 3. Mood Selector Widget - Stateful
class MoodSelectorWidget extends StatefulWidget {
  @override
  _MoodSelectorWidgetState createState() => _MoodSelectorWidgetState();
}

class _MoodSelectorWidgetState extends State<MoodSelectorWidget> {
  String mood = '😊'; // Default mood

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text('Current Mood: $mood'),
        subtitle: Row(
          children: [
            TextButton(
              child: Text('😊 Happy', style: TextStyle(fontSize: 16)),
              onPressed: () => setState(() => mood = '😊'),
            ),
            SizedBox(width: 10),
            TextButton(
              child: Text('😢 Sad', style: TextStyle(fontSize: 16)),
              onPressed: () => setState(() => mood = '😢'),
            ),
          ],
        ),
      ),
    );
  }
}

// 4. Footer Widget - Stateless
class FooterWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("Chinamy", style: TextStyle(fontWeight: FontWeight.bold)),
        Text("Powered by Flutter", style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }
}
