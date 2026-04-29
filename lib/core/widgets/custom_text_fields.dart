// ignore_for_file: deprecated_member_use, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:synqer_io/core/theme/app_colors.dart';
import 'package:synqer_io/core/theme/theme_scope.dart'; // adjust path if needed

/// Theme variants supported by [CustomTextFormField].
enum TextFieldTheme { light, dark }

class CustomTextFormField extends StatefulWidget {
  final TextEditingController controller;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final bool enable;
  final bool readOnly;
  final bool isPassword;
  final bool obscureText;
  final String? hint_text;
  final String? labelText;
  final IconData? fieldIcon; // prefix icon (left)
  final Widget? suffixIcon; // suffix widget (right)
  final List<TextInputFormatter>? inputFormatters;
  final Function(String)? onChanged;
  final VoidCallback? onTap;
  final int maxLines;

  /// Theme to apply. Defaults to [TextFieldTheme.light].
  final TextFieldTheme themeMode;

  const CustomTextFormField({
    super.key,
    required this.controller,
    this.validator,
    this.hint_text,
    this.labelText,
    this.fieldIcon,
    this.isPassword = false,
    this.obscureText = false,
    this.keyboardType,
    this.enable = true,
    this.readOnly = false,
    this.suffixIcon,
    this.inputFormatters,
    this.onChanged,
    this.onTap,
    this.maxLines = 1,
    this.themeMode = TextFieldTheme.light,
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  late final FocusNode _focusNode;
  final ValueNotifier<bool> _isFocused = ValueNotifier(false);

  // ── Light theme palette (original) ────────────────────────────────────────
  static const _lightFill = Color(0xFFF7F7F7);
  static const _lightText = Colors.black;
  static const _lightHint = Color(0xFFBBBBBB);
  static const _lightIconIdle = Color(0xFF888888);
  static const _lightIconFocus = Colors.black54;
  static const _lightBorder = Colors.black12;
  static const _lightBorderFocus = Colors.black38;

  // ── Dark theme palette (neutrals only; accent comes from AppColors) ───────
  static const _darkFill = Color(0xFF141C2A);
  static const _darkText = Color(0xFFEEF2FF);
  static const _darkHint = Color(0xFF3A4A65);
  static const _darkIconIdle = Color(0xFF6B7A99);
  static const _darkBorder = Color(0xFF1F2D42);

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()
      ..addListener(() {
        _isFocused.value = _focusNode.hasFocus;
      });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _isFocused.dispose();
    super.dispose();
  }

  bool get _isDark => widget.themeMode == TextFieldTheme.dark;

  Color get _fillColor => _isDark ? _darkFill : _lightFill;
  Color get _textColor => _isDark ? _darkText : _lightText;
  Color get _hintColor => _isDark ? _darkHint : _lightHint;
  Color get _iconIdleColor => _isDark ? _darkIconIdle : _lightIconIdle;
  Color get _iconFocusColor =>
      _isDark ? context.colors.primary : _lightIconFocus;
  Color get _borderColor => _isDark ? _darkBorder : _lightBorder;
  Color get _borderFocusColor =>
      _isDark ? context.colors.primary : _lightBorderFocus;

  @override
  Widget build(BuildContext context) {
    // Responsive font scaling (clamped to keep layout sane)
    final width = MediaQuery.of(context).size.width;
    final scale = (width / 375).clamp(0.85, 1.15);
    final fontSize = 14.0 * scale;
    final hintSize = 13.0 * scale;

    return ValueListenableBuilder<bool>(
      valueListenable: _isFocused,
      builder: (context, isFocused, _) {
        return TextFormField(
          onTap: widget.onTap,
          readOnly: widget.readOnly,
          focusNode: _focusNode,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          controller: widget.controller,
          validator: widget.validator,
          keyboardType: widget.keyboardType,
          enabled: widget.enable,
          obscureText: widget.isPassword ? widget.obscureText : false,
          inputFormatters: widget.inputFormatters,
          onChanged: widget.onChanged,
          maxLines: widget.isPassword ? 1 : widget.maxLines,
          cursorColor: context.colors.primary,
          style: TextStyle(
            fontSize: fontSize,
            color: _textColor,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: _fillColor,
            enabledBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: _borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: _borderFocusColor, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: context.colors.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: context.colors.error, width: 1.5),
            ),
            prefixIcon: widget.fieldIcon != null
                ? Icon(
                    widget.fieldIcon,
                    color: isFocused ? _iconFocusColor : _iconIdleColor,
                    size: 18 * scale,
                  )
                : null,
            prefixIconConstraints: const BoxConstraints(
              minWidth: 44,
              minHeight: 44,
            ),
            labelText: widget.labelText,
            hintText: widget.hint_text,
            hintStyle: TextStyle(color: _hintColor, fontSize: hintSize),
            errorStyle: TextStyle(fontSize: 11, color: context.colors.error),
            alignLabelWithHint: true,
            suffixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16 * scale,
              vertical: 16 * scale,
            ),
            suffixIcon: widget.suffixIcon != null
                ? Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: widget.suffixIcon,
                  )
                : null,
          ),
        );
      },
    );
  }
}
