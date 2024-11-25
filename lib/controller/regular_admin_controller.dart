import 'dart:convert';
import 'dart:developer';

import 'package:e_learningapp_admin/utils/toast_notification_config.dart';

import '../export/export.dart';
import '../services/firebase/api_service.dart';
import '../services/firebase/firebase_api_notifications.dart';
import '../services/firebase/firebase_api_topics.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

class RegularAdminController extends GetxController {
  final FirebaseApiNotifications _notifications = FirebaseApiNotifications();
  final RegularFirebaseService _firebaseService = RegularFirebaseService();
  final FirebaseApiTopics _apiTopics = FirebaseApiTopics();
  final FirebaseService _service = FirebaseService();
  var isLoading = false.obs;
  final topics = <TopicModel>[].obs;
  final category = <CategoryModel>[].obs;
  User? user = FirebaseAuth.instance.currentUser;
  ApiService apiService = ApiService();
  int perPage = 8; // Number of items per pagee
  int currentPage = 1; // Current page number
  List<CourseModel> courses = []; // List to hold fetched courses
  Map<int, List<QueryDocumentSnapshot>> cachedPages =
      {}; // Cache for storing fetched pages
  DocumentSnapshot? lastDocument; // Track last document for pagination
  int totalCoursesCount = 0;
  int totalPages = 0; // Total pages for pagination

  Future fetchAdminCourses(String adminId, {int requestedPage = 1}) async {
    try {
      // Set loading state only when fetching new data
      if (!cachedPages.containsKey(requestedPage)) {
        isLoading.value = true;
      }

      currentPage = requestedPage;

      // Fetch the total count of courses if not already done
      if (totalCoursesCount == 0) {
        totalCoursesCount = await getTotalCoursesCount(adminId);
      }

      // Recalculate total pages
      totalPages = (totalCoursesCount / perPage).ceil();

      // Use cached data if available
      if (cachedPages.containsKey(currentPage)) {
        List<CourseModel> cachedCourses = cachedPages[currentPage]!
            .map((doc) => CourseModel.fromFirestore(doc))
            .toList();

        // Adjust the list if it's the last page
        if (currentPage * perPage >= totalCoursesCount) {
          int remainingItems = totalCoursesCount % perPage;
          if (remainingItems == 0) remainingItems = perPage;
          cachedCourses = cachedCourses.sublist(0, remainingItems);
        }

        courses.assignAll(cachedCourses);
        isLoading.value = false;
        return;
      }

      // Calculate the start index and number of pages to skip
      int pagesToSkip = currentPage - 1;
      List<QueryDocumentSnapshot> allDocs = [];

      // Fetch data page by page until the requested page
      for (int i = 0; i <= pagesToSkip; i++) {
        Query query = FirebaseFirestore.instance
            .collectionGroup('courses')
            .where('adminId', isEqualTo: adminId)
            .orderBy('timestamp', descending: true)
            .limit(perPage);

        // Use lastDocument from the previous page
        if (i > 0) {
          DocumentSnapshot? previousLastDocument = cachedPages[i]?.lastOrNull;
          if (previousLastDocument != null) {
            query = query.startAfterDocument(previousLastDocument);
          }
        }

        QuerySnapshot querySnapshot = await query.get();
        List<QueryDocumentSnapshot> docs = querySnapshot.docs;
        allDocs.addAll(docs);

        // Cache the fetched data
        cachedPages[i + 1] = docs;

        // Update last document for the current page
        if (docs.isNotEmpty) {
          lastDocument = docs.last;
        }
      }

      List<CourseModel> adminCourses = allDocs
          .skip((currentPage - 1) * perPage)
          .take(perPage)
          .map((doc) => CourseModel.fromFirestore(doc))
          .toList();

      // Adjust the list if it's the last page
      if (currentPage * perPage >= totalCoursesCount) {
        int remainingItems = totalCoursesCount % perPage;
        if (remainingItems == 0) remainingItems = perPage;
        adminCourses = adminCourses.sublist(0, remainingItems);
      }

      courses.assignAll(adminCourses); // Update courses list
    } catch (error) {
      log('Error fetching admin courses: $error');
    } finally {
      isLoading.value = false; // Set loading state to false
    }
  }

