import 'package:flutter/material.dart';

import 'package:consulting_fe/const/app_colors.dart';
import 'package:consulting_fe/const/app_fonts.dart';

/// Tappable search bar that visually matches the real search field inside
/// AddressSearchSheet (pill shape, same colors/padding/icon).
class SearchBarButton extends StatefulWidget {
  const SearchBarButton({
    super.key,
    this.placeholder = 'Search address',
    required this.onTap,
  });

  final String placeholder;
  final VoidCallback onTap;

  @override
  State<SearchBarButton> createState() => _SearchBarButtonState();
}

class _SearchBarButtonState extends State<SearchBarButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: _pressed
              ? AppColors.sub.withValues(alpha: 0.5)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.sub, width: 1),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.search_rounded,
              size: 22,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.placeholder,
                style: const TextStyle(
                  fontFamily: AppFonts.normal,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
