import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:provider/provider.dart';
import 'package:trackme/main.dart';
import 'package:trackme/models/user.dart';
import 'package:trackme/screens/choose_location.dart';
import 'package:trackme/utilities/api.dart';
import 'package:trackme/utilities/foreground_service.dart';
import 'package:trackme/utilities/route_arguments.dart';
import 'package:trackme/utilities/snackbar_factory.dart';
import 'package:trackme/widgets/accounts.dart';
import 'package:trackme/widgets/aliases.dart';
import 'package:trackme/widgets/bot_channels.dart';
import 'package:trackme/widgets/locations.dart';
import 'package:trackme/widgets/tracking.dart';

class ChildItem {
  String title;
  Widget widget;

  ChildItem({required this.title, required this.widget});
}

class Home extends StatefulWidget {
  static String route = '/home';

  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 2;
  String _newAlias = '';
  final User _user = User();
  late List<ChildItem> _children;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await requestPermissionForAndroid();
      initForegroundTask();
    });
    _children = [
      ChildItem(
        title: 'Account',
        widget: Accounts(
          reloadUserData: _loadUserData,
        ),
      ),
      ChildItem(
          title: 'Bot Channel',
          widget: BotChannels(
            reloadUserData: _loadUserData,
          )),
      ChildItem(
        title: 'Tracking',
        widget: const Tracking(),
      ),
      ChildItem(
          title: 'Location',
          widget: Locations(
            reloadUserData: _loadUserData,
          )),
      ChildItem(
        title: 'Alias',
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
      // TODO:Push to login on 401, show snack bar session timeout
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
    if (_currentIndex == 4) {
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
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.person_outlined),
                activeIcon: const Icon(Icons.person),
                label: _children[0].title,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.chat_outlined),
                activeIcon: const Icon(Icons.chat),
                label: _children[1].title,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.navigation_outlined),
                activeIcon: const Icon(Icons.navigation),
                label: _children[2].title,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.location_on_outlined),
                activeIcon: const Icon(Icons.location_on),
                label: _children[3].title,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.campaign_outlined),
                activeIcon: const Icon(Icons.campaign),
                label: _children[4].title,
              ),
            ],
            type: BottomNavigationBarType.fixed,
          ),
          floatingActionButton: (_currentIndex == 3 || _currentIndex == 4)
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
