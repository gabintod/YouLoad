import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:youload/utils/DownloadMode.dart';
import 'package:youload/utils/TitledMessage.dart';
import 'package:youload/utils/Youloader.dart';
import 'package:youload/widgets/utils/Collapser.dart';
import 'package:youload/widgets/utils/FutureButtonBuilder.dart';
import 'package:youload/widgets/utils/Selector.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final Youloader youloader = Youloader();
  final GlobalKey<FormState> _formKey = GlobalKey();
  DownloadMode mode = DownloadMode.audio;

  bool showError = false;
  TitledMessage? _error;
  TitledMessage? get error => _error;
  set error(TitledMessage? value) {
    if (value != null) {
      _error = value;
      showError = true;
    } else {
      showError = false;
    }
  }

  bool showSuccess = false;
  TitledMessage? _success;
  TitledMessage? get success => _success;
  set success(TitledMessage? value) {
    if (value != null) {
      _success = value;
      showSuccess = true;
    } else {
      showSuccess = false;
    }
  }

  late String url;
  Video? videoInfo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        // elevation: 0,
        title: const Text('Youload'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(25),
          children: [
            Transform.translate(
              offset: const Offset(0, -25),
              child: Card(
                elevation: 0,
                margin: EdgeInsets.zero,
                clipBehavior: Clip.antiAlias,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
                ),
                child: Collapser(
                  collapsed: !showError,
                  alignment: Alignment.bottomCenter,
                  child: ListTile(
                    tileColor: Theme.of(context).colorScheme.error,
                    textColor: Theme.of(context).colorScheme.onError,
                    iconColor: Theme.of(context).colorScheme.onError,
                    title: error?.title != null ? Text(error!.title!) : null,
                    subtitle: error?.message != null ? Text(error!.message!) : null,
                    isThreeLine: error?.message != null,
                    trailing: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          error = null;
                        });
                      },
                    ),
                  ),
                ),
              ),
            ),
            Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 10),
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              child: Collapser(
                collapsed: !showSuccess,
                child: ListTile(
                  tileColor: Theme.of(context).colorScheme.background,
                  textColor: Theme.of(context).colorScheme.onBackground,
                  iconColor: Theme.of(context).colorScheme.onBackground,
                  title: success?.title != null ? Text(success!.title!) : null,
                  subtitle: success?.message != null ? Text(success!.message!) : null,
                  isThreeLine: success?.message != null,
                  trailing: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    child: const Icon(Icons.check),
                  ),
                ),
              ),
            ),
            TextFormField(
              decoration: InputDecoration(
                hintText: 'URL',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'URL must be filled';
                return null;
              },
              onSaved: (value) => url = value!,
            ),
            Selector(
              margin: const EdgeInsets.only(top: 10),
              items:
                  DownloadMode.values.map((mode) => Text(mode.name)).toList(),
              selection: mode.index,
              onSelection: (index) {
                setState(() {
                  mode = DownloadMode.values[index];
                });
              },
            ),
            const SizedBox(height: 10),
            FutureButtonBuilder(
              callback: download,
              builder: (context, callback) => ElevatedButton(
                style: ButtonStyle(
                  padding: MaterialStateProperty.all(const EdgeInsets.all(15)),
                  shape: MaterialStateProperty.all(const StadiumBorder()),
                  elevation: MaterialStateProperty.all(0),
                ),
                child: const Text('DOWNLOAD'),
                onPressed: callback,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future checkPermission() async {
    if (!(await Permission.storage.isGranted)) {
      if (!(await Permission.storage.request()).isGranted) {
        throw Exception('Storage permission denied');
      }
    }

    if (!(await Permission.manageExternalStorage.isGranted)) {
      if (!(await Permission.manageExternalStorage.request()).isGranted) {
        throw Exception('Storage management permission denied');
      }
    }
  }

  Future download() async {
    setState(() {
      success = null;
      error = null;
    });

    try {
      await checkPermission();
    } catch(e) {
      setState(() {
        error = TitledMessage(
          title: 'Permission denied',
          message: e.toString(),
        );
      });
      return;
    }

    if (_formKey.currentState?.validate() == true) {
      _formKey.currentState!.save();

      try {
        Video videoInfo = await youloader.getInfo(url);
        setState(() {
          this.videoInfo = videoInfo;
        });
      } catch(e) {
        setState(() {
          error = TitledMessage(
            title: 'Fetching info error',
            message: e.toString(),
          );
        });
        return;
      }

      try {
        if (mode == DownloadMode.audio) {
          await youloader.downloadAudio(url, videoInfo: videoInfo);
        } else {
          await youloader.downloadVideo(url, videoInfo: videoInfo);
        }
      } catch(e) {
        setState(() {
          error = TitledMessage(
            title: 'Download error',
            message: e.toString(),
          );
        });
        return;
      }

      setState(() {
        success = TitledMessage(
          title: 'Download success',
          message: '${videoInfo!.title} downloaded',
        );
      });
    }
  }
}
