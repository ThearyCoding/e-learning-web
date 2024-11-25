

import '../../export/export.dart';

class SubCategoriesScreen extends StatefulWidget {
  const SubCategoriesScreen({super.key});

  @override
  State<SubCategoriesScreen> createState() => _SubCategoriesScreenState();
}

class _SubCategoriesScreenState extends State<SubCategoriesScreen> {
  final CoursesController coursesController =
      Get.find<CoursesController>();

  // ignore: unused_field
  Uint8List? _imageBytes;

  String? oldImageUrl;

  String filename = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Courses',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 36,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton.icon(
              icon: const Icon(
                Icons.add,
                color: Colors.white,
              ),
              onPressed: () {
                _showCategoryDialog(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(
                    vertical: 16.0, horizontal: 24.0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0)),
              ),
              label: const Text(
                'New Course',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Obx(() {
                final courses = coursesController.courses;
                if (courses.isEmpty) {
                  return const Center(child: Text('No Course Found!'));
                } else {
                  return SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      border: const TableBorder(
                          left: BorderSide(color: Colors.grey),
                          right: BorderSide(color: Colors.grey),
                          bottom: BorderSide(color: Colors.grey),
                          top: BorderSide(color: Colors.grey)),
                      // ignore: deprecated_member_use
                      dataRowHeight: 70,
                      dividerThickness: 1,
                      // ignore: deprecated_member_use
                      dataRowColor: MaterialStateColor.resolveWith((states) {
                        // Set color for even and odd rows
                        // ignore: deprecated_member_use
                        if (states.contains(MaterialState.selected)) {
                          return Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.08);
                        }
                        return Colors.transparent;
                      }),
                      // ignore: deprecated_member_use
                      headingRowColor: MaterialStateProperty.all(Colors.blue),
                      columnSpacing: 40,
                      columns: const [
                        DataColumn(
                            label: Text('No.',
                                style: TextStyle(color: Colors.white))),
                        DataColumn(
                            label: Text('Course Id',
                                style: TextStyle(color: Colors.white))),
                        DataColumn(
                            label: Text('Course Name',
                                style: TextStyle(color: Colors.white))),
                        DataColumn(
                            label: Text('Image',
                                style: TextStyle(color: Colors.white))),
                        DataColumn(
                            label: Text('CategoryId',
                                style: TextStyle(color: Colors.white))),
                        DataColumn(
                            label: Text('Actions',
                                style: TextStyle(color: Colors.white))),
                      ],
                      rows: courses.asMap().entries.map((entry) {
                        final index = entry.key + 1;
                        final course = entry.value;
                        return DataRow(cells: [
                          DataCell(Text('$index')),
                          DataCell(Text(course.id)),
                          DataCell(Text(course.title)),
                          DataCell(
                            Image.network(
                              course.imageUrl,
                              width: 70,
                              fit: BoxFit.cover,
                            ),
                          ),
                          DataCell(
                            Text(course.categoryId),
                          ),
                          DataCell(
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    coursesController.deleteCourse(
                                        course.categoryId, course.id);
                                  },
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                ),
                                IconButton(
                                  onPressed: () {
                                    _showCategoryDialog(
                                      context,
                                      categoryid: course.categoryId,
                                      courseModel: course,
                                    );
                                  },
                                  icon: const Icon(Icons.update),
                                ),
                              ],
                            ),
                          ),
                        ]);
                      }).toList(),
                    ),
                  );
                }
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryDialog(BuildContext context,
      {String? categoryid, CourseModel? courseModel}) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          child: AddOrUpdateSubcategories(
            title: courseModel != null ? 'Update Course' : 'Add Course',
            courseModel: courseModel,
            categoryId: categoryid,
          ),
        );
      },
    );
  }
}
