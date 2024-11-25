import 'package:e_learningapp_admin/models/admin_regular_course_model.dart';
import 'package:e_learningapp_admin/controller/regular_admin_controller.dart';
import 'package:e_learningapp_admin/models/quiz_question_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../../controller/quiz_controller.dart';

class AddUpdateQuiz extends StatefulWidget {
  final String courseId;
  final VoidCallback onQuestionAdded;
  final QuizQuestion? question;
  final VoidCallback onCancel;
  final ValueChanged<QuizQuestion> onSave;
  const AddUpdateQuiz(
      {super.key,
      required this.courseId,
      required this.onQuestionAdded,
      this.question,
      required this.onCancel,
      required this.onSave});

  @override
  State<AddUpdateQuiz> createState() => _AddUpdateQuizState();
}

class _AddUpdateQuizState extends State<AddUpdateQuiz> {
  final _formKey = GlobalKey<FormState>();
  final QuizController _quizController = Get.find<QuizController>();
  TextEditingController _questionController = TextEditingController();
  TextEditingController _answerController = TextEditingController();

  final Color _backgroundColor = const Color(0xFFF5F9FD);
  final Color _foregroundColor = Colors.white;
  RegularAdminCourseModel? selectedCourse;
  List<RegularAdminCourseModel> courses = [];
  final RegularAdminController controller = Get.find<RegularAdminController>();
  List<TextEditingController> _optionControllers =
      List.generate(4, (index) => TextEditingController());
  @override
  void initState() {
    super.initState();
    _questionController =
        TextEditingController(text: widget.question?.question ?? '');
    _answerController =
        TextEditingController(text: widget.question?.correctAnswer ?? '');
    _optionControllers = List.generate(4, (index) {
      return TextEditingController(text: widget.question?.options[index] ?? '');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _backgroundColor,
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 800) {
            return _buildDesktopLayout();
          } else if (constraints.maxWidth > 600) {
            return _buildTabletLayout();
          } else {
            return _buildMobileLayout();
          }
        },
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 100.0, vertical: 20),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: _foregroundColor,
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 20),
                        const SizedBox(height: 20),
                        _buildQuestionDetails(),
                        const SizedBox(height: 20),
                        _buildOptions(),
                        const SizedBox(height: 20),
                        _buildAnswerInput(),
                        const SizedBox(height: 20),
                        _buildSaveButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabletLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            const SizedBox(height: 20),
            _buildQuestionDetails(),
            const SizedBox(height: 20),
            _buildOptions(),
            const SizedBox(height: 20),
            _buildAnswerInput(),
            const SizedBox(height: 20),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            const SizedBox(height: 20),
            _buildQuestionDetails(),
            const SizedBox(height: 20),
            _buildOptions(),
            const SizedBox(height: 20),
            _buildAnswerInput(),
            const SizedBox(height: 20),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(left: 30, right: 30),
      child: Center(
        child: Row(
          children: [
            IconButton(
                onPressed: () {
                  setState(() {
                    widget.onQuestionAdded();
                  });
                },
                icon: const Icon(Icons.arrow_back)),
            Text(
              widget.question == null
                  ? 'Add Quiz Question'
                  : 'Edit Quiz Question',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionDetails() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Question Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          TextFormField(
            maxLines: null,
            controller: _questionController,
            decoration: _inputDecoration('Enter question'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a question';
              }
              return null;
            },
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildOptions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Options',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ..._optionControllers.asMap().entries.map((entry) {
            int index = entry.key;
            TextEditingController controller = entry.value;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5.0),
              child: TextFormField(
                controller: controller,
                decoration: _inputDecoration('Option ${index + 1}',
                    icon: _getIconForIndex(index)),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter option ${index + 1}';
                  }
                  return null;
                },
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildAnswerInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Answer',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          TextFormField(
            controller: _answerController,
            decoration: _inputDecoration('Enter the correct answer'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the correct answer';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
      prefixIcon: icon != null ? Icon(icon, color: Colors.blue) : null,
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.grey, width: 1.0),
        borderRadius: BorderRadius.circular(12.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.blue, width: 2.0),
        borderRadius: BorderRadius.circular(12.0),
      ),
    );
  }

  IconData _getIconForIndex(int index) {
    switch (index) {
      case 0:
        return Icons.looks_one;
      case 1:
        return Icons.looks_two;
      case 2:
        return Icons.looks_3;
      case 3:
        return Icons.looks_4;
      default:
        return Icons.add;
    }
  }

  void _addQuestion() async {
    if (_formKey.currentState!.validate()) {
      String id = const Uuid().v4();
      QuizQuestion newQuestion = QuizQuestion(
        id: id,
        courseId: widget.courseId,
        timestamp: DateTime.now(),
        question: _questionController.text,
        options:
            _optionControllers.map((controller) => controller.text).toList(),
        correctAnswer: _answerController.text,
      );

      _quizController.addQuizQuestion(newQuestion);
    }
  }

  void _onsave() {
    if (widget.question != null) {
      _updateQuizQuestion();
    } else {
      _addQuestion();
    }
  }

  void _updateQuizQuestion() async {
    if (_formKey.currentState!.validate()) {
      QuizQuestion newQuestion = QuizQuestion(
        id: widget.question!.id,
        courseId: widget.courseId,
        timestamp: DateTime.now(),
        question: _questionController.text,
        options:
            _optionControllers.map((controller) => controller.text).toList(),
        correctAnswer: _answerController.text,
      );
      _quizController.updateQuizQuestion(widget.courseId, newQuestion);
    }
  }

  Widget _buildSaveButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          if (_formKey.currentState?.validate() == true) {
            _onsave();
            _questionController.clear();

            for (var controller in _optionControllers) {
              controller.clear();
            }
            _answerController.clear();
          }
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        child: Text(
            widget.question == null ? 'Add Question' : 'Update Question',
            style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
