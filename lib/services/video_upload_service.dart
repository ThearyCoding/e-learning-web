import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:e_learningapp_admin/core/constant.dart';

typedef OnUploadProgressCallback = void Function(int sentBytes, int totalBytes);

class FileService {

  // Video upload method with Uint8List and progress tracking
  static Future<String> uploadVideo({
    required Uint8List videoData, 
    required String fileName,
    required OnUploadProgressCallback onUploadProgress
  }) async {
    // Create a Dio instance for handling the HTTP requests
    Dio dio = Dio();

    // Prepare the video file for upload
    FormData formData = FormData.fromMap({
      "video": MultipartFile.fromBytes(videoData, filename: fileName),
    });

    // Make a POST request to upload the video with progress tracking
    try {
      Response response = await dio.post(
        '$serverHost/api/upload-video',
        data: formData,
        onSendProgress: (int sentBytes, int totalBytes) {
          onUploadProgress(sentBytes, totalBytes);
        },
      );

      // Check the status code for success
      if (response.statusCode == 200) {
        return response.data.toString();  // Handle response data here
      } else {
        throw Exception("Failed to upload video. Status code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error uploading video: $e");
    }
  }
}
