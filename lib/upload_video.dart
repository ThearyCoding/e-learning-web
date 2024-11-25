import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

class VideoUploader extends StatefulWidget {
  @override
  _VideoUploaderState createState() => _VideoUploaderState();
}

class _VideoUploaderState extends State<VideoUploader> {
  Uint8List? _videoBytes;
  String? _fileName;
  String? _statusMessage;

  Future<void> _pickVideo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );

    if (result != null) {
      setState(() {
        _fileName = result.files.single.name; // Get the file name
        _videoBytes = result.files.single.bytes; // Get the file bytes
      });
    }
  }

  Future<void> _uploadVideo() async {
    if (_videoBytes == null || _fileName == null) {
      setState(() {
        _statusMessage = 'Please select a video first.';
      });
      return;
    }

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://emndxpdnekorthpeethf.supabase.co/functions/v1/compressVideo'),
      );

      request.files.add(
        http.MultipartFile.fromBytes(
          'application/octet-stream',
          _videoBytes!,
          filename: _fileName,
        ),
      );

      // Send the request
      final response = await request.send();
      final responseBody = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        setState(() {
          _statusMessage = 'Video uploaded and compressed successfully.';
        });
      } else {
        setState(() {
          _statusMessage = 'Error: ${responseBody.body}';
          print(_statusMessage);
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Failed to upload video: $e';
      });
      print(_statusMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Upload and Compression'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _pickVideo,
              child: Text('Pick Video'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _uploadVideo,
              child: Text('Upload and Compress Video'),
            ),
            SizedBox(height: 16),
            if (_fileName != null) Text('Selected video: $_fileName'),
            if (_statusMessage != null) Text(_statusMessage!),
          ],
        ),
      ),
    );
  }
}
