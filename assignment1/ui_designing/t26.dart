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
      home: InfiniteScrollList(),
    );
  }
}

class InfiniteScrollList extends StatefulWidget {
  const InfiniteScrollList({super.key});

  @override
  State<InfiniteScrollList> createState() => _InfiniteScrollListState();
}

class _InfiniteScrollListState extends State<InfiniteScrollList> {
  final List<int> _items = List.generate(20, (index) => index); // initial data
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !_isLoading) {
        _loadMoreData();
      }
    });
  }

  Future<void> _loadMoreData() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 2)); // simulate API call

    setState(() {
      final nextItems =
          List.generate(10, (index) => _items.length + index); // add 10 more
      _items.addAll(nextItems);
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Infinite Scroll List")),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: _items.length + (_isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _items.length) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return ListTile(
            title: Text("Item ${_items[index]}"),
          );
        },
      ),
    );
  }
}
