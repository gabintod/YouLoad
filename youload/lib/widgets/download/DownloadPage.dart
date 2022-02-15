import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:youload/main.dart';
import 'package:youload/utils/Config.dart';
import 'package:youload/widgets/download/AudioSource.dart';
import 'package:youload/widgets/download/DownloadAudio.dart';
import 'package:youload/widgets/download/DownloadForm.dart';
import 'package:youload/widgets/download/EncodeFile.dart';
import 'package:youload/widgets/download/VideoSource.dart';
import 'package:youload/widgets/utils/Carousel.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class DownloadPage extends StatefulWidget {
  final Video video;

  const DownloadPage({Key? key, required this.video}) : super(key: key);

  @override
  _DownloadPageState createState() => _DownloadPageState();

  static Future<bool> checkPermissions() async {
    if (!(await Permission.storage.isGranted)) {
      if (!(await Permission.storage.request().isGranted)) return false;
    }

    return true;
  }

  static Future<File?> downloadStream(Video video, StreamInfo streamInfo, YoutubeExplode youtubeExplode, {Function(double?)? onProgress}) async {
    if (!(await checkPermissions())) {
      throw Exception('Permissions denied');
    }

    Directory tempDirectory = await getTemporaryDirectory();
    if (!tempDirectory.existsSync()) {
      throw Exception('Download directory does not exist');
    }

    File file = File('${tempDirectory.path}/temporary_file_${Random().nextInt(4294967296)}.${streamInfo.container.name}');

    Stream<List<int>> stream = youtubeExplode.videos.streamsClient.get(streamInfo);
    IOSink fileStream = file.openWrite();

    await stream.pipe(fileStream);

    await fileStream.flush();
    await fileStream.close();

    onProgress?.call(1);

    return file;
  }
}

class _DownloadPageState extends State<DownloadPage> {
  String? _defaultFolderPath;
  String? _defaultFileName;

  String? get _defaultFileFormat => _audioStream?.container.name;

  int _index = 0;
  late List<Widget> _carouselSteps;

  StreamManifest? _streamManifest;
  AudioOnlyStreamInfo? _audioStream;
  Directory? _downloadDirectory;
  String? _fileName;
  String? _downloadError;

  File? _audioTempFile;
  File? _outputFile;

