

import '../export/export.dart';

class AddOrUpdateSubcategories extends StatefulWidget {
  final String? categoryId;
  final CourseModel? courseModel;
  final String title;
  const AddOrUpdateSubcategories(
      {super.key, this.categoryId, this.courseModel, required this.title});

  @override
  State<AddOrUpdateSubcategories> createState() =>
      _AddOrUpdateSubcategoriesState();
}

class _AddOrUpdateSubcategoriesState extends State<AddOrUpdateSubcategories> {
  TextEditingController courseTitleController = TextEditingController();
  final CoursesController coursesController =
      Get.find<CoursesController>();
  CategoryModel? selectedCategoryModel;
  List<CategoryModel> fetchedCategories = [];
  bool categoriesLoaded = false;
  String? oldImageUrl;
  final FirebaseApiCategories _apiCategories = FirebaseApiCategories();
  Future<String?> fetchCategories() async {
  List<CategoryModel> fetchedCategories =
      await _apiCategories.getCategories();

  String? categoryId; // Define categoryId variable

  if (mounted) {
    setState(() {
      this.fetchedCategories = fetchedCategories;
      categoriesLoaded = true; 
      if (widget.categoryId != null) {
        selectedCategoryModel = fetchedCategories.firstWhere(
          (category) => category.id == widget.categoryId,
        );

        if (selectedCategoryModel != null) {
          categoryId = selectedCategoryModel!.id;
        }
      }
    });
  }

  return categoryId; // Return the categoryId
}

String filename = '';
  Uint8List? _imageBytes;
  Future<void> _pickImageweb() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        filename = result.files.first.name;
        _imageBytes = result.files.first.bytes;
      });
    }
  }

  String? categoryid;
  void updateTextFields(CategoryModel? selectedCategory) {
    if (selectedCategory != null) {
      categoryid = selectedCategory.id;
    }
  }

  @override
  void initState() {
    super.initState();

     fetchCategories().then((categoryId) {
    setState(() {
      categoryid = categoryId;
    });
  });
    if (widget.courseModel != null) {
      courseTitleController.text = widget.courseModel!.title;
      oldImageUrl = widget.courseModel!.imageUrl;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.3,
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 21, vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(fontSize: 20),
                ),
                IconButton(
                    onPressed: () {
                      Get.back();
                    },
                    icon: const Icon(Icons.clear))
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
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
                controller: courseTitleController,
                style: const TextStyle(fontSize: 16.0, color: Colors.black),
                decoration: const InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                  labelText: 'Course Title',
                  hintText: 'Enter course title',
                  labelStyle: TextStyle(fontSize: 18.0, color: Colors.grey),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: _pickImageweb,
            child: _imageBytes != null
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 21),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.memory(
                        _imageBytes!,
                        height: 200,
                        width: MediaQuery.of(context).size.width * 0.3,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                : (widget.courseModel != null &&
                        // ignore: unnecessary_null_comparison
                        widget.courseModel!.imageUrl != null
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 21),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            widget.courseModel!.imageUrl,
                            height: 200,
                            width: MediaQuery.of(context).size.width * 0.3,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 21),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.transparent,
                            border: Border.all(color: Colors.grey),
                          ),
                          height: 200,
                          child: const Center(
                            child: Icon(
                              Icons.add_photo_alternate,
                              size: 50,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      )),
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 10.0),
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
                    child: categoriesLoaded
                        ? DropdownButtonFormField<CategoryModel>(
                            value: selectedCategoryModel,
                            onChanged: (value) {
                              setState(() {
                                selectedCategoryModel = value!;
                                updateTextFields(selectedCategoryModel);
                              });
                            },
                            items: fetchedCategories.map((category) {
                              return DropdownMenuItem<CategoryModel>(
                                value: category,
                                child: Text(
                                  category.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              );
                            }).toList(),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              labelText: 'Select Category',
                              labelStyle: TextStyle(
                                fontSize: 18.0,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 10.0),
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
                            child: const Text(
                              'Loading...',
                              style: TextStyle(
                                fontSize: 18.0,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 21),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ElevatedButton(
                  onPressed: handleButtonPress,
                  style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  child: const Text(
                    'Submit',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void handleButtonPress() {
  if (widget.title == 'Add Course') {
    CourseModel? courseModel = CourseModel(
        id: '',
        title: courseTitleController.text.trim(),
        imageUrl: '',
        categoryId: categoryid!, adminId: '', timestamp: DateTime.now(), registerCounts: 0);
    coursesController.addCourse(
      categoryid!,
      courseModel,
      _imageBytes!,
    );
  } else if (widget.title == 'Update Course') {
    coursesController.updateCourse(
      categoryid!,
      CourseModel(
        id: widget.courseModel!.id,
        title: courseTitleController.text,
        imageUrl: widget.courseModel!.imageUrl,
        categoryId: widget.categoryId!,
   adminId: widget.courseModel!.adminId,
        
      ),
      _imageBytes,
      oldImageUrl!,
    );
  }
}

}
