import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:sample_app_Flutter/ui/commons/square_camera_preview.dart';
import 'package:sample_app_Flutter/ui/screens/picture_filter.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import "package:intl/intl.dart";
import 'package:intl/date_symbol_data_local.dart';

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
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.camera_alt),
            onPressed: onTakePictureButtonPressed));
  }

  void onTakePictureButtonPressed() {
    _takePicture().then((path) => _cropPhoto(path)).then((String filePath) {
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

  Future<String> _cropPhoto(String filePath) async {
    if (Platform.isIOS) {
      return CropImageChannel.squareForIPhone(filePath);
    } else {
      return _cropPhotoForAndroid(filePath);
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
