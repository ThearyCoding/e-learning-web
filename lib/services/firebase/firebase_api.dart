import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_learningapp_admin/models/course_model.dart';
import 'package:e_learningapp_admin/models/topic_model.dart';
import 'package:e_learningapp_admin/models/administrator_model.dart';
import 'package:e_learningapp_admin/models/category_model.dart';
import 'package:e_learningapp_admin/models/quiz_model.dart';
import 'package:e_learningapp_admin/models/quiz_question_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:uuid/uuid.dart';

class FirebaseService {
  final CollectionReference categoriesCollection =
      FirebaseFirestore.instance.collection('categories');
  final CollectionReference coursesCollection =
      FirebaseFirestore.instance.collection('courses');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<CategoryModel>> getCategories() async {
    try {
      QuerySnapshot querySnapshot = await categoriesCollection.get();
      debugPrint('Number of categories: ${querySnapshot.docs.length}');
      List<CategoryModel> categories = querySnapshot.docs
          .map((doc) =>
              CategoryModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      return categories;
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      return [];
    }
  }

  Future<List<CourseModel>> getCourses() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collectionGroup('courses').get();

      return querySnapshot.docs.map((doc) {
        return CourseModel(
            id: doc.id,
            title: doc.get('title'),
            imageUrl: doc.get('imageUrl'),
            categoryId: doc.get('categoryId'),
            adminId: doc.get('adminId'));
      }).toList();
    } catch (error) {
      // ignore: avoid_debugPrint
      debugPrint('Error fetching courses: $error');
      return [];
    }
  }

  Future<void> updateCategoryTitle(
      CategoryModel categoryModel, String newTitle, String imageUrl) async {
    try {
      // Update the title and imageUrl of the category document
      await _firestore
          .collection('categories')
          .doc(categoryModel.id)
          .update({'title': newTitle, 'imageUrl': imageUrl});

      // Update the categoryId of documents within the category's courses collection
      QuerySnapshot querySnapshot = await _firestore
          .collection('categories')
          .doc(categoryModel.id)
          .collection('courses')
          .get();
      // ignore: avoid_function_literals_in_foreach_calls
      querySnapshot.docs.forEach((doc) async {
        await doc.reference.update({
          'categoryId': newTitle,
        });
      });

      debugPrint('Category ${categoryModel.title} updated successfully.');
    } catch (error) {
      debugPrint('Error updating category title: $error');
      rethrow; // Throw the error for handling in higher levels
    }
  }

  Future<bool> isInformationComplete(User user) async {
    // Reference to the 'admins' collection in Firestore
    final CollectionReference admins =
        FirebaseFirestore.instance.collection('admins');

    try {
      // Get the document for the current user from the 'admins' collection
      DocumentSnapshot snapshot = await admins.doc(user.uid).get();

      // Check if the document exists and if all required fields are present
      if (snapshot.exists) {
        Map<String, dynamic> adminData =
            snapshot.data() as Map<String, dynamic>;
        if (adminData.containsKey('firstName') &&
            adminData.containsKey('lastName')) {
          // Check if all required fields are present
          return true;
        } else {
          // Information is not complete
          return false;
        }
      } else {
        // Document does not exist, information is not complete
        return false;
      }
    } catch (error) {
      // Error occurred while checking information completeness
      debugPrint('Error checking information completeness: $error');
      return false;
    }
  }

  Future<Map<String, dynamic>?> fetchAdminByUid(String uid) async {
    try {
      // Reference to the 'admins' collection in Firestore
      final CollectionReference<Map<String, dynamic>> admins =
          FirebaseFirestore.instance.collection('admins');

      // Get the document for the admin with the specified UID
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await admins.doc(uid).get();

      // Check if the document exists and return its data
      if (snapshot.exists) {
        return snapshot.data();
      } else {
        return null; // Return null if admin document does not exist
      }
    } catch (error) {
      // Error occurred while fetching admin information
      debugPrint('Error fetching admin information: $error');
      return null; // Return null in case of error
    }
  }

  Stream<bool> isInformationCompleteStream(User user) {
    // Reference to the 'admins' collection in Firestore
    final CollectionReference admins =
        FirebaseFirestore.instance.collection('admins');

    // Stream that listens for changes in the document for the current user
    return admins.doc(user.uid).snapshots().map((snapshot) {
      if (snapshot.exists) {
        Map<String, dynamic> adminData =
            snapshot.data() as Map<String, dynamic>;
        if (adminData.containsKey('firstName') &&
            adminData.containsKey('lastName')) {
          // Check if all required fields are present
          return true;
        } else {
          // Information is not complete
          return false;
        }
      } else {
        // Document does not exist, information is not complete
        return false;
      }
    });
  }

  static User? getCurrentUser() {
    User? user = FirebaseAuth.instance.currentUser;
    return user;
  }

  static Future<void> completeInformation(
      {required String firstName,
      required String lastName,
      required String imageUrl,
      required String phoneNumber}) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        debugPrint('No user is currently authenticated.');
        return; // Exit the function if no user is authenticated
      }

      // Add user details to Firestore
      await FirebaseFirestore.instance
          .collection('admins')
          .doc(currentUser.uid)
          .set({
        'uid': currentUser.uid,
        'fullName': '$firstName $lastName',
        'lastName': lastName,
        'firstName': firstName,
        'role': 'regular_admin',
        'approved': false,
        'email': currentUser.email,
        'imageUrl': imageUrl,
        'phoneNumber': phoneNumber,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Successful sign-up
      debugPrint('User signed up successfully: ${currentUser.uid}');
    } catch (error) {
      // Error handling
      debugPrint('Signing error: $error');
      rethrow; // Rethrow the error to propagate it to the caller
    }
  }

  Future<void> deleteAdminById(String adminId) async {
    try {
      // Get a reference to the document using its ID
      DocumentReference adminRef =
          FirebaseFirestore.instance.collection('admins').doc(adminId);

      // Check admin authentication state
      if (FirebaseAuth.instance.currentUser != null) {
        // Re-authenticate the admin to ensure recent authentication
        // This step may not be necessary if you are sure the admin is authenticated
        // Delete the admin document
        await adminRef.delete();
        debugPrint('Admin with ID $adminId deleted successfully.');
      } else {
        debugPrint('Admin is not authenticated.');
        // Handle the case where the admin is not authenticated
      }
    } catch (error) {
      // Error handling
      debugPrint('Error deleting admin: $error');
      rethrow; // Rethrow the error to propagate it to the caller
    }
  }

