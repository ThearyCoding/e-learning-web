import 'package:e_learningapp_admin/screens/category-screen/category_list_screen.dart';

import '../../export/export.dart';
import '../../widgets/show_category_dialog.dart';

class CategoryPage extends StatelessWidget {
  final CategoryController categoryController = Get.find<CategoryController>();

  CategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Category List',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: ElevatedButton(
              onPressed: () {
                showCategoryDialog(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff2B2B2B),
                foregroundColor: Colors.grey[300],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(
                    vertical: 16.0, horizontal: 24.0),
              ),
              child: const Text(
                'Add Category',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            return _buildMobileLayout(context);
          } else if (constraints.maxWidth < 1024) {
            return CategoryListScreen(categoryController: categoryController,);
          } else {
            return CategoryListScreen(categoryController: categoryController);
          }
        },
      ),
    );
  }
  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Obx(() {
            final categories = categoryController.categories;
            if (categoryController.isLoading.value) {
              return configloadingProgressIndicator();
            } else if(categories.isEmpty){
              return const Center(
                child: Text('No have category yet. add new category'),
              );
            }
            else {
              return ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return buildCategoryItem(category, categoryController,context);
                },
              );
            }
          }),
        ),
      ],
    );
  }

 

  

}
