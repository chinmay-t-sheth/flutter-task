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
      home: Task44Demo(),
    );
  }
}

class Task44Demo extends StatelessWidget {
  const Task44Demo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Task 44 Demo")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Part 1: AvatarBadge
            const Text("1️⃣ AvatarBadge Example", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const AvatarBadge(
              imageUrl: "https://i.pravatar.cc/100?img=5",
              isOnline: true,
            ),
            const SizedBox(height: 20),

            // Part 2: Profile Screen Layout
            const Text("2️⃣ Profile Screen Layout", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=7"),
                  ),
                  const SizedBox(height: 10),
                  const Text("John Doe", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const Text("Flutter Developer"),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.email, size: 20),
                      SizedBox(width: 5),
                      Text("john.doe@example.com"),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Part 3: Product Catalog
            const Text("3️⃣ Product Catalog", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Column(
              children: [
                ProductCard(
                  name: "Smartphone",
                  price: "\$699",
                  imageUrl: "https://via.placeholder.com/150",
                ),
                ProductCard(
                  name: "Headphones",
                  price: "\$199",
                  imageUrl: "https://via.placeholder.com/150/92c952",
                ),
                ProductCard(
                  name: "Smartwatch",
                  price: "\$299",
                  imageUrl: "https://via.placeholder.com/150/771796",
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Part 4: Custom Button
            const Text("4️⃣ Custom Button", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            CustomButton(
              text: "Click Me",
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Custom Button Pressed!")),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- Part 1: AvatarBadge ----------
class AvatarBadge extends StatelessWidget {
  final String imageUrl;
  final bool isOnline;

  const AvatarBadge({
    super.key,
    required this.imageUrl,
    this.isOnline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(radius: 40, backgroundImage: NetworkImage(imageUrl)),
        Positioned(
          bottom: 4,
          right: 4,
          child: Container(
            width: 15,
            height: 15,
            decoration: BoxDecoration(
              color: isOnline ? Colors.green : Colors.red,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------- Part 3: ProductCard ----------
class ProductCard extends StatelessWidget {
  final String name;
  final String price;
  final String imageUrl;

  const ProductCard({
    super.key,
    required this.name,
    required this.price,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      child: ListTile(
        leading: Image.network(imageUrl, width: 50, height: 50, fit: BoxFit.cover),
        title: Text(name),
        subtitle: Text(price),
        trailing: const Icon(Icons.shopping_cart),
      ),
    );
  }
}

// ---------- Part 4: CustomButton ----------
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
