import 'package:e_learningapp_admin/export/export.dart';

class DialogUtils {
  static final RxBool _isDeleting =
      false.obs; // Observable boolean for delete progress
  static final RxBool _deleteCancelled =
      false.obs; // Observable boolean for delete cancellation

  static bool get isDeleting => _isDeleting.value;
  static bool get deleteCancelled => _deleteCancelled.value;

  static Future<bool?> showConfirmationDialog({
    required String title,
    required String content,
    String noButtonText = 'No',
    String yesButtonText = 'Yes',
    bool barrierDismissible = false,
  }) {
    return Get.dialog<bool>(
      AlertDialog(
        shape:
            ContinuousRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              foregroundColor: Colors.black,
            ),
            child: Text(noButtonText),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              foregroundColor: Colors.white,
              backgroundColor: Colors.red,
            ),
            child: Text(yesButtonText),
          ),
        ],
      ),
      barrierDismissible: barrierDismissible,
    );
  }

  static void showDeleteAlertDialog(VoidCallback onCancel,
      {required String title, required String content}) {
    _deleteCancelled.value = false;

    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 20),
            Text(title),
          ],
        ),
        content: Text(content),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              _deleteCancelled.value = true;
              Get.back(result: false);
              onCancel();
            },
            child: const Text("Cancel"),
          ),
        ],
      ),
      barrierDismissible: false,
    );

    _isDeleting.value = true;
  }

  static void dismissDeleteAlertDialog() {
    if (_isDeleting.value) {
      _isDeleting.value = false;
      _deleteCancelled.value = false;
      Get.back();
    }
  }
}
