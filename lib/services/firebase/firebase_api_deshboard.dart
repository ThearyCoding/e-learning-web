import '../../export/export.dart';

class FirebaseApiDeshboard {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<int> getTotalCourses() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collectionGroup('courses').get();
      return querySnapshot.docs.length;
    } catch (error) {
      debugPrint('Error fetching total courses: $error');
      rethrow;
    }
  }

  Future<int> getTotalUsers() async {
    QuerySnapshot querySnapshot = await _firestore.collection('users').get();
    return querySnapshot.docs.length;
  }

  Future<int> getActiveCourses() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collectionGroup('courses')
          .where('status', isEqualTo: 'active')
          .get();
      return querySnapshot.docs.length;
    } catch (error) {
      debugPrint('Error fetching active courses: $error');
      rethrow;
    }
  }

  Future<int> getPendingApprovals() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collectionGroup('courses')
          .where('status', isEqualTo: 'pending')
          .get();
      return querySnapshot.docs.length;
    } catch (error) {
      debugPrint('Error fetching pending approvals: $error');
      rethrow;
    }
  }
}
