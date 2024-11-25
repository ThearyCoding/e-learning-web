import 'package:ffmpeg_wasm/ffmpeg_wasm.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late FFmpeg ffmpeg;
  bool isLoaded = false;
  String? selectedFile;
  String? conversionStatus;
  double compressionProgress = 0.0;

  @override
  void initState() {
    super.initState();
    loadFFmpeg();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Is FFmpeg loaded: $isLoaded and selected: $selectedFile',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            OutlinedButton(
              onPressed: loadFFmpeg,
              child: const Text('Load FFmpeg'),
            ),
            OutlinedButton(
              onPressed: isLoaded ? pickFile : null,
              child: const Text('Pick File'),
            ),
            OutlinedButton(
              onPressed: selectedFile == null ? null : compressVideo,
              child: const Text('Compress Video'),
            ),
            Text('Conversion Status: $conversionStatus'),

            // Display progress bar
            LinearProgressIndicator(value: compressionProgress),

            OutlinedButton(
                onPressed: () {
                  setState(() {
                    ffmpeg.exit();
                    compressionProgress = 0;
                  });
                },
                child: Text("Cancel Compression")),
          ],
        ),
      ),
    );
  }

  Future<void> loadFFmpeg() async {
    ffmpeg = createFFmpeg(
      CreateFFmpegParam(
        log: true,
        corePath: "https://unpkg.com/@ffmpeg/core@0.11.0/dist/ffmpeg-core.js",
      ),
    );

    await ffmpeg.load();
    checkLoaded();
  }

  void checkLoaded() {
    setState(() {
      isLoaded = ffmpeg.isLoaded();
    });
  }

  Future<void> pickFile() async {
    final filePickerResult =
        await FilePicker.platform.pickFiles(type: FileType.video);
    if (filePickerResult != null &&
        filePickerResult.files.single.bytes != null) {
      ffmpeg.writeFile('input.mp4', filePickerResult.files.single.bytes!);
      setState(() {
        selectedFile = filePickerResult.files.single.name;
      });
    }
  }

  Future<void> compressVideo() async {
    setState(() {
      conversionStatus = 'Compressing...';
      compressionProgress = 0.0;
    });

    ffmpeg.setProgress(_onProgressHandler);

    String outputFileName =
        '${DateTime.now().millisecondsSinceEpoch}_compressed.mp4';

    await ffmpeg
        .run([
          '-i', 'input.mp4',
          '-vcodec', 'libx264',
          '-crf', '35',
          '-preset', 'superfast',
          '-vf', 'scale=640:-1',
          '-acodec', 'aac',
          '-b:a', '48k',
          '-b:v', '400k',
          outputFileName
        ])
        .asStream()
        .listen(
          (event) {},
          onDone: () async {
            // Read the compressed video file as bytes
            final compressedVideo = ffmpeg.readFile(outputFileName);

            // Uploading to Firebase Storage
            final storageRef =
                FirebaseStorage.instance.ref().child('videos/$outputFileName');

            try {
              // Set a listener to track upload progress
              await storageRef
                  .putData(compressedVideo)
                  .snapshotEvents
                  .listen((taskSnapshot) {
                // Calculate overall progress
                double uploadProgress =
                    taskSnapshot.bytesTransferred / taskSnapshot.totalBytes;
                double totalProgress = 0.5 + (uploadProgress * 0.5);

                setState(() {
                  compressionProgress = totalProgress;
                });
              }).asFuture(); // Await the upload to complete

              setState(() {
                conversionStatus = 'Upload Complete';
              });
            } catch (e) {
              setState(() {
                conversionStatus = 'Upload Failed: $e';
              });
            }
          },
        );

    // Finalize the compression progress to 50% when done
    setState(() {
      compressionProgress = 0.5; // 50% completion for compression
    });
  }

  void _onProgressHandler(ProgressParam progress) {
    setState(() {
      compressionProgress = progress.ratio;
    });
    print('Progress: ${progress.ratio * 100}%');
  }
}
