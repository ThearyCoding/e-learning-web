import 'package:e_learningapp_admin/export/export.dart';
import 'package:e_learningapp_admin/utils/toast_notification_config.dart';

import '../services/firebase/firebase_api_admin.dart';
import '../services/firebase/firebase_api_deshboard.dart';

class AdminController extends GetxController {
  final admins = <Admin>[].obs;
  final FirebaseApiAdmin _apiAdmin = FirebaseApiAdmin();
  var admin = Rxn<Admin>();
  final isLoading = true.obs;
  var totalCourses = 0.obs;
  var totalUsers = 0.obs;
  var activeCourses = 0.obs;
  var pendingApprovals = 0.obs;
  var errorMessage = ''.obs;
  final FirebaseApiDeshboard _apiDeshboard = FirebaseApiDeshboard();
  @override
  void onClose() {
    _adminsSubscription.cancel();
    _adminSubscription!.cancel();
    super.onClose();
  }

  @override
  void onInit() {
    fetchDashboardData();
    fetchadminById();

    super.onInit();
  }

  void onButtonPressed(Admin regularAdmin) async {
    bool newApprovalStatus =
        !regularAdmin.approved; // Toggle the approval status
    await updateAdminApproval(regularAdmin.uid, newApprovalStatus);
  }

  void deleteAdminById(
      BuildContext context, String adminId, String adminName) async {
    try {
      bool? confirmDelete = await DialogUtils.showConfirmationDialog(
        title: 'Confirm Deletion',
        content: 'Are you sure you want to delete this admin, $adminName?',
      );
      if (confirmDelete == true) {
        await _apiAdmin.deleteAdminById(adminId);
        admins.removeWhere((admin) => admin.uid == adminId);

        toastificationUtils('Admin $adminName has been successfully deleted.',
            title: 'Successful');
      }
    } catch (error) {
      debugPrint('Error deleting admin: $error');
      SnackbarUtils.showCustomSnackbar(
          title: 'Error',
          message: 'Error deleting admin: $error',
          icon: Icons.info);
    }
  }

  late StreamSubscription<List<Admin>> _adminsSubscription;
  void fetchRegularAdmins() {
    isLoading(true);
    try {
      _adminsSubscription = _apiAdmin.fetchRegularAdminsStream().listen(
        (List<Admin> regularAdmins) {
          admins.assignAll(regularAdmins);
          isLoading(false);
        },
      );
    } catch (error) {
      debugPrint('Error fetching Regular Admins: $error');

      isLoading(false);
    }
  }

  Future<void> fetchadminById() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      Admin? adminData = await _apiAdmin.fetchAdminById(user!.uid);
      admin(adminData);
    } catch (error) {
      debugPrint('Error fetching admin: $error');
      rethrow;
    }
  }

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      _adminSubscription;

  Future<void> updateAdminApproval(String adminId, bool isApproved) async {
    await _apiAdmin.updateAdminApproval(adminId, isApproved);
  }

  Future<void> fetchDashboardData() async {
    isLoading(true);
    try {
      // Fetch all data concurrently
      final results = await Future.wait([
        _apiDeshboard.getTotalCourses(),
        _apiDeshboard.getTotalUsers(),
        _apiDeshboard.getActiveCourses(),
        _apiDeshboard.getPendingApprovals(),
      ]);

      // Update the observable variables with the fetched data
      totalCourses.value = results[0];
      totalUsers.value = results[1];
      activeCourses.value = results[2];
      pendingApprovals.value = results[3];
    } catch (error) {
      // Handle any errors
      debugPrint('Error fetching dashboard data: $error');
      errorMessage.value = 'Error fetching dashboard data: $error';
    } finally {
      isLoading(false);
    }
  }
}
