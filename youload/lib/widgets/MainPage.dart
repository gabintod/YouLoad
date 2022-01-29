import 'package:flutter/material.dart';
import 'package:youload/main.dart';
import 'package:youload/widgets/utils/SimpleSearchDelegate.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
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
            const Text('YouLoad'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_outlined),
            onPressed: () => showSearch(
              context: context,
              delegate: SimpleSearchDelegate(
                resultsBuilder: (_, query) => Text(query),
              ),
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
}
