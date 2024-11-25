import 'dart:ui';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:e_learningapp_admin/utils/toast_notification_config.dart';
import 'package:video_player/video_player.dart';
import '../../export/export.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import '../../widgets/customize_textfield_area.dart';

class AddUpdateRegularAdmin extends StatefulWidget {
  final String? categoryId;
  final TopicModel? topic;
  final VoidCallback onCancel;
  const AddUpdateRegularAdmin(
      {super.key, this.categoryId, this.topic, required this.onCancel});

  @override
  State<AddUpdateRegularAdmin> createState() => _AddUpdateRegularAdminState();
}

class _AddUpdateRegularAdminState extends State<AddUpdateRegularAdmin> {
  bool _isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600;
  final TextEditingController txttitle = TextEditingController();
  final TextEditingController txtdescription = TextEditingController();
  final CoursesController controller =
      Get.find();

  CourseModel? selectedCourse;
  List<CourseModel> courses = [];
  String? filename = '';
  Uint8List? videoFile;
  VideoPlayerController? videoPlayerController;
  @override
  void initState() {
    super.initState();
    fetchCourses();
  }

  Future<void> fetchCourses() async {
    setState(() {
      courses = controller.courses;
    });
  }

  Future<void> _pickVideo() async {
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'video/mp4';
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;

      if (files != null && files.isNotEmpty) {
        final file = files[0];

        if (file.type == 'video/mp4') {
          const int maxSizeInBytes = 200 * 1024 * 1024; // 200MB in bytes
          if (file.size > maxSizeInBytes) {
            
            toastificationUtils(
                'The selected video exceeds the maximum size of 200MB. Please select a smaller video.');

            uploadInput.value =
                null; // Reset the input value to cancel the selection
            return;
          }
          final reader = html.FileReader();

          reader.onLoadEnd.listen((e) {
            setState(() {
              filename = file.name;
              videoFile = reader.result as Uint8List?;
              _initializeVideoPlayer();
            });
          });

          reader.readAsArrayBuffer(file);
        } else {
          // Handle invalid file type
          toastificationUtils(
              '${file.type} not supported, Please select an MP4 video file.');
          // Reset the input value to cancel the selection
          setState(() {
            uploadInput.value = null;
            videoPlayerController = null;
        
            filename = 'No video selected';
          });
        }
      }
    });
  }

  void _initializeVideoPlayer() {
    if (videoFile != null) {
      final blob = html.Blob([videoFile]);
      // ignore: unused_local_variable
      final url = html.Url.createObjectUrlFromBlob(blob);

      // // ignore: deprecated_member_use
      // videoPlayerController = VideoPlayerController.network(url)
      //   ..initialize().then((_) {
      //     setState(() {
      //       chewieController = ChewieController(
      //         videoPlayerController: videoPlayerController!,
      //         aspectRatio: 16 / 9,
      //         autoPlay: true,
      //         looping: false,
      //       );
      //     });
      //   });
    }
  }

  void updateCategory() {
    categoryId = selectedCourse?.categoryId;
  }

  String? categoryId;

  void handleButtonPress() {
    videoPlayerController!.pause();
    if (widget.topic == null) {
      TopicModel topicModel = TopicModel(
        id: '',
        title: txttitle.text,
        description: txtdescription.text,
        videoUrl: '',
        timestamp: DateTime.now(),
        courseId: selectedCourse?.id ?? '',
        thumbnailUrl: '',
        videoDuration: 0.0,
      );
      controller.addTopic(
          context, categoryId!, topicModel, videoFile, filename!);
    } else if (widget.topic != null) {
      // Handle course update logic here
    }
  }

  @override
  void dispose() {
    txttitle.dispose();
    txtdescription.dispose();
    videoPlayerController?.dispose();

    super.dispose();
  }

  Color color = const Color(0xFFF5F9FD);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
            color: const Color.fromARGB(124, 224, 224, 224),
            borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal:
                          ResponsiveLayout.isDesktop(context) ? 50 : 20),
                  child: const Text(
                    'Enter Lesson title',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                CustomizTextFormFieldV1(
                  controller: txttitle,
                  autoFocus: true,
                  hintText: 'Lesson title',
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Enter Lesson title';
                    }
                    return null;
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: _isDesktop(context) ? 50 : 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Lesson Description'),
                  const SizedBox(height: 10),
                  ResizableTextField(
                    controller: txtdescription,
                    hintText: 'Enter the description here',
                    minHeight: 100,
                    maxHeight: 250,
                    minWidth: 400,
                    maxWidth: 800,
                    onChanged: (value) {},
                    onSubmitted: (value) {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
           
            const SizedBox(height: 20),
            buildVideoUploadField(),
            const SizedBox(height: 20),
            buildDropdownField(),
            const SizedBox(height: 20),
            buildSubmitButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: TextField(
          selectionHeightStyle: BoxHeightStyle.strut,
          controller: controller,
          style: const TextStyle(fontSize: 16.0, color: Colors.black),
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
            labelText: labelText,
            hintText: hintText,
            labelStyle: const TextStyle(fontSize: 18.0, color: Colors.grey),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget buildVideoUploadField() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: _isDesktop(context) ? 50 : 20),
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            ElevatedButton(
              onPressed: _pickVideo,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(vertical: 21, horizontal: 15),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10)),
                ),
              ),
              child: const Text(
                "Upload Video",
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
            Expanded(
              child: TextField(
                selectionHeightStyle: BoxHeightStyle.strut,
                readOnly: true,
                controller: TextEditingController(
                  text: videoFile != null ? filename : 'No video selected',
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  hintText: 'Video File Name',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDropdownField() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: _isDesktop(context) ? 50 : 20),
      child: CustomDropdown<CourseModel>(
        hintText: 'Select Course',
        initialItem: selectedCourse,
        onChanged: (CourseModel? value) {
          setState(() {
            selectedCourse = value;
            updateCategory();
          });
        },
        items: courses,
        listItemBuilder: (context, item, isSelected, onItemSelect) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              item.title,
              style: const TextStyle(
                fontSize: 16,
                overflow: TextOverflow.ellipsis,
              ),
              maxLines: 1,
            ),
          );
        },
      ),
    );
  }

  Widget buildSubmitButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: _isDesktop(context) ? 50 : 20),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: handleButtonPress,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                widget.topic != null ? 'Update Course' : 'Add Topic',
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: widget.onCancel,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Back',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
