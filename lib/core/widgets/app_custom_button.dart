import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color bgColor;
  final double? btnHeight;

  // Optional features
  final IconData? icon;
  final Color? iconColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Widget? child;
  final double borderWidth;
  final Color? borderColor;
  final Color? textColor;
  final double borderRadius;

  // Loading support
  final bool loading;
  final Color? loaderColor;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.bgColor,
    this.child,
    this.icon,
    this.iconColor,
    this.fontSize,
    this.fontWeight,
    this.borderWidth = 0,
    this.borderColor,
    this.textColor,
    this.btnHeight = 45,
    this.borderRadius = 30,

    // Loading
    this.loading = false,
    this.loaderColor,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      color: textColor ?? Colors.white,
      fontSize: fontSize ?? 16,
      fontWeight: fontWeight ?? FontWeight.w700,
    );

    final buttonStyle = ElevatedButton.styleFrom(
      elevation: 0,
      backgroundColor: bgColor,
      disabledBackgroundColor: bgColor.withOpacity(0.7),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        side: BorderSide(
          width: borderWidth,
          color: borderColor ?? Colors.transparent,
        ),
      ),
    );

    Widget buttonChild;

    // =========================
    // Loading State
    // =========================
    if (loading) {
      buttonChild = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: loaderColor ?? Colors.white,
            ),
          ),

          // Show text while loading
          if (text.isNotEmpty) ...[
            const SizedBox(width: 10),
            Text(text, style: textStyle),
          ],
        ],
      );
    }
    // =========================
    // Custom Child
    // =========================
    else if (child != null) {
      buttonChild = child!;
    }
    // =========================
    // Icon + Text
    // =========================
    else if (icon != null) {
      buttonChild = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor ?? (textColor ?? Colors.white), size: 18),
          const SizedBox(width: 8),
          Text(text, style: textStyle),
        ],
      );
    }
    // =========================
    // Text Only
    // =========================
    else {
      buttonChild = Text(text, style: textStyle);
    }

    return SizedBox(
      width: double.infinity,
      height: btnHeight,
      child: ElevatedButton(
        style: buttonStyle,

        // Disable button while loading
        onPressed: loading ? null : onPressed,

        child: FittedBox(fit: BoxFit.scaleDown, child: buttonChild),
      ),
    );
  }
}
