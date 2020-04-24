import "package:flutter/services.dart";

// iPhone用の画像切り出しChannel
class CropImageChannel {
  static const MethodChannel channel =
      MethodChannel("photo.sample.app/crop.image");

  // [iPhone用]写真の正方形切り出し
  static Future<String> squareForIPhone(String filePath) async {
    if (filePath == null) {
      return null;
    }
    try {
      var properties =
          await channel.invokeMethod('getImageProperties', <String, dynamic>{
        'filePath': filePath,
      });

      int width = properties["width"];
      var offset = (properties["height"] - properties["width"]) / 2;

      String croppedFilePath =
          await channel.invokeMethod('cropImage', <String, dynamic>{
        'filePath': filePath,
        'originX': 0,
        'originY': offset.round(),
        'width': width,
        'height': width
      });

      return croppedFilePath;
    } on PlatformException catch (e) {
      print('errorMassage:${e.message}');
      return null;
    }
  }
}
