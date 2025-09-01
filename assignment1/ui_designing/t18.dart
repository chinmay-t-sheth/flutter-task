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
      home: FeedbackForm(),
    );
  }
}

class FeedbackForm extends StatefulWidget {
  const FeedbackForm({super.key});

  @override
  State<FeedbackForm> createState() => _FeedbackFormState();
}

class _FeedbackFormState extends State<FeedbackForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _commentsController = TextEditingController();
  String _selectedCategory = "General";

  final List<String> _categories = [
    "General",
    "Bug Report",
    "Feature Request",
    "Other",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Feedback Form")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Name",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Comments
              TextField(
                controller: _commentsController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: "Comments",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Category Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
                decoration: const InputDecoration(
                  labelText: "Feedback Category",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    String feedbackSummary =
                        "Name: ${_nameController.text}\nCategory: $_selectedCategory\nComments: ${_commentsController.text}";
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Feedback Submitted!\n$feedbackSummary")),
                    );
                  },
                  child: const Text("Submit Feedback"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
