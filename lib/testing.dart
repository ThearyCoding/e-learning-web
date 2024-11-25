import 'dart:typed_data';
import 'package:e_learningapp_admin/core/constant.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class VideoUploadScreen extends StatefulWidget {
  @override
  _VideoUploadScreenState createState() => _VideoUploadScreenState();
}

class _VideoUploadScreenState extends State<VideoUploadScreen> {
  IO.Socket? socket;
  double compressProgress = 0;
  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    _connectSocket();
  }

  // Connect to the Socket.IO server
  void _connectSocket() {
    String server = "$renderUrl"; // Ensure your serverHost is set correctly
    socket = IO.io(server, <String, dynamic>{
      'transports': ['websocket'],
    });

    socket!.on('progress', (data) {
      // Handle the emitted progress from the server
      if (data['type'] == 'upload') {
        // setState(() {
        //   compressProgress = double.parse(data['progress']);
        // });
      } else if (data['type'] == 'compression') {
        setState(() {
          compressProgress = double.parse(data['progress']);
        });
      }
    });

    socket?.onConnect((_) {
      print('Connected to server');
    });

    socket?.onDisconnect((_) {
      print('Disconnected from server');
    });
  }

  // Pick and upload video
  Future<void> _pickAndUploadVideo() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.video);

    if (result != null) {
      Uint8List? videoBytes = result.files.first.bytes;
      String fileName = result.files.first.name;

      if (videoBytes == null) {
        print("No video bytes selected. Aborting.");
        return;
      }

      setState(() {
        isUploading = true;
      });

      try {
        await _uploadVideo(videoBytes, fileName);
      } catch (e) {
        print('Upload error: $e');
      }

      setState(() {
        isUploading = false;
      });
    } else {
      print('User canceled video picker');
    }
  }

  // Upload video and include socket ID in request headers
  Future<void> _uploadVideo(Uint8List videoBytes, String fileName) async {
    var url = Uri.parse('$renderUrl/api/upload');

    var request = http.MultipartRequest('POST', url);
    request.files.add(http.MultipartFile.fromBytes(
      'video',
      videoBytes,
      filename: fileName,
      contentType: MediaType('video', 'mp4'),
    ));
    request.headers['socket-id'] = socket?.id ?? '';

    var response = await request.send();

    if (response.statusCode == 200) {
      print('Video uploaded successfully');
    } else {
      print('Failed to upload video');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text("Video Upload with Progress"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (isUploading) ...[
                Text("Upload Progress: ${compressProgress.toStringAsFixed(2)}%",
                    style: TextStyle(color: Colors.white)),
                SizedBox(height: 16),
                LinearProgressIndicator(
                  value: compressProgress / 100,
                  color: Colors.red,
                ),
              ],
              Center(
                child: ElevatedButton(
                  onPressed: isUploading ? null : _pickAndUploadVideo,
                  child: Text(
                    isUploading ? "Uploading..." : "Pick and Upload Video",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    socket?.disconnect();
    super.dispose();
  }
}
