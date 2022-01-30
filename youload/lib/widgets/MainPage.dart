import 'package:flutter/material.dart';
import 'package:youload/main.dart';
import 'package:youload/widgets/SearchResultList.dart';
import 'package:youload/widgets/utils/SimpleSearchDelegate.dart';
import 'package:youload/widgets/utils/VideoTile.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late SearchDelegate searchDelegate;

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
      body: Container(),
    );
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
