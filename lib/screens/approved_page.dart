import '../export/export.dart';

class ApprovedPage extends StatelessWidget {
  const ApprovedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.active) {
          if (authSnapshot.data != null) {
            FirebaseService firebaseService = FirebaseService();
            return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>?>(
              stream: firebaseService.adminStream(authSnapshot.data!.uid),
              builder: (context, adminSnapshot) {
                if (adminSnapshot.connectionState == ConnectionState.waiting) {
                  return configloadingProgressIndicator();
                } else if (adminSnapshot.hasError) {
                  return Center(child: Text('Error: ${adminSnapshot.error}'));
                } else if (adminSnapshot.hasData &&
                    adminSnapshot.data!.exists) {
                  bool isAdminApproved = adminSnapshot.data!['approved'];
                  String isSuperAdmin = adminSnapshot.data!['role'];
                  String imageUrl = adminSnapshot.data!['imageUrl'];
                  String userEmail = adminSnapshot.data!['email'];
                  return _buildApprovalPage(
                    context,
                    isAdminApproved,
                    isSuperAdmin,
                    imageUrl,
                    userEmail,
                  );
                } else {
                  return const Text('Admin document does not exist');
                }
              },
            );
          } else {
            return const Text('User not authenticated.');
          }
        } else {
          return configloadingProgressIndicator();
        }
      },
    ));
  }

  Widget _buildApprovalPage(BuildContext context, bool isAdminApproved,
      String isSuperAdmin, String imageUrl, String userEmail) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double fontSize = constraints.maxWidth > 600 ? 24 : 16;
        double imageSize = constraints.maxWidth > 600 ? 200 : 150;
        EdgeInsetsGeometry padding =
            EdgeInsets.all(constraints.maxWidth > 600 ? 30.0 : 20.0);

        return isAdminApproved
            ? isSuperAdmin == 'super_admin'
                ? const SuperAdminScreen()
                : isSuperAdmin == 'regular_admin'
                    ? const RegularAdminScreen()
                    : Container()
            : Center(
                child: Container(
                  padding: padding,
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Padding(
                      padding: padding,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15.0),
                            child: Image.network(
                              imageUrl,
                              width: imageSize,
                              height: imageSize,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Status : ',
                                style: TextStyle(
                                  fontSize: fontSize,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                isAdminApproved
                                    ? 'You are approved!'
                                    : 'Approval Pending',
                                style: TextStyle(
                                  fontSize: fontSize,
                                  fontWeight: FontWeight.bold,
                                  color: isAdminApproved
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          if (!isAdminApproved) ...[
                            const Text(
                              'Dear user, your account is currently under review.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Please check your email: $userEmail for further instructions.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'If you have any questions, contact support at support@theary12.com.',
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(fontSize: 16, color: Colors.blue),
                            ),
                          ],
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              FirebaseAuth.instance.signOut();
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            child: const Text('Sign Out',
                                style: TextStyle(fontSize: 16)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
      },
    );
  }
}
