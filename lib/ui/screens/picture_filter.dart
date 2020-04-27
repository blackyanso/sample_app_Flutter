import 'dart:io';
import 'package:flutter/material.dart';
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
  PictureFilterScreenState createState() => PictureFilterScreenState();
}
class PictureFilterScreenState extends State<PictureFilterScreen> {
  WebViewController _controller;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(title: Text('Filter')),
  //     body: Image.file(File(widget.imagePath)),
  //   );
  // }

  String _base64;
  bool _notFilter = true;

  @override
  Widget build(BuildContext context) {
    print('build start');
//    _base64 = base64Encode(File(widget.imagePath).readAsBytes());

    print('fileter file path : ' + widget.imagePath);
    print('fileter flg : ' + _notFilter.toString());
    if (_notFilter) {
      final bytes = Io.File(widget.imagePath).readAsBytesSync();
      _base64 = base64Encode(bytes);
      print(_base64.substring(0, 100));
    }
    Uint8List _bytes = base64Decode(_base64);
    print('build end');

    return Scaffold(
      appBar: AppBar(
        title: Text('Filter'),
      ),
      body: ListView(
        itemExtent: 500,
        children: <Widget>[
          Image.memory(_bytes),
          WebView(
            // onWebViewCreatedはWebViewが生成された時に行う処理を記述できます
            onWebViewCreated: (WebViewController webViewController) async {
              _controller = webViewController; // 生成されたWebViewController情報を取得する
              await _loadHtmlFromAssets(); // HTMLファイルのURL（ローカルファイルの情報）をControllerに追加する処理
            },
            javascriptMode: JavascriptMode.unrestricted,
            // JSから関数を呼び出す為にjavascriptChannelsで紐付けを行う
            javascriptChannels: Set.from([
              JavascriptChannel(
                  name: "getData",
                  onMessageReceived: (JavascriptMessage result) {
                    // イベントが発動した時に呼び出したい関数
                    _changeImage(result.message);
                  }),
            ]),
          ),
        ],
      ),
      // 画面下にボタン配置
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.redAccent,
        onPressed: _addFilter,
      ),
    );
  }

  /// フィルターをかけるfunctionを呼ぶ
  void _addFilter() {
    print('_addFilter start');
    print(_base64.substring(0, 100));
    // JSメソッド呼び出し
    // WebViewControllerクラスのevaluateJavascriptの引数に呼び出すJSメソッドを入れる
    _controller.evaluateJavascript("test(\"" + _base64 + "\");");
    _notFilter = false;
    print('fileter flg : ' + _notFilter.toString());
    print('_addFilter end');
  }

  // フィルターかかったデータに入れ替え
  void _changeImage(String str) {
    print('_changeImage start');
    print(_base64.substring(0, 100));
    setState(() {
      _base64 = str.replaceFirst('data:image/jpeg;base64,', '');
    });
    print('_changeImage end');
  }

  /// HTMLファイルを読み込む処理
  Future _loadHtmlFromAssets() async {
    //　HTMLファイルを読み込んでHTML要素を文字列で返す
    String fileText = await rootBundle.loadString('assets/test.html');
    // <WebViewControllerのloadUrlメソッドにローカルファイルのURI情報を渡す>
    // WebViewControllerはWebViewウィジェットに情報を与えることができます。
    // <Uri.dataFromStringについて>
    // パラメータで指定されたエンコーディングまたは文字セット（指定されていないか認識されない場合はデフォルトでUS-ASCII）
    // を使用してコンテンツをバイトに変換し、結果のデータURIにバイトをエンコードします。
    _controller.loadUrl(Uri.dataFromString(fileText,
            mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
        .toString());
  }
}
