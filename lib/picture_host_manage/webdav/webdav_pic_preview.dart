import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:horopic/widgets/common_widgets.dart';
import 'package:horopic/widgets/load_state_change.dart';
import 'package:horopic/utils/common_functions.dart';

class WebdavImagePreview extends StatefulWidget {
  final int index;
  final List images;
  final List headersList;

  const WebdavImagePreview({super.key, required this.index, required this.images, required this.headersList});

  @override
  WebdavImagePreviewState createState() => WebdavImagePreviewState();
}

class WebdavImagePreviewState extends State<WebdavImagePreview> {
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
        flexibleSpace: getFlexibleSpace(context),
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
            headers: Map<String, String>.from(widget.headersList[index]),
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
