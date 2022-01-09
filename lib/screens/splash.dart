import 'package:flutter/material.dart';
import 'package:trackme_mobile/utilities/api.dart';
import 'package:trackme_mobile/screens/home.dart';
import 'package:trackme_mobile/screens/auth.dart';
import 'package:trackme_mobile/main.dart';

class Splash extends StatefulWidget {
  static String route = '/';

  const Splash({Key? key}) : super(key: key);

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  Future<void> _initializeApp() async {
    await initializeApi();
    Map<String, dynamic> authCheckResult = await authCheck();

    if (authCheckResult['code'] == 200) {
      MainApp.navKey.currentState?.pushNamedAndRemoveUntil(
        Home.route,
        (route) => false,
      );
    } else {
      MainApp.navKey.currentState?.pushNamedAndRemoveUntil(
        Auth.route,
            (route) => false,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Hero(
                tag: 'trackmeBanner',
                child: Image.asset(
                  'assets/images/trackme_banner.png',
                  width: MediaQuery.of(context).size.width * 0.7,
                ),
              )
            ],
          ),
          CircularProgressIndicator(
            color: Theme.of(context).colorScheme.secondary,
          ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
      resizeToAvoidBottomInset: false,
    );
  }
}
