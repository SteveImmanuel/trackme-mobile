import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:trackme_mobile/utilities/custom_callback_types.dart';
import 'package:trackme_mobile/utilities/api.dart';
import 'package:trackme_mobile/models/location.dart';

class MapViewer extends StatefulWidget {
  final UpdateLatLong updateLatLongCallback;
  final double? latitude;
  final double? longitude;

  const MapViewer({
    Key? key,
    required this.updateLatLongCallback,
    this.latitude,
    this.longitude,
  }) : super(key: key);

  @override
  _MapViewerState createState() => _MapViewerState();
}

class _MapViewerState extends State<MapViewer> {
  final MapController _mapController = MapController();
  LatLng? initialPos;

  @override
  void initState() {
    super.initState();
    if (widget.latitude != null && widget.longitude != null) {
      initialPos =
          LatLng(widget.latitude as double, widget.longitude as double);
    } else {
      _getCurrentPosition();
    }
  }

  Future<void> _getCurrentPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position curPos = await Geolocator.getCurrentPosition();
    _mapController.move(LatLng(curPos.latitude, curPos.longitude), 15);
    widget.updateLatLongCallback(curPos.latitude, curPos.longitude);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.center,
      fit: StackFit.loose,
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            center: initialPos,
            zoom: 15,
            onPositionChanged: (MapPosition pos, bool isChanged) {
              LatLng? center = pos.center;
              if (center != null) {
                widget.updateLatLongCallback(center.latitude, center.longitude);
              }
            },
          ),
          layers: [
            TileLayerOptions(
              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: ['a', 'b', 'c'],
            ),
          ],
        ),
        Positioned(
          child: ClipOval(
            child: Material(
              child: InkWell(
                child: const Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(Icons.arrow_back),
                ),
                onTap: () => Navigator.pop(context),
              ),
            ),
          ),
          top: 40,
          left: 15,
        ),
        Padding(
          child: Icon(
            Icons.location_on,
            size: 30,
            color: Theme.of(context).colorScheme.primary,
          ),
          padding: const EdgeInsets.only(bottom: 15),
        ),
        Positioned(
          child: FloatingActionButton(
            onPressed: _getCurrentPosition,
            child: Icon(
              Icons.gps_fixed,
              color: Theme.of(context).colorScheme.primary,
            ),
            backgroundColor: Colors.white,
            elevation: 2,
          ),
          bottom: 15,
          right: 15,
        )
      ],
    );
  }
}

class ChooseLocation extends StatefulWidget {
  static String route = '/location';

  final ReloadUserData callback;
  final List<Location> currentLocationList;
  final int currentIndex;

  const ChooseLocation(
      {Key? key,
      required this.callback,
      required this.currentLocationList,
      required this.currentIndex // -1 to indicate add new
      })
      : super(key: key);

  @override
  _ChooseLocationState createState() => _ChooseLocationState();
}

class _ChooseLocationState extends State<ChooseLocation> {
  bool _alertOnLeave = false;
  bool _alertOnArrive = true;
  String _name = '';
  double? _latitude;
  double? _longitude;
  final _formKey = GlobalKey<FormState>();

  void _onAlertOnLeaveSwitched(bool value) {
    setState(() {
      _alertOnLeave = value;
    });
  }

  void _onAlertOnArriveSwitched(bool value) {
    setState(() {
      _alertOnArrive = value;
    });
  }

  void _onNameChanged(String text) {
    _name = text;
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name cannot be empty';
    }
    return null;
  }

  Future<void> _onSubmit(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      // If the form is valid, display a snackbar. In the real world,
      // you'd often call a server or save the information in a database.
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('Processing Data')),
      // );
      List<Map<String, dynamic>> updateData = widget.currentLocationList
          .map((location) => location.toJson())
          .toList();

      Map<String, dynamic> newValue = {
        'latitude': _latitude.toString(),
        'longitude': _longitude.toString(),
        'name': _name,
        'alert_on_leave': _alertOnLeave,
        'alert_on_arrive': _alertOnArrive,
      };
      if (widget.currentIndex == -1) {
        updateData.add(newValue);
      } else {
        updateData[widget.currentIndex] = newValue;
      }

      await updateUser({'locations': updateData});

      widget.callback();
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.currentIndex != -1){
      Location currentLocation = widget.currentLocationList[widget.currentIndex];
      _latitude = double.parse(currentLocation.latitude);
      _longitude = double.parse(currentLocation.longitude);
      _alertOnLeave = currentLocation.alertOnLeave;
      _alertOnArrive = currentLocation.alertOnArrive;
      _name = currentLocation.name;
    }
  }

  void _updateLatLong(double latitude, double longitude) {
    _latitude = latitude;
    _longitude = longitude;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: MapViewer(
              updateLatLongCallback: _updateLatLong,
              latitude: _latitude,
              longitude: _longitude,
            ),
          ),
          Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Location Name',
                      hintText: 'Home, Work, Supermarket, etc.',
                    ),
                    onChanged: _onNameChanged,
                    validator: _validateName,
                    initialValue: _name,
                  ),
                  Row(
                    children: [
                      Switch(
                        onChanged: _onAlertOnArriveSwitched,
                        value: _alertOnArrive,
                      ),
                      const Text('Alert On Arrive')
                    ],
                  ),
                  Row(
                    children: [
                      Switch(
                        onChanged: _onAlertOnLeaveSwitched,
                        value: _alertOnLeave,
                      ),
                      const Text('Alert On Leave')
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () => _onSubmit(context),
                    child: const Padding(
                      child: Text('CHOOSE THIS LOCATION'),
                      padding: EdgeInsets.all(15),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
