import 'package:flutter/material.dart';

class PhotoMissionContent extends StatelessWidget {
  const PhotoMissionContent({super.key, this.onResult});

  final ValueChanged<dynamic>? onResult;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo Mission'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => onResult?.call(null),
        ),
      ),
      body: const Center(child: Text('Photo Mission – coming soon')),
    );
  }
}
