import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_avif/flutter_avif.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:horopic/utils/common_functions.dart';
import 'package:path_provider/path_provider.dart';

Future<File> compressAndGetFile(String path, String fileName, String format,
    {int minWidth = 1920, int minHeight = 1080, int quality = 80}) async {
  try {
    Uint8List? result;

    if (format == 'avif') {
      result = await encodeAvif(await File(path).readAsBytes());
    } else {
      CompressFormat compressFormat = {
            'jpg': CompressFormat.jpeg,
            'png': CompressFormat.png,
          }[format] ??
          CompressFormat.webp;

      result = await FlutterImageCompress.compressWithFile(path,
          minWidth: minWidth, minHeight: minHeight, quality: quality, rotate: 0, format: compressFormat);
    }

    if (result != null) {
      var dir = await getTemporaryDirectory();
      String fileNameWithoutExtension = fileName.split('.').first;
      String targetPath = "${dir.absolute.path}/$fileNameWithoutExtension.$format";
      return File(targetPath)..writeAsBytesSync(result);
    }

    return File(path);
  } catch (e) {
    flogErr(
        e,
        {
          'path': path,
          'fileName': fileName,
          'format': format,
          'minWidth': minWidth,
          'minHeight': minHeight,
          'quality': quality
        },
        'ImageCompressor',
        'compressAndGetFile');
    return File(path);
  }
}
