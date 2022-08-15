import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class Youloader {
  static Youloader? _instance;

  late final YoutubeExplode ye;

  Youloader._() {
    ye = YoutubeExplode();
  }

  factory Youloader() {
    _instance ??= Youloader._();

    return _instance!;
  }

  Future<Video> getInfo(String url) => ye.videos.get(url);

  Future downloadAudio(String url, {Video? videoInfo}) async {
    videoInfo ??= await getInfo(url);
    StreamManifest manifest = await ye.videos.streamsClient.getManifest(url);

    StreamInfo streamInfo = manifest.audioOnly.withHighestBitrate();
    Stream<List<int>> stream = ye.videos.streamsClient.get(streamInfo);

    String fileName = videoInfo.title;
    Directory directory = Directory('/storage/emulated/0/DCIM/Youload/Music');

    if (!directory.existsSync()) {
      await directory.create(recursive: true);
      print('"${directory.path}" folder created');
    }

    File file = File('${directory.path}/$fileName.${streamInfo.container}');

    int i = 0;
    while (file.existsSync()) {
      i ++;
      file = File('${directory.path}/$fileName ($i).${streamInfo.container}');
    }

    print(file.path);

    IOSink fileStream = file.openWrite();
    await stream.pipe(fileStream);
    await fileStream.flush();
    await fileStream.close();
  }

  Future downloadVideo(String url, {Video? videoInfo}) async {
    videoInfo ??= await getInfo(url);
    StreamManifest manifest = await ye.videos.streamsClient.getManifest(url);

    StreamInfo streamInfo = manifest.muxed.withHighestBitrate();
    Stream<List<int>> stream = ye.videos.streamsClient.get(streamInfo);

    String fileName = videoInfo.title;
    Directory directory = Directory('/storage/emulated/0/DCIM/Youload/Video');

    if (!directory.existsSync()) {
      await directory.create(recursive: true);
      print('"${directory.path}" folder created');
    }

    File file = File('${directory.path}/$fileName.${streamInfo.container}');

    int i = 0;
    while (file.existsSync()) {
      i ++;
      file = File('${directory.path}/$fileName ($i).${streamInfo.container}');
    }

    print(file.path);

    IOSink fileStream = file.openWrite();
    await stream.pipe(fileStream);
    await fileStream.flush();
    await fileStream.close();
  }
}