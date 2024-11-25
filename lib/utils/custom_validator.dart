String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }

    // Using a regular expression to validate email format
    String emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    RegExp regExp = RegExp(emailPattern);

    if (!regExp.hasMatch(email)) {
      return 'Invalid email format';
    }

    return null;
  }
String? validatePassword(String? password) {
  if (password == null || password.isEmpty) {
    return 'Password is required';
  }

  // Minimum length of 8 characters
  if (password.length < 8) {
    return 'Password must be at least 8 characters long';
  }


  return null;
}
