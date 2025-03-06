import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:external_path/external_path.dart';
import 'package:extended_image/extended_image.dart';
import 'package:horopic/album/load_state_change.dart';
import 'package:horopic/utils/common_functions.dart';

class AuthorInformation extends StatelessWidget {
  const AuthorInformation({super.key});

  final String qrCodeUrl = 'https://pichoro.msq.pub/wechat.png';

  Future<void> _saveQRCodeToGallery(BuildContext context) async {
    try {
      var path = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DCIM);
      await Dio().download(qrCodeUrl, '$path/wechat_picHoro.png');
      showToast('保存成功');
    } catch (e) {
      showToast('保存失败: ${e.toString()}');
    }
  }

  void _showSaveConfirmDialog(BuildContext context) {
    showCupertinoAlertDialogWithConfirmFunc(
        context: context,
        title: '保存到相册',
        content: '是否保存到相册？',
        onConfirm: () {
          Navigator.pop(context);
          _saveQRCodeToGallery(context);
        });
  }

  GestureConfig _getGestureConfig(ExtendedImageState state) {
    return GestureConfig(
        minScale: 0.9,
        animationMinScale: 0.7,
        maxScale: 3.0,
        animationMaxScale: 3.5,
        speed: 1.0,
        inertialSpeed: 100.0,
        initialScale: 1.0,
        inPageView: true);
  }

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
          const SizedBox(height: 50),
          GestureDetector(
              onTap: () => _showSaveConfirmDialog(context),
              onLongPress: () => _saveQRCodeToGallery(context),
              child: Center(
                child: ExtendedImage.network(
                  qrCodeUrl,
                  fit: BoxFit.contain,
                  mode: ExtendedImageMode.gesture,
                  cache: false,
                  loadStateChanged: (state) => defaultLoadStateChanged(state, iconSize: 60),
                  initGestureConfigHandler: _getGestureConfig,
                ),
              )),
          const SizedBox(height: 15),
          Center(
            child: Text(
              '点击或长按二维码可保存到相册',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ],
      )),
    );
  }
}
