import 'package:cloud_firestore/cloud_firestore.dart';

class TopicModel {
  final String id;
  final String title;
  final String description;
  final String videoUrl;
  final DateTime timestamp;
  final String courseId;
  final String thumbnailUrl;
  final double videoDuration;

  TopicModel({
    required this.id,
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.timestamp,
    required this.courseId,
    required this.thumbnailUrl,
    required this.videoDuration,
  });

  factory TopicModel.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return TopicModel(
      id: snapshot.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      videoUrl: data['videoUrl'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      courseId: data['courseId'] ?? '',
      thumbnailUrl: data['thumbnailUrl'] ?? '',
      videoDuration: data['videoDuration'] ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'videoUrl': videoUrl,
      'timestamp': timestamp,
      'courseId': courseId,
      'thumbnailUrl': thumbnailUrl,
      'videoDuration': videoDuration,
    };
  }

  factory TopicModel.fromJson(Map<String, dynamic> json) {
    return TopicModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      videoUrl: json['videoUrl'],
      timestamp: json['timestamp'],
      courseId: json['courseId'],
      thumbnailUrl: json['thumbnailUrl'],
      videoDuration: json['videoDuration'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'videoUrl': videoUrl,
      'timestamp': timestamp,
      'courseId': courseId,
      'thumbnailUrl': thumbnailUrl,
      'videoDuration': videoDuration,
    };
  }
}
