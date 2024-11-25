import '../../export/export.dart';

class ManageLessonScreen extends StatefulWidget {
  const ManageLessonScreen({super.key});

  @override
  State<ManageLessonScreen> createState() => _ManageLessonScreenState();
}

class _ManageLessonScreenState extends State<ManageLessonScreen> {
  int _currentPage = 0;
  TopicModel? _selectedTopic;
  final PageController _pageController = PageController(initialPage: 0);
  void _switchToPage(int pageIndex, {TopicModel? course}) {
    setState(() {
      _currentPage = pageIndex;
      _selectedTopic = course;
    });
    _pageController.animateToPage(
      pageIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.linearToEaseOut,
    );
  }

  Color color = const Color(0xFFF5F9FD);
  List<BreadCrumbItem> _buildBreadCrumbItems() {
    List<BreadCrumbItem> items = [
      BreadCrumbItem(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
        content: const Text(
          'Lessons List',
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
            _selectedTopic != null ? 'Update Lesson' : 'Add Lesson',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          onTap: _currentPage != 1 ? () => _switchToPage(1) : null,
        ),
      );
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: color,
      appBar: AppBar(
        backgroundColor: color,
        notificationPredicate: (notification) {
          return SnackbarController.isSnackbarBeingShown;
        },
        title: Padding(
          padding: _currentPage == 0
              ? const EdgeInsets.symmetric(horizontal: 70)
              : const EdgeInsets.symmetric(horizontal: 280),
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
                      'Add Lesson',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                )
              : Container(),
        ],
      ),
      body: Padding(
        padding: _currentPage == 0
            ? const EdgeInsets.symmetric(horizontal: 70)
            : const EdgeInsets.symmetric(horizontal: 300),
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
          },
          children: [
            RegularTopicScreen(
              onAddLessons: () => _switchToPage(1),
              onUpdateTopic: (course) => _switchToPage(1, course: course),
            ),
            // AddUpdateRegularAdmin(
            //   onCancel: () => _switchToPage(0),
            //   topic: _selectedTopic,
            // ),
          ],
        ),
      ),
    );
  }
}
