import 'package:flutter/material.dart';

showAlertDialog({
  bool? barrierDismissible,
  required BuildContext context,
  required String title,
  required String content,
}) {
  return showDialog(
      context: context,
      barrierDismissible: barrierDismissible == true ? true : false,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.only(left: 20, right: 20),
          title: Center(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 23.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          content: Container(
            height: 200,
            width: 300,
            child: ListView(
              children: [
                const SizedBox(
                  height: 20,
                ),
                Text(content)
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Center(
                child: Text(
                  '确  定',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      });
}