  @override
  void initState() {
    YouLoad.of(context).youtubeExplode.videos.streamsClient.getManifest(widget.video.id).then((manifest) {
      if (!mounted) return null;

      setState(() {
        _streamManifest = manifest;
      });
    });

    Config.getInstance().then((config) {
      _defaultFolderPath = config.downloadDirectory?.path;
    });
    _defaultFileName = htmlEscape.convert(widget.video.title);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _carouselSteps = [
      Builder(
        builder: (context) {
          if (_streamManifest != null) {
            Future.delayed(
              Duration.zero,
              () => setState(() {
                _index++;
              }),
            );
          }

          return Center(
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
          );
        },
      ),
      if (_streamManifest != null) ...[
        AudioSource(
          manifest: _streamManifest!,
          onSelect: (info) {
            setState(() {
              _audioStream = info;
              _index++;
            });
          },
          onBack: () {
            setState(() {
              _index--;
            });
          },
          showNoSourceButton: false,
        ),
      ],
      DownloadForm(
        defaultFileName: _defaultFileName,
        defaultDownloadPath: _defaultFolderPath,
        onDownload: (fileName, downloadPath) {
          setState(() {
            _fileName = fileName;
            _downloadDirectory = Directory(downloadPath);
            _index++;
          });
        },
        onBack: () {
          setState(() {
            _index--;
          });
        },
      ),
      if (_audioStream != null)
        DownloadAudio(
          video: widget.video,
          streamInfo: _audioStream!,
          onDownloaded: (file) {
            if (mounted) {
              setState(() {
                _audioTempFile = file;

                _index++;
              });
            }
          },
          onDownloadError: (e) {
            setState(() {
              _downloadError = e?.toString() ?? '';
            });
          },
        ),
      if (_audioTempFile != null)
        EncodeFile(
          source: _audioTempFile!,
          destinationPath: '${_downloadDirectory?.path}/$_fileName.mp3',
          onEncoded: (file) {
            if (mounted) {
              setState(() {
                _outputFile = file;
                _index++;
              });
            }
          },
          onError: (e) {
            setState(() {
              _downloadError = e?.toString() ?? '';
            });
          },
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
              Text(
                'Download complete',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline6,
              ),
              const SizedBox(height: 20),
              ButtonBar(
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Back'),
                  ),
                  OutlinedButton(
                    onPressed: () => OpenFile.open(_outputFile!.path),
                    child: const Text('OPEN'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Download'),
      ),
      body: _downloadError != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Theme.of(context).errorColor,
                      size: 30,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Download error !',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    Text(
                      _downloadError!,
                      style: Theme.of(context).textTheme.caption,
                    ),
                    const SizedBox(height: 20),
                    ButtonBar(
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Quit'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          : WillPopScope(
              child: Carousel(
                index: min(_index, _carouselSteps.length - 1),
                children: _carouselSteps,
              ),
              onWillPop: () async {
                if (_index > 1) {
                  setState(() {
                    _index--;
                  });
                  return false;
                }

                return true;
              },
            ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

// Future<void> download() async {
//   if (_videoTempFile != null && _audioTempFile != null) {
//     // TODO: merge files
//     String mergedFilePath = '${_videoTempFile!.parent.path}/merged_file.${_defaultFileFormat!}';
//     FlutterFFmpeg()
//         .execute('-i ${_videoTempFile!.path} -i ${_audioTempFile!.path} -c:v copy -c:a aac $mergedFilePath')
//         .then((value) => print('=>   Merging: $value'));
//     _mergedTempFile = File(mergedFilePath);
//
//     // _mergedTempFile = _audioTempFile;
//   } else if (_videoTempFile == null && _audioTempFile == null) {
//     if (mounted) {
//       setState(() {
//         _downloadError = 'Neither video or audio has been downloaded';
//         _index = 9;
//       });
//     }
//
//     return;
//   } else {
//     _mergedTempFile = _videoTempFile ?? _audioTempFile;
//   }
//
//   // TODO: return output file and goto final page
//   if (_mergedTempFile == null || !_mergedTempFile!.existsSync()) {
//     if (mounted) {
//       setState(() {
//         _downloadError = 'Error merging files';
//         _index = 9;
//       });
//     }
//
//     return;
//   }
//
//   if (_defaultFileFormat != _fileFormat) {
//     // TODO: encode file
//     String encodedFilePath = '${_mergedTempFile!.parent.path}/encoded_file.${_fileFormat!}';
//     FlutterFFmpeg().execute('-i ${_mergedTempFile!.path} $encodedFilePath').then((value) => print('=>   Encoding: $value'));
//     _mergedTempFile = File(encodedFilePath);
//   }
//
//   // TODO: return output file and goto final page
//   if (_mergedTempFile == null || !_mergedTempFile!.existsSync()) {
//     if (mounted) {
//       setState(() {
//         _downloadError = 'Error encoding';
//         _index = 9;
//       });
//     }
//
//     return;
//   }
//
//   if (!mounted) {
//     return;
//   }
//
//   _outputFile = _mergedTempFile!.renameSync('${_downloadDirectory!.path}/${_fileName!}.${_fileFormat!}');
//
//   if (_outputFile == null || !_outputFile!.existsSync()) {
//     if (mounted) {
//       setState(() {
//         _downloadError = 'Error output file';
//         _index = 9;
//       });
//     }
//
//     return;
//   }
//
//   if (mounted) {
//     setState(() {
//       _index = 8;
//     });
//   }
// }
}
