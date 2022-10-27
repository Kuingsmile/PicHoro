import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'dart:io';

class LocalImagePreview extends StatefulWidget {
  final int index;
  final List images;

  LocalImagePreview({Key? key, required this.index, required this.images})
      : super(key: key);

  @override
  _LocalImagePreviewState createState() => _LocalImagePreviewState();
}

class _LocalImagePreviewState extends State<LocalImagePreview> {
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
        title: const Text('图片预览'),
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
            return ExtendedImage.file(
              File(widget.images[index]),
              fit: BoxFit.contain,
              mode: ExtendedImageMode.gesture,
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
          } catch (e) {
            return Container();
          }
        },
        itemCount: widget.images.length,
      ),
    );
  }
}
