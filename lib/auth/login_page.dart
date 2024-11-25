import 'package:e_learningapp_admin/auth/auth_message_friendly.dart';
import 'package:e_learningapp_admin/export/export.dart';
import 'package:loading_btn/loading_btn.dart';
import 'package:toastification/toastification.dart';
import '../utils/toast_notification_config.dart';

// ignore: must_be_immutable
class LoginPage extends StatelessWidget {
  final VoidCallback onswitchtoSignup;
  final TextEditingController txtemail = TextEditingController();
  final TextEditingController txtpassword = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool autoFocus = false;

  LoginPage({Key? key, required this.onswitchtoSignup}) : super(key: key);

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
                  'Welcome Back!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10.0),
                Text(
                  'Sign in to your account to continue',
                  style: TextStyle(
                    fontSize: 14,
                    color: txtemail.text.isEmpty ||
                            _validateEmail(txtemail.text) != null
                        ? Colors.red
                        : Colors.grey,
                  ),
                ),
                SizedBox(
                    height: isDesktop
                        ? 30.0
                        : isTablet
                            ? 20.0
                            : 10.0),
                TextFormField(
                  controller: txtemail,
                  validator: (value) => _validateEmail(value),
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
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) {
                    //  FocusScope.of(context).nextFocus();
                    autoFocus = true;
                  },
                ),
                SizedBox(
                    height: isDesktop
                        ? 20.0
                        : isTablet
                            ? 15.0
                            : 10.0),
                TextFormField(
                  controller: txtpassword,
                  validator: (value) => _validatePassword(value),
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
                  textInputAction: TextInputAction.done,
                  autofocus: autoFocus,
                  onFieldSubmitted: (_) {
                    if (_formKey.currentState!.validate()) {
                      _signIn(context);
                    }
                    autoFocus = false;
                  },
                  obscureText: true,
                ),
                SizedBox(
                    height: isDesktop
                        ? 30.0
                        : isTablet
                            ? 20.0
                            : 10.0),
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
                    "Login",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onTap: (startLoading, stopLoading, btnState) async {
                    if (btnState == ButtonState.idle) {
                      if (_formKey.currentState!.validate()) {
                        startLoading();
                        await _signIn(context);
                        stopLoading();
                      }
                    }
                  },
                ),
                const SizedBox(height: 10.0),
                TextButton(
                  onPressed: onswitchtoSignup,
                  child: const Text('Create an account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _validateEmail(String? email) {
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

  String? _validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    } else if (password.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    return null;
  }

  Future<void> _signIn(BuildContext context) async {
    String message = '';
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: txtemail.text.trim(),
        password: txtpassword.text.trim(),
      );
      message = 'Login successful. Welcome!';
      toastificationUtils(
          title: 'Success',
          message,
          primaryColor: Colors.green,
          icon: Icons.check,
          showProgressBar: true,
          BackgroundColor: Colors.green.shade200,
          foregroundColor: Colors.black,
          toastType: ToastificationType.success);
    } on FirebaseAuthException catch (e) {
      message = getUserFriendlyMessage(e.code);
      toastificationUtils(message,
          title: 'Failed to login', showProgressBar: true);
    } catch (e) {
      message = e.toString();
      toastificationUtils(message, title: 'Failed to login');
    }
  }
}
