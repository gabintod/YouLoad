import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:youload/main.dart';
import 'package:youload/utils/Config.dart';
import 'package:youload/widgets/SearchResultList.dart';
import 'package:youload/widgets/utils/SimpleSearchDelegate.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late SearchDelegate searchDelegate;
  late Future<List<FileSystemEntity>?> downloadedFiles;

  @override
  void initState() {
    downloadedFiles = _getDownloads();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    searchDelegate = SimpleSearchDelegate(
      resultsBuilder: (_, query) => buildSearchResults(query),
      suggestionsBuilder: (_, query) => buildSearchSuggestions(query),
    );

    return Scaffold(
      appBar: AppBar(
        title: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 5,
          children: [
            Image.asset(
              'assets/icon/icon.png',
              height: 40,
            ),
            const Text('YouLoad',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontFamily: 'Impact')),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_outlined),
            onPressed: () => showSearch(
              context: context,
              delegate: searchDelegate,
            ),
          ),
          PopupMenuButton<ThemeMode>(
            icon: const Icon(Icons.brightness_6),
            initialValue: YouLoad.of(context).themeMode,
            itemBuilder: (context) => const [
              PopupMenuItem<ThemeMode>(
                value: ThemeMode.light,
                child: Text('Light'),
              ),
              PopupMenuItem<ThemeMode>(
                value: ThemeMode.dark,
                child: Text('Dark'),
              ),
              PopupMenuItem<ThemeMode>(
                value: ThemeMode.system,
                child: Text('System'),
              ),
            ],
            onSelected: (mode) {
              setState(() {
                YouLoad.of(context).themeMode = mode;
              });
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            downloadedFiles = _getDownloads();
          });
        },
        child: FutureBuilder<List<FileSystemEntity>?>(
          future: downloadedFiles,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error,
                      color: Theme.of(context).errorColor,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      snapshot.error.toString(),
                      style: Theme.of(context).textTheme.caption,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  FileSystemEntity file = snapshot.data![index];

                  return ListTile(
                    leading: const Icon(Icons.music_video),
                    title: Text(file.path.split('/').last),
                    subtitle: Text(file.path),
                    onTap: () => OpenFile.open(file.path),
                    isThreeLine: true,
                  );
                },
              );
            }

            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }

  Future<List<FileSystemEntity>?> _getDownloads() async {
    Directory? downloadDirectory =
        (await Config.getInstance()).downloadDirectory;

    if (downloadDirectory == null || !downloadDirectory.existsSync()) {
      throw Exception('Download directory not found');
    }

    return downloadDirectory.listSync();
  }

  Widget buildSearchSuggestions(String query) {
    Future<List<String>> suggestions =
        YouLoad.of(context).youtubeExplode.search.getQuerySuggestions(query);

    return FutureBuilder<List<String>>(
      future: suggestions,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.error,
                color: Theme.of(context).errorColor,
              ),
              const SizedBox(height: 10),
              Text(
                snapshot.error.toString(),
                style: Theme.of(context).textTheme.caption,
                textAlign: TextAlign.center,
              ),
            ],
          );
        }

        if (snapshot.hasData) {
          return ListView(
            children: snapshot.data!
                .map<Widget>(
                  (result) => ListTile(
                    leading: const Icon(Icons.search),
                    title: Text(result),
                    onTap: () {
                      setState(() {
                        searchDelegate.query = result;
                        searchDelegate.showResults(context);
                      });
                    },
                  ),
                )
                .toList(),
          );
        }

        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  Widget buildSearchResults(String query) => SearchResultList(query: query);
}
