
import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'login_screen.dart';
import 'admin_screen.dart';
import 'dashboard_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Login App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/login': (context) => LoginScreen(),
        '/admin': (context) => AdminScreen(),
        '/dashboard': (context) => DashboardScreen(),
      },
    );
  }
}
