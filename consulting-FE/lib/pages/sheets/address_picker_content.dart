import 'package:flutter/material.dart';
import 'package:consulting_fe/api/models/location_model.dart';
import 'package:consulting_fe/api/models/location_suggestion.dart';

class AddressPickerContent extends StatelessWidget {
  const AddressPickerContent({
    super.key,
    this.savedLocations = const [],
    this.currentLabel = '',
    this.searchPlaceholder = 'Search for an address',
    this.showLabelStep = true,
    this.onResult,
  });

  final List<LocationModel> savedLocations;
  final String currentLabel;
  final String searchPlaceholder;
  final bool showLabelStep;
  final ValueChanged<LocationSuggestion?>? onResult;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Address'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => onResult?.call(null),
        ),
      ),
      body: const Center(child: Text('Address Picker – coming soon')),
    );
  }
}
