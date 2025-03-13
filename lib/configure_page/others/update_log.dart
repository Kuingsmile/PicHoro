import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:extended_image/extended_image.dart';

import 'package:horopic/widgets/load_state_change.dart';
import 'package:horopic/utils/common_functions.dart';

class UpdateLog extends StatefulWidget {
  const UpdateLog({super.key});

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
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withValues(alpha: 0.8)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: FutureBuilder(
        future: _future,
        builder: (context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData) {
            return Markdown(
              data: snapshot.data!,
              selectable: true,
              padding: const EdgeInsets.all(16.0),
              styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                h1: Theme.of(context).textTheme.headlineMedium,
                h2: Theme.of(context).textTheme.titleLarge,
                h3: Theme.of(context).textTheme.titleMedium,
                p: Theme.of(context).textTheme.bodyMedium,
                blockquote: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                      fontStyle: FontStyle.italic,
                    ),
                code: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      fontFamily: 'monospace',
                    ),
                codeblockDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
              softLineBreak: true,
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
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
                await launchUrl(url, mode: LaunchMode.externalApplication);
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
