import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/lecture_model.dart';

class FirebaseApiLecture {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> uploadLecture(String categoryId, String courseId, String sectionId, Lecture lecture) async {
    final sectionRef = _firestore
        .collection('categories')
        .doc(categoryId)
        .collection('courses')
        .doc(courseId)
        .collection('sections')
        .doc(sectionId);

    // Fetch the section document
    final sectionSnapshot = await sectionRef.get();
    final sectionData = sectionSnapshot.data() as Map<String, dynamic>;

    // Get the list of lectures from the section document
    final sectionLectures = List<Map<String, dynamic>>.from(sectionData['lectures'] ?? []);

    // Add the new lecture to the list
    sectionLectures.add(lecture.toJson());

    // Update the section document with the modified lectures list
    await sectionRef.update({
      'lectures': sectionLectures,
    });
  }

  Future<void> deleteLecture(String categoryId, String courseId, String sectionId, String lectureId) async {
    final sectionRef = _firestore
        .collection('categories')
        .doc(categoryId)
        .collection('courses')
        .doc(courseId)
        .collection('sections')
        .doc(sectionId);

    // Fetch the section document
    final sectionSnapshot = await sectionRef.get();
    final sectionData = sectionSnapshot.data() as Map<String, dynamic>;

    // Get the list of lectures from the section document
    final sectionLectures = List<Map<String, dynamic>>.from(sectionData['lectures'] ?? []);

    // Remove the lecture from the list
    sectionLectures.removeWhere((lecture) => lecture['id'] == lectureId);

    // Update the section document with the modified lectures list
    await sectionRef.update({
      'lectures': sectionLectures,
    });
  }

  Future<void> updateLecture(String categoryId, String courseId, String sectionId, Lecture updatedLecture) async {
    final sectionRef = _firestore
        .collection('categories')
        .doc(categoryId)
        .collection('courses')
        .doc(courseId)
        .collection('sections')
        .doc(sectionId);

    // Fetch the section document
    final sectionSnapshot = await sectionRef.get();
    final sectionData = sectionSnapshot.data() as Map<String, dynamic>;

    // Get the list of lectures from the section document
    final sectionLectures = List<Map<String, dynamic>>.from(sectionData['lectures'] ?? []);

    // Find the index of the lecture to update
    final lectureIndex = sectionLectures.indexWhere((lecture) => lecture['id'] == updatedLecture.id);

    // If the lecture exists, update it
    if (lectureIndex != -1) {
      sectionLectures[lectureIndex] = updatedLecture.toJson();
    } else {
      throw Exception('Lecture not found in section');
    }

    // Update the section document with the modified lectures list
    await sectionRef.update({
      'lectures': sectionLectures,
    });
  }
}
