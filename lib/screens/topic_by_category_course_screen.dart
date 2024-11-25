

import '../export/export.dart';

class TopicByCategoryCourse extends StatefulWidget {
  final CourseModel courseModel;

  const TopicByCategoryCourse({Key? key, required this.courseModel})
      : super(key: key);

  @override
  State<TopicByCategoryCourse> createState() => _TopicByCategoryCourseState();
}

class _TopicByCategoryCourseState extends State<TopicByCategoryCourse> {
  final CoursesController controller =
      Get.find<CoursesController>();
  Color color = const Color(0xFFF5F9FD);
  @override
  void initState() {
    super.initState();
    controller.fetchTopics(
        widget.courseModel.categoryId, widget.courseModel.id);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      height: MediaQuery.of(context).size.height * 0.8,
      color: color,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 21, vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.courseModel.title,
                  style: const TextStyle(fontSize: 20),
                ),
                IconButton(
                    onPressed: () {
                      controller.topics.clear();
                      Get.back();
                    },
                    icon: const Icon(Icons.clear))
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              final topics = controller.topics;
              final isLoading =
                  controller.isLoading.value; // Get the isLoading value
              if (isLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (topics.isEmpty) {
                return const Center(child: Text('No data found yet!'));
              } else {
                return GridView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 50),
                  shrinkWrap: true,
                  itemCount: topics.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    mainAxisSpacing: 40,
                    crossAxisSpacing: 20,
                  ),
                  itemBuilder: (ctx, index) {
                    TopicModel topicModel = topics[index];
                    return BuildCard(topicModel: topicModel);
                  },
                );
              }
            }),
          )
        ],
      ),
    );
  }
}

class BuildCard extends StatelessWidget {
  const BuildCard({
    super.key,
    required this.topicModel,
  });

  final TopicModel topicModel;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
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
              // Image.network(
              //   topicModel.imageUrl,
              //   fit: BoxFit.contain,
              //   height: 150,
              // ),
              Text(topicModel.description),
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Text(
                        topicModel.title,
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
}
