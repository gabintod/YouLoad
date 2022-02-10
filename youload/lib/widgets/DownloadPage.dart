import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:youload/main.dart';
import 'package:youload/utils/Config.dart';
import 'package:youload/widgets/utils/Carousel.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class DownloadPage extends StatefulWidget {
  final Video video;

  const DownloadPage({Key? key, required this.video}) : super(key: key);

  @override
  _DownloadPageState createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  final _formKey = GlobalKey<FormState>();
  final _folderPathController = TextEditingController();
  String? _defaultFolderPath;
  String? _defaultFileName;

  String? get _defaultFileFormat => (_videoStream ?? _audioStream)?.container.name;

  int _index = 0;
  StreamManifest? _streamManifest;
  VideoOnlyStreamInfo? _videoStream;
  AudioOnlyStreamInfo? _audioStream;
  Directory? _downloadDirectory;
  String? _fileName;
  String? _fileFormat;

  double? _videoDownloadProgress;
  double? _audioDownloadProgress;
  double? _mergingSourcesProgress;
  double? _encodingOutputProgress;

  File? _videoTempFile;
  File? _audioTempFile;
  File? _mergingTempFile;
  File? _outputFile;

  @override
  void initState() {
    YouLoad.of(context).youtubeExplode.videos.streamsClient.getManifest(widget.video.id).then((manifest) {
      if (!mounted) return null;

      setState(() {
        _streamManifest = manifest;
        _index = 1;
      });
    });

    Config.getInstance().then((config) {
      _defaultFolderPath = config.downloadDirectory?.path;

      if (_defaultFolderPath != null) {
        _folderPathController.text = _defaultFolderPath!;
      }
    });
    _defaultFileName = htmlEscape.convert(widget.video.title);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Download'),
        ),
        body: Carousel(
          index: _index,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: const [
                    CircularProgressIndicator(),
                    SizedBox(height: 10),
                    Text(
                      'Fetching info...',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            if (_streamManifest != null) ...[
              Column(
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
                      itemCount: _streamManifest!.videoOnly.length,
                      itemBuilder: (context, index) {
                        VideoOnlyStreamInfo info = _streamManifest!.videoOnly[index];

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
                          onTap: () {
                            setState(() {
                              _videoStream = info;
                              _index++;
                            });
                          },
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    child: Row(
                      children: [
                        const Spacer(),
                        OutlinedButton(
                          child: const Text('No video'),
                          onPressed: () {
                            setState(() {
                              _videoStream = null;
                              _index++;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Column(
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
                      itemCount: _streamManifest!.audioOnly.length,
                      itemBuilder: (context, index) {
                        AudioOnlyStreamInfo info = _streamManifest!.audioOnly[index];

                        return ListTile(
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
                          onTap: () {
                            setState(() {
                              _audioStream = info;
                              _index++;
                            });
                          },
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
                          onPressed: () {
                            setState(() {
                              _index--;
                            });
                          },
                        ),
                        const Spacer(),
                        OutlinedButton(
                          child: const Text('No audio'),
                          onPressed: _videoStream != null
                              ? () {
                                  setState(() {
                                    _audioStream = null;
                                    _index++;
                                  });
                                }
                              : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Expanded(
                      child: ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          'Destination',
                          style: Theme.of(context).textTheme.headline5,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                        child: TextFormField(
                          controller: _folderPathController,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.folder),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.more_horiz),
                              onPressed: () {
                                FilePicker.platform.getDirectoryPath().then(
                                  (value) {
                                    if (value != null && mounted) {
                                      setState(() {
                                        _folderPathController.text = value;
                                      });
                                    }
                                  },
                                );
                              },
                            ),
                            labelText: 'Destination folder',
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                        child: TextFormField(
                          initialValue: _defaultFileName,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.text_fields),
                            labelText: 'File name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                        child: DropdownButtonFormField<String>(
                          value: _defaultFileFormat,
                          items: const [
                            DropdownMenuItem(
                              value: 'mp3',
                              child: Text('MP3'),
                            ),
                            DropdownMenuItem(
                              value: 'mp4',
                              child: Text('MP4'),
                            ),
                            DropdownMenuItem(
                              value: 'webm',
                              child: Text('WEBM'),
                            ),
                            DropdownMenuItem(
                              value: 'wav',
                              child: Text('WAV'),
                            ),
                            DropdownMenuItem(
                              value: 'avi',
                              child: Text('AVI'),
                            ),
                            DropdownMenuItem(
                              value: 'mov',
                              child: Text('MOV'),
                            ),
                          ],
                          onChanged: (item) {},
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.insert_drive_file),
                            labelText: 'Output format',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text('Sources', style: Theme.of(context).textTheme.overline),
                      ),
                      ListTile(
                        dense: true,
                        leading: const Icon(Icons.ondemand_video),
                        title: Text(_videoStream?.videoQualityLabel ?? 'None'),
                        subtitle: _videoStream != null
                            ? Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_videoStream!.videoResolution.toString()),
                                  Text(_videoStream!.container.name),
                                  Text(_videoStream!.size.toString()),
                                ],
                              )
                            : null,
                      ),
                      ListTile(
                        dense: true,
                        leading: const Icon(Icons.music_note),
                        title: Text(_audioStream?.qualityLabel ?? 'None'),
                        subtitle: _audioStream != null
                            ? Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_audioStream!.container.name),
                                  Text(_audioStream!.size.toString()),
                                ],
                              )
                            : null,
                      ),
                    ],
                  )),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    child: Row(
                      children: [
                        TextButton(
                          child: const Text('Back'),
                          onPressed: () {
                            setState(() {
                              _index--;
                            });
                          },
                        ),
                        const Spacer(),
                        ElevatedButton(
                          child: const Text('Download'),
                          onPressed: () {
                            download();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Downloading video...',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(value: _videoDownloadProgress),
                  ],
                ),
              ),
            ),
            Center(
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
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Merging sources...',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(value: _mergingSourcesProgress),
                  ],
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Encoding...',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(value: _encodingOutputProgress),
                  ],
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                      size: 30,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Download complete',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ButtonBar(
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Back'),
                        ),
                        OutlinedButton(
                          onPressed: () => null,
                          child: const Text('OPEN'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      onWillPop: () async {
        if (_index == 8) {
          return true;
        }

        if (_index > 3) {
          return false;
        }

        if (_index > 1) {
          setState(() {
            _index--;
          });
          return false;
        }

        return true;
      },
    );
  }

  @override
  void dispose() {
    _folderPathController.dispose();

    super.dispose();
  }

  Future<void> download() async {
    // TODO: add validation & save to inputs
    if (_formKey.currentState?.validate() == true) {
      _formKey.currentState?.save();

      _videoTempFile = null;
      _audioTempFile = null;
      _mergingTempFile = null;
      _outputFile = null;

      if (_videoStream != null) {
        setState(() {
          _videoDownloadProgress = null;
          _index = 4;
        });

        _videoTempFile = await downloadStream(
          widget.video,
          _videoStream!,
          onProgress: (progress) {
            setState(() {
              _videoDownloadProgress = progress;
            });
          },
        );
      }

      if (_audioStream != null) {
        setState(() {
          _audioDownloadProgress = null;
          _index = 4;
        });

        _audioTempFile = await downloadStream(
          widget.video,
          _audioStream!,
          onProgress: (progress) {
            setState(() {
              _audioDownloadProgress = progress;
            });
          },
        );
      }

      if (_videoTempFile != null && _audioTempFile != null) {
        // TODO: merge files
      }

      // TODO: encode file

      // TODO: return output file and goto final page
    }
  }

  Future<bool> checkPermissions() async {
    if (!(await Permission.storage.isGranted)) {
      if (!(await Permission.storage.request().isGranted)) return false;
    }

    return true;
  }

  Future<File?> downloadStream(Video video, StreamInfo streamInfo, {Function(double)? onProgress}) async {
    if (!(await checkPermissions())) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Permission denied'),
      ));
      return null;
    }

    Directory? directory = (await Config.getInstance()).downloadDirectory;

    if (directory == null || !directory.existsSync()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Could not find download directory'),
      ));
      return null;
    }

    bool isDialogOpened = false;
    late void Function(void Function()) dialogSetState;
    double? downloadProgress;

    File file = File('${directory.path}/${htmlEscape.convert(video.title)}.mp4');

    if (file.existsSync()) {
      bool? overrideFile = await showDialog<bool?>(
        context: context,
        builder: (context) => AlertDialog(
          content: const Text('This file already exists. Override file ?'),
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

      if (overrideFile != true) return null;
    }

    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => WillPopScope(child: StatefulBuilder(
        builder: (context, setState) {
          dialogSetState = setState;
          isDialogOpened = true;

          return AlertDialog(
            title: const Text('Downloading...'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  file.path,
                  style: Theme.of(context).textTheme.caption,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: LinearProgressIndicator(value: downloadProgress),
                ),
              ],
            ),
            actions: [
              TextButton(
                child: const Text('Open'),
                onPressed: downloadProgress == 1 ? () => OpenFile.open(file.path) : null,
              ),
            ],
          );
        },
      ), onWillPop: () async {
        isDialogOpened = false;
        return true;
      }),
    );

    Stream<List<int>> stream = YouLoad.of(context).youtubeExplode.videos.streamsClient.get(streamInfo);
    IOSink fileStream = file.openWrite();

    await stream.pipe(fileStream);

    await fileStream.flush();
    await fileStream.close();

    if (isDialogOpened) dialogSetState(() => downloadProgress = 1);
  }
}
