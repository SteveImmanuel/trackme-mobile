import 'package:flutter/material.dart';

typedef DeleteListItem = void Function(BuildContext, int, String);
typedef UpdateIndirectNotif = void Function(BuildContext, int, bool);
typedef UpdateLatLong = void Function(double, double);
typedef ReloadUserData = Future<void> Function();
typedef OnUpdateLocation = void Function(BuildContext, int);
typedef GenerateToken = Future<Map<String, dynamic>> Function();