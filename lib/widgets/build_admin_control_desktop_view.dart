
import 'package:intl/intl.dart';
import '../export/export.dart';

class BuildAdminControlDesktopView extends StatelessWidget {
  final VoidCallback? onAddadmin;
  final AdminController adminController;

  const BuildAdminControlDesktopView(
      {super.key, this.onAddadmin, required this.adminController});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildHeader(),
        Expanded(
          child: Obx(() {
            if (adminController.isLoading.value) {
              return configloadingProgressIndicator();
            } else if (adminController.admins.isEmpty) {
              return const Center(
                child: Text('No have admins yet.'),
              );
            }
            return ListView.builder(
              itemCount: adminController.admins.length,
              itemBuilder: (context, index) {
                final admin = adminController.admins[index];
                return buildadminItems(
                    index + 1, admin, index.isEven, adminController, context);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.grey[700],
      child: Row(
        children: [
          headerItem('#', flex: 1),
          headerItem('Avatar', flex: 2),
          headerItem('Full Name', flex: 2),
          headerItem('Role', flex: 2),
          headerItem('Email', flex: 3),
          headerItem('Tel', flex: 3),
          headerItem('Created at', flex: 3),
          headerItem('Actions', flex: 3),
        ],
      ),
    );
  }

  Widget headerItem(String title, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Center(
        child: Text(
          title,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white60),
        ),
      ),
    );
  }

  Widget buildadminItems(int index, Admin admin, bool isEven,
      AdminController controller, BuildContext context) {
    String formattedTimestamp =
        DateFormat('yyyy-MM-dd').format(admin.createdAt);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        margin: EdgeInsets.zero,
        color: isEven ? Colors.grey[200] : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              adminItem(Center(child: Text('$index')), flex: 1),
              adminItem(
                Center(
                  child: CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(admin.imageUrl!),
                  ),
                ),
                flex: 2,
              ),
              adminItem(
                Text(
                  admin.fullName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                flex: 2,
              ),
              adminItem(Text(admin.role), flex: 2),
              adminItem(Text(admin.email), flex: 3),
              adminItem(Text('${admin.phoneNumber}'), flex: 3),
              adminItem(
                Text(
                  formattedTimestamp,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                flex: 3,
              ),
              adminItem(
                  PopupMenuButton<String>(
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
                  flex: 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget adminItem(Widget child, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Center(child: child),
    );
  }
}
