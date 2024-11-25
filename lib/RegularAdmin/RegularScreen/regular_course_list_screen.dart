import 'package:e_learningapp_admin/RegularAdmin/RegularScreen/build_regular_admin_course.dart';

import '../../export/export.dart';

// ignore: must_be_immutable
class RegularCousesListScreen extends StatelessWidget {
  final VoidCallback onAddocourse;
  final Function(CourseModel) onUpdateCourse;
  final Function(CourseModel) onReviewLessons;

  RegularCousesListScreen(
      {super.key,
      required this.onAddocourse,
      required this.onUpdateCourse,
      required this.onReviewLessons});

  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final RegularAdminController controller =
        Get.find<RegularAdminController>();
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile = constraints.maxWidth < 600;
          bool isTablet =
              constraints.maxWidth >= 600 && constraints.maxWidth < 1024;
          if (isMobile) {
            return _buildMobileLayout(context, controller);
          } else if (isTablet) {
            return _buildTabletLayout(context, controller);
          } else {
            return BuildRegularAdminCourse(
              controller: controller,
              onUpdateCourse: (course) {
                onUpdateCourse(course);
              },
              onReviewLessons: (course) {
                onReviewLessons(course);
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildMobileLayout(
      BuildContext context, RegularAdminController controller) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Expanded(
            child: Obx(() {
              final courses = controller.courses;
              final isLoading = controller.isLoading.value;
              if (isLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (courses.isEmpty) {
                return const Center(child: Text('No Course Found!'));
              } else {
                return ListView.builder(
                  itemCount: courses.length,
                  itemBuilder: (context, index) {
                    final List<CourseModel> courseList =
                        controller.courses.toList();
                    final course = courseList[index];
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: Image.network(
                          course.imageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                        title: Text(course.title),
                        subtitle: Text(course.categoryId),
                        trailing: PopupMenuButton<String>(
                          onSelected: (String result) {
                            if (result == 'delete') {
                              controller.deleteCourseByAdminId(
                                  user!.uid, course, context);
                            } else if (result == 'update') {
                              onUpdateCourse(course);
                            } else if (result == 'review-lessons') {}
                          },
                          itemBuilder: (BuildContext context) =>
                              <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: 'delete',
                              child: ListTile(
                                leading: Icon(Icons.delete, color: Colors.red),
                                title: Text('delete'),
                              ),
                            ),
                            const PopupMenuItem<String>(
                              value: 'update',
                              child: ListTile(
                                leading: Icon(Icons.edit, color: Colors.blue),
                                title: Text('update'),
                              ),
                            ),
                            const PopupMenuItem(
                                value: 'review-lessons',
                                child: ListTile(
                                  leading: Icon(Icons.school),
                                  title: Text('View Lessons'),
                                ))
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(
      BuildContext context, RegularAdminController controller) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Expanded(
            child: Obx(() {
              final courses = controller.courses;
              final isLoading = controller.isLoading.value;
              if (isLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (courses.isEmpty) {
                return const Center(child: Text('No Course Found!'));
              } else {
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 3,
                  ),
                  itemCount: courses.length,
                  itemBuilder: (context, index) {
                    final List<CourseModel> courseList =
                        controller.courses.toList();
                    final course = courseList[index];
                    return Card(
                      elevation: 4,
                      child: ListTile(
                        leading: Image.network(
                          course.imageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                        title: Text(course.title),
                        subtitle: Text(course.categoryId),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {
                                controller.deleteCourseByAdminId(
                                    user!.uid, course, context);
                              },
                              icon: const Icon(Icons.delete, color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
            }),
          ),
        ],
      ),
    );
  }
}
