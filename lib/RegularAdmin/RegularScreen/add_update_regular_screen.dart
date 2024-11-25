import 'package:e_learningapp_admin/utils/toast_notification_config.dart';
import 'package:loading_btn/loading_btn.dart';
import '../../export/export.dart';
import '../../widgets/build_customize_drop_down.dart';
import '../../widgets/customize_textfield_area.dart';
import '../../widgets/responsive_course_form.dart';

class AddUpdateForRegularCourseScreen extends StatefulWidget {
  final String? categoryId;
  final CourseModel? courseModel;
  final VoidCallback onCancel;
  final Function(CourseModel) onSubmit;
  const AddUpdateForRegularCourseScreen({
    Key? key,
    this.categoryId,
    this.courseModel,
    required this.onCancel,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<AddUpdateForRegularCourseScreen> createState() =>
      _AddUpdateForRegularCourseScreenState();
}

class _AddUpdateForRegularCourseScreenState
    extends State<AddUpdateForRegularCourseScreen> {
  TextEditingController txttitle = TextEditingController();
  TextEditingController txtdescription = TextEditingController();
  final RegularAdminController controller = Get.find<RegularAdminController>();
  final CategoryController categoryController = Get.put(CategoryController());
  CategoryModel? selectedCategoryModel;
  String? oldImageUrl;
  User? user = FirebaseAuth.instance.currentUser;
  String filename = '';
  Uint8List? _imageBytes;
  final _key = GlobalKey<FormState>();
  final _listStatus = ['Available', 'Coming Soon'];
  String? _selectedStatus;
  double coursePrice = 0;
  int discount = 0;
  bool status = false;

  void _onStatusChanged(String? newValue) {
    setState(() {
      _selectedStatus = newValue;
      status = newValue == 'Available';
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.courseModel != null) {
      txttitle.text = widget.courseModel!.title;
      txtdescription.text = widget.courseModel!.description ?? '';
      oldImageUrl = widget.courseModel!.imageUrl;
      bool courseStatus = widget.courseModel!.status ?? false;
      _selectedStatus = courseStatus ? 'Available' : 'Coming Soon';
      coursePrice = widget.courseModel!.price ?? 0.0;
      discount = widget.courseModel!.discount ?? 0;
      status = widget.courseModel!.status ?? false;

      setSelectedCategory();
    } else {
      categoryController.fetchCategories();
    }
  }

  void setSelectedCategory() {
    if (widget.courseModel != null) {
      selectedCategoryModel = categoryController.categories.firstWhere(
        (category) => category.id == widget.courseModel!.categoryId,
        orElse: () => CategoryModel(
          id: '',
          title: '',
          imageUrl: '',
          timestamp: DateTime.now(),
        ),
      );
      setState(() {
        categoryid = selectedCategoryModel?.id;
      });
    }
  }

  void updateTextFields(CategoryModel? selectedCategory) {
    if (selectedCategory != null) {
      setState(() {
        categoryid = selectedCategory.id;
      });
    }
  }

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

  Future<void> handleButtonPress() async {
    String courseId = const Uuid().v4();
    if (_key.currentState!.validate()) {
      status = _selectedStatus == 'Available';

      if (categoryid != null) {
        if (widget.courseModel != null) {
          if (oldImageUrl != null) {
            controller.updateCourseByAdminId(
              user!.uid,
              categoryid!,
              CourseModel(
                  id: widget.courseModel!.id,
                  title: txttitle.text,
                  imageUrl: widget.courseModel!.imageUrl,
                  categoryId: widget.courseModel!.categoryId,
                  adminId: user!.uid,
                  timestamp: widget.courseModel!.timestamp,
                  price: coursePrice,
                  discount: discount,
                  status: status,
                  description: txtdescription.text,
                  registerCounts: widget.courseModel!.registerCounts),
              _imageBytes,
              oldImageUrl,
            );
          } else {
            toastificationUtils('Error: oldImageUrl is null');
          }
        } else {
          if (_imageBytes != null) {
            CourseModel courseModel = CourseModel(
              id: courseId,
              title: txttitle.text,
              imageUrl: '',
              categoryId: categoryid!,
              adminId: user!.uid,
              timestamp: DateTime.now(),
              price: coursePrice,
              discount: discount,
              status: status,
              description: txtdescription.text,
            );
            await controller.addRegularAdminCourse(
              categoryid!,
              courseModel,
              _imageBytes!,
              user!.uid,
            );
            widget.onSubmit(courseModel);
          } else {
            toastificationUtils(
                'Image cannot be null , please upload a new image.');
          }
        }
      } else {
        toastificationUtils('Please select category',
            title: 'Category required');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildAddCourse(context);
  }

  Widget _buildAddCourse(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _key,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 10,
            ),
            ResponsiveCourseForm(
              txttitle: txttitle,
              coursePrice: coursePrice,
              discount: discount,
              onCoursePriceChanged: (value) {
                coursePrice = value;
              },
              onDiscountChanged: (value) {
                setState(() {
                  discount = value;
                });
              },
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                bool isDesktop = constraints.maxWidth > 600;

                return isDesktop
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildDescription(context),
                          ),
                          Expanded(
                            child: _buildImagePicker(context),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDescription(context),
                          const SizedBox(height: 20),
                          _buildImagePicker(context),
                        ],
                      );
              },
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                bool isDesktop = constraints.maxWidth >= 600;

                return isDesktop
                    ? Row(
                        children: [
                          Expanded(child: _buildCategoryDropdown(context)),
                          Expanded(child: _buildStatusDropdown(context)),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCategoryDropdown(context),
                          const SizedBox(height: 20),
                          _buildStatusDropdown(context),
                        ],
                      );
              },
            ),
            const SizedBox(height: 20),
            LayoutBuilder(builder: (context, BoxConstraints constraints) {
              bool isDesktop = constraints.maxWidth >= 600;
              return isDesktop
                  ? _buildButtons(context, isDesktop)
                  : _buildButtons(context, isDesktop);
            })
          ],
        ),
      ),
    );
  }

  Widget _buildButtons(BuildContext context, bool isDesktop) {
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: isDesktop ? 50 : 20, vertical: 20),
      child: Row(
        children: [
          Expanded(
            child: LoadingBtn(
              height: 50,
              borderRadius: 8,
              animate: true,
              color: Colors.green,
              width:
                  MediaQuery.of(context).size.width * (isDesktop ? 0.45 : 0.8),
              loader: Container(
                padding: const EdgeInsets.all(10),
                width: 40,
                height: 40,
                child: const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              child: const Text(
                "Save Changes",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onTap: (startLoading, stopLoading, btnState) async {
                if (!_key.currentState!.validate()) {
                  return;
                }
                if (btnState == ButtonState.idle) {
                  startLoading();
                  await handleButtonPress();
                  stopLoading();
                }
              },
            ),
          ),
          SizedBox(width: isDesktop ? 100 : 20),
          Expanded(
            child: ElevatedButton(
              onPressed: widget.onCancel,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(
                  color: Colors.green,
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              EdgeInsets.symmetric(horizontal: _isDesktop(context) ? 50 : 20),
          child: const Text('Select category',
              style: TextStyle(fontWeight: FontWeight.w500)),
        ),
        const SizedBox(height: 10),
        Obx(() {
          if (categoryController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: _isDesktop(context) ? 50 : 20),
              child: DropdownField<CategoryModel>(
                hintText: 'Select Category',
                initialItem: selectedCategoryModel,
                items: categoryController.categories,
                onChanged: (CategoryModel? newValue) {
                  setState(() {
                    selectedCategoryModel = newValue;
                    updateTextFields(newValue);
                  });
                },
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
        })
      ],
    );
  }

  Widget _buildStatusDropdown(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              EdgeInsets.symmetric(horizontal: _isDesktop(context) ? 50 : 20),
          child: const Text('Select Status',
              style: TextStyle(fontWeight: FontWeight.w500)),
        ),
        const SizedBox(height: 10),
        Padding(
          padding:
              EdgeInsets.symmetric(horizontal: _isDesktop(context) ? 50 : 20),
          child: DropdownField<String>(
            hintText: 'Select course status',
            items: _listStatus,
            onChanged: _onStatusChanged,
            listItemBuilder: (context, title, bool, void Function()) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    overflow: TextOverflow.ellipsis,
                  ),
                  maxLines: 1,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildImagePicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              EdgeInsets.symmetric(horizontal: _isDesktop(context) ? 50 : 20),
          child: const Text(
            'Upload Course Image',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding:
              EdgeInsets.symmetric(horizontal: _isDesktop(context) ? 50 : 20),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: _pickImageweb,
            child: ImageSelector(
              imageBytes: _imageBytes,
              imageUrl: widget.courseModel?.imageUrl,
              height: 200,
              width: _isDesktop(context) ? 400 : double.infinity,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              EdgeInsets.symmetric(horizontal: _isDesktop(context) ? 50 : 20),
          child: const Text(
            'Enter description:',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding:
              EdgeInsets.symmetric(horizontal: _isDesktop(context) ? 50 : 20),
          child: ResizableTextField(
            hintText: 'Type your remarks here...',
            minHeight: 150,
            maxHeight: 200,
            minWidth: 200,
            maxWidth: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            controller: txtdescription,
            onChanged: (value) {},
            onSubmitted: (value) {},
            autoFocus: false,
          ),
        ),
      ],
    );
  }

  bool _isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600;
}
