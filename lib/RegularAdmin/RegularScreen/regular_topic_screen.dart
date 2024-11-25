

import '../../export/export.dart';

class RegularTopicScreen extends StatefulWidget {
    final VoidCallback onAddLessons;
    final Function(TopicModel) onUpdateTopic;
  const RegularTopicScreen({super.key, required this.onAddLessons, required this.onUpdateTopic});

  @override
  State<RegularTopicScreen> createState() => _RegularTopicScreenState();
}

class _RegularTopicScreenState extends State<RegularTopicScreen> {
  final RegularAdminController controller = Get.find<RegularAdminController>();
  Color color = const Color(0xFFF5F9FD);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    
      backgroundColor: color,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: Obx(() {
                final courses = controller.courses;
                final isLoading = controller.isLoading.value;
                if (courses.isEmpty) {
                  return const Center(
                    child: Text("No Topic Found!"),
                  );
                } else if (isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth >= 1200) {
                        // Desktop layout
                        return GridView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 25, vertical: 50),
                          shrinkWrap: true,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 6,
                                  mainAxisSpacing: 40,
                                  crossAxisSpacing: 20,
                                  childAspectRatio: 3 / 2),
                          itemCount: courses.length,
                          itemBuilder: (ctx, index) {
                            CourseModel courseModel =
                                courses[index];
                            return BuildCardRegularAdmin(
                                courseModel: courseModel);
                          },
                        );
                      } else if (constraints.maxWidth >= 600) {
                        // Tablet layout
                        return GridView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 25, vertical: 50),
                          shrinkWrap: true,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  mainAxisSpacing: 40,
                                  crossAxisSpacing: 20,
                                  childAspectRatio: 3 / 2),
                          itemCount: courses.length,
                          itemBuilder: (ctx, index) {
                            CourseModel courseModel =
                                courses[index];
                            return BuildCardRegularAdmin(
                                courseModel: courseModel);
                          },
                        );
                      } else {
                        // Mobile layout
                        return ListView.separated(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 25, vertical: 50),
                          itemCount: courses.length,
                          itemBuilder: (ctx, index) {
                            CourseModel courseModel =
                                courses[index];
                            return BuildCardRegularAdmin(
                                courseModel: courseModel);
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            return const SizedBox(height: 20);
                          },
                        );
                      }
                    },
                  );
                }
              }),
            )
          ],
        ),
      ),
    );
  }

}
