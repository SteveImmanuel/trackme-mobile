import 'package:flutter/material.dart';
import 'package:trackme_mobile/constants.dart';
import 'package:trackme_mobile/widgets/bot_channels.dart';
import 'package:trackme_mobile/widgets/locations.dart';
import 'package:trackme_mobile/widgets/profile.dart';
import 'package:trackme_mobile/widgets/aliases.dart';

class ChildItem {
  String title;
  Widget widget;

  ChildItem({required this.title, required this.widget});
}

class LocationListController {}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;
  final List<ChildItem> _children = [
    ChildItem(title: 'Profile', widget: const Profile()),
    ChildItem(title: 'Bot Channels', widget: const BotChannels()),
    ChildItem(title: 'Locations', widget: const Locations()),
    ChildItem(title: 'Aliases', widget: const Aliases()),
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: IndexedStack(
          index: _currentIndex,
          children: _children.map((ChildItem child) => child.widget).toList(),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outlined),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_outlined),
            activeIcon: Icon(Icons.chat),
            label: 'Bot Channels',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on_outlined),
            activeIcon: Icon(Icons.location_on),
            label: 'Locations',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.campaign_outlined),
            activeIcon: Icon(Icons.campaign),
            label: 'Aliases',
          ),
        ],
        type: BottomNavigationBarType.fixed,
      ),
      floatingActionButton: (_currentIndex == 2 || _currentIndex == 3)
          ? FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () {},
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
