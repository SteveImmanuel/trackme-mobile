import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:trackme_mobile/widgets/bot_channels.dart';
import 'package:trackme_mobile/widgets/locations.dart';
import 'package:trackme_mobile/widgets/profile.dart';
import 'package:trackme_mobile/widgets/aliases.dart';
import 'package:trackme_mobile/models/user.dart';
import 'package:trackme_mobile/utilities/api.dart';

class ChildItem {
  String title;
  Widget widget;

  ChildItem({required this.title, required this.widget});
}

class LocationListController {}

class Home extends StatefulWidget {
  static String route = '/home';

  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;
  String _newAlias = '';
  final User _user = User();
  late List<ChildItem> _children;

  @override
  void initState() {
    super.initState();
    _children = [
      ChildItem(title: 'Profile', widget: const Profile()),
      ChildItem(title: 'Bot Channels', widget: const BotChannels()),
      ChildItem(title: 'Locations', widget: const Locations()),
      ChildItem(
          title: 'Aliases', widget: Aliases(reloadUserData: _loadUserData)),
    ];
    _loadUserData();
  }

  void _onBottomNavTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> _loadUserData() async {
    _user.setNotReady();
    Map<String, dynamic> result = await getUserData();
    if (result['code'] == 200) {
      _user.setData(result['detail']);
    } else {
      // Push to login, show snack bar session timeout
    }
  }

  Future<void> _onAddButtonTapped(BuildContext context) async {
    if (_currentIndex == 3) {
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Add New Alias'),
            content: TextField(
              onChanged: (value) {
                _newAlias = value;
              },
              decoration: const InputDecoration(
                hintText: "Case sensitive, not empty",
                isDense: true,
              ),
            ),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: const Text('Add'),
                onPressed: () async {
                  if (_newAlias != '') {
                    await updateAlias({
                      'aliases': [_newAlias, ..._user.aliases],
                    });
                    await _loadUserData();
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          );
        },
      );
    }

    // return null;
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
                onPressed: () => _onAddButtonTapped(context),
              )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        resizeToAvoidBottomInset: false,
      ),
    );
  }
}
