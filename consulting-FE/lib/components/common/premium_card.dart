import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bouncing_widgets/flutter_bouncing_widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:consulting_fe/const/app_fonts.dart';

class PremiumCard extends StatelessWidget {
  const PremiumCard({super.key, this.onTap});

  final VoidCallback? onTap;

  static const _gradientStart = Color(0xFF2979FF);
  static const _gradientEnd = Color(0xFF40C4FF);

  @override
  Widget build(BuildContext context) {
    return CustomBounceWidget(
      scaleFactor: 0.3,
      onPressed: onTap ?? () {},
      isScrollable: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_gradientStart, _gradientEnd],
            ),
          ),
          child: Stack(
            children: [
              // Background particles
              ..._buildParticles(),
              Row(
                children: [
                  SvgPicture.asset(
                    'assets/settings/premium.svg',
                    width: 28,
                    height: 28,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pro',
                          style: TextStyle(
                            fontFamily: AppFonts.normal,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Unlock all features',
                          style: TextStyle(
                            fontFamily: AppFonts.normal,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.white70,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildUpgradeButton(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpgradeButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 9,
            backgroundColor: _gradientStart,
            child: Icon(
              Icons.arrow_upward_rounded,
              size: 12,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 6),
          Text(
            'Upgrade',
            style: TextStyle(
              fontFamily: AppFonts.normal,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _gradientStart,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildParticles() {
    final positions = [
      (0.15, 0.1, 3.0),
      (0.55, 0.6, 2.0),
      (0.72, 0.15, 2.5),
      (0.88, 0.7, 1.5),
      (0.35, 0.85, 2.0),
    ];
    return positions.map((p) {
      return Positioned(
        left: p.$1 * 300,
        top: p.$2 * 80,
        child: Container(
          width: p.$3,
          height: p.$3,
          decoration: const BoxDecoration(
            color: Colors.white38,
            shape: BoxShape.circle,
          ),
        ),
      );
    }).toList();
  }
}
