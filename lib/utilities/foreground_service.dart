import 'dart:isolate';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

Future<void> initForegroundTask() async {
  await FlutterForegroundTask.init(
    androidNotificationOptions: AndroidNotificationOptions(
      channelId: 'trackme_notif_channel',
      channelName: 'TrackMe Tracking Service',
      channelDescription: 'Tracks user location periodically in background',
      channelImportance: NotificationChannelImportance.LOW,
      priority: NotificationPriority.LOW,
      iconData: const NotificationIconData(
        resType: ResourceType.mipmap,
        resPrefix: ResourcePrefix.ic,
        name: 'launcher',
      ),
      buttons: [
        NotificationButton(
          id: LocationTaskHandler.toggleKeyword,
          text: 'TOGGLE',
        ),
        NotificationButton(id: LocationTaskHandler.stopKeyword, text: 'STOP'),
      ],
    ),
    iosNotificationOptions: const IOSNotificationOptions(
      showNotification: true,
      playSound: false,
    ),
    foregroundTaskOptions: const ForegroundTaskOptions(
        interval: 120000, autoRunOnBoot: true, allowWifiLock: true),
    printDevLog: true,
  );
}

class LocationTaskHandler extends TaskHandler {
  SendPort? sendPort;
  static String stopKeyword = 'stopService';
  static String toggleKeyword = 'toggleService';

  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
    this.sendPort = sendPort;
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
  Future<void> onButtonPressed(String id) async {
    if (id == LocationTaskHandler.stopKeyword ||
        id == LocationTaskHandler.toggleKeyword) {
      sendPort?.send(id);
    }
  }
}
