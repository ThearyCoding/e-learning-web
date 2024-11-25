import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import '../../export/export.dart';

class FirebaseApiCategories {
  final CollectionReference categoriesCollection =
      FirebaseFirestore.instance.collection('categories');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<CategoryModel>> getCategories() async {
    try {
      QuerySnapshot querySnapshot = await categoriesCollection
          .orderBy('timestamp', descending: true)
          .get();
      List<CategoryModel> categories = querySnapshot.docs
          .map((doc) =>
              CategoryModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      return categories;
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      return [];
    }
  }

  Future<void> deleteCategory(String id, String oldImageUrl) async {
    try {
      await firebase_storage.FirebaseStorage.instance
          .refFromURL(oldImageUrl)
          .delete();
      await _firestore.collection('categories').doc(id).delete();
    } catch (error) {
      debugPrint('Error deleting category: $error');
      rethrow; // Rethrow the error to be handled by the caller if needed
    }
  }

  Future<void> updateCategory(
      CategoryModel categoryModel, String newTitle, String imageUrl) async {
    try {
      await _firestore
          .collection('categories')
          .doc(categoryModel.id)
          .update({'title': newTitle, 'imageUrl': imageUrl});

      QuerySnapshot querySnapshot = await _firestore
          .collection('categories')
          .doc(categoryModel.id)
          .collection('courses')
          .get();
      querySnapshot.docs.forEach((doc) async {
        await doc.reference.update({
          'categoryId': newTitle,
        });
      });

      debugPrint('Category ${categoryModel.title} updated successfully.');
    } catch (error) {
      debugPrint('Error updating category title: $error');
      rethrow;
    }
  }

  Future<void> addCategory(CategoryModel category) async {
    try {
      await categoriesCollection.doc(category.id).set(category.toMap());
      debugPrint('Category ${category.title} added successfully.');
    } catch (error) {
      debugPrint('Error adding category: $error');
      rethrow;
    }
  }
}
