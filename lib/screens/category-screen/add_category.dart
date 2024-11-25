import 'dart:ui';

import '../../export/export.dart';

class AddCategoryScreen extends StatefulWidget {
  final String title;
  final CategoryModel? category;

  const AddCategoryScreen({Key? key, required this.title, this.category})
      : super(key: key);

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final CategoryController categoryController = Get.find();
  TextEditingController txttitle = TextEditingController();
  Uint8List? _imageBytes;
  String? oldImageUrl;
  String filename = '';
  ValueNotifier<bool> isButtonEnabled = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      txttitle.text = widget.category!.title;
      oldImageUrl = widget.category!.imageUrl;
      filename = widget.category!.imageUrl;
    }
    txttitle.addListener(_updateButtonState);
  }

  void _updateButtonState() {
    bool isNameEntered = txttitle.text.isNotEmpty;
    bool isImagePicked = _imageBytes != null;
    bool isButtonEnabled = isNameEntered && isImagePicked;

    this.isButtonEnabled.value = isButtonEnabled;
  }

  Future<void> _pickImageWeb() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        filename = result.files.first.name;
        _imageBytes = result.files.first.bytes;
      });
      _updateButtonState();
    }
  }

  void _handleSubmit() {
    if (widget.title == 'Add Category') {
      categoryController.addCategory(
        txttitle.text,
        _imageBytes!,
      );
    } else if (widget.title == 'Update Category') {
      categoryController.updateCategory(
        widget.category!,
        txttitle.text,
        _imageBytes!,
        oldImageUrl!,
      );
    }
  }

  @override
  void dispose() {
    txttitle.removeListener(_updateButtonState);
    txttitle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double padding = 21;
      double imageHeight = 200;
      double width = 500;
      double height = 600;
      double imageWidth = constraints.maxWidth * 0.3;
      double textFieldWidth = constraints.maxWidth * 0.8;
      double textFieldHeight = 50;
      if (constraints.maxWidth > 1200) {
        // Desktop layout
        padding = 50;
        imageHeight = 250;
        imageWidth = constraints.maxWidth * 0.6;
        textFieldWidth = constraints.maxWidth * 0.6;
        textFieldHeight = 60;
      } else if (constraints.maxWidth > 800) {
        // Tablet layout
        padding = 40;
        imageHeight = 200;
        imageWidth = constraints.maxWidth * 0.3;
        textFieldWidth = constraints.maxWidth * 0.7;
        textFieldHeight = 55;
      } else {
        // Mobile layout
        padding = 21;
        imageHeight = 150;
        imageWidth = constraints.maxWidth * 0.8;
        textFieldWidth = constraints.maxWidth * 0.8;
        textFieldHeight = 50;
      }
      return SizedBox(
        width: width,
        height: height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _imageBytes != null
                ? Padding(
                    padding: EdgeInsets.symmetric(horizontal: padding),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.memory(
                        _imageBytes!,
                        height: imageHeight,
                        width: imageWidth,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                : (widget.category != null && oldImageUrl != null
                    ? Padding(
                        padding: EdgeInsets.symmetric(horizontal: padding),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            oldImageUrl!,
                            height: imageHeight,
                            width: imageWidth,
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    : Container(
                        margin: EdgeInsets.symmetric(horizontal: padding),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.transparent,
                          border: Border.all(color: Colors.grey),
                        ),
                        height: imageHeight,
                        width: imageWidth,
                        child: const Center(
                          child: Icon(
                            Icons.add_photo_alternate,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                      )),
            const SizedBox(height: 20),
            buildVideoUploadField(padding),
            const SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: padding),
              child: SizedBox(
                width: textFieldWidth,
                height: textFieldHeight,
                child: TextField(
                  controller: txttitle,
                  decoration: const InputDecoration(
                    labelText: 'Category Name',
                    hintText: 'E.g.., Mobile App',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: padding),
              child: Align(
                alignment: Alignment.centerLeft,
                child: ValueListenableBuilder<bool>(
                  valueListenable: isButtonEnabled,
                  builder: (context, value, child) {
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff2B2B2B),
                        foregroundColor: Colors.grey[300],
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 20.0),
                      ),
                      onPressed: value ? _handleSubmit : null,
                      child: const Text('Save changes'),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  bool _isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600;
  Widget buildVideoUploadField(double padding) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: _isDesktop(context) ? padding : padding + 10),
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            ElevatedButton(
              onPressed: _pickImageWeb,
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
                  text: _imageBytes != null || filename.isNotEmpty
                      ? filename
                      : 'No video selected',
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
}
