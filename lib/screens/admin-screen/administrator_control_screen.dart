import 'package:e_learningapp_admin/widgets/build_admin_control_desktop_view.dart';
import '../../export/export.dart';

class AdministratorControlScreen extends StatefulWidget {
  const AdministratorControlScreen({super.key});

  @override
  State<AdministratorControlScreen> createState() =>
      _AdministratorControlScreenState();
}

class _AdministratorControlScreenState
    extends State<AdministratorControlScreen> {
  final AdminController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        notificationPredicate: (notification) {
          return SnackbarController.isSnackbarBeingShown;
        },
        title: const Text(
          "Manage Teacher",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1024) {
          // Desktop layout: Show table
          return BuildAdminControlDesktopView(adminController: controller);
        } else if (constraints.maxWidth >= 600) {
          // Tablet layout: Show GridView with actions icon
          return _buildLayoutTablet();
        } else {
          // Mobile layout: Show ListView
          return _buildLayoutMobile();
        }
      },
    );
  }

  Widget _buildLayoutTablet() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Obx(() {
        final admins = controller.admins;
        final isLoading = controller.isLoading.value;
        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (admins.isEmpty) {
          return const Center(child: Text('No data found yet!'));
        } else {
          return LayoutBuilder(
            builder: (context, constraints) {
              double fontSize = constraints.maxWidth >= 600 ? 16.0 : 14.0;

              return ListView.builder(
                itemCount: admins.length,
                itemBuilder: (context, index) {
                  final admin = admins[index];
                  return Card(
                    elevation: 4.0,
                    margin: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 15.0),
                      leading: CircleAvatar(
                        radius: 30,
                        backgroundImage: admin.imageUrl != null
                            ? NetworkImage(admin.imageUrl!)
                            : const AssetImage('assets/default_avatar.png')
                                as ImageProvider,
                      ),
                      title: Text(
                        admin.fullName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: fontSize + 2.0,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Email: ${admin.email}',
                            style: TextStyle(
                              fontSize: fontSize,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            'Role: ${admin.role}',
                            style: TextStyle(
                              fontSize: fontSize,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            'Phone: ${admin.phoneNumber ?? "N/A"}',
                            style: TextStyle(
                              fontSize: fontSize,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            'Created: ${admin.createdAt.toLocal()}',
                            style: TextStyle(
                              fontSize: fontSize,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (String result) {
                          if (result == 'approve') {
                            controller.onButtonPressed(admin);
                          } else if (result == 'delete') {
                            controller.deleteAdminById(
                                context, admin.uid, admin.fullName);
                          }
                        },
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<String>>[
                          PopupMenuItem<String>(
                            value: 'approve',
                            child: ListTile(
                              leading: Icon(
                                admin.approved
                                    ? Icons.check_box
                                    : Icons.check_box_outline_blank,
                                color:
                                    admin.approved ? Colors.green : Colors.grey,
                              ),
                              title: Text(
                                  admin.approved ? 'Unapprove' : 'Approve'),
                            ),
                          ),
                          const PopupMenuItem<String>(
                            value: 'delete',
                            child: ListTile(
                              leading: Icon(Icons.delete, color: Colors.red),
                              title: Text('Delete'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        }
      }),
    );
  }

  Widget _buildLayoutMobile() {
    return Obx(() {
      final admins = controller.admins;
      return ListView.builder(
        itemCount: admins.length,
        itemBuilder: (context, index) {
          Admin admin = admins[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(admin.imageUrl ?? ''),
            ),
            title: Text(admin.fullName),
            subtitle: Text(admin.email),
            trailing: PopupMenuButton<String>(
              onSelected: (String result) {
                if (result == 'approve') {
                  controller.onButtonPressed(admin);
                } else if (result == 'delete') {
                  controller.deleteAdminById(
                      context, admin.uid, admin.fullName);
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'approve',
                  child: ListTile(
                    leading: Icon(
                      admin.approved
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                      color: admin.approved ? Colors.green : Colors.grey,
                    ),
                    title: Text(admin.approved ? 'Unapprove' : 'Approve'),
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title: Text('Delete'),
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }
}
