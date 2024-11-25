import 'package:cloud_firestore/cloud_firestore.dart';

class QuizQuestion {
  final String id;
  final String courseId;
  final DateTime timestamp;
  final String question;
  final List<String> options;
  final String correctAnswer;

  QuizQuestion({
    required this.id,
    required this.courseId,
    required this.timestamp,
    required this.question,
    required this.options,
    required this.correctAnswer,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'courseId': courseId,
      'timestamp': timestamp,
      'question': question,
      'options': options,
      'answer': correctAnswer,
    };
  }

  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    return QuizQuestion(
      id: map['id'],
      courseId: map['courseId'],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      question: map['question'],
      options: List<String>.from(map['options']),
      correctAnswer: map['answer'],
    );
  }
}
