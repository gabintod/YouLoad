import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class VideoSource extends StatelessWidget {
  final StreamManifest manifest;
  final Function(VideoOnlyStreamInfo) onSelect;
  final Function()? onBack;
  final Function()? onNoSource;
  final bool showBackButton;
  final bool showNoSourceButton;

  const VideoSource({Key? key, required this.manifest, required this.onSelect, this.onBack, this.onNoSource, this.showBackButton = true, this.showNoSourceButton = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'Video source',
            style: Theme.of(context).textTheme.headline5,
          ),
        ),
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: manifest.videoOnly.length,
            itemBuilder: (context, index) {
              VideoOnlyStreamInfo info = manifest.videoOnly[index];

              return ListTile(
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
                onTap: () => onSelect(info),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: Row(
            children: [
              TextButton(
                child: const Text('Back'),
                onPressed: onBack,
              ),
              const Spacer(),
              OutlinedButton(
                child: const Text('No video'),
                onPressed: onNoSource,
              ),
            ],
          ),
        ),
      ],
    );
  }
}