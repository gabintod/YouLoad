import 'package:flutter/material.dart';
import 'package:youload/main.dart';
import 'download/DownloadPage.dart';
import 'package:youload/widgets/StreamsListDialog.dart';
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DownloadPage(video: results[index]),
              ),
            );
            return;

            // showDialog(
            //   context: context,
            //   builder: (context) => StreamsListDialog(
            //     results[index],
            //     onAudioDownload: (info) =>
            //         widget.onAudioDownload?.call(results[index], info),
            //     onVideoDownload: (info) =>
            //         widget.onVideoDownload?.call(results[index], info),
            //   ),
            // );
          },
        );
      },
    );
  }
}
