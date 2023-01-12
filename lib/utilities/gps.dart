import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart';

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

Future<Position> getCurrentLocation() async {
  bool accessGranted = await requestAccess();
  if (accessGranted) {
    return await Geolocator.getCurrentPosition();
  }
  throw ('Location Access Not Granted');
}
