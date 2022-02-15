import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class AudioSource extends StatelessWidget {
  final StreamManifest manifest;
  final Function(AudioOnlyStreamInfo) onSelect;
  final Function()? onBack;
  final Function()? onNoSource;
  final bool showBackButton;
  final bool showNoSourceButton;

  const AudioSource(
      {Key? key,
      required this.manifest,
      required this.onSelect,
      this.onBack,
      this.onNoSource,
      this.showBackButton = true,
      this.showNoSourceButton = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'Audio source',
            style: Theme.of(context).textTheme.headline5,
          ),
        ),
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: manifest.audioOnly.length,
            itemBuilder: (context, index) {
              AudioOnlyStreamInfo info = manifest.audioOnly[index];

              return ListTile(
                leading: const Icon(Icons.music_note),
                title: Text(info.qualityLabel),
                subtitle: Text(info.container.name),
                trailing: Text(info.size.toString()),
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
                child: const Text('No audio'),
                onPressed: onNoSource,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
