class Quiz {
  final String id;
  final String title;
  final String imageUrl;
  final String adminId;

  Quiz({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.adminId,
  });

  factory Quiz.fromMap(Map<String, dynamic> map) {
    return Quiz(
      id: map['id'],
      title: map['title'],
      imageUrl: map['imageUrl'],
      adminId: map['adminId'],
    );
  }
}
