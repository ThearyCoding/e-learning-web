class UserModel {
  final String firstName;
  final String lastName;
  final String fullName;
  final String photoURL;
  final String email;
  final String gender;
  final DateTime dob;

  UserModel({
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.photoURL,
    required this.email,
    required this.gender,
    required this.dob,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      firstName: map['firstName'],
      lastName: map['lastName'],
      fullName: map['fullName'],
      photoURL: map['photoURL'],
      email: map['email'],
      gender: map['gender'],
      dob: map['dob'].toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'fullName': fullName,
      'photoURL': photoURL,
      'email': email,
      'gender': gender,
      'dob': dob,
    };
  }
}
