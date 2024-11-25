import 'package:e_learningapp_admin/export/export.dart';

class Lecture {
  final String id;
  final String title;
  final String description;
  final String videoUrl;
  final DateTime timestamp;
  final String sectionId;
  final String thumbnailUrl;
  final double videoDuration;
  final String fileName;
  Lecture({
    required this.id,
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.timestamp,
    required this.sectionId,
    required this.thumbnailUrl,
    required this.videoDuration,
    required this.fileName
  });

  factory Lecture.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return Lecture(
      id: snapshot.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      videoUrl: data['videoUrl'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      sectionId: data['sectionId'] ?? '',
      thumbnailUrl: data['thumbnailUrl'] ?? '',
      videoDuration: data['videoDuration'] ?? 0.0,
      fileName: data['fileName'] ?? '',
    );
  }

  factory Lecture.fromMap(Map<String, dynamic> json) {
    return Lecture(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      videoUrl: json['videoUrl'],
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      sectionId: json['sectionId'],
      thumbnailUrl: json['thumbnailUrl'],
      videoDuration: json['videoDuration'],
      fileName: json['fileName'],
    );
  }

  factory Lecture.fromJson(Map<String, dynamic> json) {
    return Lecture(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      videoUrl: json['videoUrl'],
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      sectionId: json['sectionId'],
      thumbnailUrl: json['thumbnailUrl'],
      videoDuration: json['videoDuration'],
      fileName: json['fileName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'videoUrl': videoUrl,
      'timestamp': Timestamp.fromDate(timestamp),
      'sectionId': sectionId,
      'thumbnailUrl': thumbnailUrl,
      'videoDuration': videoDuration,
      'fileName': fileName,
    };
  }
}
