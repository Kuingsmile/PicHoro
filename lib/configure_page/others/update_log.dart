import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:extended_image/extended_image.dart';

import 'package:horopic/album/load_state_change.dart';
import 'package:horopic/utils/common_functions.dart';

class UpdateLog extends StatefulWidget {
  const UpdateLog({Key? key}) : super(key: key);

  @override
  UpdateLogState createState() => UpdateLogState();
}

class UpdateLogState extends State<UpdateLog> {
  late Future<String> _future;

  @override
  void initState() {
    super.initState();
    _future = rootBundle.loadString('assets/files/UpdateLog.md');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: titleText(
          '更新日志',
        ),
      ),
      body: FutureBuilder(
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
      ),
    );
  }
}
