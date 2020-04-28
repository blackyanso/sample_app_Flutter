import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';

class MovieFilterScreen extends StatefulWidget {
  final String imagePath;
  final String videoPath;
  const MovieFilterScreen({Key key, this.imagePath, this.videoPath})
      : super(key: key);

  @override
  _MovieFilterScreenState createState() => _MovieFilterScreenState();
}

class _MovieFilterScreenState extends State<MovieFilterScreen> {
  String filteredImagePath = '';
  String filteredVideoPath = '';
  bool isDisplayFilteredImage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Movie Filter')),
        body: Image.file(File(
            isDisplayFilteredImage ? filteredImagePath : widget.imagePath)),
        floatingActionButton: Column(
          verticalDirection: VerticalDirection.up, // childrenの先頭を下に配置
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            FloatingActionButton(
                heroTag: "hero1",
                backgroundColor: Colors.redAccent,
                child: Icon(Icons.camera_alt),
                onPressed: onFilterPictureButtonPressed),
            Container(
              // 余白のためContainerでラップ
              margin: EdgeInsets.only(bottom: 16.0),
              child: FloatingActionButton(
                  heroTag: "hero2",
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.movie),
                  onPressed: onFilterVideoButtonPressed),
            ),
          ],
        ));
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
    int rc = await _flutterFFmpeg.execute(
        "-i ${widget.imagePath} -y -vf hue=s=0 -pix_fmt yuv420p $outputPath");
    print("FFmpeg process exited with rc $rc");
    print('filtered picture file path:' + outputPath);

    return outputPath;
  }

  void onFilterVideoButtonPressed() async {
    // 初回のみフィルター加工する
    if (filteredVideoPath.isEmpty) {
      await _filterVideo();
    }
    setState(() {});
  }

  Future<String> _filterVideo() async {
    final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();
    final String outputPath =
        widget.videoPath.replaceAll('.mp4', '') + '_filtered.mp4';
    print("video input:" + widget.videoPath);
    int rc = await _flutterFFmpeg.execute(
        "-i ${widget.videoPath} -y -vf hue=s=0 -pix_fmt yuv420p $outputPath");
    print("FFmpeg process exited with rc $rc");
    print('filtered movie file path:' + outputPath);

    return outputPath;
  }
}
