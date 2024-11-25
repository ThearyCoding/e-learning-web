import 'package:e_learningapp_admin/export/export.dart';

class FirebaseApiTopics {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addTopic(String categoryId, TopicModel topic) async {
    try {
      await _firestore
          .collection('categories')
          .doc(categoryId)
          .collection('courses')
          .doc(topic.courseId)
          .collection('topics')
          .doc(topic.id)
          .set(topic.toJson());
      debugPrint('Topic ${topic.title} added successfully.');
    } catch (error) {
      debugPrint('Error adding topic: $error');
      rethrow;
    }
  }

  
}
