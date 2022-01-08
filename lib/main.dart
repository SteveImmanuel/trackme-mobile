import 'package:flutter/material.dart';
import 'package:trackme_mobile/screens/home.dart';
import 'package:trackme_mobile/screens/auth.dart';
import 'package:trackme_mobile/screens/choose_location.dart';
import 'package:trackme_mobile/screens/splash.dart';

void main() {
  runApp(const MainApp());
}

final ThemeData theme = ThemeData(
  colorScheme: ColorScheme.fromSwatch(
    primarySwatch: Colors.indigo,
    backgroundColor: Colors.white,
  ).copyWith(secondary: Colors.amber),
  appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0),
  scaffoldBackgroundColor: Colors.white,
);

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);
  static final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navKey,
      initialRoute: Splash.route,
      theme: theme,
      routes: {
        Splash.route: (context) => const Splash(),
        Auth.route: (context) => const Auth(),
        Home.route: (context) => const Home(),
        ChooseLocation.route: (context) => const ChooseLocation()
      },
    );
  }
}
