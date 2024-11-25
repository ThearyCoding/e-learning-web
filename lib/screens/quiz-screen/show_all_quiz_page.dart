import 'package:e_learningapp_admin/controller/quiz_controller.dart';
import 'package:e_learningapp_admin/controller/regular_admin_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ShowAllQuizPage extends StatelessWidget {
  final String adminId;
  final ValueChanged<String> onQuizSelected;

  ShowAllQuizPage({required this.adminId, required this.onQuizSelected});

  final RegularAdminController regularcontroller = Get.put(RegularAdminController());
  final QuizController quizController = Get.put(QuizController());
  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            // Mobile layout
            return _buildContent(context, padding: 8.0, itemPadding: 8.0, maxWidth: constraints.maxWidth - 16);
          } else if (constraints.maxWidth < 1024) {
            // Tablet layout
            return _buildContent(context, padding: 16.0, itemPadding: 12.0, maxWidth: constraints.maxWidth - 32);
          } else {
            // Desktop layout
            return _buildContent(context, padding: 32.0, itemPadding: 16.0, maxWidth: constraints.maxWidth - 64);
          }
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, {required double padding, required double itemPadding, required double maxWidth}) {
    return Container(
      color: Colors.grey[200],
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(padding),
            color: Colors.blue,
            child: const Text(
              'All Quizzes',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Center(
              child: Container(
                width: maxWidth,
                height: MediaQuery.of(context).size.height - padding * 2,
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
                child: Obx(() {
                  if (quizController.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (quizController.quizzes.isEmpty) {
                    return const Center(child: Text('No quizzes found.'));
                  } else {
                    return SingleChildScrollView(
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height - padding * 3,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: quizController.quizzes.length,
                          itemBuilder: (context, index) {
                            final quiz = quizController.quizzes[index];
                            return Card(
                              elevation: 5,
                              margin: EdgeInsets.symmetric(vertical: itemPadding),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ListTile(
                                contentPadding: EdgeInsets.symmetric(vertical: itemPadding, horizontal: itemPadding * 2),
                                title: Text(
                                  quiz.title,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text('Quiz ID: ${quiz.id}'),
                                trailing: PopupMenuButton<String>(
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'view',
                                      child: Text('View'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Text('Edit'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Text('Delete'),
                                    ),
                                  ],
                                  onSelected: (value) {
                                    if (value == 'view') {
                                      onQuizSelected(quiz.id);
                                    } else if (value == 'edit') {
                                      // Navigate to the edit quiz page
                                    } else if (value == 'delete') {
                                      // Handle quiz deletion
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
