import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_learningapp_admin/models/section_model.dart';

class FirebaseApiSection {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> uploadSection(String categoryId, Section section) async {
    final courseRef = _firestore
        .collection('categories')
        .doc(categoryId)
        .collection('courses')
        .doc(section.courseId);

    await courseRef.collection('sections').doc(section.id).set(section.toJson());
  }

 Future<List<Section>> fetchSections(String categoryId, String courseId) async {
  // Fetch data from Firestore
  final querySnapshot = await FirebaseFirestore.instance
      .collection('categories')
      .doc(categoryId)
      .collection('courses')
      .doc(courseId)
      .collection('sections')
      .get();


  return querySnapshot.docs.map((doc) => Section.fromMap(doc.data())).toList();
}


  Future<void> deleteSection(String categoryId, String courseId, String sectionId) async {
    final sectionRef = _firestore
        .collection('categories')
        .doc(categoryId)
        .collection('courses')
        .doc(courseId)
        .collection('sections')
        .doc(sectionId);

    await sectionRef.delete();
  }

  Future<void> updateSectionTitle(String categoryId, String courseId, String sectionId, String newTitle) async {
    final sectionRef = _firestore
        .collection('categories')
        .doc(categoryId)
        .collection('courses')
        .doc(courseId)
        .collection('sections')
        .doc(sectionId);

    await sectionRef.update({'title': newTitle});
  }
}
