import 'package:flutter/cupertino.dart';
import 'package:trackme_mobile/utilities/custom_callback_types.dart';
import 'package:trackme_mobile/models/location.dart';

class LocationArgs {
  ReloadUserData callback;
  List<Location> currentLocationList;
  int currentIndex;
  BuildContext parentContext;

  LocationArgs({
    required this.callback,
    required this.currentLocationList,
    required this.currentIndex,
    required this.parentContext
  });
}
