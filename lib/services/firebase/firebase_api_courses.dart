import '../../export/export.dart';

class FirebaseApiCourses {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<List<CourseModel>> getCourses() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collectionGroup('courses').get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return CourseModel(
          id: doc.id,
          title: data['title'] ?? '',
          imageUrl: data['imageUrl'] ?? '',
          categoryId: data['categoryId'] ?? '',
          adminId: data['adminId'] ?? '',
          registerCounts: data.containsKey('registerCounts')
              ? data['registerCounts'] as int
              : null,
          timestamp: data.containsKey('timestamp')
              ? (data['timestamp'] as Timestamp).toDate()
              : null,
        );
      }).toList();
    } catch (error) {
      debugPrint('Error fetching courses: $error');
      return [];
    }
  }

  Future<void> addCourse(String id, CourseModel courseModel) async {
    try {
      await _firestore
          .collection('categories')
          .doc(id)
          .collection('courses')
          .doc(courseModel.id)
          .set(courseModel.toMap());
    } catch (error) {
      debugPrint('Error adding course: $error');
      rethrow;
    }
  }

  
}
