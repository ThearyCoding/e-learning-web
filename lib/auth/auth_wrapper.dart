import 'package:e_learningapp_admin/admin/completion_information.dart';
import 'package:e_learningapp_admin/auth/auth.dart';
import 'package:e_learningapp_admin/services/firebase/firebase_service.dart';
import 'package:e_learningapp_admin/screens/approved_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class IsAuthenticated extends StatelessWidget {
  const IsAuthenticated({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: Colors.white,
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.data == null) {
              return const Auth();
            } else {
              return StreamBuilder(
                  stream: FirebaseService()
                      .isInformationCompleteStream(snapshot.data!),
                  builder: (context, infoSnapshot) {
                    if (infoSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Container(
                        color: Colors.white,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    } else if (infoSnapshot.data == true) {
                      return const ApprovedPage();
                    } else {
                      return CompletionInformation();
                    }
                  });
            }
          }
          return const Auth();
        });
  }
}
