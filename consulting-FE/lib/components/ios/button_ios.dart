import 'package:consulting_fe/components/customs/cupertino_native-0.1.1/lib/cupertino_native.dart';
import 'package:flutter/cupertino.dart';

class IosTextButton extends StatelessWidget {
  const IosTextButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.tint,
    this.style = CNButtonStyle.plain,
    this.height = 32.0,
    this.shrinkWrap = true,
  });

  final String text;
  final VoidCallback? onPressed;
  final Color? tint;
  final CNButtonStyle style;
  final double height;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    return CNButton(
      label: text,
      onPressed: onPressed,
      tint: tint,
      shrinkWrap: shrinkWrap,
      style: style,
      height: height,
    );
  }
}

class IosLoginButton extends StatefulWidget {
  const IosLoginButton({
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
  State<IosLoginButton> createState() => _IosLoginButtonState();
}

class _IosLoginButtonState extends State<IosLoginButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = widget.enabled ? widget.onPressed : null;
    final isDisabled = effectiveOnPressed == null;

    // ── prominentGlass style: white surface card with press animation ──────
    if (widget.isProminentGlass) {
      return GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          effectiveOnPressed?.call();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            height: widget.height,
            decoration: BoxDecoration(
              color: _pressed
                  ? CupertinoColors.systemBackground.withValues(alpha: 0.85)
                  : CupertinoColors.systemBackground,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: CupertinoColors.separator.resolveFrom(context),
                width: 0.5,
              ),
              boxShadow: isDisabled
                  ? null
                  : [
                      BoxShadow(
                        color: CupertinoColors.black.withValues(
                          alpha: _pressed ? 0.04 : 0.09,
                        ),
                        blurRadius: _pressed ? 8 : 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: _buildContent(
              fg: isDisabled
                  ? CupertinoColors.inactiveGray
                  : CupertinoColors.label,
            ),
          ),
        ),
      );
    }

    // ── outlined style ────────────────────────────────────────────────────
    if (widget.outlined) {
      return SizedBox(
        height: widget.height,
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          minSize: 0,
          onPressed: effectiveOnPressed,
          child: Container(
            decoration: BoxDecoration(
              color: CupertinoColors.systemBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: CupertinoColors.separator,
                width: 0.5,
              ),
            ),
            child: Center(
              child: _buildContent(fg: CupertinoColors.label),
            ),
          ),
        ),
      );
    }

    // ── solid tinted style ────────────────────────────────────────────────
    final bg = widget.tint ?? CupertinoColors.label;
    return SizedBox(
      height: widget.height,
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        minSize: 0,
        onPressed: effectiveOnPressed,
        color: bg,
        borderRadius: BorderRadius.circular(12),
        child: Center(child: _buildContent(fg: CupertinoColors.white)),
      ),
    );
  }

  Widget _buildContent({required Color fg}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          widget.icon,
          const SizedBox(width: 10),
          Text(
            widget.text,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

class IosIconButton extends StatelessWidget {
  const IosIconButton({
    super.key,
    required this.sfSymbolName,
    required this.onPressed,
    this.tint,
    this.size = 32.0,
    this.style = CNButtonStyle.glass,
  });

  final String sfSymbolName;
  final VoidCallback? onPressed;
  final Color? tint;
  final double size;
  final CNButtonStyle style;

  @override
  Widget build(BuildContext context) {
    return CNButton.icon(
      icon: CNSymbol(sfSymbolName, size: size * 0.45),
      onPressed: onPressed,
      tint: tint,
      size: size,
      style: style,
    );
  }
}
