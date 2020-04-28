import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_exif_rotation/flutter_exif_rotation.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:sample_app_Flutter/ui/commons/square_camera_preview.dart';
import 'package:sample_app_Flutter/ui/screens/picture_filter.dart';
import 'package:sample_app_Flutter/ui/screens/picture_filter_webview.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import "package:intl/intl.dart";

import 'native_channels/crop_image.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final cameras = await availableCameras();

  final firstCamera = cameras.first;

  runApp(
    MaterialApp(
      theme: ThemeData.dark(),
      home: TakePictureScreen(camera: firstCamera),
    ),
  );
}

class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;

  const TakePictureScreen({
    Key key,
    @required this.camera,
  }) : super(key: key);

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;
  String videoPath;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.camera, ResolutionPreset.medium);

    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(title: Text('Take a picture!')),
        body: FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return SquareCameraPreview(
                    cameraPreview: CameraPreview(_controller),
                    size: width,
                    aspectRatio: _controller.value.aspectRatio);
              } else {
                return Center(child: CircularProgressIndicator());
              }
            }),
        floatingActionButton: Column(
          verticalDirection: VerticalDirection.up, // childrenの先頭を下に配置
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            FloatingActionButton(
                heroTag: "hero1",
                backgroundColor: Colors.redAccent,
                child: Icon(Icons.camera_alt),
                onPressed: onTakePictureButtonPressed),
            Container(
              // 余白のためContainerでラップ
              margin: EdgeInsets.only(bottom: 16.0),
              child: FloatingActionButton(
                heroTag: "hero2",
                backgroundColor: Colors.amberAccent,
                onPressed: onTakePictureWebViewButtonPressed,
              ),
            ),
            Container(
              // 余白のためContainerでラップ
              margin: EdgeInsets.only(bottom: 16.0),
              child: FloatingActionButton(
                heroTag: "hero3",
                backgroundColor: Colors.blue,
                child: Icon(Icons.movie),
                onPressed: _controller.value.isRecordingVideo
                    ? onStopButtonPressed
                    : onVideoRecordButtonPressed,
              ),
            ),
          ],
        ));
  }

  void onTakePictureButtonPressed() {
    _takePicture()
        .then((path) => _fixExif(path))
        .then((path) => _cropPhoto(path))
        .then((String filePath) {
      if (filePath != null) {
        print('preview file path:' + filePath);
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PictureFilterScreen(imagePath: filePath),
            ));
      } else {
        print("file path is empty");
      }
    });
  }

  void onTakePictureWebViewButtonPressed() {
    _takePicture()
        .then((path) => _fixExif(path))
        .then((path) => _cropPhoto(path))
        .then((String filePath) {
      if (filePath != null) {
        print('preview file path:' + filePath);
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  PictureFilterWebViewScreen(imagePath: filePath),
            ));
      } else {
        print("file path is empty");
      }
    });
  }

  void onVideoRecordButtonPressed() {
    _startVideoRecording().then((String filePath) {
      if (mounted) setState(() {});
      if (filePath != null) print(filePath);
      print('録画終了');
      print('onVideoRecordButtonPressed then');
    });
  }

  void onStopButtonPressed() {
    _stopVideoRecording().then((_) {
      if (mounted) setState(() {});
      print('onStopButtonPressed then');
    });
  }

  Future<String> _fixExif(String filePath) async {
    if (Platform.isAndroid) {
      File image = await FlutterExifRotation.rotateAndSaveImage(path: filePath);
      return image.path;
    } else {
      return filePath;
    }
  }

  Future<String> _takePicture() async {
    final Directory extDir = await getTemporaryDirectory();
    // ファイル名にスペースがあるとffmpegで取り扱えないため、datetimeからスペースを取り除く
    final String now = DateFormat('yyyyMMddHHmmss').format(DateTime.now());
    final String filePath = join(extDir.path, now + '.jpg');
    if (_controller.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }
    try {
      await _controller.takePicture(filePath);
    } on CameraException catch (e) {
      // should show error on display.
      print(e);
      return null;
    }
    return filePath;
  }

  Future<String> _startVideoRecording() async {
    print('_startVideoRecording start');
    if (!_controller.value.isInitialized) {
      print('Error: select a camera first.');
      return null;
    }
    final Directory extDir = await getTemporaryDirectory();
    final String dirPath = '${extDir.path}/Movies/sample_app';
    final String now = DateFormat('yyyyMMddHHmmss').format(DateTime.now());
    await Directory(dirPath).create(recursive: true);
    final String filePath = join(dirPath, now + '.mp4');

    if (_controller.value.isRecordingVideo) {
      // A recording is already started, do nothing.
      return null;
    }

    try {
      videoPath = filePath;
      print('startVideoRecording ...');
      await _controller.startVideoRecording(filePath);
      print('... startVideoRecording');
    } on CameraException catch (e) {
      print(e);
      return null;
    }
    return filePath;
  }

  Future<void> _stopVideoRecording() async {
    print('_stopVideoRecording start');
    if (!_controller.value.isRecordingVideo) {
      return null;
    }

    try {
      await _controller.stopVideoRecording();
    } on CameraException catch (e) {
      print(e);
      return null;
    }
    return null;
  }

  Future<String> _cropPhoto(String filePath) async {
    if (Platform.isIOS) {
      return CropImageChannel.squareForIPhone(filePath);
    } else {
      // Crop処理がAndroidでコケるので一旦コメントアウト
      // return _cropPhotoForAndroid(filePath);
      return filePath;
    }
  }

  // [Android用]写真の切り出し
  // iOSではうまく動作しないので使用しないこと
  // https://github.com/btastic/flutter_native_image/issues/22
  Future<String> _cropPhotoForAndroid(String filePath) async {
    if (filePath == null) {
      return null;
    }
    ImageProperties properties =
        await FlutterNativeImage.getImageProperties(filePath);

    int width = properties.width;
    var offset = (properties.height - properties.width) / 2;

    File croppedFile = await FlutterNativeImage.cropImage(
        filePath, 0, offset.round(), width, width);
    return croppedFile.path;
  }
}
