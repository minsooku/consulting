import 'package:consulting_fe/components/customs/cupertino_native-0.1.1/lib/cupertino_native.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:consulting_fe/components/android/button_android.dart';
import 'package:consulting_fe/components/ios/button_ios.dart';
import 'package:consulting_fe/const/app_colors.dart';

bool get _isCupertino {
  if (kIsWeb) return false;
  return defaultTargetPlatform == TargetPlatform.iOS;
}

class PlatformButton extends StatelessWidget {
  const PlatformButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isGlass = false,
    this.isProminentGlass = false,
    this.tint,
    this.height = 32.0,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isGlass;
  final bool isProminentGlass;
  final Color? tint;
  final double height;

  @override
  Widget build(BuildContext context) {
    final resolvedTint = tint ?? AppColors.mainPoint;

    final CNButtonStyle style;
    if (isProminentGlass) {
      style = CNButtonStyle.prominentGlass;
    } else if (isGlass) {
      style = CNButtonStyle.glass;
    } else {
      style = CNButtonStyle.plain;
    }

    if (_isCupertino) {
      return IosTextButton(
        text: text,
        onPressed: onPressed,
        tint: resolvedTint,
        style: style,
        height: height,
        shrinkWrap: !isProminentGlass,
      );
    }

    return AndroidTextButton(
      text: text,
      onPressed: onPressed,
      backgroundColor: isGlass ? null : resolvedTint,
      foregroundColor: isGlass
          ? (tint ?? AppColors.textPrimary) // respect explicit tint on glass
          : AppColors.mainPointText,
      isGlass: isGlass,
      isProminentGlass: isProminentGlass,
      height: height,
    );
  }
}

class PlatformLoginButton extends StatelessWidget {
  const PlatformLoginButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onPressed,
    this.tint,
    this.height = 50.0,
    this.enabled = true,
    this.outlined = false,
    this.isProminentGlass = false,
  });

  final String text;
  final Widget icon;
  final VoidCallback? onPressed;
  final Color? tint;
  final double height;
  final bool enabled;
  final bool outlined;
  final bool isProminentGlass;

  @override
  Widget build(BuildContext context) {
    if (_isCupertino) {
      return IosLoginButton(
        text: text,
        icon: icon,
        onPressed: onPressed,
        tint: tint ?? AppColors.mainPoint,
        height: height,
        enabled: enabled,
        outlined: outlined,
        isProminentGlass: isProminentGlass,
      );
    }

    return AndroidLoginButton(
      text: text,
      icon: icon,
      onPressed: onPressed,
      backgroundColor: outlined ? null : (tint ?? AppColors.mainPoint),
      foregroundColor: outlined
          ? AppColors.textPrimary
          : AppColors.mainPointText,
      height: height,
      enabled: enabled,
      outlined: outlined,
      isProminentGlass: isProminentGlass,
    );
  }
}

class PlatformIconButton extends StatelessWidget {
  const PlatformIconButton({
    super.key,
    required this.iosIcon,
    required this.androidIcon,
    required this.onPressed,
    this.size = 44.0,
    this.isGlass = true,
  });

  final String iosIcon;
  final IconData androidIcon;
  final VoidCallback? onPressed;
  final double size;
  final bool isGlass;

  @override
  Widget build(BuildContext context) {
    if (_isCupertino) {
      return IosIconButton(
        sfSymbolName: iosIcon,
        onPressed: onPressed,
        tint: AppColors.mainPoint,
        size: size,
        style: isGlass ? CNButtonStyle.glass : CNButtonStyle.plain,
      );
    }

    return AndroidIconButton(
      icon: androidIcon,
      onPressed: onPressed,
      size: size,
      isGlass: isGlass,
    );
  }
}
