import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

// 正方形写真プレビュー
// https://ja.coder.work/so/camera/936842
// https://inducesmile.com/google-flutter/how-to-square-crop-a-flutter-camera-preview/
class SquareCameraPreview extends StatelessWidget {
  final CameraPreview cameraPreview;
  final double size;
  final double aspectRatio;
  const SquareCameraPreview(
      {Key key, this.cameraPreview, this.size, this.aspectRatio})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: size,
        height: size,
        child: ClipRect(
          child: OverflowBox(
            alignment: Alignment.center,
            child: FittedBox(
              fit: BoxFit.fitWidth,
              child: Container(
                width: size,
                height: size / aspectRatio,
                child: cameraPreview, // this is my CameraPreview
              ),
            ),
          ),
        ));
  }
}
