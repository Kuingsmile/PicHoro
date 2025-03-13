enum VideoType {
  asset,
  file,
  network,
}

class VideoData {
  final String name;
  final String path;
  final String subtitlePath;
  final VideoType type;

  VideoData({
    required this.name,
    required this.path,
    required this.subtitlePath,
    required this.type,
  });
}
