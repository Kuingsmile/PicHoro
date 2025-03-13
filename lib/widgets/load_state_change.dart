import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';

Widget? defaultLoadStateChanged(ExtendedImageState state, {double iconSize = 16}) {
  switch (state.extendedImageLoadState) {
    case LoadState.loading:
      return Center(
        child: Center(
          child: SizedBox(
            width: iconSize,
            height: iconSize,
            child: const CircularProgressIndicator(
              strokeWidth: 2.0,
            ),
          ),
        ),
      );
    case LoadState.failed:
      return GestureDetector(
        child: Stack(
          fit: StackFit.expand,
          alignment: AlignmentDirectional.center,
          children: <Widget>[
            Icon(
              Icons.error,
              size: iconSize,
              color: Colors.grey[600],
            )
          ],
        ),
        onTap: () {
          state.reLoadImage();
        },
      );
    default:
      return null;
  }
}
