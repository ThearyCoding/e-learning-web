import '../export/export.dart';

void showCategoryDialog(BuildContext context,
      {CategoryModel? categoryModel}) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:  RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: AddCategoryScreen(
            title: categoryModel != null ? 'Update Category' : 'Add Category',
            category: categoryModel,
          ),
        );
      },
    );
  }

