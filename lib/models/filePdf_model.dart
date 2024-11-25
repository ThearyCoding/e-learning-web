import 'package:cloud_firestore/cloud_firestore.dart';

class PdfFileModel {
  final String id;
  final String courseId;
  final String adminId;
  final String pdfUrl;
  final DateTime timestamp;

  PdfFileModel({
    required this.id,
    required this.courseId,
    required this.adminId,
    required this.pdfUrl,
    required this.timestamp,
  });

  factory PdfFileModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    Timestamp timestamp = data['timestamp'] as Timestamp;

    return PdfFileModel(
      id: doc.id,
      courseId: data['courseId'],
      adminId: data['adminId'],
      pdfUrl: data['pdfUrl'],
      timestamp: timestamp.toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'courseId': courseId,
      'adminId': adminId,
      'pdfUrl': pdfUrl,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
