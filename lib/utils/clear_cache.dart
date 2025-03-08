import 'dart:io';
import 'package:path_provider/path_provider.dart';

class CacheUtil {
  static Future<String> total() async {
    Directory tempDir = await getTemporaryDirectory();
    int total = await _reduce(tempDir);
    return (total / 1024 / 1024).toStringAsFixed(2);
  }

  static Future<void> clear() async {
    Directory tempDir = await getTemporaryDirectory();
    await _delete(tempDir);
  }

  static Future<int> _reduce(final FileSystemEntity file) async {
    if (file is File) {
      return await file.length();
    }

    if (file is Directory) {
      final List<FileSystemEntity> children = file.listSync();
      int total = 0;
      if (children.isNotEmpty) {
        for (final FileSystemEntity child in children) {
          total += await _reduce(child);
        }
      }
      return total;
    }
    return 0;
  }

  static Future<void> _delete(FileSystemEntity file) async {
    if (file is Directory) {
      final List<FileSystemEntity> children = file.listSync();
      for (final FileSystemEntity child in children) {
        await _delete(child);
      }
    } else {
      await file.delete();
    }
  }
}
