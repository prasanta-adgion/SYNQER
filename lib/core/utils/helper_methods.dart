import 'package:characters/characters.dart';

class AppHelperMethods {
  static String initialsNameCharacter(String name) {
    final parts = _safeUtf16(name)
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return _firstCharacter(parts.first);
    return '${_firstCharacter(parts.first)}${_firstCharacter(parts.last)}'
        .toUpperCase();
  }

  static String _firstCharacter(String value) {
    final characters = value.characters;
    if (characters.isEmpty) return 'U';
    return characters.first.toUpperCase();
  }

  static String _safeUtf16(String value) {
    final buffer = StringBuffer();

    for (var i = 0; i < value.length; i++) {
      final code = value.codeUnitAt(i);

      if (code >= 0xD800 && code <= 0xDBFF) {
        if (i + 1 < value.length) {
          final next = value.codeUnitAt(i + 1);
          if (next >= 0xDC00 && next <= 0xDFFF) {
            buffer.writeCharCode(code);
            buffer.writeCharCode(next);
            i++;
          }
        }
      } else if (code < 0xDC00 || code > 0xDFFF) {
        buffer.writeCharCode(code);
      }
    }

    return buffer.toString();
  }
}
