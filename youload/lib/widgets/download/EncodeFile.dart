import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:path_provider/path_provider.dart';

class EncodeFile extends StatefulWidget {
  final File? source;
  final String destinationPath;
  final Function(File)? onEncoded;
  final Function(dynamic)? onError;

  const EncodeFile({Key? key, required this.source, required this.destinationPath, required this.onEncoded, required this.onError}) : super(key: key);

  @override
  _EncodeFileState createState() => _EncodeFileState();
}

class _EncodeFileState extends State<EncodeFile> {
  double? _encodingOutputProgress;

  @override
  Widget build(BuildContext context) {
    encode();

    return Center(
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
    );
  }

  Future<void> encode() async {
    if (widget.source?.existsSync() != true) {
      widget.onError?.call(Exception('No file to encode'));
      return;
    }

    Directory tempDirectory = await getTemporaryDirectory();
    if (!tempDirectory.existsSync()) {
      widget.onError?.call(Exception('Download directory does not exist'));
      return;
    }

    String destinationFormat = widget.destinationPath.split('.').last;
    String encodedFilePath = '${tempDirectory.path}/encoded_file_${Random().nextInt(4294967296)}.$destinationFormat';

    try {
      FlutterFFmpeg().execute('-i ${widget.source!.path} $encodedFilePath').then((value) => print('=>   Encoding: $value'));
    } catch (e) {
      widget.onError?.call(e);
      return;
    }

    File encodedFile = File(encodedFilePath);

    if (!encodedFile.existsSync()) {
      widget.onError?.call('Encoding error');
      return;
    }

    encodedFile.renameSync(widget.destinationPath);

    if (!encodedFile.existsSync()) {
      widget.onError?.call('Error moving file to final destination');
      return;
    }

    widget.onEncoded?.call(encodedFile);
  }
}
