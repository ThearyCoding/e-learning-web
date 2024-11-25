import 'package:e_learningapp_admin/export/export.dart';
import 'package:loading_btn/loading_btn.dart';
import '../../services/firebase/firebase_api_lecture.dart';
import '../../services/firebase/firebase_api_section.dart';
import '../../models/lecture_model.dart';
import '../../models/section_model.dart';
import '../../widgets/section_widget.dart';

class CourseCurriculumScreen extends StatefulWidget {
  final CourseModel? course;
    final Function(CourseModel) onCancel;

  const CourseCurriculumScreen({super.key, required this.course,required this.onCancel});

  @override
  CourseCurriculumScreenState createState() => CourseCurriculumScreenState();
}

class CourseCurriculumScreenState extends State<CourseCurriculumScreen> {
  List<Section> sections = [];
  List<Lecture> lectures = [];
  var isLoading = true;
  final FirebaseApiSection _firebaseApiSection = FirebaseApiSection();
  final FirebaseApiLecture _firebaseApiLecture = FirebaseApiLecture();

 
  Future<void> _addSection() async {
    String newSectionId = const Uuid().v1();
    Section newSection = Section(
      id: newSectionId,
      title: 'New Section',
      learningObjective: '',
      lectures: lectures,
      courseId: widget.course!.id,
    );
    await _firebaseApiSection.uploadSection(widget.course!.categoryId, newSection);

    setState(() {
      sections.add(newSection);
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchSections();
  }

  void _fetchSections() async {
    try {
      List<Section> fetchedSections =
          await _firebaseApiSection.fetchSections(widget.course!.categoryId, widget.course!.id);

      setState(() {
        sections = fetchedSections;
      });
    } catch (e) {
      debugPrint('Error fetching sections: $e');
    } finally {
      isLoading = false;
    }
  }

  Future<void> _removeSection(int index) async {
    await _firebaseApiSection.deleteSection(
        widget.course!.categoryId,  widget.course!.id, sections[index].id);
    setState(() {
      sections.removeAt(index);
    });
  }

  Future<void> _editSectionTitle(int index, String newTitle) async {
    await _firebaseApiSection.updateSectionTitle(
       widget.course!.categoryId,  widget.course!.id, sections[index].id, newTitle);
    setState(() {
      sections[index].title = newTitle;
    });
  }

  void _editLearningObjective(int index, String newObjective) {
    setState(() {
      sections[index].learningObjective = newObjective;
    });
  }

  Future<void> _addLecture(int sectionIndex) async {
    String id = const Uuid().v1();
    final lecture = Lecture(
      title: 'New Lecture',
      description: '',
      id: id,
      videoUrl: '',
      timestamp: DateTime.now(),
      sectionId: sections[sectionIndex].id,
      thumbnailUrl: '',
      videoDuration: 0.0,
      fileName: ''
    );

    await _firebaseApiLecture.uploadLecture(
        widget.course!.categoryId,  widget.course!.id, sections[sectionIndex].id, lecture);
    setState(() {
      sections[sectionIndex].lectures.add(lecture);
    });
  }

  Future<void> _removeLecture(int sectionIndex, int lectureIndex) async {
    final lectureId = sections[sectionIndex].lectures[lectureIndex].id;
    await _firebaseApiLecture.deleteLecture(
        widget.course!.categoryId,  widget.course!.id, sections[sectionIndex].id, lectureId);
    setState(() {
      sections[sectionIndex].lectures.removeAt(lectureIndex);
    });
  }

  Future<void> _editLecture(
      int sectionIndex, int lectureIndex, Lecture updatedLecture) async {
    await _firebaseApiLecture.updateLecture(
       widget.course!.categoryId,  widget.course!.id, sections[sectionIndex].id, updatedLecture);
    setState(() {
      sections[sectionIndex].lectures[lectureIndex] = updatedLecture;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...sections.asMap().entries.map((entry) {
                      int index = entry.key;
                      Section section = entry.value;
                      return SectionWidget(
                        index: index,
                        section: section,
                        onAddLecture: () => _addLecture(index),
                        onRemoveSection: () => _removeSection(index),
                        onEditSectionTitle: (newTitle) =>
                            _editSectionTitle(index, newTitle),
                        onEditLearningObjective: (newObjective) =>
                            _editLearningObjective(index, newObjective),
                        onRemoveLecture: (lectureIndex) =>
                            _removeLecture(index, lectureIndex),
                        onEditLecture: (lectureIndex, updatedLecture) =>
                            _editLecture(index, lectureIndex, updatedLecture),
                      );
                    }).toList(),
                    const SizedBox(height: 16.0),
                    LoadingBtn(
                      height: 40,
                      borderRadius: 8,
                      animate: true,
                      color: Colors.green,
                      width: 150,
                      loader: Container(
                        padding: const EdgeInsets.all(10),
                        width: 40,
                        height: 40,
                        child: const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add,
                            color: Colors.amber,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "Section",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      onTap: (startLoading, stopLoading, btnState) async {
                        if (btnState == ButtonState.idle) {
                          startLoading();
                          await _addSection();
                          stopLoading();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
