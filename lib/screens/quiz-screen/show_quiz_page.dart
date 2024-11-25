import 'package:e_learningapp_admin/controller/quiz_controller.dart';
import 'package:e_learningapp_admin/controller/regular_admin_controller.dart';
import 'package:e_learningapp_admin/widgets/quiz_question_widget.dart';
import 'package:flutter/material.dart';
import 'package:e_learningapp_admin/models/quiz_question_model.dart';
import 'package:get/get.dart';

class ShowQuizPage extends StatefulWidget {
  final String courseId;
  final ValueChanged<String> onQuizSelected;
  final VoidCallback onAddQuestion;
  final ValueChanged<QuizQuestion> onEditQuestion;

  const ShowQuizPage({super.key, 
    required this.courseId,
    required this.onQuizSelected,
    required this.onAddQuestion,
    required this.onEditQuestion,
  });

  @override
  State<ShowQuizPage> createState() => _ShowQuizPageState();
}

class _ShowQuizPageState extends State<ShowQuizPage> {
  final RegularAdminController controller = Get.put(RegularAdminController());
  final QuizController quizController = Get.put(QuizController());
  @override
  void initState() {
    super.initState();
    quizController.fetchQuizQuestions(widget.courseId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          double padding = constraints.maxWidth < 600 ? 8.0 : 16.0;
          return Container(
            color: Colors.grey[200],
            padding: EdgeInsets.symmetric(horizontal: padding),
            child: Center(
              child: Align(
                alignment: Alignment.center,
                child: FractionallySizedBox(
                  widthFactor: 0.9,
                  child: Container(
                    padding: EdgeInsets.all(padding),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(padding),
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(10),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                onPressed: () {
                                  widget.onQuizSelected('');
                                },
                                icon: const Icon(Icons.arrow_back, color: Colors.white),
                              ),
                              const Text(
                                'Quiz Questions',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton.icon(
                                icon: const Icon(Icons.add, color: Colors.white),
                                label: const Text(
                                  'Add Questions',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onPressed: widget.onAddQuestion,
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: padding, vertical: padding / 2),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Obx(() {
                            if (controller.isLoading.value) {
                              return const Center(child: CircularProgressIndicator());
                            } else if (quizController.quizQuestion.isEmpty) {
                              return const Center(child: Text('No questions found.'));
                            } else {
                              return ListView.builder(
                                padding: EdgeInsets.all(padding),
                                itemCount: quizController.quizQuestion.length,
                                itemBuilder: (context, index) {
                                  final question = quizController.quizQuestion[index];
                                  return QuizQuestionWidget(
                                    question: question,
                                    onEdit: () {
                                      widget.onEditQuestion(question);
                                    },
                                    onDelete: () {
                                      quizController.deleteQuizQuestion(question.id, widget.courseId);
                                    },
                                  );
                                },
                              );
                            }
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
