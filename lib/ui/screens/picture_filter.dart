import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:typed_data';
import 'dart:io' as Io;

class PictureFilterScreen extends StatefulWidget {
  final String imagePath;
  const PictureFilterScreen({Key key, this.imagePath}) : super(key: key);

  @override
  _PictureFilterScreenState createState() => _PictureFilterScreenState();
}

class _PictureFilterScreenState extends State<PictureFilterScreen> {

  String filteredImagePath = '';
  bool isDisplayFilteredImage = false;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text('Filter')),
      body: Image.file(
          File(isDisplayFilteredImage ? filteredImagePath : widget.imagePath)
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.filter),
        onPressed: onFilterPictureButtonPressed,
      ),
    );
  }

  void onFilterPictureButtonPressed() async {

    // 初回のみフィルター加工する
    if (filteredImagePath.isEmpty) {
      await _filterPicture().then((path) => filteredImagePath = path);
    }
    isDisplayFilteredImage = !isDisplayFilteredImage;
    setState(() {});
  }

  Future<String> _filterPicture() async {
    final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();
    final String outputPath = widget.imagePath + '_filtered.jpg';
    int rc = await _flutterFFmpeg.execute("-i ${widget.imagePath} -y -vf hue=s=0 -pix_fmt yuv420p $outputPath");
    print("FFmpeg process exited with rc $rc");
    print('filtered file path:' + outputPath);

    return outputPath;
  }
}
