final Map<String, String> errorMessages = {
  'invalid-credential': 'Invalid login credentials. Please check your email and password.',
  'user-not-found': 'No account found with this email. Please sign up first.',
  'email-already-in-use': 'This email is already in use. Please use a different email or log in.',
  'weak-password': 'The password is too weak. Please choose a stronger password.',
  'network-request-failed': 'Network error. Please check your internet connection and try again.',
  'SERVER_ERROR': 'Server error. Please try again later.',
  'too-many-requests': 'You have made too many requests in a short period. Please wait a moment and try again.',
  'OPERATION_NOT_ALLOWED': 'This operation is not allowed. Please contact support.',
  'user-disabled': 'Your account has been disabled. Please contact support for assistance.',
  'SESSION_EXPIRED': 'Your session has expired. Please log in again.',
  'INVALID_VERIFICATION_CODE': 'The verification code is invalid. Please check and try again.',
  'ACCOUNT_LOCKED': 'Your account has been locked due to multiple failed login attempts. Please try again later.',
  'wrong-password': 'The password you entered is incorrect. Please try again.',
  'EMAIL_NOT_VERIFIED': 'Your email address is not verified. Please check your email for a verification link.',
  'INSUFFICIENT_PERMISSIONS': 'You do not have sufficient permissions to perform this action.',
  'MISSING_REQUIRED_FIELDS': 'Some required fields are missing. Please fill in all required fields and try again.',
  'password_too_recent': 'The password was changed recently. Please try again later or use a different password.',
  'CREDENTIALS_EXPIRED': 'Your credentials have expired. Please log in again.',
  'AUTHENTICATION_FAILED': 'Authentication failed. Please check your credentials and try again.',
  'DUPLICATE_ENTRY': 'This entry already exists. Please use a different value.',
  'invalid-email': 'The email address is badly formatted.'
};
String getUserFriendlyMessage(String errorCode) {
  return errorMessages[errorCode] ?? 'An unknown error occurred. Please try again later.';
}