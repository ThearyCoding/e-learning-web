import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_web_pagination/flutter_web_pagination.dart';
import 'package:intl/intl.dart';
import '../../export/export.dart';
import '../../widgets/build_status_container.dart';

class BuildRegularAdminCourse extends StatefulWidget {
  final VoidCallback? onAddadmin;
  final RegularAdminController controller;
  final Function(CourseModel) onUpdateCourse;
  final Function(CourseModel) onReviewLessons;
  const BuildRegularAdminCourse({
    Key? key,
    this.onAddadmin,
    required this.controller,
    required this.onUpdateCourse,
    required this.onReviewLessons,
  }) : super(key: key);

  @override
  BuildRegularAdminCourseState createState() => BuildRegularAdminCourseState();
}

class BuildRegularAdminCourseState extends State<BuildRegularAdminCourse> {
  int hoveredIndex = -1;

  int _currentPage = 1;
  User? user = FirebaseAuth.instance.currentUser;
  final CategoryController _categoryController = Get.find<CategoryController>();
  @override
  void initState() {
    super.initState();
    widget.controller.fetchAdminCourses(user!.uid, requestedPage: _currentPage);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildHeader(),
        Expanded(
          child: Obx(() {
            // final courses = widget.controller.courses;
            if (widget.controller.isLoading.value) {
              return configloadingProgressIndicator();
            } else if (widget.controller.courses.isEmpty) {
              return const Center(
                child: Text('No courses yet.'),
              );
            }
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.controller.courses.length,
                    itemBuilder: (context, index) {
                      final course = widget.controller.courses[index];
                      int displayIndex =
                          (_currentPage - 1) * widget.controller.perPage +
                              index +
                              1;
                      String categoryTitle = _categoryController
                          .getCategoryTitle(course.categoryId);

                      return buildAdminItem(
                        displayIndex,
                        course,
                        index.isEven,
                        categoryTitle,
                        context,
                      );
                    },
                  ),
                ),
                _buildPagination(),
              ],
            );
          }),
        ),
      ],
    );
  }

  Widget _buildPagination() {
    return WebPagination(
      onPageChanged: (int newPage) {
        setState(() {
          _currentPage = newPage;
        });
        widget.controller.fetchAdminCourses(user!.uid, requestedPage: newPage);
      },
      currentPage: _currentPage,
      totalPage: calculateTotalPages(),
    );
  }

  int calculateTotalPages() {
    int totalCoursesCount = widget.controller.totalCoursesCount;
    int perPage = widget.controller.perPage;

    if (totalCoursesCount > 0) {
      return (totalCoursesCount / perPage).ceil();
    } else {
      return 1;
    }
  }

  Widget buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.grey[700],
      child: Row(
        children: [
          headerItem('#', flex: 1),
          headerItem('Image', flex: 2),
          headerItem('Title', flex: 2),
          headerItem('Price', flex: 2),
          headerItem('Discount', flex: 2),
          headerItem('Description', flex: 3),
          headerItem('Category', flex: 2),
          headerItem('Register', flex: 2),
          headerItem('Status', flex: 2),
          headerItem('Created at', flex: 3),
          headerItem('Actions', flex: 4),
        ],
      ),
    );
  }

  Widget headerItem(String title, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Center(
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.white60,
          ),
        ),
      ),
    );
  }

  Widget buildAdminItem(
    int index,
    CourseModel course,
    bool isEven,
    String categoryTitle,
    BuildContext context,
  ) {
    String formattedTimestamp =
        DateFormat('dd-MMM-yyyy').format(course.timestamp!);

    bool isHovered = hoveredIndex == index;

    return MouseRegion(
      onEnter: (_) {
        setState(() {
          hoveredIndex = index;
        });
      },
      onExit: (_) {
        setState(() {
          hoveredIndex = -1;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: isHovered
                ? Colors.grey[300]
                : isEven
                    ? Colors.grey[200]
                    : Colors.white,
            borderRadius: BorderRadius.zero,
          ),
          child: Row(
            children: [
              adminItem(Center(child: Text('$index')), flex: 1),
              adminItem(
                Center(
                  child: CachedNetworkImage(
                    width: 100,
                    height: 60,
                    imageUrl: course.imageUrl,
                    placeholder: (context, url) =>
                        Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),
                flex: 2,
              ),
              adminItem(
                Text(
                  course.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                flex: 2,
              ),
              adminItem(
                Text(
                  course.price != null && course.price != 0
                      ? '\$${course.price}'
                      : 'Free',
                  style: TextStyle(
                      fontSize: 16,
                      color: course.price != null && course.price != 0
                          ? Colors.black
                          : Colors.green.withOpacity(.8)),
                ),
                flex: 2,
              ),
              adminItem(
                  Text(course.discount != null
                      ? '%${course.discount}'
                      : 'No Discount'),
                  flex: 2),
              adminItem(
                Text(
                  course.description != null
                      ? '${course.description}'
                      : 'no description',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                ),
                flex: 3,
              ),
              adminItem(Text(categoryTitle), flex: 2),
              adminItem(
                  Text(course.registerCounts != null
                      ? '${course.registerCounts}'
                      : '0'),
                  flex: 2),
              adminItem(StatusContainer(status: course.status), flex: 2),
              adminItem(
                Text(
                  formattedTimestamp,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                flex: 3,
              ),
              adminItem(
                flex: 4,
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        widget.controller.onButtonPressed(course);
                      },
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        side: const BorderSide(color: Colors.grey),
                      ),
                      child: Text(
                          course.status == true ? 'Published' : 'Unpublish'),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (String result) {
                        if (result == 'update') {
                          widget.onUpdateCourse(course);
                        } else if (result == 'delete') {
                          widget.controller.deleteCourseByAdminId(
                              user!.uid, course, context);
                        } else if (result == 'review-lessons') {
                          widget.onReviewLessons(course);
                        }
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'update',
                          child: ListTile(
                            leading: Icon(Icons.edit),
                            title: Text('Update'),
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: ListTile(
                            leading: Icon(Icons.delete, color: Colors.red),
                            title: Text('Delete'),
                          ),
                        ),
                        const PopupMenuItem(
                            value: 'review-lessons',
                            child: ListTile(
                              leading: Icon(Icons.video_collection),
                              title: Text('View Lessons'),
                            ))
                      ],
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

  Widget adminItem(Widget child, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Center(child: child),
    );
  }
}
