import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, this.onInputActiveChanged});

  final ValueChanged<bool>? onInputActiveChanged;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Settings Page – coming soon')),
    );
  }
}
