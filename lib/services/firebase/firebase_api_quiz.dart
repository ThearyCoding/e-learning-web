import 'package:e_learningapp_admin/export/export.dart';

class FirebaseApiQuiz {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<List<Quiz>> fetchAllQuizzes(String adminId, {String? courseId}) async {
    try {
      Query query =
          _firestore.collection('quizzes').where('adminId', isEqualTo: adminId);

      if (courseId != null) {
        query = query.where('courseId', isEqualTo: courseId);
      }

      QuerySnapshot snapshot = await query.get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Quiz(
          id: doc.id,
          title: data['title'] as String,
          imageUrl: data['imageUrl'] as String,
          adminId: data['adminId'] as String,
        );
      }).toList();
    } catch (error) {
      debugPrint('Error fetching quizzes: $error');
      rethrow;
    }
  }

   Future<void> updateQuizQuestion(
      String courseId, QuizQuestion question) async {
    try {
      await _firestore
          .collection('quizzes')
          .doc(courseId)
          .collection('questions')
          .doc(question.id)
          .update(question.toMap());
    } catch (error) {
      throw 'Error updating quiz question: $error';
    }
  }

  Future<void> deleteQuizQuestion(String quizId, String courseId) async {
    try {
      // Reference the specific question document in the sub-collection 'questions' under the course document
      QuerySnapshot snapshot = await _firestore
          .collection('quizzes')
          .doc(courseId)
          .collection('questions')
          .where('id', isEqualTo: quizId)
          .get();

      if (snapshot.docs.isNotEmpty) {
        await snapshot.docs.first.reference.delete();
        debugPrint('Quiz question $quizId deleted successfully.');
      } else {
        throw 'Quiz question not found: $quizId';
      }
    } catch (error) {
      throw 'Error deleting quiz question: $error';
    }
  }

  Future<List<QuizQuestion>> fetchQuizQuestions(String courseId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('quizzes')
          .doc(courseId)
          .collection('questions')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map(
              (doc) => QuizQuestion.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (error) {
      debugPrint('Error fetching quiz questions! $error');
      rethrow;
    }
  }

  Future<void> addQuizQuestion(QuizQuestion quizQuestion) async {
    try {
      await _firestore
          .collection('quizzes')
          .doc(quizQuestion.courseId)
          .collection('questions')
          .doc(quizQuestion.id)
          .set(quizQuestion.toMap());
    } catch (error) {
      debugPrint('Error adding quiz question! $error');
    }
  }
}
