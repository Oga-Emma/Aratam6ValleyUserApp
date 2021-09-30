import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CustomWebView extends StatefulWidget {
  final String url;

  CustomWebView({this.url});

  @override
  _CustomWebViewState createState() => _CustomWebViewState();
}

class _CustomWebViewState extends State<CustomWebView> {
  @override
  Widget build(BuildContext context) {
    print(widget.url);
    return WebView(
      initialUrl: widget.url,
      // Enable Javascript on WebView
      javascriptMode: JavascriptMode.unrestricted,
    );
  }
}
