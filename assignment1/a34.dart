import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(title: Text("QR Code Example")),
      body: Center(
        child: QrImageView(
          data: "https://example.com",
          version: QrVersions.auto,
          size: 200.0,
        ),
      ),
    ),
  ));
}
