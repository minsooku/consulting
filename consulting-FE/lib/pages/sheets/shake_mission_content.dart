import 'package:flutter/material.dart';

class ShakeMissionContent extends StatelessWidget {
  const ShakeMissionContent({super.key, this.onResult});

  final ValueChanged<dynamic>? onResult;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shake Mission'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => onResult?.call(null),
        ),
      ),
      body: const Center(child: Text('Shake Mission – coming soon')),
    );
  }
}
