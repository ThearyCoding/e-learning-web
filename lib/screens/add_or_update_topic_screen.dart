
import '../export/export.dart';
import '../services/firebase/firebase_api_courses.dart';
class AddOrUpdateTopicScreen extends StatefulWidget {
  final String? title;
  final String? categoryId;
  final CourseModel? courseModel;
  final VoidCallback onCancel;
  AddOrUpdateTopicScreen({super.key, required this.title, this.categoryId, this.courseModel, required this.onCancel});

  @override
  State<AddOrUpdateTopicScreen> createState() => _AddOrUpdateTopicScreenState();
}

class _AddOrUpdateTopicScreenState extends State<AddOrUpdateTopicScreen> {
  TextEditingController txttitle = TextEditingController();
  TextEditingController txtdescription = TextEditingController();
  final CoursesController coursesController = Get.find<CoursesController>();
    final FirebaseApiCourses _apiCourses = FirebaseApiCourses();
  String? filename = '';
  Uint8List? videoFile;

  Future<void> _pickVideo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        filename = result.files.first.name;
        videoFile = result.files.first.bytes;
      });
    }
  }

  CourseModel? selectedCourse;
  List<CourseModel> courses = [];

  Future<void> fetchCourses() async {
    try {
      List<CourseModel> fetchedCourses = await _apiCourses.getCourses();
      setState(() {
        courses = fetchedCourses;
      });
    } catch (error) {
      rethrow;
    }
  }

  String? categoryId;

  void updateCategory() {
    categoryId = selectedCourse!.categoryId;
  }

  @override
  void initState() {
    super.initState();
    fetchCourses();
  }

  Color color = const Color(0xFFF5F9FD);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double width = constraints.maxWidth;
        double height = constraints.maxHeight;
        bool isDesktop = width >= 1024;
        bool isTablet = width >= 600 && width < 1024;

        return Scaffold(
          backgroundColor: color,
          appBar: AppBar(
            title: Text(widget.title ?? ''),
            leading: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                Get.back();
              },
            ),
          ),
          body: Center(
            child: Container(
              width: isDesktop ? width * 0.5 : (isTablet ? width * 0.7 : width * 0.9),
              height: isDesktop ? height * 0.8 : (isTablet ? height * 0.9 : height * 0.95),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: txttitle,
                      decoration: const InputDecoration(
                        labelText: 'Topic Title',
                        hintText: 'E.g., Introduction to...',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: txtdescription,
                      decoration: const InputDecoration(
                        labelText: 'Topic Description',
                        hintText: 'E.g., This tutorial teaches about...',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: _pickVideo,
                          child: const Text('Upload Video'),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            videoFile != null ? filename! : 'No video selected',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<CourseModel>(
                      value: selectedCourse,
                      onChanged: (value) {
                        setState(() {
                          selectedCourse = value!;
                          updateCategory();
                        });
                      },
                      items: courses.map((course) {
                        return DropdownMenuItem<CourseModel>(
                          value: course,
                          child: Text(course.title),
                        );
                      }).toList(),
                      decoration: const InputDecoration(
                        labelText: 'Select Course',
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: handleButtonPress,
                      child: const Text('Submit'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void handleButtonPress() {
    if (widget.title == 'Add Topic') {
      TopicModel topicModel = TopicModel(
        id: '',
        title: txttitle.text,
        description: txtdescription.text,
        videoUrl: '',
        timestamp: DateTime.now(),
        courseId: selectedCourse!.id,
        thumbnailUrl: '',
        videoDuration: 0.0
      );
      coursesController.addTopic(context,categoryId!, topicModel,videoFile,filename!);
    } else if (widget.title == 'Update Course') {
      // Handle update course logic here
    }
  }
}
