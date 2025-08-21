import 'package:flutter/material.dart';

void main() {
  runApp(ColorChangerApp());
}

class ColorChangerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Color Changer',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ColorChangerScreen(),
    );
  }
}

enum BgColor { red, green, blue, yellow }

class ColorChangerScreen extends StatefulWidget {
  @override
  _ColorChangerScreenState createState() => _ColorChangerScreenState();
}

class _ColorChangerScreenState extends State<ColorChangerScreen> {
  BgColor? _selectedColor;

  Color _getColor() {
    switch (_selectedColor) {
      case BgColor.red:
        return Colors.red;
      case BgColor.green:
        return Colors.green;
      case BgColor.blue:
        return Colors.blue;
      case BgColor.yellow:
        return Colors.yellow;
      default:
        return Colors.white; // default background
    }
  }

  Widget _buildRadio(BgColor color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<BgColor>(
          value: color,
          groupValue: _selectedColor,
          onChanged: (BgColor? value) {
            setState(() {
              _selectedColor = value;
            });
          },
        ),
        Text(label),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Background Color Changer")),
      body: Container(
        color: _getColor(),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildRadio(BgColor.red, "Red"),
              _buildRadio(BgColor.green, "Green"),
              _buildRadio(BgColor.blue, "Blue"),
              _buildRadio(BgColor.yellow, "Yellow"),
            ],
          ),
        ),
      ),
    );
  }
}
