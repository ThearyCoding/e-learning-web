import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String id;
  final String title;
  final String imageUrl;
  final DateTime timestamp;

  CategoryModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'timestamp': timestamp
    };
  }
   Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'timestamp': timestamp
    };
  }

factory CategoryModel.fromJson(Map<String, dynamic> json){
return CategoryModel(
    id: json['id'],
    title: json['title'] ?? "",
    imageUrl: json['imageUrl'] ?? "",
    timestamp:  (json['timestamp'] as Timestamp).toDate(),
  );
}

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'],
      title: map['title'],
      imageUrl: map['imageUrl'],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }

  @override
  String toString() {
    return this.title;
  }
}
