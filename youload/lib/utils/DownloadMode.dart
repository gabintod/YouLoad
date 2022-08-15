enum DownloadMode {
  audio,
  video,
}

extension DownloadModeExtension on DownloadMode {
  String get name => [
        'Audio',
        'Video',
      ][index];
}
