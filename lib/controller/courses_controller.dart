import 'package:e_learningapp_admin/services/firebase/api_service.dart';
import 'package:e_learningapp_admin/services/firebase/firebase_api_courses.dart';
import 'package:e_learningapp_admin/services/firebase/firebase_api_topics.dart';

import '../export/export.dart';

class CoursesController extends GetxController {
  final topics = <TopicModel>[].obs;
  final admins = <Admin>[].obs;
  var superAdmin = Rxn<Admin>();
  final isLoading = true.obs;
  DocumentSnapshot? lastdoc;
  User? user = FirebaseAuth.instance.currentUser;
  final FirebaseApiCourses _apiCourses = FirebaseApiCourses();
  final FirebaseApiTopics _apiTopics = FirebaseApiTopics();
  @override
  void onInit() {
    super.onInit();
    fetchAdminCourses(user!.uid);
  }

  ApiService apiService = ApiService();
  int perPage = 8; // Number of items per page
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
      debugPrint('Error fetching admin courses: $error');
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
      debugPrint('Error fetching total courses count: $error');
      return 0;
    }
  }

  void fetchTopics(String categoryId, String courseId) async {
    try {
      isLoading(true);
      final List<TopicModel> fetchTopics =
          await FirebaseService().fetchTopicsByCourseId(categoryId, courseId);
      topics.assignAll(fetchTopics);
    } catch (e) {
      debugPrint('Error fetching topics $e');
      rethrow;
    } finally {
      isLoading(false);
    }
  }
  
  void addTopic(BuildContext context, String categoryId, TopicModel topicModel,
      Uint8List? videoBytes, String fileName) async {
    try {
      EasyLoading.show(status: 'Adding...');
      String id = const Uuid().v4();
      String? videoUrl;
      if (videoBytes!.isNotEmpty) {
        videoUrl = await FirebaseService().uploadVideoAndGetUrl(videoBytes);
      }else{
        return;
      }

      TopicModel newTopic = TopicModel(
        id: id,
        title: topicModel.title,
        description: topicModel.description,
        videoUrl: videoUrl,
        timestamp: DateTime.now(),
        courseId: topicModel.courseId,
        thumbnailUrl: '',
        videoDuration: 0.0,
      );
      await _apiTopics.addTopic(categoryId, newTopic);
      // await _apiService.uploadTopic(
      //     context, categoryId, videoBytes!, fileName, newTopic);
      fetchTopics(categoryId, newTopic.courseId);
      EasyLoading.showSuccess('Course added successfully');
      Get.back();
    } catch (e) {
      debugPrint('Error Adding topic $e');
      rethrow;
    } finally {
      EasyLoading.dismiss();
    }
  }

  void addCourse(
      String categoryid, CourseModel course, Uint8List imageBytes) async {
    try {
      EasyLoading.show(status: 'Adding...');

      String id = const Uuid().v4();

      String? imageUrl =
          await FirebaseService().uploadImageToStorage(imageBytes, 'courses');

      if (imageUrl != null) {
        CourseModel newCourse = CourseModel(
          id: id,
          title: course.title,
          imageUrl: imageUrl,
          categoryId: categoryid,
          adminId: course.adminId,
          timestamp: course.timestamp,
        );

        await _apiCourses.addCourse(categoryid, newCourse);
      }

      EasyLoading.showSuccess('Course added successfully');
      Get.back();
    } catch (error) {
      debugPrint('Error adding course: $error');
      EasyLoading.showError('Failed to add course');
    } finally {
      EasyLoading.dismiss();
    }
  }

  void updateCourse(String categoryId, CourseModel courseModel,
      Uint8List? imageBytes, String oldImageUrl) async {
    try {
      String? imageUrl;
      EasyLoading.show(status: 'Updating please wait...');
      if (imageBytes != null) {
        imageUrl =
            await FirebaseService().uploadImageToStorage(imageBytes, 'courses');

        if (imageUrl == null) {
          EasyLoading.showError('Failed to upload image');
          return;
        }
      } else {
        imageUrl = oldImageUrl;
      }
      await FirebaseService().updateCourse(categoryId, courseModel, imageUrl);

      EasyLoading.showSuccess('Course updated successfully');
      Get.back();
    } catch (error) {
      debugPrint('Update error: $error');
    } finally {
      EasyLoading.dismiss();
    }
  }

  void deleteCourse(String categoryId, String courseId) async {
    try {
      bool? confirmDelete = await DialogUtils.showConfirmationDialog(
          title: 'Confirmation',
          content: 'Are you sure you want to delete this course?');
      if (confirmDelete == true) {
        EasyLoading.show(status: 'Deleting...');
        await FirebaseService().deleteCourse(categoryId, courseId);
        courses.removeWhere((course) => course.id == courseId);
        SnackbarUtils.showCustomSnackbar(title: 'successfully', message: '');
      }
    } catch (error) {
      EasyLoading.showError('Deletion Failed!');
      rethrow;
    } finally {
      EasyLoading.dismiss();
    }
  }
}
