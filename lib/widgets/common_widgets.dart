import 'package:flutter/material.dart';

Widget getFlexibleSpace(BuildContext context) {
  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withValues(alpha: 0.8)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
  );
}
