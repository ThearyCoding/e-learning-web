import 'dart:typed_data';
import 'package:http/http.dart' as http;

class SupabaseService {
  final String edgeFunctionUrl = 'https://emndxpdnekorthpeethf.supabase.co/functions/v1/compressVideo'; 

  Future<void> compressVideo(String bucket, String fileName, Uint8List fileBytes) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(edgeFunctionUrl))
        ..fields['bucket'] = bucket
        ..fields['key'] = fileName
        ..files.add(http.MultipartFile.fromBytes('file', fileBytes, filename: fileName));

      var response = await request.send();

      if (response.statusCode == 200) {
        print('Video compressed successfully: ${await response.stream.bytesToString()}');
      } else {
        print('Failed to compress video: ${response.statusCode} - ${await response.stream.bytesToString()}');
      }
    } catch (e) {
      print('Error calling Edge Function: $e');
    }
  }
}
