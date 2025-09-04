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
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _commentsController = TextEditingController();

  // Dropdown
  String? _selectedCategory;

  // Checkboxes
  bool _isSatisfied = false;
  bool _wantsNewsletter = false;

  void _submitFeedback() {
    if (_formKey.currentState!.validate()) {
      String feedbackData = """
Name: ${_nameController.text}
Category: $_selectedCategory
Satisfied: $_isSatisfied
Wants Newsletter: $_wantsNewsletter
Comments: ${_commentsController.text}
""";

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Feedback Submitted ✅\n$feedbackData")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Feedback Form")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Your Name",
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? "Enter your name" : null,
              ),
              const SizedBox(height: 16),

              // Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Feedback Category",
                  border: OutlineInputBorder(),
                ),
                value: _selectedCategory,
                items: ["App Experience", "Bug Report", "Feature Request"]
                    .map((cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(cat),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                validator: (value) =>
                    value == null ? "Please select a category" : null,
              ),
              const SizedBox(height: 16),

              // Checkboxes
              CheckboxListTile(
                title: const Text("Are you satisfied with the app?"),
                value: _isSatisfied,
                onChanged: (value) {
                  setState(() {
                    _isSatisfied = value ?? false;
                  });
                },
              ),
              CheckboxListTile(
                title: const Text("Subscribe to our newsletter"),
                value: _wantsNewsletter,
                onChanged: (value) {
                  setState(() {
                    _wantsNewsletter = value ?? false;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Comments
              TextFormField(
                controller: _commentsController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Additional Comments",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Submit Button
              ElevatedButton(
                onPressed: _submitFeedback,
                child: const Text("Submit Feedback"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
