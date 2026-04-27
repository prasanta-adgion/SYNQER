// ignore_for_file: deprecated_member_use, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  @override
  Widget build(BuildContext context) {
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
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF7F7F7),
            enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(color: Colors.black12),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(color: Colors.black38),
            ),
            errorBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(color: Colors.redAccent, width: 1),
            ),
            focusedErrorBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(color: Colors.redAccent, width: 1),
            ),
            // Fix: icon aligned with text via constraints + color shift on focus
            prefixIcon: widget.fieldIcon != null
                ? Icon(
                    widget.fieldIcon,
                    color: isFocused ? Colors.black54 : const Color(0xFF888888),
                    size: 20,
                  )
                : null,
            prefixIconConstraints: const BoxConstraints(
              minWidth: 44,
              minHeight: 44,
            ),
            labelText: widget.labelText,
            hintText: widget.hint_text,
            hintStyle: const TextStyle(color: Color(0xFFBBBBBB), fontSize: 13),
            errorStyle: const TextStyle(fontSize: 10),
            alignLabelWithHint: true,
            suffixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
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
