import 'dart:io';

import 'package:flutter/material.dart';
import 'package:f_logs/f_logs.dart';
import 'package:extended_image/extended_image.dart';

import 'package:horopic/album/load_state_change.dart';
import 'package:horopic/utils/common_functions.dart';

class LocalImagePreview extends StatefulWidget {
  final int index;
  final List images;

  const LocalImagePreview({Key? key, required this.index, required this.images})
      : super(key: key);

  @override
  LocalImagePreviewState createState() => LocalImagePreviewState();
}

class LocalImagePreviewState extends State<LocalImagePreview> {
  int _index = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _index = widget.index;
    _pageController = PageController(initialPage: _index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: titleText('图片预览'),
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _index = index;
          });
        },
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          try {
            if (File(widget.images[index]).existsSync()) {
              return ExtendedImage.file(
                File(widget.images[index]),
                fit: BoxFit.contain,
                mode: ExtendedImageMode.gesture,
                clearMemoryCacheIfFailed: true,
                loadStateChanged: (state) =>
                    defaultLoadStateChanged(state, iconSize: 60),
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
            } else {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/empty.png',
                      width: 100,
                      height: 100,
                    ),
                    const Text('文件不存在',
                        style: TextStyle(
                            fontSize: 20,
                            color: Color.fromARGB(136, 121, 118, 118)))
                  ],
                ),
              );
            }
          } catch (e) {
            FLog.error(
                className: 'LocalImagePreviewState',
                methodName: 'build',
                text: formatErrorMessage({}, e.toString()),
                dataLogType: DataLogType.ERRORS.toString());

            return Container();
          }
        },
        itemCount: widget.images.length,
      ),
    );
  }
}
