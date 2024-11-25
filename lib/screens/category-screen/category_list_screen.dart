import 'package:intl/intl.dart';
import '../../export/export.dart';

class CategoryListScreen extends StatelessWidget {
  final VoidCallback? onAddCategory;
  final CategoryController categoryController;

  const CategoryListScreen(
      {super.key, this.onAddCategory, required this.categoryController});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildHeader(),
        Expanded(
          child: Obx(() {
            if (categoryController.isLoading.value) {
              return configloadingProgressIndicator();
            } else if (categoryController.categories.isEmpty) {
              return const Center(
                child: Text('No have category yet. add new category'),
              );
            }
            return ListView.builder(
              itemCount: categoryController.categories.length,
              itemBuilder: (context, index) {
                final category = categoryController.categories[index];
                return buildCategoryItemDesktop(index + 1, category,
                    index.isEven, categoryController, context);
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
          headerItem('#', flex: 2),
          headerItem('Image', flex: 2),
          headerItem('Category title', flex: 4),
          headerItem('Created at', flex: 3),
          headerItem('Actions', flex: 4),
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
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white60),
        ),
      ),
    );
  }

  Widget buildCategoryItemDesktop(int index, CategoryModel category,
      bool isEven, CategoryController controller, BuildContext context) {
    String formattedTimestamp =
        DateFormat('yyyy-MM-dd HH:mm').format(category.timestamp);
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
              categoryItem(Center(child: Text('$index')), flex: 2),
              categoryItem(
                Center(
                  child: CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(category.imageUrl),
                  ),
                ),
                flex: 2,
              ),
              categoryItem(
                Text(
                  category.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                flex: 4,
              ),
              categoryItem(
                Text(
                  formattedTimestamp,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                flex: 3,
              ),
              categoryItem(
                Center(
                  child: Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          controller.deleteCategory(
                              category.id, category.imageUrl);
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.red,
                        ),
                        child: const Text('Delete'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _showCategoryDialog(context, categoryModel: category);
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blue,
                        ),
                        child: const Text('Update'),
                      ),
                    ],
                  ),
                ),
                flex: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget categoryItem(Widget child, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Center(child: child),
    );
  }

  void _showCategoryDialog(BuildContext context, {CategoryModel? categoryModel}) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        content: AddCategoryScreen(
          title: categoryModel != null ? 'Update Category' : 'Add Category',
          category: categoryModel,
        ),
      );
    },
  );
}

}
