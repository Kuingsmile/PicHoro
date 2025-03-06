import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

class ImageCompress {
  int minWidth = 1920;
  int minHeight = 1080;
  int quality = 80;

  Future<File> compressAndGetFile(String path, String fileName, String format,
      {int minWidth = 1920, int minHeight = 1080, int quality = 80}) async {
    this.minWidth = minWidth;
    this.minHeight = minHeight;
    this.quality = quality;
    var result = await FlutterImageCompress.compressWithFile(path,
        minWidth: minWidth,
        minHeight: minHeight,
        quality: quality,
        rotate: 0,
        format: format == 'jpg'
            ? CompressFormat.jpeg
            : format == 'png'
                ? CompressFormat.png
                : CompressFormat.webp);
    var dir = await getTemporaryDirectory();
    String fileNameWithoutExtension = fileName.split('.').first;
    var targetPath = "${dir.absolute.path}/$fileNameWithoutExtension.$format";
    if (result != null) {
      File targetFile = File(targetPath);
      targetFile.writeAsBytesSync(result);
      return targetFile;
    } else {
      return File(path);
    }
  }
}
