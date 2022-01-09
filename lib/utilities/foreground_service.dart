import 'dart:isolate';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';

Future<void> initForegroundTask() async {
  await FlutterForegroundTask.init(
    androidNotificationOptions: AndroidNotificationOptions(
      channelId: 'trackme_notif_channel',
      channelName: 'TrackMe Tracking Service',
      channelDescription: 'TrackMe is running in background',
      channelImportance: NotificationChannelImportance.LOW,
      priority: NotificationPriority.LOW,
      iconData: const NotificationIconData(
        resType: ResourceType.mipmap,
        resPrefix: ResourcePrefix.ic,
        name: 'launcher',
      ),
      buttons: [
        const NotificationButton(id: 'stopService', text: 'STOP'),
      ],
    ),
    iosNotificationOptions: const IOSNotificationOptions(
      showNotification: true,
      playSound: false,
    ),
    foregroundTaskOptions: const ForegroundTaskOptions(
      interval: 5000,
      autoRunOnBoot: true,
      allowWifiLock: true,
    ),
    printDevLog: true,
  );
}

class LocationTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
    await FlutterForegroundTask.updateService(
      notificationTitle: 'TrackMe Tracking Service',
      notificationText: 'Location Tracking Is On',
      callback: null,
    );
  }

  @override
  Future<void> onEvent(DateTime timestamp, SendPort? sendPort) async {
    sendPort?.send(timestamp);
  }

  @override
  Future<void> onDestroy(DateTime timestamp) async {
    await FlutterForegroundTask.clearAllData();
  }

  @override
  void onButtonPressed(String id) {
    if (id == 'stopService') {
      FlutterForegroundTask.stopService();
    }
  }
}