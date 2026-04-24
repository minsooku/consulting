import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:consulting_fe/const/app_colors.dart';
import 'package:consulting_fe/const/app_fonts.dart';

class SettingsFooter extends StatelessWidget {
  const SettingsFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 90, top: 40),
      child: Column(
        children: [
          ClipRRect(
            child: Image.asset(
              'assets/login/light_icon.png',
              width: 72,
              height: 72,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Developed by Wonjae Kim',
            style: TextStyle(
              fontFamily: AppFonts.normal,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () => launchUrl(
              Uri.parse('https://google.com'),
              mode: LaunchMode.externalApplication,
            ),
            child: Text(
              'google.com',
              style: TextStyle(
                fontFamily: AppFonts.normal,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
