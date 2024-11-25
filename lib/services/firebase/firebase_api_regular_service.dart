import '../../export/export.dart';

class RegularFirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseService _service = FirebaseService();
  Future<List<TopicModel>> fetchTopicsByCourseId(
      String categoryId, String courseId) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('categories')
          .doc(categoryId)
          .collection('courses')
          .doc(courseId)
          .collection('topics')
          .orderBy('timestamp', descending: false)
          .get();

      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        Timestamp timestamp = data['timestamp'] as Timestamp;

        return TopicModel(
          id: data['id'],
          title: data['title'],
          description: data['description'],
          videoUrl: data['videoUrl'],
          timestamp: timestamp.toDate(),
          courseId: data['courseId'],
          thumbnailUrl: data['thumbnailUrl'],
          videoDuration: data['videoDuration'],
        );
      }).toList();
    } catch (error) {
      debugPrint('Error fetching topics: $error');
      rethrow;
    }
  }


  Future<void> addRegularAdminCourse(
      String categoryId, CourseModel course) async {
    try {
      await _firestore.collection('quizzes').doc(course.id).set({
        'courseId': course.id,
        'title': course.title,
        'imageUrl': course.imageUrl,
        'adminId': course.adminId,
        'timestamp': FieldValue.serverTimestamp(),
        'status': course.status,
      });
      await _firestore
          .collection('categories')
          .doc(categoryId)
          .collection('courses')
          .doc(course.id)
          .set(course.toJson());
          
      
    } catch (error) {
      throw 'Error adding course: $error';
    }
  }

  

  Future<List<CourseModel>> getCoursesByAdminId(String adminId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collectionGroup('courses')
          .where('adminId', isEqualTo: adminId)
          .get();

      List<CourseModel> courses = querySnapshot.docs
          .map((doc) => CourseModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      return courses;
    } catch (error) {
      throw 'Error fetching admin courses: $error';
    }
  }

  Future<void> updateCourse(String categoryId, CourseModel course,
      String? newImageUrl, String adminId) async {
    try {
      if (newImageUrl != null) {
        if (categoryId == course.categoryId) {
          QuerySnapshot querySnapshot = await _firestore
              .collectionGroup('courses')
              .where('adminId', isEqualTo: adminId)
              .where('id', isEqualTo: course.id)
              .get();

          if (querySnapshot.docs.isNotEmpty) {
            // If the course is found, update it
            DocumentReference docRef = querySnapshot.docs.first.reference;

            await docRef.update({
              'title': course.title,
              'imageUrl': newImageUrl,
              'categoryId': categoryId,
              'status': course.status,
              'adminId': course.adminId,
              'price': course.price,
              'discount': course.discount,
              'timestamp': course.timestamp,
              'description': course.description,
              'registerCounts': course.registerCounts
            });

            // ignore: avoid_debugPrint
            debugPrint('Course ${course.title} updated successfully.');
          } else {
            // If no documents were found, throw an error
            throw 'Course not found for adminId: $adminId and courseId: ${course.id}';
          }
        } else {
          // Move the course to a different category
          String id = const Uuid().v4();

          // Delete the course from its current category
          await _firestore
              .collection('categories')
              .doc(course.categoryId)
              .collection('courses')
              .doc(course.id)
              .delete();

          // Add the course to the new category
          await _firestore
              .collection('categories')
              .doc(categoryId)
              .collection('courses')
              .doc(id)
              .set({
            'id': id,
            'title': course.title,
            'imageUrl': newImageUrl,
            'categoryId': categoryId,
            'adminId': course.adminId,
            'status': course.status,
            'price': course.price,
            'discount': course.discount,
            'description': course.description,
            'timestamp': course.timestamp,
            'registerCounts': course.registerCounts
          });

          debugPrint(
              'Course ${course.title} moved to new category and updated successfully.');
        }
      } else {
        throw 'Image URL cannot be null';
      }
    } catch (error) {
      debugPrint('Error updating course: $error');
      rethrow;
    }
  }

  Future<void> deleteCourseByAdminId(String adminId, CourseModel course) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collectionGroup('courses')
          .where('adminId', isEqualTo: adminId)
          .where('id', isEqualTo: course.id)
          .get();

      if (snapshot.docs.isNotEmpty) {
        await snapshot.docs.first.reference.delete();
        if (course.imageUrl.isNotEmpty) {
          _service.deleteImageFromStorage(course.imageUrl);
        }
      } else {
        throw 'Course not found for adminId: $adminId and courseId: ${course.id}';
      }
    } catch (error) {
      debugPrint('Error deleting admin course $error');
      rethrow;
    }
  }

  Future<void> updateCourseStatus(
      String categoryId, String courseId, bool isActive) async {
    try {
      // Get a reference to the specific course document
      DocumentReference courseRef = FirebaseFirestore.instance
          .collection('categories')
          .doc(categoryId)
          .collection('courses')
          .doc(courseId);

      // Update the status field of the course document
      await courseRef.update({
        'status': isActive,
      });

      debugPrint('Course status updated successfully');
    } catch (error) {
      debugPrint('Error updating course status: $error');
    }
  }
}
