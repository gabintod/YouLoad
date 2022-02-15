import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class DownloadForm extends StatefulWidget {
  final String? defaultFileName;
  final String? defaultDownloadPath;
  final Function(String fileName, String downloadPath)? onDownload;
  final Function()? onBack;
  final bool showBackButton;

  const DownloadForm({Key? key, this.defaultFileName, this.defaultDownloadPath, required this.onDownload, this.onBack, this.showBackButton = true}) : super(key: key);

  @override
  _DownloadFormState createState() => _DownloadFormState();
}

class _DownloadFormState extends State<DownloadForm> {
  final _formKey = GlobalKey<FormState>();
  final _folderPathController = TextEditingController();

  String? _downloadPath;
  String? _fileName;

  @override
  Widget build(BuildContext context) {

    return Form(
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'A destination is necessary';
                        }

                        Directory dir = Directory(value);
                        if (!dir.existsSync()) {
                          return 'Folder not found';
                        }

                        return null;
                      },
                      onSaved: (value) {
                        _downloadPath = value;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    child: TextFormField(
                      initialValue: widget.defaultFileName,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.text_fields),
                        labelText: 'File name',
                        suffixText: '.mp3',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Name is necessary';
                        }

                        if (value.contains('/')) {
                          return 'Unauthorized symbol \'/\'';
                        }

                        return null;
                      },
                      onSaved: (value) {
                        _fileName = value;
                      },
                    ),
                  ),
                ],
              )),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: Row(
              children: [
                TextButton(
                  child: const Text('Back'),
                  onPressed: widget.onBack,
                ),
                const Spacer(),
                ElevatedButton(
                  child: const Text('Download'),
                  onPressed: download,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _folderPathController.dispose();

    super.dispose();
  }

  void download() {
    if (_formKey.currentState?.validate() == true) {
      _formKey.currentState?.save();

      if (_fileName != null && _downloadPath != null) {
        widget.onDownload?.call(_fileName!, _downloadPath!);
      }
    }
  }
}