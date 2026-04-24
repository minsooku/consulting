import 'package:flutter/material.dart';
import 'package:consulting_fe/api/models/location_suggestion.dart';

class AddressSearchSheetContent extends StatelessWidget {
  const AddressSearchSheetContent({
    super.key,
    this.initialQuery,
    this.showLabelStep = false,
    this.onResult,
  });

  final String? initialQuery;
  final bool showLabelStep;
  final ValueChanged<LocationSuggestion?>? onResult;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Address'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => onResult?.call(null),
        ),
      ),
      body: const Center(child: Text('Address Search – coming soon')),
    );
  }
}
