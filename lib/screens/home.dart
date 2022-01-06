import 'package:flutter/material.dart';
import 'package:trackme_mobile/constants.dart';
import 'package:trackme_mobile/widgets/bot_channels.dart';
import 'package:trackme_mobile/widgets/locations.dart';
import 'package:trackme_mobile/widgets/profile.dart';

class ChildItem {
  String title;
  Widget widget;
  ChildItem({required this.title, required this.widget});
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 1;
  final List<ChildItem> _children = [
    ChildItem(title: 'Bot Channels', widget: BotChannels()),
    ChildItem(title: 'Profile', widget: Profile()),
    ChildItem(title: 'Locations', widget: Locations()),
  ];

  void _onBottomNavTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(_children[_currentIndex].title),
          backgroundColor: AppColor.primary,
          foregroundColor: AppColor.text,
          elevation: 0,
        ),
        body: _children[_currentIndex].widget,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onBottomNavTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              label: 'Bot Channels',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.location_on),
              label: 'Locations',
            ),
          ],
      ),
    );
  }
}

