import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:youload/main.dart';
import 'package:youload/widgets/utils/KeepAliveBuilder.dart';
import 'package:youload/widgets/utils/VideoTile.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class SearchResultList extends StatefulWidget {
  final String query;

  const SearchResultList({Key? key, required this.query}) : super(key: key);

  @override
  _SearchResultListState createState() => _SearchResultListState();
}

class _SearchResultListState extends State<SearchResultList> {
  late Future<SearchList> resultsFuture;

  @override
  void initState() {
    resultsFuture =
        YouLoad.of(context).youtubeExplode.search.getVideos(widget.query);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('build list');

    return FutureBuilder<SearchList>(
      future: resultsFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return LayoutBuilder(
            builder: (context, constraints) => RefreshIndicator(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
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
                ),
              ),
              onRefresh: () async {
                resultsFuture = YouLoad.of(context)
                    .youtubeExplode
                    .search
                    .getVideos(widget.query);
              },
            ),
          );
        }

        if (snapshot.hasData) {
          if (snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No result',
                style: Theme.of(context).textTheme.caption,
                textAlign: TextAlign.center,
              ),
            );
          }

          return RefreshIndicator(
            child: ListView(
              children: [
                buildResultList(snapshot.data!),
              ],
              addAutomaticKeepAlives: true,
            ),
            onRefresh: () async {
              resultsFuture = YouLoad.of(context)
                  .youtubeExplode
                  .search
                  .getVideos(widget.query);
            },
          );
        }

        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  Widget buildResultList(SearchList results) {
    return ListView.builder(
      primary: false,
      shrinkWrap: true,
      itemCount: results.length + 1,
      itemBuilder: (context, index) {
        if (index >= results.length) {
          return FutureBuilder<SearchList?>(
            future: results.nextPage(),
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
                return buildResultList(snapshot.data!);
              }

              if (snapshot.connectionState != ConnectionState.done) {
                return Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(20),
                  child: const CircularProgressIndicator(),
                );
              }

              return Container();
            },
          );
        }

        return VideoTile(
          results[index],
          onTap: () {
            showDialog(
              context: context,
              builder: (context) {
                int iType = 0;

                return FutureBuilder<StreamManifest>(
                  future: YouLoad.of(context)
                      .youtubeExplode
                      .videos
                      .streamsClient
                      .getManifest(results[index].id),
                  builder: (context, snapshot) {
                    return StatefulBuilder(
                      builder: (context, setState) {
                        List<UnmodifiableListView<StreamInfo>> streamsInfo = [];

                        if (snapshot.hasData) {
                          streamsInfo = [
                            snapshot.data!.muxed,
                            snapshot.data!.video,
                            snapshot.data!.audio,
                            snapshot.data!.videoOnly,
                            snapshot.data!.audioOnly,
                          ];
                        }

                        return SimpleDialog(
                          contentPadding: const EdgeInsets.all(20),
                          children: [
                            Wrap(
                              children: [
                                ChoiceChip(
                                  label: const Text('Muxed'),
                                  selected: iType == 0,
                                  onSelected: (_) => setState(() => iType = 0),
                                ),
                                ChoiceChip(
                                  label: const Text('Video'),
                                  selected: iType == 1,
                                  onSelected: (_) => setState(() => iType = 1),
                                ),
                                ChoiceChip(
                                  label: const Text('Audio'),
                                  selected: iType == 2,
                                  onSelected: (_) => setState(() => iType = 2),
                                ),
                                ChoiceChip(
                                  label: const Text('Video only'),
                                  selected: iType == 3,
                                  onSelected: (_) => setState(() => iType = 3),
                                ),
                                ChoiceChip(
                                  label: const Text('Audio only'),
                                  selected: iType == 4,
                                  onSelected: (_) => setState(() => iType = 4),
                                ),
                              ],
                            ),
                            if (!snapshot.hasData)
                              const AspectRatio(
                                aspectRatio: 1,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            if (snapshot.hasData)
                              ...streamsInfo[iType]
                                  .map<Widget>(
                                    (info) => ListTile(
                                      title: Text(info.qualityLabel),
                                      subtitle: Text(info.toString()),
                                    ),
                                  )
                                  .toList(),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
