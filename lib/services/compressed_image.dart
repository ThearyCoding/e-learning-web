import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImageCompressService {

  Future<Uint8List> compressImage(Uint8List imageBytes, {int quality = 75}) async {
    try {
      Uint8List? compressedBytes = await FlutterImageCompress.compressWithList(
        imageBytes,
        quality: quality, 
      );
      if (compressedBytes.isNotEmpty) {
        return compressedBytes;
      } else {
        throw Exception('Image compression failed');
      }
    } catch (e) {
      throw Exception('Error compressing image: $e');
    }
  }
}
