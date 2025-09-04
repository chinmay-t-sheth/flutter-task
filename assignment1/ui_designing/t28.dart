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
      home: ProductListingPage(),
    );
  }
}

class ProductListingPage extends StatelessWidget {
  const ProductListingPage({super.key});

  final List<Map<String, String>> products = const [
    {
      "name": "Smartphone",
      "price": "\$699",
      "image":
          "https://images.unsplash.com/photo-1511707171634-5f897ff02aa9"
    },
    {
      "name": "Headphones",
      "price": "\$199",
      "image":
          "https://images.unsplash.com/photo-1511367461989-f85a21fda167"
    },
    {
      "name": "Sneakers",
      "price": "\$129",
      "image":
          "https://images.unsplash.com/photo-1528701800489-20be9c1e6baf"
    },
    {
      "name": "Backpack",
      "price": "\$89",
      "image":
          "https://images.unsplash.com/photo-1542291026-7eec264c27ff"
    },
    {
      "name": "Wrist Watch",
      "price": "\$249",
      "image":
          "https://images.unsplash.com/photo-1516728778615-2d590ea1855e"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("🛍 Product Listing")),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return Container(
              width: 180,
              margin: const EdgeInsets.only(right: 12),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: Image.network(
                        product["image"]!,
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        product["name"]!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        product["price"]!,
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
