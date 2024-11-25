import 'package:e_learningapp_admin/utils/toast_notification_config.dart';

import '../export/export.dart';
import '../services/compressed_image.dart';

class CategoryController extends GetxController {
  final categories = <CategoryModel>[].obs;
  var isLoading = false.obs;
  bool isDeleteCancelled = false;
  final FirebaseService _firebaseService = FirebaseService();
  final FirebaseApiCategories _apiCategories = FirebaseApiCategories();

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  String getCategoryTitle(String categoryId) {
    final category =
        categories.firstWhereOrNull((category) => category.id == categoryId);
    return category!.title;
  }

  Future<void> fetchCategories() async {
    isLoading(true);
    try {
      final List<CategoryModel> fetchedCategories =
          await _apiCategories.getCategories();
      categories.assignAll(fetchedCategories);
    } catch (error) {
      debugPrint('Error fetching categories: $error');
    } finally {
      isLoading(false);
    }
  }

  Future<bool> deleteCategory(String id, String oldImageUrl) async {
    var isDeleting = false.obs;
    try {
      bool? confirmDelete = await DialogUtils.showConfirmationDialog(
        title: 'Confirmation',
        content: 'Are you sure you want to delete this category?',
      );

      if (confirmDelete == true) {
        DialogUtils.showDeleteAlertDialog(() {
          toastificationUtils('Deletion cancelled by user',
              icon: Icons.info, title: 'Info', BackgroundColor: Colors.orange);
        },
            title: 'Deleting...',
            content: 'Please wait while the category is being deleted.');

        await Future.delayed(const Duration(seconds: 2));

        if (DialogUtils.deleteCancelled) {
          DialogUtils.dismissDeleteAlertDialog();
          return false;
        }

        await _apiCategories.deleteCategory(id, oldImageUrl);
        categories.removeWhere((category) => category.id == id);
        isDeleting.value = false;

        DialogUtils.dismissDeleteAlertDialog();
        toastificationUtils(
          'Category deleted successfully',
          BackgroundColor: Colors.green,
          title: 'Success',
          icon: Icons.check,
        );

        return true;
      } else {
        return false;
      }
    } catch (error) {
      debugPrint('Error deleting category: $error');

      toastificationUtils('Failed to delete category',
          BackgroundColor: Colors.red, icon: Icons.error, title: 'Error');
      return false;
    } finally {
      isDeleting.value = false;
      DialogUtils.dismissDeleteAlertDialog();
    }
  }

  Future<void> updateCategory(CategoryModel categoryModel, String newTitle,
      Uint8List? imageBytes, String oldImageUrl) async {
    try {
      String? imageUrl = oldImageUrl;

      // If a new image is provided, upload it to Firebase Storage
      if (imageBytes != null) {
        imageUrl = await _firebaseService.uploadImageToStorage(
            imageBytes, 'categories');

        // If upload successful and there's an old image URL, delete the old image
        if (imageUrl != null && oldImageUrl.isNotEmpty) {
          await _firebaseService.deleteImageFromStorage(oldImageUrl);
        }
      }

      // Update category title and image URL in Firestore
      await _apiCategories.updateCategory(categoryModel, newTitle, imageUrl!);
      SnackbarUtils.showCustomSnackbar(
        title: 'Success',
        message:
            'Category ${categoryModel.title} title updated to $newTitle successfully.',
        icon: Icons.check,
      );

      fetchCategories();
    } catch (error) {
      debugPrint('Error updating category title: $error');
      rethrow;
    } finally {
      Get.back();
    }
  }

  Future<void> addCategory(String title, Uint8List imageBytes) async {
    RxBool isDeleting = false.obs;
    RxBool deleteCancelled = false.obs;

    // Show loading dialog
    DialogUtils.showDeleteAlertDialog(
      () {
        deleteCancelled.value = true;
      },
      title: "Adding...",
      content: "Please wait while the category is being added.",
    );

    try {
      String id = const Uuid().v1();

      Uint8List compressedImage =
          await ImageCompressService().compressImage(imageBytes);

      // Upload compressed image to Firebase Storage
      String? imageUrl = await _firebaseService.uploadImageToStorage(
          compressedImage, 'categories');

      if (deleteCancelled.value) {
        SnackbarUtils.showCustomSnackbar(
          title: 'Cancelled',
          icon: Icons.info,
          message: 'Category addition was cancelled',
          backgroundColor: Colors.orange,
        );
        return;
      }

      if (imageUrl != null) {
        DateTime timestamp = DateTime.now();

        await _apiCategories.addCategory(
          CategoryModel(
            id: id,
            title: title,
            imageUrl: imageUrl,
            timestamp: timestamp,
          ),
        );

        if (deleteCancelled.value) {
          toastificationUtils('Category addition was cancelled');
          return;
        }

        fetchCategories();
        toastificationUtils(
          'Category added successfully',
          icon: Icons.check,
          title: 'Success',
        );

        Get.back();
      } else {
        toastificationUtils(
          'Error uploading image',
          icon: Icons.check,
          title: 'Error',
        );
      }
    } catch (error) {
      debugPrint('Error adding category: $error');
      SnackbarUtils.showCustomSnackbar(
        title: 'Error',
        icon: Icons.error,
        message: 'Failed to add category',
        backgroundColor: Colors.red,
      );
      toastificationUtils(
        'Failed to add category',
        icon: Icons.error,
        title: 'Error',
      );
    } finally {
      isDeleting.value = false;
      DialogUtils.dismissDeleteAlertDialog();
      Get.back();
      Get.back();
    }
  }
}
