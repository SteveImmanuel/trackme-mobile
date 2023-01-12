import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:trackme/utilities/custom_callback_types.dart';
import 'package:trackme/utilities/api.dart';
import 'package:trackme/utilities/gps.dart';
import 'package:trackme/models/location.dart' as location_model;
import 'package:trackme/utilities/snackbar_factory.dart';

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
    LocationData curPos = await getCurrentLocation();

    double latitude = curPos.latitude ?? 50.010083;
    double longitude = curPos.longitude ?? -110.113006;
    _mapController.move(LatLng(latitude, longitude), _mapController.zoom);
    widget.updateLatLongCallback(latitude, longitude);
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
          children: [
            TileLayer(
              urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              userAgentPackageName: "id.steve.trackme",
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
  final List<location_model.Location> currentLocationList;
  final int currentIndex;
  final BuildContext parentContext;

  const ChooseLocation({
    Key? key,
    required this.callback,
    required this.currentLocationList,
    required this.currentIndex, // -1 to indicate add new
    required this.parentContext,
  }) : super(key: key);

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

  Future<void> _onSubmit() async {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(widget.parentContext);
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

      String msg;
      String msg2;

      if (widget.currentIndex == -1) {
        updateData.add(newValue);
        msg = 'Adding New Location';
        msg2 = 'Add New Location';
      } else {
        updateData[widget.currentIndex] = newValue;
        msg = 'Updating New Location';
        msg2 = 'Update Location';
      }

      ScaffoldMessenger.of(widget.parentContext).hideCurrentSnackBar();
      ScaffoldMessenger.of(widget.parentContext).showSnackBar(SnackBarFactory.create(
        duration: 3000000,
        type: SnackBarType.loading,
        content: msg,
      ));

      Map<String, dynamic> updateResult =
          await updateUser({'locations': updateData});
      ScaffoldMessenger.of(widget.parentContext).hideCurrentSnackBar();
      if (updateResult['code'] == 200) {
        ScaffoldMessenger.of(widget.parentContext).showSnackBar(SnackBarFactory.create(
          duration: 1000,
          type: SnackBarType.success,
          content: '$msg2 Success',
        ));
      } else if (updateResult['code'] != 401) {
        ScaffoldMessenger.of(widget.parentContext).showSnackBar(SnackBarFactory.create(
          duration: 1000,
          type: SnackBarType.failed,
          content: '$msg2 Failed',
        ));
      }
      widget.callback();
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.currentIndex != -1) {
      location_model.Location currentLocation =
          widget.currentLocationList[widget.currentIndex];
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
                    onPressed: _onSubmit,
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
