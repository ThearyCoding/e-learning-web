import 'package:cloud_firestore/cloud_firestore.dart';

class Admin {
  final String uid;
  final String fullName;
  final String firstName;
  final String lastName;
  final String role;
    bool approved;
  final String email;
  final String? imageUrl;
  final String? phoneNumber;
  final DateTime createdAt;
  final DateTime updatedAt;

  Admin({
    required this.uid,
    required this.fullName,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.approved,
    required this.email,
    this.imageUrl,
    required this.phoneNumber,
    required this.createdAt,
    required this.updatedAt,
  });


  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'fullName': fullName,
      'firstName': firstName,
      'lastName': lastName,
      'role': role,
      'approved': approved,
      'email': email,
      'imageUrl': imageUrl,
      'phoneNumber': phoneNumber,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
      uid: json['uid'],
      fullName: json['fullName'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      role: json['role'],
      approved: json['approved'],
      email: json['email'],
      imageUrl: json['imageUrl'],
      phoneNumber: json['phoneNumber'],
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'fullName': fullName,
      'firstName': firstName,
      'lastName': lastName,
      'role': role,
      'approved': approved,
      'email': email,
      'imageUrl': imageUrl,
      'phoneNumber': phoneNumber,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory Admin.fromMap(Map<String, dynamic> map) {
    return Admin(
      uid: map['uid'] as String,
      fullName: map['fullName'] as String,
      firstName: map['firstName'] as String,
      lastName: map['lastName'] as String,
      role: map['role'] as String,
      approved: map['approved'] as bool,
      email: map['email'] as String,
      imageUrl: map['imageUrl'] != null ? map['imageUrl'] as String : null,
      phoneNumber: map['phoneNumber'] != null ? map['phoneNumber'] as String : null,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

}
