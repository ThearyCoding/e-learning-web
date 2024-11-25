import 'dart:io';
import 'dart:typed_data';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter/material.dart';

class CroppImage {

  static Future<Uint8List?> cropImage(BuildContext context, File pickedFile) async {
    final CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 100,
      uiSettings: [
        WebUiSettings(
          viewwMode: WebViewMode.mode_2,
          context: context,
          presentStyle: WebPresentStyle.dialog,
          size: const CropperSize(
            width: 520,
            height: 520,
          ),
          
        ),
      ],
    );

    if (croppedFile != null) {
      final Uint8List croppedImageBytes = await croppedFile.readAsBytes();
      return croppedImageBytes;
    }

    return null;
  }

  
}
