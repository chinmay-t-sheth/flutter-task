// lib/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SwitchListTile(
              title: const Text('Dark Mode'),
              value: themeProvider.isDarkMode,
              onChanged: (value) {
                themeProvider.toggleTheme(value);
              },
            ),
            ListTile(
              title: const Text('About'),
              subtitle: const Text('FD Tracker v1.0'),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'FD Tracker',
                  applicationVersion: '1.0',
                  applicationIcon: const Icon(Icons.account_balance),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}