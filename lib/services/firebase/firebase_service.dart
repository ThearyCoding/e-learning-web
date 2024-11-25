
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import '../../export/export.dart';

class FirebaseService {
  final CollectionReference categoriesCollection =
      FirebaseFirestore.instance.collection('categories');
  final CollectionReference coursesCollection =
      FirebaseFirestore.instance.collection('courses');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  Stream<DocumentSnapshot<Map<String, dynamic>>?> adminStream(String uid) {
    try {
      // Reference to the 'admins' collection in Firestore
      final CollectionReference<Map<String, dynamic>> admins =
          FirebaseFirestore.instance.collection('admins');

      // Return a stream that listens to changes for the admin with the specified UID
      return admins.doc(uid).snapshots();
    } catch (error) {
      // Error occurred while setting up stream
      debugPrint('Error setting up admin stream: $error');
      return const Stream.empty(); // Return an empty stream in case of error
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

  Future<String?> uploadImageToStorage(
      Uint8List imageData, String folderName) async {
    try {
      firebase_storage.Reference storageRef = firebase_storage
          .FirebaseStorage.instance
          .ref('$folderName/${DateTime.now().millisecondsSinceEpoch}.jpg');

      firebase_storage.UploadTask uploadTask = storageRef.putData(
          imageData, SettableMetadata(contentType: 'image/jpg'));
      String downloadURL = await (await uploadTask).ref.getDownloadURL();

      return downloadURL;
    } catch (e) {
      debugPrint('Error uploading image to Firebase Storage: $e');
      return '';
    } finally {}
  }

  Future<void> deleteImageFromStorage(String imageUrl) async {
    try {
      await firebase_storage.FirebaseStorage.instance
          .refFromURL(imageUrl)
          .delete();
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
          .child('${DateTime.now().toIso8601String()}.mp4');

      // Start the upload task
      UploadTask uploadTask = storageReference.putData(
          videoFile, SettableMetadata(contentType: 'video/mp4'));

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

  Future<String> uploadPhotoAndGetUrl(
      Uint8List photoPath, String folderName) async {
    String photoUrl = '';

    try {
      // Create a reference to the Firebase Storage location
      Reference storageReference = FirebaseStorage.instance
          .ref()
          .child(folderName)
          .child('${DateTime.now().toIso8601String()}.jpg');

      // Start the upload task
      UploadTask uploadTask = storageReference.putData(
          photoPath, SettableMetadata(contentType: 'application/jpg'));

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
      photoUrl = await taskSnapshot.ref.getDownloadURL();
    } catch (error) {
      debugPrint("Error uploading photo: $error");
      rethrow;
    } finally {
      EasyLoading.dismiss();
    
    }

    return photoUrl;
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

  Future<void> deleteCategorySubcollections(String id) async {
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
}
