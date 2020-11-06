import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class VideoRecorder extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => VideoRecorderState();
}

class VideoRecorderState extends State<VideoRecorder> {
  List<CameraDescription> cameras;
  CameraController controller;

  @override
  void initState() {
    super.initState();
    availableCameras().then((value) {
      cameras = value;
      controller = CameraController(getFrontCamera(), ResolutionPreset.high);
      controller.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller.value.isInitialized) {
      return Container();
    }

    return Scaffold(
        appBar: AppBar(
          title: Text('Video Recorder'),
        ),
        body: AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: CameraPreview(controller)),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: () => startVideoRecording(),
              tooltip: 'Start recording',
              child: Icon(Icons.camera_alt),
            ),
            FloatingActionButton(
              onPressed: () => stopVideoRecording(),
              tooltip: 'Stop recording',
              child: Icon(Icons.camera_alt),
            ),
          ],
        ));
  }

  CameraDescription getFrontCamera() {
    return cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front);
  }

  String getTimestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  Future<void> startVideoRecording() async {
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Movies/flutter_camera';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${getTimestamp()}.mp4';

    if (controller.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      print("recording video to " + filePath);
      await controller.startVideoRecording(filePath);
      // setState(() {
      //   _filePath = filePath;
      // });
    } on CameraException catch (e) {
      print(e);
    }
  }

  Future<void> stopVideoRecording() async {
    if (!controller.value.isRecordingVideo) {
      return null;
    }

    try {
      await controller.stopVideoRecording();
      print("stopVideoRecording");
      // setState(() {
      //   _showBottomSheet(context);
      // });
    } on CameraException catch (e) {
      print(e);
    }
  }
}
