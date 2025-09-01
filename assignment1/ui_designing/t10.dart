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
      title: 'Shopping Cart App',
      home: const ShoppingCartScreen(),
    );
  }
}

class ShoppingCartScreen extends StatefulWidget {
  const ShoppingCartScreen({super.key});

  @override
  State<ShoppingCartScreen> createState() => _ShoppingCartScreenState();
}

class _ShoppingCartScreenState extends State<ShoppingCartScreen> {
  int cartCount = 0;

  final List<String> items = [
    "Apples",
    "Bananas",
    "Oranges",
    "Mangoes",
    "Grapes",
    "Pineapples",
  ];

  void addToCart() {
    setState(() {
      cartCount++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Shopping Cart"),
        centerTitle: true,
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.only(right: 16),
                child: Icon(Icons.shopping_cart, size: 30),
              ),
              if (cartCount > 0)
                Positioned(
                  right: 10,
                  top: 10,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      cartCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.shopping_bag),
            title: Text(items[index]),
            trailing: ElevatedButton(
              onPressed: addToCart,
              child: const Text("Add to Cart"),
            ),
          );
        },
      ),
    );
  }
}
