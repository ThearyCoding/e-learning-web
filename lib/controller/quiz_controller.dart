import 'package:e_learningapp_admin/export/export.dart';
import 'package:e_learningapp_admin/services/firebase/firebase_api_quiz.dart';

class QuizController extends GetxController{
  var quizzes = <Quiz>[].obs;
  final User? user = FirebaseAuth.instance.currentUser;
  final isLoading = false.obs;
  final FirebaseApiQuiz _apiQuiz = FirebaseApiQuiz();
    final quizQuestion = <QuizQuestion>[].obs;


  void fetchQuizQuestions(String courseId) async {
    try {
      isLoading(true);
      var quizQuestions = await _apiQuiz.fetchQuizQuestions(courseId);
      quizQuestion.assignAll(quizQuestions);
    } catch (error) {
      debugPrint('Error fetching quiz questions! $error');
    } finally {
      isLoading(false);
    }
  }

  void deleteQuizQuestion(String quizId, String courseId) async {
    try {
      EasyLoading.show(status: 'Deleting...');
      await _apiQuiz.deleteQuizQuestion(quizId, courseId);

      EasyLoading.showSuccess('Delete quiz completed');
    } catch (error) {
      debugPrint('Error deleting quiz question: $error');
    } finally {
      fetchQuizQuestions(courseId);
      EasyLoading.dismiss();
    }
  }

  void updateQuizQuestion(String courseId, QuizQuestion question) async {
    try {
      EasyLoading.show(status: 'Updating...');
      await _apiQuiz.updateQuizQuestion(courseId, question);
      EasyLoading.showSuccess('Update Question Completed');
    } catch (error) {
      throw 'Error updating quiz question: $error';
    } finally {
      EasyLoading.dismiss();
      fetchQuizzes(user!.uid);
    }
  }

  void fetchQuizzes(String adminId) async {
    try {
      isLoading(true);
      final fetchedQuizzes = await _apiQuiz.fetchAllQuizzes(adminId);
      quizzes.assignAll(fetchedQuizzes);
    } catch (error) {
      debugPrint('Error fetching quizzes: $error');
    } finally {
      isLoading(false);
    }
  }

  

  

  

  Future<void> addQuizQuestion(QuizQuestion quizQuestion) async {
    try {
      EasyLoading.show(status: 'Adding...');
      await _apiQuiz.addQuizQuestion(quizQuestion);
      fetchQuizzes(user!.uid);
      EasyLoading.showSuccess('Add quiz Successfull');
    } catch (error) {
      debugPrint('Error adding quiz question! $error');
    } finally {
      EasyLoading.dismiss();
    }
  }
  @override
  void onInit() {
    super.onInit();
    fetchQuizzes(user!.uid);
  }
}