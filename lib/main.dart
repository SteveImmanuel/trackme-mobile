import 'package:flutter/material.dart';
import 'package:trackme/screens/home.dart';
import 'package:trackme/screens/auth.dart';
import 'package:trackme/screens/choose_location.dart';
import 'package:trackme/screens/splash.dart';
import 'package:trackme/utilities/route_arguments.dart';

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
      onGenerateRoute: (settings) {
        if (settings.name == ChooseLocation.route) {
          final args = settings.arguments as LocationArgs;

          return MaterialPageRoute(
            builder: (context) {
              return ChooseLocation(
                callback: args.callback,
                currentLocationList: args.currentLocationList,
                currentIndex: args.currentIndex,
                parentContext: args.parentContext,
              );
            },
          );
        } else if (settings.name == Splash.route) {
          return MaterialPageRoute(builder: (context) => const Splash());
        } else if (settings.name == Auth.route) {
          return MaterialPageRoute(builder: (context) => const Auth());
        } else if (settings.name == Home.route) {
          return MaterialPageRoute(builder: (context) => const Home());
        }
        assert(false, 'Need to implement ${settings.name}');
        return null;
      },
      // routes: {
      //   Splash.route: (context) => const Splash(),
      //   Auth.route: (context) => const Auth(),
      //   Home.route: (context) => const Home(),
      //   ChooseLocation.route: (context) => const ChooseLocation()
      // },
    );
  }
}