  // Method to reset pagination
  void resetPagination() {
    lastDocument = null;
    courses.clear();
    cachedPages.clear(); // Clear the cache when resetting pagination
  }

  // Method to get total count of courses (for calculating total pages)
  Future<int> getTotalCoursesCount(String adminId) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collectionGroup('courses')
          .where('adminId', isEqualTo: adminId)
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.size;
    } catch (error) {
      log('Error fetching total courses count: $error');
      return 0;
    }
  }

  void clearFetching() {
    courses.clear();
    isLoading.value = false;
    topics.clear();
  }

  void fetchTopics(String categoryId, String courseId) async {
    try {
      isLoading(true);
      final List<TopicModel> fetchedTopics =
          await _firebaseService.fetchTopicsByCourseId(categoryId, courseId);
      topics.assignAll(fetchedTopics);
    } catch (e) {
      log('Error fetching topics $e');
      rethrow;
    } finally {
      isLoading(false);
    }
  }

  void addTopic(String categoryId, TopicModel topicModel, Uint8List? videoBytes,
      String fileName) async {
    try {
      EasyLoading.show(status: 'Adding...');
      String id = const Uuid().v4();
      TopicModel newTopic = TopicModel(
        id: id,
        title: topicModel.title,
        description: topicModel.description,
        videoUrl: '',
        thumbnailUrl: '',
        videoDuration: 0.0,
        timestamp: DateTime.now(),
        courseId: topicModel.courseId,
      );

      await _apiTopics.addTopic(categoryId, newTopic);

      fetchTopics(categoryId, topicModel.courseId);

      toastificationUtils('Topic ${topicModel.title} added successfully.');
      Get.back();
    } catch (e) {
      log('Error adding topic: $e');
      rethrow;
    } finally {
      EasyLoading.dismiss();
    }
  }

  void deleteCourseByAdminId(
      String adminId, CourseModel course, BuildContext context) async {
    try {
      bool? confirmDelete = await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Delete Course?'),
            content: const Text('Are you sure you want to delete this course?'),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: const Text('Yes'),
              ),
            ],
          ),
          barrierDismissible: false);

      if (confirmDelete == true) {
        EasyLoading.show(status: 'Deleting...');
        await _firebaseService.deleteCourseByAdminId(adminId, course);

        toastificationUtils('Deleted course successfully',
            icon: Icons.check, title: 'Success');
        // Clear the cache and fetch the updated list of courses
        cachedPages.clear();

        // Update the total courses count
        totalCoursesCount = await getTotalCoursesCount(adminId);

        // Recalculate the total pages
        totalPages = (totalCoursesCount / perPage).ceil();

        // If the new course causes the current page to be out of range, adjust the current page
        if (currentPage > totalPages) {
          currentPage = totalPages;
        }

        await fetchAdminCourses(adminId, requestedPage: currentPage);
      }
    } catch (error) {
      log('Error deleting admin course $error');
      rethrow;
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> addRegularAdminCourse(String categoryId, CourseModel course,
      Uint8List imageBytes, String adminId) async {
    try {
      EasyLoading.show(status: 'Adding...');

      String? imageUrl =
          await FirebaseService().uploadImageToStorage(imageBytes, 'courses');

      if (imageUrl != null) {
        CourseModel newCourse = CourseModel(
          id: course.id,
          title: course.title,
          imageUrl: imageUrl,
          categoryId: categoryId,
          adminId: adminId,
          timestamp: DateTime.now(),
          price: course.price,
          discount: course.discount,
          status: course.status,
          description: course.description,
        );

        await _firebaseService.addRegularAdminCourse(categoryId, newCourse);
        // Clear the cache and fetch the updated list of courses
        cachedPages.clear();

        // Update the total courses count
        totalCoursesCount = await getTotalCoursesCount(adminId);

        // Recalculate the total pages
        totalPages = (totalCoursesCount / perPage).ceil();

        // If the new course causes the current page to be out of range, adjust the current page
        if (currentPage > totalPages) {
          currentPage = totalPages;
        }
        String notificationId = const Uuid().v1();
        await fetchAdminCourses(adminId, requestedPage: currentPage);
        await sendPushNotificationForNewCourse(
          categoryId,
          'Chorn Theary',
          imageUrl,
          course.id,
          'https://example.com/default-author-image.jpg',
          course.description ?? '',
          course.title,
          'Check out the latest course on ${course.title}',
          course.price ?? 0,
        );
        await _notifications.markAsReadForUsersWithToken(
          notificationId,
          'Check out our latest course on ${course.title}',
          'New Course Available!',
          courseId: course.id,
          categoryId: categoryId,
        );
      }
      toastificationUtils('Course added successfully',
          icon: Icons.check, title: 'Success');
      Get.back();
    } catch (error) {
      log('Error Adding: $error');
      rethrow;
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> sendPushNotificationForNewCourse(
    String categoryId,
    String authorName,
    String courseImageUrl,
    String courseId,
    String authorImageUrl,
    String description,
    String title,
    String body,
    double? price,
  ) async {
    try {
      final payload = <String, dynamic>{
        'categoryId': categoryId,
        'authorName': authorName,
        'courseImageUrl': courseImageUrl,
        'courseId': courseId,
        'authorImageUrl': authorImageUrl,
        'description': description.isEmpty ? '' : description,
        'title': title,
        'body': body,
        'price': price?.toString() ?? '0',
      };


      final response = await http.post(
        Uri.parse(
            'http://172.20.10.2:3000/api/notifications/send-notification-for-new-course'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        log('Notifications sent successfully');
      } else {
        log('Failed to send notifications');
        log('Response body: ${response.body}');
      }
    } catch (e) {
      log('Failed to send notifications: $e');
    }
  }

  Future<void> sendPushNotificationToAll(
      String title, String body, String courseId, String categoryId) async {
    try {
      final response = await http.post(
        Uri.parse('http://172.20.10.2:3000/send-notification-to-all'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'title': title,
          'body': body,
          'courseId': courseId,
          'categoryId': categoryId,
        }),
      );

      if (response.statusCode == 200) {
        log('Notifications sent successfully');
      } else {
        log('Failed to send notifications');
        log('Response body: ${response.body}');
      }
    } catch (e) {
      log('Failed to send notifications: $e');
    }
  }

  void updateCourseByAdminId(String adminId, String categoryId,
      CourseModel course, Uint8List? imageBytes, String? oldImageUrl) async {
    try {
      String? imageUrl;
      EasyLoading.show(status: 'Updating please wait...');

      // Check if imageBytes is provided and not null
      if (imageBytes != null) {
        imageUrl = await _service.uploadImageToStorage(imageBytes, 'courses');

        if (imageUrl == null) {
          EasyLoading.showError('Failed to upload image');
          return;
        }
        await _service.deleteImageFromStorage(imageUrl);
      } else {
        // Use oldImageUrl only if it is not null
        imageUrl = oldImageUrl;
      }

      // Check if imageUrl is still null
      if (imageUrl == null) {
        throw Exception('imageUrl is null');
      }

      // Update the course with the new or existing imageUrl
      await _firebaseService.updateCourse(
          categoryId, course, imageUrl, adminId);

      EasyLoading.showSuccess('Course updated successfully');
      Get.back();
      cachedPages.remove(currentPage);

      // Refetch the data for the updated page
      await fetchAdminCourses(course.adminId, requestedPage: currentPage);
    } catch (error) {
      log('Error updating admin course: $error');
      EasyLoading.showError('Error updating course');
    } finally {
      EasyLoading.dismiss();
    }
  }

  final RegularFirebaseService _regularFirebaseService =
      RegularFirebaseService();
  Future<void> updateCourseStatus(
      String categoryId, String courseId, bool isActive) async {
    await _regularFirebaseService.updateCourseStatus(
        categoryId, courseId, isActive);
  }

  void onButtonPressed(CourseModel course) async {
    bool isActive = !(course.status ?? false);
    course.status = isActive;
    await updateCourseStatus(course.categoryId, course.id, isActive);

    // Show a detailed toast message
    String statusMessage = isActive ? 'published' : 'unpublished';
    toastificationUtils(
      'Course "${course.title}" status updated to $statusMessage.',
      title: 'Success',
      icon: Icons.check,
      primaryColor: Colors.green.shade300,
      showProgressBar: true,
    );
    cachedPages.remove(currentPage);

    // Refetch the data for the updated page
    await fetchAdminCourses(course.adminId, requestedPage: currentPage);
  }
}
