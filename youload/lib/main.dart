import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youload/widgets/MainPage.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ThemeMode? savedThemeMode = await YouLoad.getSavedTheme();

  runApp(YouLoad(themeMode: savedThemeMode));
}

class YouLoad extends StatefulWidget {
  static const String themeModeMemKey = 'theme_mode_memkey';

  static const MaterialColor megabombColor = MaterialColor(0xFF0254CF, {
    50: Color(0xFFF3F7FD),
    100: Color(0xFFE6EEFB),
    200: Color(0xFFC0D5F3),
    300: Color(0xFF98B9EC),
    400: Color(0xFF4E88DE),
    500: Color(0xFF0254CF),
    600: Color(0xFF024BB9),
    700: Color(0xFF02337D),
    800: Color(0xFF01265E),
    900: Color(0xFF01193D),
  });
  static const Color youtubeColor = Color(0xFFFC0000);
  static const Color youloadColor = Color(0xFF006aff);

  final ThemeMode? themeMode;

  const YouLoad({Key? key, this.themeMode}) : super(key: key);

  @override
  YouLoadState createState() => YouLoadState();

  static YouLoadState of(BuildContext? context) {
    assert(context != null);
    final YouLoadState? result =
        context!.findAncestorStateOfType<YouLoadState>();
    if (result != null) {
      return result;
    }
    throw FlutterError.fromParts(<DiagnosticsNode>[
      ErrorSummary(
        'YouLoad.of() called with a context that does not contain a YouLoad.',
      ),
      context.describeElement('The context used was'),
    ]);
  }

  static Future<ThemeMode?> getSavedTheme() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    int? themeModeIndex = preferences.getInt(themeModeMemKey);
    if (themeModeIndex == null) return null;
    return ThemeMode.values[themeModeIndex];
  }
}

class YouLoadState extends State<YouLoad> {
  late final YoutubeExplode youtubeExplode;
  late ThemeMode _themeMode;

  ThemeMode get themeMode => _themeMode;

  set themeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
    saveTheme();
  }

  @override
  void initState() {
    youtubeExplode = YoutubeExplode();
    _themeMode = widget.themeMode ?? ThemeMode.system;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YouLoad',
      theme: ThemeData(
        colorScheme: const ColorScheme(
          primary: YouLoad.youloadColor,
          onPrimary: Colors.white,
          secondary: YouLoad.youloadColor,
          onSecondary: Colors.white,
          background: Colors.white,
          onBackground: Colors.black,
          surface: Colors.white,
          onSurface: Colors.black,
          error: Color(0xFFD00000),
          onError: Colors.white,
          primaryVariant: Colors.white,
          secondaryVariant: Colors.white,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: const ColorScheme(
          primary: YouLoad.youloadColor,
          onPrimary: Colors.white,
          secondary: YouLoad.youloadColor,
          onSecondary: Colors.white,
          background: Colors.white,
          onBackground: Colors.black,
          surface: Colors.white,
          onSurface: Colors.black,
          error: Color(0xFFD00000),
          onError: Colors.white,
          primaryVariant: Colors.white,
          secondaryVariant: Colors.white,
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0XFF404040),
          foregroundColor: Colors.white,
        ),
      ),
      themeMode: _themeMode,
      home: const MainPage(),
    );
  }

  @override
  void dispose() {
    youtubeExplode.close();

    super.dispose();
  }

  Future<void> saveTheme() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    await preferences.setInt(YouLoad.themeModeMemKey, themeMode.index);
  }
}
