mixin Validation {
  // static final RegExp _emailRegex = RegExp(
  //   r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
  // );
  static final RegExp _emailRegex = RegExp(
    r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
  );

  static String? validateName(String? v) {
    final value = v?.trim();

    if (value == null || value.isEmpty) {
      return 'Please enter your full name';
    }

    if (value.length < 3) {
      return 'Name must be at least 3 characters';
    }

    if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(value)) {
      return 'Name can contain only letters';
    }

    return null;
  }

  static String? validateEmail(String? v) {
    final value = v?.trim();

    if (value == null || value.isEmpty) {
      return 'Please enter your email address';
    }

    if (!_emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  static String? validatePhone(String? v) {
    final value = v?.trim();

    if (value == null || value.isEmpty) {
      return 'Please enter mobile number.';
    }

    final digits = value.replaceAll(RegExp(r'\D'), '');

    if (digits.length != 10) {
      return 'Mobile number must be 10 digits.';
    }

    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(digits)) {
      return 'Enter a valid Indian mobile number.';
    }

    return null;
  }

  static String? validatePassword(String? v) {
    final value = v?.trim();

    if (value == null || value.isEmpty) {
      return 'Please enter your password.';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters.';
    }

    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Include at least one uppercase letter.';
    }

    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Include at least one lowercase letter.';
    }

    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Include at least one number.';
    }

    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Include at least one special character.';
    }

    return null;
  }
}
