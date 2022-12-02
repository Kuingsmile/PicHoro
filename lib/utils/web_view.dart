import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:horopic/utils/common_functions.dart';

class WebViewPage extends StatefulWidget {
  final String url;
  final String title;
  final bool enableJs;

  const WebViewPage(
      {Key? key, required this.url, required this.title, this.enableJs = false})
      : super(key: key);

  @override
  WebViewPageState createState() => WebViewPageState();
}

class WebViewPageState extends State<WebViewPage> {
  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = AndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: widget.title == 'None'
            ? titleText('网页浏览')
            : titleText(widget.title),
      ),
      body: WebView(
        initialUrl: widget.url,
        javascriptMode: widget.enableJs
            ? JavascriptMode.unrestricted
            : JavascriptMode.disabled,
      ),
    );
  }
}
