import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:external_path/external_path.dart';
import 'package:horopic/utils/common_functions.dart';

class AuthorInformation extends StatelessWidget {
  const AuthorInformation({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          title: const Text('作者信息'),
        ),
        body: Center(
            child: ListView(
          padding: const EdgeInsets.all(10),
          children: [
            const SizedBox(
              height: 50,
            ),
            GestureDetector(
                //save to  album
                onTap: () async {
                  showCupertinoAlertDialogWithConfirmFunc(
                      context: context,
                      title: '保存到相册',
                      content: '是否保存到相册？',
                      onConfirm: () async {
                        Navigator.pop(context);
                        var path = await ExternalPath
                            .getExternalStoragePublicDirectory(
                                ExternalPath.DIRECTORY_DCIM);
                        var assetFilePath = '$path/PicHoro_author.jpg';
                        String assetPath = 'assets/qq_author.jpg';
                        File assetFile = File(assetFilePath);
                        if (!assetFile.existsSync()) {
                          ByteData data = await rootBundle.load(assetPath);
                          List<int> bytes = data.buffer.asUint8List(
                              data.offsetInBytes, data.lengthInBytes);
                          await assetFile.writeAsBytes(bytes);
                        }
                        showToast('保存成功');
                      });
                },
                child: Center(
                  child: Image.asset(
                    'assets/qq_author.jpg',
                    width: 400,
                    height: 300,
                  ),
                )),
          ],
        )));
  }
}
