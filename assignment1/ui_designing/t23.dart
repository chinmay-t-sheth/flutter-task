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
      home: DrawerNavigationApp(),
    );
  }
}

class DrawerNavigationApp extends StatefulWidget {
  const DrawerNavigationApp({super.key});

  @override
  State<DrawerNavigationApp> createState() => _DrawerNavigationAppState();
}

class _DrawerNavigationAppState extends State<DrawerNavigationApp> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    Center(child: Text("🏠 Home Screen", style: TextStyle(fontSize: 24))),
    Center(child: Text("👤 Profile Screen", style: TextStyle(fontSize: 24))),
    Center(child: Text("⚙️ Settings Screen", style: TextStyle(fontSize: 24))),
  ];

  final List<String> _titles = ["Home", "Profile", "Settings"];

  void _onItemTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context); // close the drawer after selecting
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_selectedIndex])),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const UserAccountsDrawerHeader(
              accountName: Text("John Doe"),
              accountEmail: Text("john.doe@example.com"),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text("J", style: TextStyle(fontSize: 24)),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Home"),
              onTap: () => _onItemTap(0),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Profile"),
              onTap: () => _onItemTap(1),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              onTap: () => _onItemTap(2),
            ),
          ],
        ),
      ),
      body: _screens[_selectedIndex],
    );
  }
}
