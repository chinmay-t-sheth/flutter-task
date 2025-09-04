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
      home: CustomListExample(),
    );
  }
}

class CustomListExample extends StatefulWidget {
  const CustomListExample({super.key});

  @override
  State<CustomListExample> createState() => _CustomListExampleState();
}

class _CustomListExampleState extends State<CustomListExample> {
  final List<String> _items = [
    "Buy groceries",
    "Walk the dog",
    "Check emails",
    "Prepare presentation",
    "Workout"
  ];

  void _deleteItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Item deleted")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Custom List with ListTile")),
      body: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
            child: ListTile(
              leading: const Icon(Icons.task, color: Colors.blue),
              title: Text(
                _items[index],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text("Tap delete to remove this task"),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteItem(index),
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Tapped: ${_items[index]}")),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
