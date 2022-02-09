import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:youload/main.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class StreamsListDialog extends StatefulWidget {
  final Video video;
  final Function(VideoOnlyStreamInfo)? onVideoDownload;
  final Function(AudioOnlyStreamInfo)? onAudioDownload;

  const StreamsListDialog(this.video, {Key? key, this.onVideoDownload, this.onAudioDownload}) : super(key: key);

  @override
  _StreamsListDialogState createState() => _StreamsListDialogState();
}

class _StreamsListDialogState extends State<StreamsListDialog> {
  int iType = 0;
  StreamManifest? streamManifest;
  UnmodifiableListView<VideoOnlyStreamInfo>? videosInfo;
  UnmodifiableListView<AudioOnlyStreamInfo>? audiosInfo;

  @override
  void initState() {
    YouLoad.of(context)
        .youtubeExplode
        .videos
        .streamsClient
        .getManifest(widget.video.id)
        .then((manifest) {
      if (!mounted) return;

      setState(() {
        streamManifest = manifest;
        videosInfo = manifest.videoOnly;
        audiosInfo = manifest.audioOnly;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      contentPadding: const EdgeInsets.all(20),
      children: [
        Text(
          htmlEscape.convert(widget.video.title),
          style: Theme.of(context).textTheme.headline5,
        ),
        Wrap(
          spacing: 10,
          children: [
            ChoiceChip(
              label: const Text('Video'),
              selected: iType == 0,
              onSelected: (_) => setState(() => iType = 0),
            ),
            ChoiceChip(
              label: const Text('Audio'),
              selected: iType == 1,
              onSelected: (_) => setState(() => iType = 1),
            ),
          ],
        ),
        if (videosInfo != null && iType == 0)
          ...videosInfo!
              .map<Widget>(
                (info) => ListTile(
                  leading: const Icon(Icons.ondemand_video),
                  title: Text(info.videoQualityLabel),
                  subtitle: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(info.videoResolution.toString()),
                      Text(info.container.name),
                      Text(info.size.toString()),
                    ],
                  ),
                  onTap: () => widget.onVideoDownload?.call(info),
                ),
              )
              .toList(),
        if (audiosInfo != null && iType == 1)
          ...audiosInfo!
              .map<Widget>(
                (info) => ListTile(
                  leading: const Icon(Icons.music_note),
                  title: Text(info.qualityLabel),
                  subtitle: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(info.container.name),
                      Text(info.size.toString()),
                    ],
                  ),
                  onTap: () => widget.onAudioDownload?.call(info),
                ),
              )
              .toList(),
        if (streamManifest == null)
          const AspectRatio(
            aspectRatio: 1,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}
