import 'dart:isolate';
import 'dart:io' show Platform;
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(LocationTaskHandler());
}

void initForegroundTask() {
  FlutterForegroundTask.init(
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
      interval: 120000,
      autoRunOnBoot: true,
      allowWifiLock: true,
      allowWakeLock: true,
      isOnceEvent: false,
    ),
  );
}

class LocationTaskHandler extends TaskHandler {
  SendPort? _sendPort;
  static String stopKeyword = 'stopService';
  static String toggleKeyword = 'toggleService';

  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
    _sendPort = sendPort;
  }

  @override
  Future<void> onRepeatEvent(DateTime timestamp, SendPort? sendPort) async {
    // sendPort?.send(timestamp); For some reason, cannot send timestamp obj as shown in the example
    sendPort?.send('');
  }

  @override
  Future<void> onDestroy(DateTime timestamp, SendPort? sendPort) async {
    await FlutterForegroundTask.clearAllData();
  }

  @override
  Future<void> onNotificationButtonPressed(String id) async {
    if (id == LocationTaskHandler.stopKeyword ||
        id == LocationTaskHandler.toggleKeyword) {
      _sendPort?.send(id);
    }
  }
}

Future<void> requestPermissionForAndroid() async {
  if (!Platform.isAndroid) {
    return;
  }

  if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
    await FlutterForegroundTask.requestIgnoreBatteryOptimization();
  }

  final NotificationPermission notificationPermissionStatus =
  await FlutterForegroundTask.checkNotificationPermission();
  if (notificationPermissionStatus != NotificationPermission.granted) {
    await FlutterForegroundTask.requestNotificationPermission();
  }
}