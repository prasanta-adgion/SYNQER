// ignore_for_file: deprecated_member_use, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:synqer_io/core/theme/app_colors.dart';
import 'package:synqer_io/core/theme/theme_scope.dart';

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

  final IconData? fieldIcon;
  final Widget? suffixIcon;

  final List<TextInputFormatter>? inputFormatters;

  final Function(String)? onChanged;
  final VoidCallback? onTap;

  final int maxLines;

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
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  late final FocusNode _focusNode;

  final ValueNotifier<bool> _isFocused = ValueNotifier(false);

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

  AppColors get c => context.colors;

  Color get _fillColor => c.inputFill;

  Color get _textColor => c.inputText;

  Color get _hintColor => c.inputHint;

  Color get _iconIdleColor => c.inputIcon;

  Color get _iconFocusColor => c.inputIconFocus;

  Color get _borderColor => c.inputBorder;

  Color get _borderFocusColor => c.inputBorderFocus;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final scale = (width / 375).clamp(0.85, 1.15);

    final fontSize = 14.0 * scale;

    final hintSize = 13.0 * scale;

    return ValueListenableBuilder<bool>(
      valueListenable: _isFocused,
      builder: (context, isFocused, _) {
        return TextFormField(
          controller: widget.controller,

          validator: widget.validator,

          keyboardType: widget.keyboardType,

          enabled: widget.enable,

          readOnly: widget.readOnly,

          onTap: widget.onTap,

          obscureText: widget.isPassword ? widget.obscureText : false,

          inputFormatters: widget.inputFormatters,

          onChanged: widget.onChanged,

          maxLines: widget.isPassword ? 1 : widget.maxLines,

          focusNode: _focusNode,

          autovalidateMode: AutovalidateMode.onUserInteraction,

          cursorColor: c.primary,

          style: TextStyle(
            fontSize: fontSize,
            color: _textColor,
            fontWeight: FontWeight.w500,
          ),

          decoration: InputDecoration(
            filled: true,

            fillColor: _fillColor,

            labelText: widget.labelText,

            hintText: widget.hint_text,

            alignLabelWithHint: true,

            hintStyle: TextStyle(color: _hintColor, fontSize: hintSize),

            errorStyle: TextStyle(fontSize: 11, color: c.error),

            contentPadding: EdgeInsets.symmetric(
              horizontal: 16 * scale,
              vertical: 16 * scale,
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _borderColor),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _borderFocusColor, width: 1.5),
            ),

            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: c.error),
            ),

            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: c.error, width: 1.5),
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

            suffixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
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
