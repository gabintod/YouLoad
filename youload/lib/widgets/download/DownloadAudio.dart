import 'dart:io';

import 'package:flutter/material.dart';
import 'package:youload/main.dart';
import 'package:youload/widgets/download/DownloadPage.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class DownloadAudio extends StatefulWidget {
  final Video video;
  final AudioOnlyStreamInfo streamInfo;
  final Function(File?)? onDownloaded;
  final Function(dynamic)? onDownloadError;

  const DownloadAudio(
      {Key? key,
      required this.video,
      required this.streamInfo,
      required this.onDownloaded,
      required this.onDownloadError})
      : super(key: key);

  @override
  _DownloadAudioState createState() => _DownloadAudioState();
}

class _DownloadAudioState extends State<DownloadAudio> {
  double? _audioDownloadProgress;

  @override
  Widget build(BuildContext context) {
    download();

    return WillPopScope(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Downloading audio...',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              LinearProgressIndicator(value: _audioDownloadProgress),
            ],
          ),
        ),
      ),
      onWillPop: () async {
        bool? cancelDownload = await showDialog<bool?>(
          context: context,
          builder: (context) => AlertDialog(
            content: const Text('Cancel download'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Yes'),
              ),
            ],
          ),
        );

        return cancelDownload != null && cancelDownload == true;
      },
    );
  }

  Future<void> download() async {
    try {
      File? audioFile = await DownloadPage.downloadStream(
        widget.video,
        widget.streamInfo,
        YouLoad.of(context).youtubeExplode,
        onProgress: (progress) {
          if (mounted) {
            setState(() {
              _audioDownloadProgress = progress;
            });
          }
        },
      );

      widget.onDownloaded?.call(audioFile);
    } catch(e) {
      widget.onDownloadError?.call(e);
    }
  }
}
