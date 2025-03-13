import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:horopic/widgets/load_state_change.dart';
import 'package:horopic/utils/common_functions.dart';

class ImagePreview extends StatefulWidget {
  final int index;
  final List images;

  const ImagePreview({super.key, required this.index, required this.images});

  @override
  ImagePreviewState createState() => ImagePreviewState();
}

class ImagePreviewState extends State<ImagePreview> {
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
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withAlpha(200)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
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
          return ExtendedImage.network(
            widget.images[index],
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
        itemCount: widget.images.length,
      ),
    );
  }
}
