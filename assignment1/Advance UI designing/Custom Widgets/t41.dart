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
      home: RatingExample(),
    );
  }
}

class RatingExample extends StatefulWidget {
  const RatingExample({super.key});

  @override
  State<RatingExample> createState() => _RatingExampleState();
}

class _RatingExampleState extends State<RatingExample> {
  int _rating = 0; // Current rating

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Custom Rating Widget")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RatingWidget(
              rating: _rating,
              onRatingSelected: (newRating) {
                setState(() {
                  _rating = newRating;
                });
              },
            ),
            const SizedBox(height: 20),
            Text(
              "Selected Rating: $_rating",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class RatingWidget extends StatelessWidget {
  final int rating;
  final ValueChanged<int> onRatingSelected;

  const RatingWidget({
    super.key,
    required this.rating,
    required this.onRatingSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        int starIndex = index + 1;
        return GestureDetector(
          onTap: () {
            onRatingSelected(starIndex);
          },
          child: Icon(
            Icons.star,
            size: 40,
            color: starIndex <= rating ? Colors.amber : Colors.grey,
          ),
        );
      }),
    );
  }
}
