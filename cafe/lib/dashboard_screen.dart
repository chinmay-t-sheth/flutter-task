import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  void _callEmployee(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Employee has been called')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Dashboard")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu, size: 100, color: Colors.blue),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _callEmployee(context),
              child: Text("Call Employee"),
            )
          ],
        ),
      ),
    );
  }
}
