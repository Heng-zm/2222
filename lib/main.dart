import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LoadUrlInApp extends StatelessWidget {
  final String url;

  const LoadUrlInApp({Key? key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('In-App Webview'),
      ),
      body: WebView(
        initialUrl: url,
        javascriptMode: JavascriptMode.unrestricted, // Adjust as needed
      ),
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      home: LoadUrlInApp(
          url:
              'https://heng-zm.github.io/tretr.github.io/oo.html'), // Replace with your desired URL
    ),
  );
}
