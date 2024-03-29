import 'dart:isolate';
import 'package:intl/intl.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trackme/models/user.dart';
import 'package:trackme/utilities/api.dart';
import 'package:trackme/utilities/foreground_service.dart';
import 'package:trackme/utilities/gps.dart';
import 'package:trackme/utilities/snackbar_factory.dart';

class Tracking extends StatefulWidget {
  const Tracking({Key? key}) : super(key: key);

  @override
  _TrackingState createState() => _TrackingState();
}

class _TrackingState extends State<Tracking> {
  final Battery battery = Battery();
  late SharedPreferences prefs;
  late final List<bool> _isActive = [false];
  final List<int> _postIntervalList = [2, 5, 10, 15, 30, 60];

  int _postInterval = 10;
  bool _isLoading = false;
  ReceivePort? _receivePort;
  DateTime _lastPostTimestamp = DateTime.now();
  bool _isPosting = false;
  bool _firstTimeActive = true;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    prefs = await SharedPreferences.getInstance();
    int? savedInterval = prefs.getInt('postInterval');
    if (savedInterval != null) {
      setState(() {
        _postInterval = savedInterval;
      });
    }
    _isActive[0] = await FlutterForegroundTask.isRunningService;
  }

  void _onSwitched(int idx) {
    if (_isActive[idx]) {
      // initially active, then turn off
      _stopForegroundTask();
    } else {
      _startForegroundTask();
    }
    setState(() {
      _isActive[idx] = !_isActive[idx];
    });
  }

  void _onIntervalChanged(int? value) {
    setState(() {
      _postInterval = value!;
    });
    prefs.setInt('postInterval', _postInterval);
  }

  Future<Map<String, dynamic>> _postCurrentLocation() async {
    try {
      Position currentLocation = await getCurrentLocation();
      int batteryLevel = await battery.batteryLevel;
      return await postLocation(
        currentLocation.latitude.toString(),
        currentLocation.longitude.toString(),
        batteryLevel,
      );
    } on String catch (e) {
      return {'code': 500, 'message': e.toString()};
    }
  }

  Future<void> _onSubmitLocation(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });
    Map<String, dynamic> postResult = await _postCurrentLocation();

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    SnackBar snackBar;
    if (postResult['code'] == 200) {
      snackBar = SnackBarFactory.create(
        duration: 1000,
        type: SnackBarType.success,
        content: 'Post Location Success',
      );
    } else {
      snackBar = SnackBarFactory.create(
        duration: 1000,
        type: SnackBarType.failed,
        content: postResult['message'],
      );
    }
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _onReceivedFromForeground(dynamic msg) async {
    if (msg is String) {
      if (msg == LocationTaskHandler.stopKeyword) {
        await _stopForegroundTask();
        setState(() {
          _isActive[0] = !_isActive[0];
        });
        return;
      } else if (msg == LocationTaskHandler.toggleKeyword) {
        _isPaused = !_isPaused;
        if (_isPaused) {
          await FlutterForegroundTask.updateService(
            notificationTitle: 'Tracking Service is OFF',
            notificationText: 'Paused, press TOGGLE to continue',
            callback: null,
          );
          return;
        } else {
          await FlutterForegroundTask.updateService(
            notificationTitle: 'Tracking Service is ON',
            notificationText: 'Initializing',
            callback: startCallback,
          );
          _firstTimeActive = true;
        }
      }
    }

    DateTime now = DateTime.now();
    int diff = now.difference(_lastPostTimestamp).inMinutes;

    if ((diff >= _postInterval && !_isPosting && !_isPaused) ||
        _firstTimeActive) {
      _isPosting = true;
      _firstTimeActive = false;

      Map<String, dynamic> postResult = await _postCurrentLocation();
      if (postResult['code'] == 200) {
        String formattedNow = DateFormat('hh:mm a').format(now);
        await FlutterForegroundTask.updateService(
          notificationTitle: 'Tracking Service is ON',
          notificationText: 'Last Posted: $formattedNow',
          callback: null,
        );
        _lastPostTimestamp = now;
      } else {
        await FlutterForegroundTask.updateService(
          notificationTitle: 'Tracking Service is ON',
          notificationText: postResult['message'],
          callback: null,
        );
      }
      _isPosting = false;
    }
  }

  Future<bool> _stopForegroundTask() async {
    _firstTimeActive = true;
    return await FlutterForegroundTask.stopService();
  }

  bool _registerReceivePort(ReceivePort? newReceivePort) {
    if (newReceivePort == null) {
      return false;
    }

    _closeReceivePort();
    _receivePort = newReceivePort;
    _receivePort?.listen(_onReceivedFromForeground);

    return _receivePort != null;
  }

  void _closeReceivePort() {
    _receivePort?.close();
    _receivePort = null;
  }

  Future<bool> _startForegroundTask() async {
    final ReceivePort? receivePort = FlutterForegroundTask.receivePort;
    final bool isRegistered = _registerReceivePort(receivePort);

    if (!isRegistered) {
      return false;
    }

    if (!(await FlutterForegroundTask.isRunningService)) {
      FlutterForegroundTask.startService(
        notificationTitle: 'Tracking Service is ON',
        notificationText: 'Initializing',
        callback: startCallback,
      );
    }
    return true;
  }

  @override
  void dispose() {
    _closeReceivePort();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(flex: 1),
        Consumer<User>(
          builder: (context, user, child) {
            Widget child = Container();
            if (user.isReady) {
              child = AnimatedTextKit(
                animatedTexts: [
                  TypewriterAnimatedText(
                    'Hello, ${user.username.toUpperCase()}',
                    textStyle: const TextStyle(
                      fontSize: 35,
                    ),
                    speed: const Duration(milliseconds: 200),
                  ),
                ],
                totalRepeatCount: 1,
              );
            }
            return SizedBox(
              child: child,
              height: 40,
            );
          },
        ),
        const Divider(
          thickness: 1,
        ),
        const Spacer(flex: 5),
        Text(
          _isActive[0] ? 'ON' : 'OFF',
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w100,
          ),
        ),
        ToggleButtons(
          children: const [
            Icon(
              Icons.power_settings_new,
              size: 200,
            )
          ],
          onPressed: _onSwitched,
          isSelected: _isActive,
          borderRadius: BorderRadius.circular(100),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Post location every:',
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
              ),
              child: DropdownButton(
                value: _postInterval,
                icon: const Icon(Icons.arrow_downward),
                items: _postIntervalList.map((int value) {
                  return DropdownMenuItem(
                    child: Text(value.toString()),
                    value: value,
                  );
                }).toList(),
                onChanged: _onIntervalChanged,
                underline: Container(height: 0.5, color: Colors.black),
              ),
            ),
            const Text('minutes'),
          ],
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : () => _onSubmitLocation(context),
          child: _isLoading
              ? const SizedBox(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.black45,
                  ),
                  height: 15,
                  width: 15,
                )
              : const Text('POST NOW'),
          style: ElevatedButton.styleFrom(minimumSize: const Size(100, 37)),
        ),
        const Spacer(flex: 5),
      ],
    );
  }
}
