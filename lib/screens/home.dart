import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:trackme_mobile/widgets/bot_channels.dart';
import 'package:trackme_mobile/widgets/locations.dart';
import 'package:trackme_mobile/widgets/profile.dart';
import 'package:trackme_mobile/widgets/aliases.dart';
import 'package:trackme_mobile/models/user.dart';

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
  User _user = User();

  void _onBottomNavTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> _getUserData() async {
    String data = """
    {
      "_id" : "61d008e31e6c15e5041e2690",
      "username" : "steve",
      "aliases" : [ 
          "andre"
      ],
      "bot_channels" : [ 
          {
              "id" : "Ud5ca5aec6ec7590de530ce4c50ed5708",
              "type" : "user",
              "photo_url" : "https://sprofile.line-scdn.net/0hNJSrz-PaEWV-Czkj0FZvGg5bEg9dekh3WmVfBkNYH1BLbF5nVW9fAUhcHVAWPFZgUm0OUE9YH1dyGGYDYF3tUXk7T1JHPFA1UWlWhQ",
              "display_name" : "Steve Immanuel",
              "platform": "line"
          }
      ],
      "locations" : [ 
          {
              "latitude" : "-7.711653",
              "longitude" : "110.599637",
              "name" : "Home",
              "alert_on_leave" : true,
              "alert_on_arrive" : true
          }
      ]
    }""";

    Map<String, dynamic> decodedData = jsonDecode(data);
    _user.setData(decodedData);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => _user,
      child: Scaffold(
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Theme.of(context).appBarTheme.backgroundColor,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
          title: Text(_children[_currentIndex].title),
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
                onPressed: _getUserData,
              )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
