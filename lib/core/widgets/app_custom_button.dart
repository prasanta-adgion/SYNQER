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
  });

  @override
  Widget build(BuildContext context) {
    final buttonStyle = ElevatedButton.styleFrom(
      elevation: 0,
      backgroundColor: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        side: BorderSide(
          width: borderWidth,
          color: borderColor ?? Colors.transparent,
        ),
      ),
    );

    final textStyle = TextStyle(
      color: textColor,
      fontSize: fontSize ?? 16,
      fontWeight: fontWeight ?? FontWeight.w700,
    );

    Widget buttonChild;

    // custom child (loader, widget, etc.)
    if (child != null) {
      buttonChild = child!;
    }
    // Icon button
    else if (icon != null) {
      buttonChild = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor ?? Colors.white),
          const SizedBox(width: 8),
          Text(text, style: textStyle),
        ],
      );
    }
    // Normal text button
    else {
      buttonChild = Text(text, style: textStyle);
    }

    return SizedBox(
      width: double.infinity,
      height: btnHeight,
      child: ElevatedButton(
        style: buttonStyle,
        onPressed: onPressed,
        child: FittedBox(fit: BoxFit.scaleDown, child: buttonChild),
      ),
    );
  }
}
