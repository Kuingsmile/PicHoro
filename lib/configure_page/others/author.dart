import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:external_path/external_path.dart';
import 'package:extended_image/extended_image.dart';
import 'package:horopic/album/load_state_change.dart';
import 'package:horopic/utils/common_functions.dart';

class AuthorInformation extends StatelessWidget {
  const AuthorInformation({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          title: titleText('交流群-长按保存二维码'),
        ),
        body: Center(
            child: ListView(
          padding: const EdgeInsets.all(10),
          children: [
            const SizedBox(
              height: 50,
            ),
            GestureDetector(
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
                        String fileurl = 'https://pichoro.msq.pub/wechat.png';
                        try {
                          await Dio().download(fileurl, '$path/wechat.png');
                          showToast('保存成功');
                        } catch (e) {
                          showToast('保存失败');
                        }
                      });
                },
                child: Center(
                  child: ExtendedImage.network(
                    'https://pichoro.msq.pub/wechat.png',
                    fit: BoxFit.contain,
                    mode: ExtendedImageMode.gesture,
                    cache: false,
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
                  ),
                )),
          ],
        )));
  }
}
