import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:horopic/widgets/common_widgets.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter_text_viewer/flutter_text_viewer.dart';

import 'package:horopic/widgets/load_state_change.dart';
import 'package:horopic/utils/common_functions.dart';

class MarkDownPreview extends StatefulWidget {
  final String filePath;
  final String fileName;
  const MarkDownPreview({
    super.key,
    required this.filePath,
    required this.fileName,
  });

  @override
  MarkDownPreviewState createState() => MarkDownPreviewState();
}

class MarkDownPreviewState extends State<MarkDownPreview> {
  late Future<String> _future;

  @override
  void initState() {
    super.initState();
    if (widget.filePath.split(".").last == "md") {
      _future = File(widget.filePath).readAsString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: titleText(widget.fileName),
        flexibleSpace: getFlexibleSpace(context),
      ),
      body: widget.filePath.split(".").last == "md"
          ? FutureBuilder(
              future: _future,
              builder: (context, AsyncSnapshot<String> snapshot) {
                if (snapshot.hasData) {
                  return Markdown(
                    data: snapshot.data!,
                    selectable: true,
                    imageBuilder: (uri, title, alt) {
                      return ExtendedImage.network(
                        uri.toString(),
                        fit: BoxFit.contain,
                        mode: ExtendedImageMode.gesture,
                        cache: true,
                        loadStateChanged: (state) => defaultLoadStateChanged(state, iconSize: 60),
                        initGestureConfigHandler: (state) {
                          return GestureConfig(
                              minScale: 0.9,
                              animationMinScale: 0.7,
                              maxScale: 3.0,
                              animationMaxScale: 3.5,
                              speed: 1.0,
                              inertialSpeed: 100.0,
                              initialScale: 1.0,
                              inPageView: true);
                        },
                      );
                    },
                    onTapLink: (text, href, title) async {
                      Uri url = Uri.parse(href!);
                      await launchUrl(url);
                    },
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            )
          : TextViewerPage(
              textViewer: TextViewer.file(
                widget.filePath,
                textStyle: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12.0,
                  height: 1.4,
                ),
              ),
            ),
    );
  }
}
