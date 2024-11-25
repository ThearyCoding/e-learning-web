import 'dart:typed_data';

import 'package:e_learningapp_admin/widgets/customize_textfield_area.dart';
import 'package:expandable/expandable.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/lecture_model.dart';
import '../utils/toast_notification_config.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class LectureWidget extends StatefulWidget {
  final Lecture lecture;
  final VoidCallback onRemove;
  final ValueChanged<Lecture> onEdit;

  const LectureWidget(
      {super.key,
      required this.lecture,
      required this.onRemove,
      required this.onEdit});

  @override
  LectureWidgetState createState() => LectureWidgetState();
}

class LectureWidgetState extends State<LectureWidget> {
  TextEditingController txttitle = TextEditingController();
  TextEditingController txtdescription = TextEditingController();

  @override
  void initState() {
    super.initState();
    txttitle.text = widget.lecture.title;

    txtdescription.text = widget.lecture.description;
    if (widget.lecture.videoUrl.isNotEmpty) {
      isHaveVideo = true;
    }
  }

  bool isHaveVideo = false;
  void _saveLecture() {
    widget.onEdit(Lecture(
      title: txttitle.text,
      description: txtdescription.text,
      id: widget.lecture.id,
      videoUrl: widget.lecture.videoUrl,
      timestamp: widget.lecture.timestamp,
      sectionId: widget.lecture.sectionId,
      thumbnailUrl: widget.lecture.thumbnailUrl,
      videoDuration: widget.lecture.videoDuration,
      fileName: widget.lecture.fileName,
    ));
  }

  VideoPlayerController? videoPlayerController;
  String? filename = 'No file selected';
  Uint8List? videoFile;
  double progress = 0;
  String videoDuration = '0:00';
  bool isPicked = false;

  Future<void> _pickVideo() async {
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'video/mp4';
    uploadInput.click();

    uploadInput.onChange.listen((e) async {
      final files = uploadInput.files;

      if (files != null && files.isNotEmpty) {
        final file = files[0];

        if (file.type == 'video/mp4') {
          const int maxSizeInBytes = 200 * 1024 * 1024; // 200MB in bytes
          if (file.size > maxSizeInBytes) {
            toastificationUtils(
                'The selected video exceeds the maximum size of 200MB. Please select a smaller video.');
            uploadInput.value = null;
            return;
          }
          final reader = html.FileReader();

          reader.onLoadEnd.listen((e) {
            setState(() {
              filename = file.name;
              videoFile = reader.result as Uint8List?;
              _initializeVideoPlayer();
            });
          });

          reader.readAsArrayBuffer(file);
        } else {
          toastificationUtils(
              '${file.type} not supported, Please select an MP4 video file.');
          setState(() {
            uploadInput.value = null;
          });
        }
      }
    });
  }

  Future<void> _initializeVideoPlayer() async {
    final blob = html.Blob([videoFile]);
    final url = html.Url.createObjectUrlFromBlob(blob);

    // ignore: deprecated_member_use
    videoPlayerController = VideoPlayerController.network(url)
      ..initialize().then((_) {
        setState(() {
          final duration = videoPlayerController!.value.duration;
          videoDuration = _formatDuration(duration);

          _uploadVideo();
          isPicked = true;
        });
      });
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _uploadVideo() async {
    if (videoFile == null) return;

    final storageRef = FirebaseStorage.instance.ref().child('videos').child(
          '${DateTime.now().toIso8601String()}.mp4',
        );
    final uploadTask = storageRef.putData(
        videoFile!, SettableMetadata(contentType: "video/mp4"));

    uploadTask.snapshotEvents.listen((event) {
      setState(() {
        progress =
            event.bytesTransferred.toDouble() / event.totalBytes.toDouble();
      });
    });

    final TaskSnapshot taskSnapshot = await uploadTask;
    final downloadURL = await taskSnapshot.ref.getDownloadURL();
    // Save the lecture details to Firestore
    widget.onEdit(Lecture(
      title: txttitle.text,
      description: txtdescription.text,
      id: widget.lecture.id,
      videoUrl: downloadURL,
      timestamp: DateTime.now(),
      sectionId: widget.lecture.sectionId,
      thumbnailUrl: widget.lecture.thumbnailUrl,
      videoDuration: videoPlayerController!.value.duration.inSeconds.toDouble(),
      fileName: filename ?? '',
    ));
    await deleteVideoPrevious();
    toastificationUtils('Upload complete.',
        icon: Icons.check,
        title: 'Success!',
        primaryColor: Colors.green.shade200);
    setState(() {
      isPicked = false;
      isHaveVideo = true;
    });
  }
  Future<void> deleteVideoPrevious() async{
     // Retrieve the previous video URL
  final previousVideoUrl = widget.lecture.videoUrl;

  // Delete the previous video from Firebase Storage if it exists
  if (previousVideoUrl.isNotEmpty) {
    try {
      final previousStorageRef = FirebaseStorage.instance.refFromURL(previousVideoUrl);
      await previousStorageRef.delete();
    } catch (e) {
      print('Failed to delete previous video: $e');
    }
  }

  }
  bool _isChecked = false;
  @override
  void dispose() {
    videoPlayerController!.dispose();
    super.dispose();
  }

  final ExpandableController controller = ExpandableController();
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ExpandablePanel(
        controller: controller,
        header: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              Checkbox(
                value: _isChecked,
                onChanged: (value) {
                  setState(() {
                    _isChecked = value!;
                  });
                },
              ),
              Text(widget.lecture.title,overflow: TextOverflow.ellipsis,maxLines: 1,softWrap: true,),
              if (_isChecked)
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => widget.onRemove(),
                ),
            ],
          ),
        ),
        collapsed: Container(),
        expanded: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: txttitle,
                decoration: InputDecoration(
                    labelText: 'Lecture Title',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        gapPadding: 1)),
                onSubmitted: (value) {
                  _saveLecture();
                },
              ),
              const SizedBox(height: 8.0),
              ResizableTextField(
                controller: txtdescription,
                maxWidth: double.infinity,
                maxHeight: 200,
                hintText: 'Enter description',
                onSubmitted: (value) {
                  _saveLecture();
                },
              ),
              const SizedBox(height: 8.0),
              Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                    ),
                    child: isPicked
                        ? Row(
                            children: [
                              Expanded(
                                  child: Text(filename ?? "No file selected")),
                              const Text("Video"),
                              const SizedBox(width: 16),
                              progress > 0
                                  ? Expanded(
                                      child: LinearProgressIndicator(
                                        value: progress,
                                        backgroundColor: Colors.grey[300],
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(
                                                Colors.purple),
                                      ),
                                    )
                                  : Container(),
                              const SizedBox(width: 16),
                              Text(DateTime.now().toString().split(' ')[0]),
                              IconButton(
                                icon: const Icon(Icons.cancel),
                                onPressed: () {
                                  setState(() {
                                    filename = 'No file selected';
                                    videoFile = null;
                                    progress = 0;
                                    isPicked = false;
                                  });
                                },
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(isHaveVideo
                                      ? widget.lecture.fileName
                                      : filename!),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: _pickVideo,
                                child: Text(isHaveVideo
                                    ? "Replace Video"
                                    : "Select Video"),
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Text(
                          "Note: files should be at least 720p and less than 4.0 GB.",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        controller.toggle();
                      });
                    },
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8.0),
                  ElevatedButton(
                    onPressed: _saveLecture,
                    child: const Text('Save Lecture'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
