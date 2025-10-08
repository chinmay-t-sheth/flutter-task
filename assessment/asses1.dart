import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting

void main() {
  runApp(const MyApp());
}

/// Root widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pet Mood Tracker',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('🐾 Pet Mood Tracker'),
          backgroundColor: Colors.teal,
        ),
        body: const Center(
          child: PetMoodCard(petName: 'Buddy'), // Example pet name
        ),
      ),
    );
  }
}

/// Stateful widget for mood tracking
class PetMoodCard extends StatefulWidget {
  final String petName;
  const PetMoodCard({super.key, required this.petName});

  @override
  State<PetMoodCard> createState() => _PetMoodCardState();
}

class _PetMoodCardState extends State<PetMoodCard> {
  String? selectedMood;

  /// Map moods to emoji and colors
  final Map<String, Map<String, dynamic>> moodData = {
    'Happy': {'emoji': '😊', 'color': Colors.greenAccent},
    'Sad': {'emoji': '😢', 'color': Colors.lightBlueAccent},
    'Energetic': {'emoji': '⚡', 'color': Colors.yellowAccent},
    'Sleepy': {'emoji': '😴', 'color': Colors.grey.shade300},
  };

  @override
  Widget build(BuildContext context) {
    // Current date formatted as "MMM dd, yyyy"
    String currentDate = DateFormat('MMM dd, yyyy').format(DateTime.now());

    // Background color based on mood
    Color bgColor = selectedMood != null
        ? moodData[selectedMood]!['color']
        : Colors.grey.shade200;

    return Card(
      elevation: 8,
      margin: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Pet name and date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.petName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                Text(
                  currentDate,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            /// Dropdown for mood selection
            DropdownButtonFormField<String>(
              value: selectedMood,
              decoration: InputDecoration(
                labelText: 'Select Mood',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: moodData.keys
                  .map((mood) => DropdownMenuItem(
                value: mood,
                child: Text(mood),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedMood = value;
                });
              },
            ),
            const SizedBox(height: 20),

            /// Mood Display Area
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: selectedMood == null
                    ? const Text(
                  "No mood selected 🐶",
                  style: TextStyle(fontSize: 18, color: Colors.black54),
                )
                    : Column(
                  children: [
                    Text(
                      moodData[selectedMood]!['emoji'],
                      style: const TextStyle(fontSize: 50),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      selectedMood!,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
