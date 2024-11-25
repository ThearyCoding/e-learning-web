import 'package:cloud_firestore/cloud_firestore.dart';

class RegularAdminCourseModel {
  final String id;
  final String title;
  final String imageUrl;
  final String categoryId;
  final String adminId;
  final DateTime timestamp;
  
  RegularAdminCourseModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.categoryId,
    required this.adminId,
    required this.timestamp
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'categoryId': categoryId,
      'adminId': adminId
    };
  }

  factory RegularAdminCourseModel.fromJson(Map<String, dynamic> json) {
  return RegularAdminCourseModel(
    id: json['id'],
    title: json['title'] ?? "",
    imageUrl: json['imageUrl'] ?? "",
    categoryId: json['categoryId'] ?? "",
    adminId: json['adminId'],
    timestamp:  (json['timestamp'] as Timestamp).toDate(),
  );
}


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'categoryId': categoryId,
      'adminId': adminId,
      'timestamp': timestamp
    };
  }
}