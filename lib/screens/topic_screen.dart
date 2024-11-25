

import '../export/export.dart';

class TopicScreen extends StatefulWidget {
  const TopicScreen({super.key});

  @override
  State<TopicScreen> createState() => _TopicScreenState();
}

class _TopicScreenState extends State<TopicScreen> {
  final CoursesController coursesController =
      Get.find<CoursesController>();
  Color color = const Color(0xFFF5F9FD);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: color,
      appBar: AppBar(
        notificationPredicate: (notification) {
          return SnackbarController.isSnackbarBeingShown;
        },
        backgroundColor: color,
        title: const Text(
          'Topic Manage',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: Obx(() {
        final topics = coursesController.courses;
        if (topics.isEmpty) {
          return const Center(
            child: Text("No Topic Found!"),
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
                          crossAxisSpacing: 20),
                  itemCount: topics.length,
                  itemBuilder: (ctx, index) {
                    CourseModel courseModel = topics[index];
                    return BuildCard(courseModel: courseModel);
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
                          crossAxisSpacing: 20),
                  itemCount: topics.length,
                  itemBuilder: (ctx, index) {
                    CourseModel courseModel = topics[index];
                    return BuildCard(courseModel: courseModel);
                  },
                );
              } else {
                // Mobile layout
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 20),
                  itemCount: topics.length,
                  itemBuilder: (ctx, index) {
                    CourseModel courseModel = topics[index];
                    return ListTile(
                      title: Text(courseModel.title),
                      subtitle: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Created At: ${courseModel.timestamp?? 'N/A'}'),
                          Text('Register Counts: ${courseModel.registerCounts ?? 'N/A'} '),
                        ],
                      ),
                      leading: CircleAvatar(
                    backgroundImage: NetworkImage(courseModel.imageUrl),

                    ),
                    trailing: PopupMenuButton<String>(
                        onSelected: (String result) {
                          
                        },
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<String>>[
                          const PopupMenuItem<String>(
                            value: 'approve',
                            child: ListTile(
                              leading: Icon(
                                Icons.remove_red_eye,
                            
                              ),
                              title: Text(
                                  'View detail Topic'),
                            ),
                          ),
                          const PopupMenuItem<String>(
                            value: 'delete',
                            child: ListTile(
                              leading: Icon(Icons.delete, color: Colors.red),
                              title: Text('Delete'),
                            ),
                          ),
                        ],
                      ),
                    );
                  }, separatorBuilder: (BuildContext context, int index) { 
                    return const SizedBox(height: 20,);
                   },
                );
              }
            },
          );
        }
      }),
    );
  }

}

class BuildCard extends StatelessWidget {
  const BuildCard({
    super.key,
    required this.courseModel,
  });

  final CourseModel courseModel;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        showDialogTopicByCourseCategory(context, courseModel);
      },
      child: Container(
        width: 400,
        height: 400,
        padding: const EdgeInsets.all(25),
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: SizedBox(
          width: 350,
          height: 350,
          child: Column(
            children: [
              Image.network(
                courseModel.imageUrl,
                fit: BoxFit.contain,
                height: 150,
              ),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Text(
                        courseModel.title,
                        style: const TextStyle(
                          fontSize: 16,
                          overflow: TextOverflow.clip,
                        ),
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showDialogTopicByCourseCategory(
      BuildContext context, CourseModel courseModel) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return Dialog(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            child: TopicByCategoryCourse(courseModel: courseModel),
          );
        });
  }
}
