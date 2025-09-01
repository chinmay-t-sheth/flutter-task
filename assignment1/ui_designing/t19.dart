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
      home: SearchBarDemo(),
    );
  }
}

class SearchBarDemo extends StatefulWidget {
  const SearchBarDemo({super.key});

  @override
  State<SearchBarDemo> createState() => _SearchBarDemoState();
}

class _SearchBarDemoState extends State<SearchBarDemo> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _allItems = [
    "Apple",
    "Banana",
    "Orange",
    "Mango",
    "Pineapple",
    "Strawberry",
    "Grapes",
    "Watermelon",
    "Papaya",
    "Cherry",
  ];

  List<String> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = _allItems; // show all initially
  }

  void _filterItems(String query) {
    final results = _allItems
        .where((item) => item.toLowerCase().contains(query.toLowerCase()))
        .toList();

    setState(() {
      _filteredItems = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Search Bar Example")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            TextField(
              controller: _controller,
              onChanged: _filterItems,
              decoration: InputDecoration(
                labelText: "Search",
                hintText: "Type to search...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Suggestions List
            Expanded(
              child: _filteredItems.isNotEmpty
                  ? ListView.builder(
                      itemCount: _filteredItems.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(_filteredItems[index]),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    "You selected: ${_filteredItems[index]}"),
                              ),
                            );
                          },
                        );
                      },
                    )
                  : const Center(
                      child: Text(
                        "No results found",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
