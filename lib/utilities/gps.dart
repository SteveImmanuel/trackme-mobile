import 'package:location/location.dart';

Location location = Location();

Future<bool> requestAccess() async {
  bool serviceEnabled = await location.serviceEnabled();
  if (!serviceEnabled) {
    serviceEnabled = await location.requestService();
    if (!serviceEnabled) {
      return false;
    }
  }

  PermissionStatus permissionGranted = await location.hasPermission();
  if (permissionGranted == PermissionStatus.denied) {
    permissionGranted = await location.requestPermission();
    if (permissionGranted != PermissionStatus.granted) {
      return false;
    }
  }

  return true;
}

Future<LocationData> getCurrentLocation() async {
  bool accessGranted = await requestAccess();
  if (accessGranted) {
    return await location.getLocation();
  }
  throw ('Location Access Not Granted');
}
