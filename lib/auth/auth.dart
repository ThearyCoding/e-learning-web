import 'package:e_learningapp_admin/auth/login_page.dart';
import 'package:e_learningapp_admin/auth/sign_page.dart';
import 'package:flutter/material.dart';

class Auth extends StatefulWidget {
  const Auth({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AuthState createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  bool showSignIn = true;
  void toggleView() {
    setState(() => showSignIn = !showSignIn);
  }

  @override
  Widget build(BuildContext context) {
    if (showSignIn) {
      return LoginPage(
        onswitchtoSignup: toggleView,
      );
    } else {
      return SignUpPage(onSwitchToLogin: toggleView);
    }
  }
}