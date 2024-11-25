
import '../../export/export.dart';
import '../../utils/size_utils.dart';

class CourseListScreen extends StatelessWidget {
  final CoursesController controller = Get.find();

  CourseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Color color = const Color(0xFFF5F9FD);
    return Scaffold(
      backgroundColor: color,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Obx(() {
          if (controller.isLoading.value) {
            return configloadingProgressIndicator();
          }else if(controller.courses.isEmpty) {return const Center(child: Text('No have courses is found yet'));}
          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 600) {
                return buildListView(context); 
              } else {
                return buildResponsiveGridView(context, constraints.maxWidth);
              }
            },
          );
        }),
      ),
    );
  }

  Widget buildListView(BuildContext context) {
    return ListView.builder(
      itemCount: controller.courses.length,
      itemBuilder: (context, index) {
        final course = controller.courses[index];
        return Card(
          color: Colors.white,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(course.imageUrl),
            ),
            title: Text(course.title),
            subtitle: Text(
                'Created At: ${course.timestamp?.toLocal().toString() ?? 'N/A'}\n'
                'Register Counts: ${course.registerCounts?.toString() ?? 'N/A'}'),
            trailing: Wrap(
              spacing: 12,
              children: <Widget>[
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _updateCourse(context, course),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteCourse(context, course.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildResponsiveGridView(BuildContext context, double maxWidth) {
   final sizes = SizeUtils.getCrossAxisCountAndChildAspectRatio(context, maxWidth);
    final crossAxisCount = sizes['crossAxisCount'];
    final childAspectRatio = sizes['childAspectRatio'];
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: controller.courses.length,
      itemBuilder: (context, index) {
        final course = controller.courses[index];
        return Card(
           color: Colors.white,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    course.imageUrl,
                    height:100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(course.title, style: const TextStyle(
                  overflow: TextOverflow.clip,
                ),maxLines: 1,),
                Text('Created At: ${course.timestamp?.toLocal().toString() ?? 'N/A'}'),
                Text('Register Counts: ${course.registerCounts?.toString() ?? 'N/A'}'),
                const SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => _updateCourse(context, course),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue,
                      ),
                      child: const Text('Update'),
                    ),
                    ElevatedButton(
                      onPressed: () => _deleteCourse(context, course.id),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _updateCourse(BuildContext context, CourseModel course) {
    // Update course logic here
  }

  void _deleteCourse(BuildContext context, String courseId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this course?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              controller.courses.removeWhere((course) => course.id == courseId);
              Navigator.of(ctx).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
