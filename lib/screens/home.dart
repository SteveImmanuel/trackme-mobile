import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:trackme/screens/choose_location.dart';
import 'package:trackme/widgets/bot_channels.dart';
import 'package:trackme/widgets/locations.dart';
import 'package:trackme/widgets/profile.dart';
import 'package:trackme/widgets/aliases.dart';
import 'package:trackme/models/user.dart';
import 'package:trackme/utilities/api.dart';
import 'package:trackme/utilities/route_arguments.dart';
import 'package:trackme/main.dart';
import 'package:trackme/utilities/snackbar_factory.dart';
import 'package:trackme/utilities/foreground_service.dart';

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
    initForegroundTask();
    _children = [
      ChildItem(title: 'Profile', widget: const Profile()),
      ChildItem(
          title: 'Bot Channels',
          widget: BotChannels(
            reloadUserData: _loadUserData,
          )),
      ChildItem(
          title: 'Locations',
          widget: Locations(
            reloadUserData: _loadUserData,
          )),
      ChildItem(
        title: 'Aliases',
        widget: Aliases(reloadUserData: _loadUserData),
      ),
    ];
    _loadUserData();
  }

  void _onBottomNavTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> _loadUserData() async {
    Map<String, dynamic> result = await getUserData();
    if (result['code'] == 200) {
      _user.setData(result['detail']);
    } else {
      // Push to login, show snack bar session timeout
    }
  }

  Future<void> _onAddAlias(BuildContext context) async {
    if (_newAlias != '') {
      Navigator.pop(context);

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBarFactory.create(
        duration: 3000000,
        type: SnackBarType.loading,
        content: 'Adding New Alias',
      ));

      Map<String, dynamic> updateResult = await updateUser({
        'aliases': [_newAlias, ..._user.aliases],
      });

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      if (updateResult['code'] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBarFactory.create(
          duration: 1000,
          type: SnackBarType.success,
          content: 'Add New Alias Success',
        ));
      } else if (updateResult['code'] != 401) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBarFactory.create(
          duration: 1000,
          type: SnackBarType.failed,
          content: 'Add New Alias Failed',
        ));
      }
      _newAlias = '';

      await _loadUserData();
    }
  }

  Future<void> _onAddButtonTapped(BuildContext parentContext) async {
    if (_currentIndex == 3) {
      return showDialog(
        context: parentContext,
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
                onPressed: () {
                  _newAlias = '';
                  Navigator.pop(context);
                },
              ),
              TextButton(
                child: const Text('Add'),
                onPressed: () => _onAddAlias(parentContext),
              ),
            ],
          );
        },
      );
    } else {
      MainApp.navKey.currentState?.pushNamed(
        ChooseLocation.route,
        arguments: LocationArgs(
            callback: _loadUserData,
            currentLocationList: _user.locations,
            currentIndex: -1,
            parentContext: parentContext),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => _user,
      child: WithForegroundTask(
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
              children:
                  _children.map((ChildItem child) => child.widget).toList(),
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
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          resizeToAvoidBottomInset: false,
        ),
      ),
    );
  }
}
