import 'package:flutter/material.dart';

typedef DeleteListItem = void Function(BuildContext, int, String);
typedef UpdateLatLong = void Function(double, double);
typedef ReloadUserData = Future<void> Function();