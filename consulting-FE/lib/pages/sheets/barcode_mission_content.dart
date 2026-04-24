import 'package:flutter/material.dart';

class BarcodeMissionContent extends StatelessWidget {
  const BarcodeMissionContent({super.key, this.onResult});

  final ValueChanged<dynamic>? onResult;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barcode Mission'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => onResult?.call(null),
        ),
      ),
      body: const Center(child: Text('Barcode Mission – coming soon')),
    );
  }
}
