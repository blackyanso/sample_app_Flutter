import 'dart:io';
import 'package:flutter/material.dart';

class PictureFilterScreen extends StatelessWidget {
  final String imagePath;
  const PictureFilterScreen({Key key, this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Filter')),
      body: Image.file(File(imagePath)),
    );
  }
}
