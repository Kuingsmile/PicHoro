import 'dart:io';

import 'package:flutter/material.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:path_provider/path_provider.dart';

import 'package:horopic/utils/common_functions.dart';

class SFTPLocalImagePreview extends StatefulWidget {
  final Map configMap;
  final String image;

  const SFTPLocalImagePreview({super.key, required this.configMap, required this.image});

  @override
  SFTPLocalImagePreviewState createState() => SFTPLocalImagePreviewState();
}

class SFTPLocalImagePreviewState extends State<SFTPLocalImagePreview> {
  String filePath = '';

  downloadFile() async {
    try {
      String ftpHost = widget.configMap['ftpHost'];
      String ftpPort = widget.configMap['ftpPort'];
      String ftpUser = widget.configMap['ftpUser'];
      String ftpPassword = widget.configMap['ftpPassword'];
      final socket = await SSHSocket.connect(ftpHost, int.parse(ftpPort));
      final client = SSHClient(
        socket,
        username: ftpUser,
        onPasswordRequest: () {
          return ftpPassword;
        },
      );
      final sftp = await client.sftp();
      String tempDir = (await getTemporaryDirectory()).path;
      String fileName = widget.configMap['name'];
      var file = File('$tempDir/$fileName');
      if (file.existsSync()) {
        file.deleteSync();
      }
      var remoteFile = await sftp.open(widget.image, mode: SftpFileOpenMode.read);
      file.writeAsBytesSync(await remoteFile.readBytes());
      return file.path;
    } catch (e) {
      flogErr(e, {}, 'SFTPLocalImagePreviewState', 'downloadFile');
    }
  }

  @override
  void initState() {
    super.initState();
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
              colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withAlpha(204)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: FutureBuilder(
        future: downloadFile(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            filePath = snapshot.data.toString();
            return Center(child: Image.file(File(filePath), fit: BoxFit.contain, width: double.infinity));
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
