import 'dart:async';

import 'package:flutter/material.dart';
import 'package:synqer_io/core/theme/theme_scope.dart';

class ReusableSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;
  final Duration debounceDuration;

  const ReusableSearchBar({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onChanged,
    this.debounceDuration = const Duration(milliseconds: 500),
  });

  @override
  State<ReusableSearchBar> createState() => _ReusableSearchBarState();
}

typedef SearchBarScreen = ReusableSearchBar;

class _ReusableSearchBarState extends State<ReusableSearchBar> {
  Timer? _debounce;
  final _hasTextNotifier = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _hasTextNotifier.value = widget.controller.text.isNotEmpty;
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _debounce?.cancel();
    _hasTextNotifier.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    final hasText = widget.controller.text.isNotEmpty;
    if (_hasTextNotifier.value != hasText) {
      _hasTextNotifier.value = hasText;
    }
  }

  void _onTextChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(widget.debounceDuration, () {
      if (!mounted) return;
      widget.onChanged(value);
    });
  }

  void _clearSearch() {
    widget.controller.clear();
    _onTextChanged('');
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: c.border),
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: c.textSecondary, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: widget.controller,
              onChanged: _onTextChanged,
              style: TextStyle(color: c.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: TextStyle(color: c.textSecondary, fontSize: 13),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _hasTextNotifier,
            builder: (_, hasText, _) {
              if (!hasText) return const SizedBox.shrink();
              return GestureDetector(
                onTap: _clearSearch,
                child: Icon(
                  Icons.close_rounded,
                  color: c.textSecondary,
                  size: 16,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
