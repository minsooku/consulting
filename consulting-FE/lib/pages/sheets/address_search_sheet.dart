import 'package:flutter/material.dart';

import 'package:consulting_fe/api/models/location_suggestion.dart';
import 'package:consulting_fe/components/customs/cupertino_native-0.1.1/lib/style/sheet_detent.dart';
import 'package:consulting_fe/components/platform/platform_sheet.dart';
import 'package:consulting_fe/const/app_colors.dart';
import 'package:consulting_fe/pages/sheets/address_search_content.dart';

class AddressSearchSheet {
  AddressSearchSheet._();

  static Future<LocationSuggestion?> show(
    BuildContext context, {
    String? initialQuery,
    bool showLabelStep = false,
  }) {
    return PlatformSheet.show<LocationSuggestion>(
      context: context,
      route: 'addressSearch',
      arguments: {
        if (initialQuery != null) 'initialQuery': initialQuery,
        if (showLabelStep) 'showLabelStep': true,
      },
      builder: (ctx) => FractionallySizedBox(
        heightFactor: 0.98,
        child: Material(
          color: AppColors.background,
          child: AddressSearchSheetContent(
            initialQuery: initialQuery,
            showLabelStep: showLabelStep,
            onResult: (suggestion) => Navigator.of(ctx).pop(suggestion),
          ),
        ),
      ),
      detents: [CNSheetDetent.large],
      initialDetent: CNSheetDetent.large,
      showDragHandle: false,
      fromResult: (raw) => raw is Map
          ? LocationSuggestion.fromJson(Map<String, dynamic>.from(raw))
          : raw as LocationSuggestion,
    );
  }
}
