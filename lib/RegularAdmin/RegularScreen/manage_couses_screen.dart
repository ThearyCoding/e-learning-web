import 'package:e_learningapp_admin/screens/courses-screen/course_curriculum_screen.dart';

import '../../export/export.dart';

class RegularCoursesScreen extends StatefulWidget {
  const RegularCoursesScreen({super.key});

  @override
  State<RegularCoursesScreen> createState() => _RegularCoursesScreenState();
}

class _RegularCoursesScreenState extends State<RegularCoursesScreen> {
  final RegularAdminController controller = Get.find<RegularAdminController>();
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  CourseModel? _selectedCourse;

  void _switchToPage(int pageIndex, {CourseModel? course}) {
    setState(() {
      _currentPage = pageIndex;
      _selectedCourse = course;
    });
    _pageController.animateToPage(
      pageIndex,
      duration: const Duration(milliseconds: 200),
      curve: Curves.linearToEaseOut,
    );
  }

  List<BreadCrumbItem> _buildBreadCrumbItems() {
    List<BreadCrumbItem> items = [
      BreadCrumbItem(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
        content: const Text(
          'Courses List',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        onTap: _currentPage != 0 ? () => _switchToPage(0) : null,
      ),
    ];
    if (_currentPage == 1) {
      items.add(
        BreadCrumbItem(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
          content: Text(
            _selectedCourse != null ? 'Update Course' : 'Add Course',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          onTap: _currentPage != 1 ? () => _switchToPage(1) : null,
        ),
      );
    }
    if (_currentPage == 2) {
      items.add(
        BreadCrumbItem(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
          content: const Text(
            'Review Lessons',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          onTap: _currentPage != 2 ? () => _switchToPage(2) : null,
        ),
      );
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: _currentPage == 0
              ? EdgeInsets.zero
              : (_currentPage == 1)
                  ? const EdgeInsets.symmetric(horizontal: 30)
                  : EdgeInsets.zero,
          child: PreferredSize(
            preferredSize: const Size.fromHeight(40.0),
            child: BreadCrumb(
              items: _buildBreadCrumbItems(),
              divider: const Icon(Icons.chevron_right),
              overflow: ScrollableOverflow(
                keepLastDivider: false,
                direction: Axis.horizontal,
              ),
            ),
          ),
        ),
        actions: [
          _currentPage == 0
              ? Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: ElevatedButton(
                    onPressed: () {
                      _switchToPage(1);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff2B2B2B),
                      foregroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 16.0,
                        horizontal: 24.0,
                      ),
                    ),
                    child: const Text(
                      'Add Course',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                )
              : Container()
        ],
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        children: [
          RegularCousesListScreen(
            onAddocourse: () => _switchToPage(1),
            onUpdateCourse: (course) => _switchToPage(1, course: course),
            onReviewLessons: (course) {
              _switchToPage(2, course: course);
            },
          ),
          AddUpdateForRegularCourseScreen(
            onCancel: () => _switchToPage(0),
            onSubmit: (course) => _switchToPage(2,course: course),
            courseModel: _selectedCourse,
          ),
         
          CourseCurriculumScreen(
            course: _selectedCourse,
            onCancel: (course) {
              () => _switchToPage(0);
            },
          )
        ],
      ),
    );
  }
}
