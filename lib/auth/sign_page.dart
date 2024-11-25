import 'package:e_learningapp_admin/auth/auth_message_friendly.dart';
import 'package:e_learningapp_admin/utils/custom_validator.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:loading_btn/loading_btn.dart';

import '../utils/toast_notification_config.dart';

// ignore: must_be_immutable
class SignUpPage extends StatelessWidget {
  final VoidCallback onSwitchToLogin;

  SignUpPage({super.key, required this.onSwitchToLogin});
  final TextEditingController txtemail = TextEditingController();
  final TextEditingController txtpassword = TextEditingController();
  final TextEditingController txtconfirmpassword = TextEditingController();
  final bool autoFocus = false;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 1200;
    final isTablet = screenSize.width > 600 && screenSize.width <= 1200;

    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.all(isDesktop
              ? 40.0
              : isTablet
                  ? 30.0
                  : 20.0),
          constraints: const BoxConstraints(maxWidth: 500),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Create an Account',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10.0),
                const Text(
                  'Please fill out the form below to create your account:',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.red,
                  ),
                ),
                SizedBox(
                  height: isDesktop
                      ? 30.0
                      : isTablet
                          ? 20.0
                          : 10.0,
                ),
                TextFormField(
                  validator: validateEmail,
                  controller: txtemail,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Colors.green,
                        width: 1.0,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: isDesktop
                      ? 20.0
                      : isTablet
                          ? 15.0
                          : 10.0,
                ),
                TextFormField(
                  validator: validatePassword,
                  controller: txtpassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Colors.green,
                        width: 1.0,
                      ),
                    ),
                  ),
                  obscureText: true,
                ),
                SizedBox(
                  height: isDesktop
                      ? 20.0
                      : isTablet
                          ? 15.0
                          : 10.0,
                ),
                TextFormField(
                  validator: (value) {
                    if (value != txtpassword.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                  controller: txtconfirmpassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: Colors.green,
                        width: 1.0,
                      ),
                    ),
                  ),
                  obscureText: true,
                ),
                SizedBox(
                  height: isDesktop
                      ? 30.0
                      : isTablet
                          ? 20.0
                          : 10.0,
                ),
                LoadingBtn(
                  height: 50,
                  borderRadius: 8,
                  animate: true,
                  color: Colors.green,
                  width: MediaQuery.of(context).size.width * 0.45,
                  loader: Container(
                    padding: const EdgeInsets.all(10),
                    width: 40,
                    height: 40,
                    child: const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  child: const Text(
                    "Sign Up",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onTap: (startLoading, stopLoading, btnState) async {
                    if (!_formKey.currentState!.validate()) {
                      return;
                    }
                    if (btnState == ButtonState.idle) {
                      startLoading();
                      await _signUp(context);
                      stopLoading();
                    }
                  },
                ),
                SizedBox(
                  height: isDesktop
                      ? 15.0
                      : isTablet
                          ? 10.0
                          : 10.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?"),
                    TextButton(
                      onPressed: onSwitchToLogin,
                      child: const Text('Sign In Here'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future _signUp(BuildContext context) async {
    String message = '';

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: txtemail.text.trim(),
        password: txtpassword.text.trim(),
      );
      message = 'Account created successfully!';
      toastificationUtils(message,
          title: 'Success!', icon: Icons.check, showProgressBar: true);
    } on FirebaseAuthException catch (e) {
      message = getUserFriendlyMessage(e.code);
      toastificationUtils(message);
    } catch (e) {
      debugPrint('Error signing up: $e');
      toastificationUtils("Failed: $e");
    }
  }
}