Future<List<Admin>> fetchRegularAdmins() async {
  try {
    // Get a reference to the collection
    CollectionReference adminsCollection =
        FirebaseFirestore.instance.collection('admins');

    // Query only regular admins (exclude super_admins)
    QuerySnapshot querySnapshot = await adminsCollection
        .where('role', isEqualTo: 'regular_admin')
        .get();

    // Convert each document to Admin object
    List<Admin> regularAdmins = querySnapshot.docs
        .map((DocumentSnapshot document) => Admin.fromJson(document.data() as Map<String, dynamic>))
        .toList();

    // debugPrint regular admin details
    for (var admin in regularAdmins) {
      debugPrint('UID: ${admin.uid}');
      debugPrint('Full Name: ${admin.fullName}');
      debugPrint('Email: ${admin.email}');
      // Access other attributes as needed
    }

    return regularAdmins; // Return the list of regular admins
  } catch (error) {
    // Error handling
    debugPrint('Error fetching data: $error');
    rethrow; // Rethrow the error to propagate it to the caller
  }
}

  Future<Admin?> fetchSuperAdminById(String adminId) async {
  try {
    // Get a reference to the super admin document
    DocumentSnapshot adminSnapshot = await FirebaseFirestore.instance
        .collection('admins')
        .doc(adminId)
        .get();

    // Check if the document exists
    if (adminSnapshot.exists) {
      // Convert the document data into an Admin object
      Admin superAdmin = Admin.fromJson(adminSnapshot.data() as Map<String, dynamic>);
      return superAdmin;
    } else {
      // Return null if the document does not exist
      return null;
    }
  } catch (error) {
    debugPrint('Error fetching super admin: $error');
    throw error;
  }
}

  Stream<List<Admin>> fetchRegularAdminsStream() {
    try {
      // Get a reference to the collection
      CollectionReference adminsCollection =
          FirebaseFirestore.instance.collection('admins');

      // Create a query to filter regular admins (exclude super_admins)
      Query query = adminsCollection.where('role', isEqualTo: 'regular_admin');
      return query.snapshots().map((QuerySnapshot querySnapshot) {
      // Convert each document snapshot to an Admin object
      return querySnapshot.docs.map((DocumentSnapshot document) {
        return Admin.fromJson(document.data() as Map<String, dynamic>);
      }).toList();
    });
    } catch (error) {
      // Error handling
      debugPrint('Error fetching data: $error');
      throw error; // Rethrow the error to propagate it to the caller
    }
  }

  // Update admin approval status in Firestore
  Future<void> updateAdminApproval(String adminId, bool isApproved) async {
    try {
      // Get a reference to the admin document
      DocumentReference adminRef =
          FirebaseFirestore.instance.collection('admins').doc(adminId);

      // Update the 'approved' field
      await adminRef.update({'approved': isApproved});
    } catch (error) {
      debugPrint('Error updating admin approval in Firestore: $error');
      rethrow;
    }
  }

  Future<String?> uploadImageToStorage(Uint8List imageData, String folderName) async {
    try {
      firebase_storage.Reference storageRef = firebase_storage
          .FirebaseStorage.instance
          .ref('$folderName/${DateTime.now().millisecondsSinceEpoch}.jpg');

      firebase_storage.UploadTask uploadTask = storageRef.putData(imageData);
      String downloadURL = await (await uploadTask).ref.getDownloadURL();

      return downloadURL;
    } catch (e) {
      debugPrint('Error uploading image to Firebase Storage: $e');
      return null;
    }
  }

  Future<void> deleteImageFromStorage(String imageUrl) async {
    try {
      await firebase_storage.FirebaseStorage.instance.refFromURL(imageUrl).delete();
      debugPrint('Old image deleted from Firebase Storage');
    } catch (e) {
      debugPrint('Error deleting old image from Firebase Storage: $e');
    }
  }

  Future<String> uploadVideoAndGetUrl(Uint8List videoFile) async {
    String videoUrl = '';

    try {
      // Create a reference to the Firebase Storage location
      Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('videos')
          .child(DateTime.now().toString());

      // Start the upload task
      UploadTask uploadTask = storageReference.putData(videoFile);

      // Listen to the progress of the upload
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        // Calculate the progress percentage
        double progress = (snapshot.bytesTransferred.toDouble() /
                snapshot.totalBytes.toDouble()) *
            100;

        // Show the progress using EasyLoading
        EasyLoading.showProgress(progress / 100,
            status: 'Uploading ${progress.toStringAsFixed(2)}%');
      });

      // Get the download URL once the upload is complete
      TaskSnapshot taskSnapshot = await uploadTask;
      videoUrl = await taskSnapshot.ref.getDownloadURL();
    } catch (error) {
      debugPrint("Error uploading video: $error");
      rethrow; // Rethrow the error to be caught by the caller
    }

    return videoUrl;
  }

  Future<String> uploadPdfAndGetUrl(Uint8List pdfFile) async {
    String pdfUrl = '';

    try {
      // Create a reference to the Firebase Storage location
      Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('pdfs')
          .child('${DateTime.now().toIso8601String()}.pdf');

      // Start the upload task
      UploadTask uploadTask = storageReference.putData(
          pdfFile, SettableMetadata(contentType: 'application/pdf'));

      // Listen to the progress of the upload
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        // Calculate the progress percentage
        double progress = (snapshot.bytesTransferred.toDouble() /
                snapshot.totalBytes.toDouble()) *
            100;

        // Show the progress using EasyLoading
        EasyLoading.showProgress(progress / 100,
            status: 'Uploading ${progress.toStringAsFixed(2)}%');
      });

      // Get the download URL once the upload is complete
      TaskSnapshot taskSnapshot = await uploadTask;
      pdfUrl = await taskSnapshot.ref.getDownloadURL();
    } catch (error) {
      debugPrint("Error uploading PDF: $error");
      rethrow; // Rethrow the error to be caught by the caller
    }

    return pdfUrl;
  }

  Future<void> addCategory(CategoryModel category) async {
    try {
      await categoriesCollection
          .doc(category.id)
          .set(category.toMap()); // Use toMap() for serialization
      debugPrint('Category ${category.title} added successfully.');
    } catch (error) {
      debugPrint('Error adding category: $error');
      rethrow; // Rethrow the error for handling in the caller
    }
  }

  Future<void> addCourse(String id, CourseModel courseModel) async {
    try {
      await _firestore
          .collection('categories')
          .doc(id)
          .collection('courses')
          .doc(courseModel.id)
          .set(courseModel.toMap());
    } catch (error) {
      debugPrint('Error adding course: $error');
      rethrow;
    }
  }

  Future<void> addTopic(String categoryId, TopicModel topic) async {
    try {
      await _firestore
          .collection('categories')
          .doc(categoryId)
          .collection('courses')
          .doc(topic.courseId)
          .collection('topics')
          .doc(topic.id)
          .set(topic.toJson());
      debugPrint('Topic ${topic.title} added successfully.');
    } catch (error) {
      debugPrint('Error adding topic: $error');
      rethrow;
    }
  }

  Future<List<TopicModel>> fetchTopicsByCourseId(
      String categoryId, String courseId) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('categories')
          .doc(categoryId)
          .collection('courses')
          .doc(courseId)
          .collection('topics')
          .orderBy('timestamp', descending: false)
          .get();

      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        Timestamp timestamp = data['timestamp'] as Timestamp;

        return TopicModel(
            id: data['id'],
            title: data['title'],
            description: data['description'],
            videoUrl: data['videoUrl'],
            timestamp: timestamp.toDate(),
            courseId: data['courseId'],
            thumbnailUrl: data['thumbnailUrl'],
            videoDuration: data['videoDuration'],
            );
      }).toList();
    } catch (error) {
      debugPrint('Error fetching topics: $error');
      rethrow;
    }
  }

  Future<void> updateCourse(
      String categoryId, CourseModel courseModel, String? newImageUrl) async {
    try {
      if (newImageUrl != null) {
        if (categoryId == courseModel.categoryId) {
          // Update the course within the same category
          await _firestore
              .collection('categories')
              .doc(courseModel.categoryId)
              .collection('courses')
              .doc(courseModel.id)
              .update({
            'title': courseModel.title,
            'imageUrl': newImageUrl,
            'categoryId': categoryId,
          });
        } else {
          // Move the course to a different category
          String id = const Uuid().v4();

          // Delete the course from its current category
          await _firestore
              .collection('categories')
              .doc(courseModel.categoryId)
              .collection('courses')
              .doc(courseModel.id)
              .delete();

          // Add the course to the new category
          await _firestore
              .collection('categories')
              .doc(categoryId)
              .collection('courses')
              .doc(id)
              .set({
            'id': id,
            'title': courseModel.title,
            'imageUrl': newImageUrl,
            'categoryId': categoryId,
          });
        }

        debugPrint('Course ${courseModel.title} updated successfully.');
      }
    } catch (error) {
      debugPrint('Error updating course: $error');
      rethrow;
    }
  }

  Future<void> deleteCourseTopic() async {
    try {} catch (error) {
      debugPrint('Error deleting $error');
      rethrow;
    }
  }

  Future<void> deleteCourse(String categoryId, String courseId) async {
    try {
      await _firestore
          .collection('categories')
          .doc(categoryId)
          .collection('courses')
          .doc(courseId)
          .delete();

      await deleteTopics(categoryId, courseId);

      debugPrint('Course deleted successfully.');
    } catch (error) {
      debugPrint('Error deleting course: $error');
      rethrow;
    }
  }

  Future<void> deleteCategory(String id, String oldImageUrl) async {
    try {
      await firebase_storage.FirebaseStorage.instance
          .refFromURL(oldImageUrl)
          .delete();

      // Delete the category and its subcollections (courses, topics)
      await _deleteCategorySubcollections(id);

      // Now delete the category itself
      await _firestore.collection('categories').doc(id).delete();
    } catch (error) {
      debugPrint('Error deleting category: $error');
      rethrow; // Rethrow the error to be handled by the caller if needed
    }
  }

  Future<void> _deleteCategorySubcollections(String id) async {
    // Query the courses under the category
    QuerySnapshot courseSnapshot = await _firestore
        .collection('categories')
        .doc(id)
        .collection('courses')
        .get();

    // Delete each course and its topics
    for (QueryDocumentSnapshot courseDoc in courseSnapshot.docs) {
      String courseId = courseDoc.id;
      // Delete the topics of the course
      await _deleteCourseTopics(id, courseId);
      // Delete the course itself
      await _firestore
          .collection('categories')
          .doc(id)
          .collection('courses')
          .doc(courseId)
          .delete();
    }
  }

  Future<void> _deleteCourseTopics(String categoryId, String courseId) async {
    // Query the topics under the course
    QuerySnapshot topicSnapshot = await _firestore
        .collection('categories')
        .doc(categoryId)
        .collection('courses')
        .doc(courseId)
        .collection('topics')
        .get();

    // Delete each topic
    for (QueryDocumentSnapshot topicDoc in topicSnapshot.docs) {
      await _firestore
          .collection('categories')
          .doc(categoryId)
          .collection('courses')
          .doc(courseId)
          .collection('topics')
          .doc(topicDoc.id)
          .delete();
    }
  }

  Future<void> deleteTopics(String categoryId, String courseId) async {
    try {
      QuerySnapshot topicSnapshot = await _firestore
          .collection('categories')
          .doc(categoryId)
          .collection('courses')
          .doc(courseId)
          .collection('topics')
          .get();

      for (DocumentSnapshot doc in topicSnapshot.docs) {
        await doc.reference.delete();
      }

      debugPrint('Topics deleted successfully.');
    } catch (error) {
      debugPrint('Error deleting topics: $error');
      rethrow;
    }
  }

  Future<Map<String, int>> fetchDashboardData() async {
    try {
      // Fetch data from Firebase Firestore
      final totalCourses = await getTotalCourses();
      final totalUsers = await getTotalUsers();
      final activeCourses = await getActiveCourses();
      final pendingApprovals = await getPendingApprovals();

      // Create a map to hold the dashboard data
      final dashboardData = {
        'totalCourses': totalCourses,
        'totalUsers': totalUsers,
        'activeCourses': activeCourses,
        'pendingApprovals': pendingApprovals,
      };

      return dashboardData;
    } catch (error) {
      // Handle any errors
      debugPrint('Error fetching dashboard data: $error');
      rethrow;
    }
  }

  Future<int> getTotalCourses() async {
    try {
      // Query Firestore using a Collection Group Query to get the total number of courses
      QuerySnapshot querySnapshot =
          await _firestore.collectionGroup('courses').get();
      return querySnapshot.docs.length;
    } catch (error) {
      // Handle any errors
      debugPrint('Error fetching total courses: $error');
      rethrow;
    }
  }

  Future<int> getTotalUsers() async {
    // Query Firestore to get the total number of users
    QuerySnapshot querySnapshot = await _firestore.collection('users').get();
    return querySnapshot.docs.length;
  }

  Future<int> getActiveCourses() async {
    try {
      // Query Firestore using a Collection Group Query to get the number of active courses
      QuerySnapshot querySnapshot = await _firestore
          .collectionGroup('courses')
          .where('status', isEqualTo: 'active')
          .get();
      return querySnapshot.docs.length;
    } catch (error) {
      // Handle any errors
      debugPrint('Error fetching active courses: $error');
      rethrow;
    }
  }

  Future<int> getPendingApprovals() async {
    try {
      // Query Firestore using a Collection Group Query to get the number of courses pending approval
      QuerySnapshot querySnapshot = await _firestore
          .collectionGroup('courses')
          .where('status', isEqualTo: 'pending')
          .get();
      return querySnapshot.docs.length;
    } catch (error) {
      // Handle any errors
      debugPrint('Error fetching pending approvals: $error');
      rethrow;
    }
  }

  Future<void> addQuizQuestion(QuizQuestion quizQuestion) async {
    try {
      await _firestore
          .collection('quizzes')
          .doc(quizQuestion.courseId)
          .collection('questions')
          .doc(quizQuestion.id)
          .set(quizQuestion.toMap());
    } catch (error) {
      debugPrint('Error adding quiz question! $error');
    }
  }

  Future<List<QuizQuestion>> fetchQuizQuestions(String courseId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('quizzes')
          .doc(courseId)
          .collection('questions')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map(
              (doc) => QuizQuestion.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (error) {
      debugPrint('Error fetching quiz questions! $error');
      rethrow;
    }
  }

  Future<List<Quiz>> fetchAllQuizzes(String adminId, {String? courseId}) async {
    try {
      Query query =
          _firestore.collection('quizzes').where('adminId', isEqualTo: adminId);

      if (courseId != null) {
        query = query.where('courseId', isEqualTo: courseId);
      }

      QuerySnapshot snapshot = await query.get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Quiz(
          id: doc.id, // Use Firestore document ID as the quiz ID
          title: data['title']
              as String, // Assuming 'title' field exists in your data
          imageUrl: data['imageUrl']
              as String, // Assuming 'imageUrl' field exists in your data
          adminId: data['adminId']
              as String, // Assuming 'adminId' field exists in your data
        );
      }).toList();
    } catch (error) {
      debugPrint('Error fetching quizzes: $error');
      rethrow;
    }
  }

  Future<void> deleteQuizQuestion(String quizId, String courseId) async {
    try {
      // Reference the specific question document in the sub-collection 'questions' under the course document
      QuerySnapshot snapshot = await _firestore
          .collection('quizzes')
          .doc(courseId)
          .collection('questions')
          .where('id', isEqualTo: quizId)
          .get();

      if (snapshot.docs.isNotEmpty) {
        await snapshot.docs.first.reference.delete();
        debugPrint('Quiz question $quizId deleted successfully.');
      } else {
        throw 'Quiz question not found: $quizId';
      }
    } catch (error) {
      throw 'Error deleting quiz question: $error';
    }
  }

  Future<void> updateQuizQuestion(
      String courseId, QuizQuestion question) async {
    try {
      await _firestore
          .collection('quizzes')
          .doc(courseId)
          .collection('questions')
          .doc(question.id)
          .update(question.toMap());
    } catch (error) {
      throw 'Error updating quiz question: $error';
    }
  }
}
