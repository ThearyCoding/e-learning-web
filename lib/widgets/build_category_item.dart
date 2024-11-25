import 'package:e_learningapp_admin/widgets/show_category_dialog.dart';
import 'package:flutter/material.dart';

import '../controller/category_controller.dart';
import '../models/category_model.dart';


Widget buildCategoryItem(CategoryModel category, CategoryController controller,
    BuildContext context) {
  return Card(
    elevation: 4.0,
    margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(category.imageUrl),
          radius: 50.0,
        ),
        title: Text(category.title),
        trailing: Wrap(
          spacing: 12,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                showCategoryDialog(context,categoryModel: category);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                  controller.deleteCategory(category.id,category.imageUrl);
              },
            ),
          ],
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
      ),
    ),
  );
}
