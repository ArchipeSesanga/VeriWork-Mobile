class Validations {
  // validate email
  static String? validateEmail(String? value, [bool isRequried = true]) {
    if (value!.isEmpty && isRequried) return 'Email is required.';
    final RegExp nameExp = RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");
    if (!nameExp.hasMatch(value) && isRequried) {
      return 'Please enter valid email address';
    }
    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value!.isEmpty || value.length < 6) {
      return 'Password must be 6 charaters long.';
    }
    // if (!value.contains('@')) {
    //   return 'Password must contain @ symbol';
    // }
    return null;
  }
}
