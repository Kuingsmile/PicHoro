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

Widget getLeadingIcon(BuildContext context) {
  return IconButton(
    icon: const Icon(
      Icons.arrow_back_ios,
      size: 20,
      color: Colors.white,
    ),
    onPressed: () {
      Navigator.pop(context);
    },
  );
}
