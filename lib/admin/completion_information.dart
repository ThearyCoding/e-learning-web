import 'dart:io';

import 'package:e_learningapp_admin/services/firebase/firebase_service.dart';
import 'package:e_learningapp_admin/utils/image_picker_utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class CompletionInformation extends StatefulWidget {
  @override
  State<CompletionInformation> createState() => _CompletionInformationState();
}

class _CompletionInformationState extends State<CompletionInformation> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  String? filename = '';
  Uint8List? imageFile;

  _pickPhoto() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    Uint8List? imagebytes =
        await CroppImage.cropImage(context, File(result!.xFiles.first.path));
    setState(() {
      filename = result.files.first.name;
      imageFile = imagebytes;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 1200;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 230, 229, 229),
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          width: isDesktop ? 500 : screenSize.width * 0.9,
          height: 650,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Complete Information required",
                  style: TextStyle(fontSize: 20, color: Colors.black),
                ),
              ),
              SizedBox(
                height: 50,
              ),
              SizedBox(
                width: 200,
                height: 200,
                child: CircleAvatar(
                  backgroundColor: Colors.grey[200],
                  backgroundImage: imageFile != null
                      ? MemoryImage(imageFile!)
                      : NetworkImage(
                          'https://t4.ftcdn.net/jpg/01/86/29/31/360_F_186293166_P4yk3uXQBDapbDFlR17ivpM6B1ux0fHG.jpg',
                        ) as ImageProvider,
                  radius: 100,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 50),
                    backgroundColor: Colors.blueAccent,
                    shape:
                        BeveledRectangleBorder(borderRadius: BorderRadius.zero)),
                onPressed: _pickPhoto,
                child: const Text(
                  'Upload Image',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: 'First Name',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  labelText: 'Last Name',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                controller: _phoneNumberController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 50),
                    backgroundColor: Colors.blueAccent,
                    shape:
                        BeveledRectangleBorder(borderRadius: BorderRadius.zero)),
                onPressed: () async {
                  try {
                    if (_firstNameController.text.isNotEmpty &&
                        _lastNameController.text.isNotEmpty &&
                        _phoneNumberController.text.isNotEmpty) {
                      EasyLoading.show(status: 'Uploading...');
                      String? imageUrl;
                      if (imageFile != null) {
                        imageUrl = await FirebaseService()
                            .uploadImageToStorage(imageFile!, 'admin_image');
                      } else {
                        imageUrl =
                            'https://t4.ftcdn.net/jpg/01/86/29/31/360_F_186293166_P4yk3uXQBDapbDFlR17ivpM6B1ux0fHG.jpg';
                      }
                      await FirebaseService.completeInformation(
                        firstName: _firstNameController.text.trim(),
                        lastName: _lastNameController.text.trim(),
                        imageUrl: imageUrl!,
                        phoneNumber: _phoneNumberController.text.trim(),
                      );
                      EasyLoading.showSuccess('Upload Successful');
                    } else {}
                  } catch (error) {
                    print('Signing error $error');
                    rethrow;
                  } finally {
                    EasyLoading.dismiss();
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'Save Changes',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
